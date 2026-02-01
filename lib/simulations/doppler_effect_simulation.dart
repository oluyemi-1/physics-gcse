import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class DopplerEffectSimulation extends StatefulWidget {
  const DopplerEffectSimulation({super.key});

  @override
  State<DopplerEffectSimulation> createState() => _DopplerEffectSimulationState();
}

class _DopplerEffectSimulationState extends State<DopplerEffectSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _sourceSpeed = 50.0; // m/s
  final double _soundSpeed = 340.0; // m/s in air
  final double _sourceFrequency = 440.0; // Hz (A note)
  bool _isMoving = false;
  double _sourcePosition = 0.0;
  bool _hasSpokenIntro = false;

  final List<_WaveFront> _waveFronts = [];
  double _lastWaveTime = 0;

  double get _observerFrequencyApproaching {
    return _sourceFrequency * (_soundSpeed / (_soundSpeed - _sourceSpeed));
  }

  double get _observerFrequencyReceding {
    return _sourceFrequency * (_soundSpeed / (_soundSpeed + _sourceSpeed));
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Doppler Effect simulation! '
          'The Doppler effect is the change in frequency of a wave as the source moves relative to an observer. '
          'When the source approaches, waves bunch up and frequency increases, making the pitch higher. '
          'When the source moves away, waves spread out and frequency decreases, making the pitch lower. '
          'This is why a siren sounds higher-pitched as it approaches and lower as it moves away.',
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

  void _update() {
    if (!_isMoving) return;

    setState(() {
      // Move the source
      _sourcePosition += _sourceSpeed * 0.01;

      // Emit new wave fronts periodically
      _lastWaveTime += 0.016;
      if (_lastWaveTime > 0.05) {
        _waveFronts.add(_WaveFront(
          x: _sourcePosition,
          radius: 0,
          emitTime: _lastWaveTime,
        ));
        _lastWaveTime = 0;
      }

      // Expand wave fronts
      for (var wave in _waveFronts) {
        wave.radius += _soundSpeed * 0.01;
      }

      // Remove old wave fronts
      _waveFronts.removeWhere((w) => w.radius > 500);

      // Reset if source goes off screen
      if (_sourcePosition > 450) {
        _sourcePosition = -50;
        _waveFronts.clear();
      }
    });
  }

  void _toggleMovement() {
    setState(() {
      _isMoving = !_isMoving;
      if (_isMoving) {
        _controller.repeat();
        speakSimulation(
          'The sound source is now moving at ${_sourceSpeed.toStringAsFixed(0)} metres per second. '
          'Watch how the wave fronts bunch up in front and spread out behind.',
          force: true,
        );
      } else {
        _controller.stop();
        speakSimulation('Source stopped.', force: true);
      }
    });
  }

  void _reset() {
    setState(() {
      _isMoving = false;
      _sourcePosition = 50;
      _waveFronts.clear();
      _lastWaveTime = 0;
    });
    _controller.stop();
    speakSimulation('Simulation reset.', force: true);
  }

  void _onSpeedChanged(double value) {
    setState(() {
      _sourceSpeed = value;
    });

    if (value >= _soundSpeed) {
      speakSimulation(
        'Speed is at or above the speed of sound! This creates a sonic boom - '
        'wave fronts pile up into a shock wave.',
        force: true,
      );
    } else if (value > _soundSpeed * 0.8) {
      speakSimulation(
        'Speed set to ${value.toStringAsFixed(0)} metres per second. '
        'Approaching the speed of sound. The Doppler shift is very large.',
      );
    } else {
      speakSimulation(
        'Speed set to ${value.toStringAsFixed(0)} metres per second.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simulation display
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade700),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _DopplerPainter(
                      sourcePosition: _sourcePosition,
                      waveFronts: _waveFronts,
                      soundSpeed: _soundSpeed,
                      sourceSpeed: _sourceSpeed,
                    ),
                    size: Size.infinite,
                  ),
                  // Observer labels
                  Positioned(
                    left: 20,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Observer A (Behind)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('f = ${_observerFrequencyReceding.toStringAsFixed(1)} Hz',
                              style: const TextStyle(color: Colors.white, fontSize: 10)),
                          const Text('Lower pitch',
                              style: TextStyle(color: Colors.white70, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    right: 20,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('Observer B (Ahead)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                          Text('f = ${_observerFrequencyApproaching.toStringAsFixed(1)} Hz',
                              style: const TextStyle(color: Colors.white, fontSize: 10)),
                          const Text('Higher pitch',
                              style: TextStyle(color: Colors.white70, fontSize: 9)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Formula and data
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Doppler Effect Formula',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'f\' = f × (v / (v ± vs))',
                style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Source frequency: ${_sourceFrequency.toStringAsFixed(0)} Hz  |  Sound speed: ${_soundSpeed.toStringAsFixed(0)} m/s',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Speed slider
                Row(
                  children: [
                    const SizedBox(width: 100, child: Text('Source Speed:', style: TextStyle(color: Colors.white))),
                    Expanded(
                      child: Slider(
                        value: _sourceSpeed,
                        min: 10,
                        max: 350,
                        divisions: 68,
                        onChanged: _onSpeedChanged,
                        activeColor: _sourceSpeed >= _soundSpeed ? Colors.red : Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Text(
                        '${_sourceSpeed.toStringAsFixed(0)} m/s',
                        style: TextStyle(
                          color: _sourceSpeed >= _soundSpeed ? Colors.red : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                if (_sourceSpeed >= _soundSpeed)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'SUPERSONIC! Source is faster than sound - shock wave forms',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _toggleMovement,
                      icon: Icon(_isMoving ? Icons.pause : Icons.play_arrow),
                      label: Text(_isMoving ? 'Pause' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isMoving ? Colors.orange : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    buildTTSToggle(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WaveFront {
  double x;
  double radius;
  double emitTime;

  _WaveFront({required this.x, required this.radius, required this.emitTime});
}

class _DopplerPainter extends CustomPainter {
  final double sourcePosition;
  final List<_WaveFront> waveFronts;
  final double soundSpeed;
  final double sourceSpeed;

  _DopplerPainter({
    required this.sourcePosition,
    required this.waveFronts,
    required this.soundSpeed,
    required this.sourceSpeed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Draw wave fronts
    for (var wave in waveFronts) {
      final opacity = (1 - wave.radius / 400).clamp(0.1, 0.8);
      final wavePaint = Paint()
        ..color = Colors.blue.withValues(alpha: opacity)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(wave.x, centerY), wave.radius, wavePaint);
    }

    // Draw observers
    final observerPaint = Paint()..color = Colors.green;
    canvas.drawCircle(Offset(30, centerY), 10, observerPaint);
    observerPaint.color = Colors.red;
    canvas.drawCircle(Offset(size.width - 30, centerY), 10, observerPaint);

    // Draw source (ambulance/car icon representation)
    _drawSource(canvas, sourcePosition, centerY);

    // Draw direction arrow
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(sourcePosition + 25, centerY),
      Offset(sourcePosition + 50, centerY),
      arrowPaint,
    );
    // Arrow head
    final path = Path();
    path.moveTo(sourcePosition + 50, centerY);
    path.lineTo(sourcePosition + 42, centerY - 6);
    path.lineTo(sourcePosition + 42, centerY + 6);
    path.close();
    canvas.drawPath(path, arrowPaint..style = PaintingStyle.fill);

    // Draw labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'v = ${sourceSpeed.toStringAsFixed(0)} m/s',
      style: const TextStyle(color: Colors.yellow, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(sourcePosition - 20, centerY - 50));

    // Show wavelength compression/expansion
    if (waveFronts.length >= 2) {
      textPainter.text = TextSpan(
        text: 'λ compressed',
        style: TextStyle(color: Colors.red.withValues(alpha: 0.8), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 100, centerY + 60));

      textPainter.text = TextSpan(
        text: 'λ stretched',
        style: TextStyle(color: Colors.green.withValues(alpha: 0.8), fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20, centerY + 60));
    }

    // Draw speed of sound reference line
    final refPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, size.height - 20), Offset(size.width, size.height - 20), refPaint);

    textPainter.text = const TextSpan(
      text: 'Speed of sound = 340 m/s',
      style: TextStyle(color: Colors.white38, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - 60, size.height - 18));
  }

  void _drawSource(Canvas canvas, double x, double y) {
    // Draw a simple ambulance/vehicle representation
    final bodyPaint = Paint()..color = Colors.white;
    final detailPaint = Paint()..color = Colors.red;

    // Vehicle body
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(x, y), width: 40, height: 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, bodyPaint);

    // Red cross
    canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 12, height: 4), detailPaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 4, height: 12), detailPaint);

    // Sound waves emanating
    final soundPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int i = 1; i <= 3; i++) {
      final arcRect = Rect.fromCenter(center: Offset(x, y - 15), width: 10.0 * i, height: 10.0 * i);
      canvas.drawArc(arcRect, -math.pi * 0.8, math.pi * 0.6, false, soundPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DopplerPainter oldDelegate) {
    return sourcePosition != oldDelegate.sourcePosition ||
        waveFronts.length != oldDelegate.waveFronts.length;
  }
}
