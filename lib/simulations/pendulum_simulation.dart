import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class PendulumSimulation extends StatefulWidget {
  const PendulumSimulation({super.key});

  @override
  State<PendulumSimulation> createState() => _PendulumSimulationState();
}

class _PendulumSimulationState extends State<PendulumSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _length = 150.0; // pixels (represents ~1m)
  double _angle = math.pi / 4; // radians
  double _angularVelocity = 0.0;
  final double _gravity = 9.8;
  double _damping = 0.0;
  bool _isRunning = false;
  bool _hasSpokenIntro = false;

  double _initialAngle = math.pi / 4;
  double _time = 0.0;
  double _previousAngle = 0.0; // Track for sound trigger

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePendulum);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Pendulum simulation! '
          'A simple pendulum demonstrates periodic motion. '
          'The period depends only on the length and gravitational field strength, not the mass. '
          'Energy converts between potential and kinetic as it swings.',
          force: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePendulum() {
    if (!_isRunning) return;

    setState(() {
      final dt = 0.016;
      _time += dt;

      // Store previous angle for sound trigger
      final oldAngle = _angle;

      // Simple harmonic motion approximation for small angles
      // θ'' = -(g/L) * sin(θ) - damping * θ'
      final lengthInMeters = _length / 150; // Scale factor
      final angularAcceleration =
          -(_gravity / lengthInMeters) * math.sin(_angle) - _damping * _angularVelocity;

      _angularVelocity += angularAcceleration * dt;
      _angle += _angularVelocity * dt;
      _previousAngle = oldAngle;

      // Play tick sound when crossing center (angle changes sign)
      if (oldAngle * _angle < 0 && _angularVelocity.abs() > 0.5) {
        if (_angle > 0) {
          context.read<SoundProvider>().playTick();
        } else {
          context.read<SoundProvider>().playTock();
        }
      }
    });
  }

  void _toggleSimulation() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      _isRunning = false;
      _controller.stop();
      _angle = _initialAngle;
      _angularVelocity = 0;
      _time = 0;
    });
  }

  void _onLengthChanged(double value) {
    setState(() {
      _length = value;
    });

    final period = _calculatePeriod();
    speakSimulation(
      'Length changed. The period is now ${period.toStringAsFixed(2)} seconds. '
      'Longer pendulums have longer periods.',
    );
  }

  void _onAngleChanged(double value) {
    if (_isRunning) return;
    setState(() {
      _angle = value;
      _initialAngle = value;
    });
  }

  double _calculatePeriod() {
    // T = 2π√(L/g)
    final lengthInMeters = _length / 150;
    return 2 * math.pi * math.sqrt(lengthInMeters / _gravity);
  }

  double _getPotentialEnergy() {
    // PE = mgh = mgL(1 - cos(θ))
    // Using arbitrary mass = 1
    final lengthInMeters = _length / 150;
    return _gravity * lengthInMeters * (1 - math.cos(_angle));
  }

  double _getKineticEnergy() {
    // KE = 0.5 * m * v² = 0.5 * m * L² * ω²
    final lengthInMeters = _length / 150;
    return 0.5 * lengthInMeters * lengthInMeters * _angularVelocity * _angularVelocity;
  }

  @override
  Widget build(BuildContext context) {
    final period = _calculatePeriod();
    final pe = _getPotentialEnergy();
    final ke = _getKineticEnergy();
    final totalEnergy = pe + ke;

    return Column(
      children: [
        // Pendulum visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.grey[900]!, Colors.grey[850]!],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade700),
            ),
            child: CustomPaint(
              painter: _PendulumPainter(
                length: _length,
                angle: _angle,
                peRatio: totalEnergy > 0 ? pe / totalEnergy : 0,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Energy bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Row(
              children: [
                Expanded(
                  flex: ((pe / (totalEnergy > 0 ? totalEnergy : 1)) * 100).round(),
                  child: Container(
                    color: Colors.blue,
                    child: const Center(
                      child: Text('PE',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ),
                Expanded(
                  flex: ((ke / (totalEnergy > 0 ? totalEnergy : 1)) * 100).round(),
                  child: Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text('KE',
                          style: TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Period',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${period.toStringAsFixed(2)} s',
                        style: const TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Angle',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${(_angle * 180 / math.pi).toStringAsFixed(1)}°',
                        style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Velocity',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${_angularVelocity.toStringAsFixed(2)} rad/s',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'T = 2π√(L/g)',
                style: TextStyle(
                    color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),

        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Length slider
              Row(
                children: [
                  SizedBox(
                      width: 90,
                      child: Text('Length: ${(_length / 150).toStringAsFixed(2)}m',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11))),
                  Expanded(
                    child: Slider(
                      value: _length,
                      min: 50,
                      max: 250,
                      onChanged: _isRunning ? null : _onLengthChanged,
                      activeColor: Colors.amber,
                    ),
                  ),
                ],
              ),

              // Initial angle slider
              Row(
                children: [
                  SizedBox(
                      width: 90,
                      child: Text(
                          'Angle: ${(_initialAngle * 180 / math.pi).toStringAsFixed(0)}°',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11))),
                  Expanded(
                    child: Slider(
                      value: _initialAngle,
                      min: 0.1,
                      max: math.pi / 2,
                      onChanged: _isRunning ? null : _onAngleChanged,
                      activeColor: Colors.orange,
                    ),
                  ),
                ],
              ),

              // Damping slider
              Row(
                children: [
                  SizedBox(
                      width: 90,
                      child: Text('Damping: ${_damping.toStringAsFixed(1)}',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 11))),
                  Expanded(
                    child: Slider(
                      value: _damping,
                      min: 0,
                      max: 2,
                      onChanged: (v) => setState(() => _damping = v),
                      activeColor: Colors.purple,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleSimulation,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isRunning ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _resetSimulation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  buildTTSToggle(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PendulumPainter extends CustomPainter {
  final double length;
  final double angle;
  final double peRatio;

  _PendulumPainter({
    required this.length,
    required this.angle,
    required this.peRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pivotX = size.width / 2;
    final pivotY = 40.0;

    // Calculate bob position
    final bobX = pivotX + length * math.sin(angle);
    final bobY = pivotY + length * math.cos(angle);

    // Draw pivot support
    final supportPaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(pivotX - 40, pivotY - 10),
      Offset(pivotX + 40, pivotY - 10),
      supportPaint,
    );

    // Draw pivot point
    final pivotPaint = Paint()..color = Colors.grey[400]!;
    canvas.drawCircle(Offset(pivotX, pivotY), 6, pivotPaint);

    // Draw string
    final stringPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 2;
    canvas.drawLine(Offset(pivotX, pivotY), Offset(bobX, bobY), stringPaint);

    // Draw bob with color based on energy
    final bobPaint = Paint()
      ..color = Color.lerp(Colors.red, Colors.blue, peRatio) ?? Colors.purple;
    canvas.drawCircle(Offset(bobX, bobY), 20, bobPaint);

    // Draw bob highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(bobX - 5, bobY - 5), 6, highlightPaint);

    // Draw equilibrium line
    final eqPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(pivotX, pivotY),
      Offset(pivotX, pivotY + length + 30),
      eqPaint,
    );

    // Draw angle arc
    if (angle.abs() > 0.05) {
      final arcPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final arcRadius = 40.0;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(pivotX, pivotY), width: arcRadius * 2, height: arcRadius * 2),
        math.pi / 2 - angle,
        angle,
        false,
        arcPaint,
      );
    }

    // Draw height reference for PE
    if (peRatio > 0.1) {
      final heightPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.5)
        ..strokeWidth = 1;

      final restY = pivotY + length;
      canvas.drawLine(
        Offset(bobX, bobY),
        Offset(bobX, restY),
        heightPaint,
      );

      // Height label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'h',
          style: TextStyle(color: Colors.blue, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(bobX + 5, (bobY + restY) / 2 - 6));
    }

    // Draw velocity arrow at bob
    // (This is a simplified representation)

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'L',
      style: TextStyle(color: Colors.white54, fontSize: 12),
    );
    textPainter.layout();
    final labelX = pivotX + length / 2 * math.sin(angle) + 10;
    final labelY = pivotY + length / 2 * math.cos(angle);
    textPainter.paint(canvas, Offset(labelX, labelY));
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter oldDelegate) {
    return angle != oldDelegate.angle ||
        length != oldDelegate.length ||
        peRatio != oldDelegate.peRatio;
  }
}
