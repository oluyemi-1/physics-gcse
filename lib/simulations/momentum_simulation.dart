import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class MomentumSimulation extends StatefulWidget {
  const MomentumSimulation({super.key});

  @override
  State<MomentumSimulation> createState() => _MomentumSimulationState();
}

class _MomentumSimulationState extends State<MomentumSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _mass1 = 2.0;
  double _mass2 = 2.0;
  double _velocity1 = 5.0;
  double _velocity2 = -3.0;

  double _ball1X = 80;
  double _ball2X = 280;
  double _currentV1 = 0;
  double _currentV2 = 0;
  bool _isRunning = false;
  bool _hasCollided = false;
  bool _isElastic = true;
  bool _hasSpokenIntro = false;
  bool _hasSpokenCollision = false;

  double get _momentum1 => _mass1 * _currentV1;
  double get _momentum2 => _mass2 * _currentV2;
  double get _totalMomentum => _momentum1 + _momentum2;
  double get _initialTotalMomentum => _mass1 * _velocity1 + _mass2 * _velocity2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateSimulation);
    _resetSimulation();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Momentum Simulation. This demonstrates conservation of momentum in collisions. '
          'You have two balls that will collide. Set their masses and velocities, then choose elastic or inelastic collision. '
          'In elastic collisions, kinetic energy is conserved. In inelastic collisions, objects stick together. '
          'Total momentum is always conserved: mass times velocity.',
          force: true,
        );
      }
    });
  }

  void _updateSimulation() {
    if (!_isRunning) return;

    setState(() {
      _ball1X += _currentV1 * 2;
      _ball2X += _currentV2 * 2;

      // Check for collision
      final ball1Radius = 15 + _mass1 * 5;
      final ball2Radius = 15 + _mass2 * 5;

      if (!_hasCollided &&
          _ball1X + ball1Radius >= _ball2X - ball2Radius &&
          _currentV1 > _currentV2) {
        _hasCollided = true;
        _hasSpokenCollision = true;

        // Play collision sound
        final impactSpeed = (_currentV1 - _currentV2).abs();
        context.read<SoundProvider>().playCollision(intensity: impactSpeed / 10);

        _performCollision();

        if (_isElastic) {
          speakSimulation(
            'Elastic collision! The balls bounced off each other. '
            'Notice that both momentum and kinetic energy are conserved. '
            'Ball 1 now has velocity ${_currentV1.toStringAsFixed(1)} and ball 2 has velocity ${_currentV2.toStringAsFixed(1)} meters per second.',
            force: true,
          );
        } else {
          speakSimulation(
            'Inelastic collision! The balls stuck together. '
            'Momentum is conserved, but kinetic energy is lost to heat and sound. '
            'Both balls now move together at ${_currentV1.toStringAsFixed(1)} meters per second.',
            force: true,
          );
        }
      }

      // Boundary checks
      if (_ball1X < ball1Radius || _ball1X > 360 - ball1Radius) {
        _currentV1 = -_currentV1 * 0.8;
        _ball1X = _ball1X.clamp(ball1Radius, 360 - ball1Radius);
      }
      if (_ball2X < ball2Radius || _ball2X > 360 - ball2Radius) {
        _currentV2 = -_currentV2 * 0.8;
        _ball2X = _ball2X.clamp(ball2Radius, 360 - ball2Radius);
      }
    });
  }

  void _performCollision() {
    if (_isElastic) {
      // Elastic collision formulas
      final newV1 = ((_mass1 - _mass2) * _currentV1 + 2 * _mass2 * _currentV2) /
          (_mass1 + _mass2);
      final newV2 = ((_mass2 - _mass1) * _currentV2 + 2 * _mass1 * _currentV1) /
          (_mass1 + _mass2);
      _currentV1 = newV1;
      _currentV2 = newV2;
    } else {
      // Inelastic collision - objects stick together
      final totalMass = _mass1 + _mass2;
      final newV = (_mass1 * _currentV1 + _mass2 * _currentV2) / totalMass;
      _currentV1 = newV;
      _currentV2 = newV;
    }
  }

  void _startSimulation() {
    _resetSimulation();
    setState(() {
      _isRunning = true;
      _currentV1 = _velocity1;
      _currentV2 = _velocity2;
      _hasSpokenCollision = false;
    });
    _controller.repeat();

    final totalMomentum = _mass1 * _velocity1 + _mass2 * _velocity2;
    speakSimulation(
      'Simulation started! Ball 1 has mass ${_mass1.toStringAsFixed(1)} kg moving at ${_velocity1.toStringAsFixed(1)} meters per second. '
      'Ball 2 has mass ${_mass2.toStringAsFixed(1)} kg moving at ${_velocity2.toStringAsFixed(1)} meters per second. '
      'Total initial momentum is ${totalMomentum.toStringAsFixed(1)} kilogram meters per second.',
      force: true,
    );
  }

  void _stopSimulation() {
    setState(() => _isRunning = false);
    _controller.stop();
    speakSimulation('Simulation stopped.', force: true);
  }

  void _resetSimulation() {
    _controller.stop();
    setState(() {
      _isRunning = false;
      _hasCollided = false;
      _hasSpokenCollision = false;
      _ball1X = 80;
      _ball2X = 280;
      _currentV1 = 0;
      _currentV2 = 0;
    });
  }

  void _onElasticSelected() {
    setState(() => _isElastic = true);
    speakSimulation(
      'Elastic collision selected. In elastic collisions, both momentum and kinetic energy are conserved. '
      'The balls will bounce off each other.',
      force: true,
    );
  }

  void _onInelasticSelected() {
    setState(() => _isElastic = false);
    speakSimulation(
      'Inelastic collision selected. In inelastic collisions, the objects stick together after impact. '
      'Momentum is still conserved, but kinetic energy is converted to heat and sound.',
      force: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Collision type toggle
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Consumer<SoundProvider>(
                builder: (context, sound, _) => IconButton(
                  icon: Icon(
                    sound.soundEnabled ? Icons.volume_up : Icons.volume_off,
                    color: sound.soundEnabled ? Colors.blue : Colors.grey,
                  ),
                  onPressed: sound.toggleSound,
                  tooltip: sound.soundEnabled ? 'Mute sounds' : 'Enable sounds',
                ),
              ),
              buildTTSToggle(),
              const SizedBox(width: 16),
              _buildToggleButton('Elastic', _isElastic, _onElasticSelected),
              const SizedBox(width: 16),
              _buildToggleButton('Inelastic', !_isElastic, _onInelasticSelected),
            ],
          ),
        ),
        // Momentum display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.indigo.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMomentumDisplay('Ball 1', _momentum1, Colors.red),
              _buildMomentumDisplay('Ball 2', _momentum2, Colors.blue),
              _buildMomentumDisplay('Total', _totalMomentum, Colors.green),
            ],
          ),
        ),
        // Simulation area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              painter: MomentumPainter(
                ball1X: _ball1X,
                ball2X: _ball2X,
                mass1: _mass1,
                mass2: _mass2,
                velocity1: _currentV1,
                velocity2: _currentV2,
                hasCollided: _hasCollided,
                isElastic: _isElastic,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildBallControls(
                      'Ball 1 (Red)',
                      _mass1,
                      _velocity1,
                      (m) => setState(() => _mass1 = m),
                      (v) => setState(() => _velocity1 = v),
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBallControls(
                      'Ball 2 (Blue)',
                      _mass2,
                      _velocity2,
                      (m) => setState(() => _mass2 = m),
                      (v) => setState(() => _velocity2 = v),
                      Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning ? null : _startSimulation,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _stopSimulation : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _resetSimulation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Conservation of Momentum: p = mv | Total momentum ${_hasCollided ? "after" : "before"}: ${_totalMomentum.toStringAsFixed(2)} kg⋅m/s',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: _isRunning ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.purple : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildMomentumDisplay(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          value.toStringAsFixed(2),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
        const Text(
          'kg⋅m/s',
          style: TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildBallControls(
    String title,
    double mass,
    double velocity,
    ValueChanged<double> onMassChanged,
    ValueChanged<double> onVelocityChanged,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text('m:', style: TextStyle(color: Colors.white54, fontSize: 11)),
              Expanded(
                child: Slider(
                  value: mass,
                  min: 1,
                  max: 5,
                  onChanged: _isRunning ? null : onMassChanged,
                  activeColor: color,
                ),
              ),
              Text('${mass.toStringAsFixed(1)}kg', style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
          Row(
            children: [
              const Text('v:', style: TextStyle(color: Colors.white54, fontSize: 11)),
              Expanded(
                child: Slider(
                  value: velocity,
                  min: -8,
                  max: 8,
                  onChanged: _isRunning ? null : onVelocityChanged,
                  activeColor: color,
                ),
              ),
              Text('${velocity.toStringAsFixed(1)}m/s', style: const TextStyle(color: Colors.white70, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

class MomentumPainter extends CustomPainter {
  final double ball1X;
  final double ball2X;
  final double mass1;
  final double mass2;
  final double velocity1;
  final double velocity2;
  final bool hasCollided;
  final bool isElastic;

  MomentumPainter({
    required this.ball1X,
    required this.ball2X,
    required this.mass1,
    required this.mass2,
    required this.velocity1,
    required this.velocity2,
    required this.hasCollided,
    required this.isElastic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final scaleX = size.width / 360;

    // Draw track
    final trackPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(20, centerY),
      Offset(size.width - 20, centerY),
      trackPaint,
    );

    // Draw ball 1 (red)
    final ball1Radius = (15 + mass1 * 5) * scaleX.clamp(0.8, 1.2);
    final ball1Paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.red.shade300, Colors.red.shade700],
      ).createShader(Rect.fromCircle(
        center: Offset(ball1X * scaleX, centerY - ball1Radius / 2),
        radius: ball1Radius,
      ));
    canvas.drawCircle(
      Offset(ball1X * scaleX, centerY - ball1Radius / 2),
      ball1Radius,
      ball1Paint,
    );

    // Draw ball 2 (blue)
    final ball2Radius = (15 + mass2 * 5) * scaleX.clamp(0.8, 1.2);
    final ball2Paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.blue.shade300, Colors.blue.shade700],
      ).createShader(Rect.fromCircle(
        center: Offset(ball2X * scaleX, centerY - ball2Radius / 2),
        radius: ball2Radius,
      ));
    canvas.drawCircle(
      Offset(ball2X * scaleX, centerY - ball2Radius / 2),
      ball2Radius,
      ball2Paint,
    );

    // Draw velocity arrows
    if (velocity1.abs() > 0.1) {
      _drawArrow(
        canvas,
        Offset(ball1X * scaleX, centerY - ball1Radius * 2),
        velocity1 * 8 * scaleX,
        Colors.red,
      );
    }
    if (velocity2.abs() > 0.1) {
      _drawArrow(
        canvas,
        Offset(ball2X * scaleX, centerY - ball2Radius * 2),
        velocity2 * 8 * scaleX,
        Colors.blue,
      );
    }

    // Draw collision indicator
    if (hasCollided) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: isElastic ? 'Elastic Collision!' : 'Inelastic Collision!',
          style: TextStyle(
            color: isElastic ? Colors.green : Colors.orange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 20));
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: 'm=${mass1.toStringAsFixed(1)}kg',
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(ball1X * scaleX - 20, centerY + ball1Radius + 5));

    textPainter.text = TextSpan(
      text: 'm=${mass2.toStringAsFixed(1)}kg',
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(ball2X * scaleX - 20, centerY + ball2Radius + 5));
  }

  void _drawArrow(Canvas canvas, Offset start, double length, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;

    final end = Offset(start.dx + length, start.dy);
    canvas.drawLine(start, end, paint);

    // Arrow head
    final direction = length > 0 ? 1.0 : -1.0;
    canvas.drawLine(
      end,
      Offset(end.dx - direction * 8, start.dy - 5),
      paint,
    );
    canvas.drawLine(
      end,
      Offset(end.dx - direction * 8, start.dy + 5),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant MomentumPainter oldDelegate) {
    return oldDelegate.ball1X != ball1X ||
        oldDelegate.ball2X != ball2X ||
        oldDelegate.velocity1 != velocity1 ||
        oldDelegate.velocity2 != velocity2 ||
        oldDelegate.hasCollided != hasCollided;
  }
}
