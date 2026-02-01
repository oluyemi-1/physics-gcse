import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class ProjectileMotionSimulation extends StatefulWidget {
  const ProjectileMotionSimulation({super.key});

  @override
  State<ProjectileMotionSimulation> createState() => _ProjectileMotionSimulationState();
}

class _ProjectileMotionSimulationState extends State<ProjectileMotionSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _launchAngle = 45.0; // degrees
  double _launchSpeed = 20.0; // m/s
  final double _gravity = 9.8; // m/s²

  bool _isLaunched = false;
  double _time = 0.0;
  List<Offset> _trajectory = [];

  double _currentX = 0.0;
  double _currentY = 0.0;
  double _maxHeight = 0.0;
  double _range = 0.0;

  bool _hasSpokenIntro = false;
  bool _showVelocityComponents = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(_updateProjectile);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Projectile Motion simulation! '
          'A projectile is any object thrown into the air that moves under gravity alone. '
          'Adjust the launch angle and speed to see how they affect the trajectory. '
          'The horizontal and vertical motions are independent of each other.',
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

  void _updateProjectile() {
    if (!_isLaunched) return;

    setState(() {
      _time += 0.016; // ~60fps

      final angleRad = _launchAngle * math.pi / 180;
      final vx = _launchSpeed * math.cos(angleRad);
      final vy = _launchSpeed * math.sin(angleRad);

      _currentX = vx * _time;
      _currentY = vy * _time - 0.5 * _gravity * _time * _time;

      if (_currentY >= 0) {
        _trajectory.add(Offset(_currentX, _currentY));

        if (_currentY > _maxHeight) {
          _maxHeight = _currentY;
        }
      } else {
        // Projectile has landed
        _isLaunched = false;
        _controller.stop();
        _range = _currentX;
        _currentY = 0;

        // Play landing sound
        context.read<SoundProvider>().playCollision(intensity: _launchSpeed / 20);

        speakSimulation(
          'The projectile has landed! '
          'Maximum height reached was ${_maxHeight.toStringAsFixed(1)} metres. '
          'Total horizontal range was ${_range.toStringAsFixed(1)} metres. '
          'Time of flight was ${_time.toStringAsFixed(2)} seconds.',
          force: true,
        );
      }
    });
  }

  void _launch() {
    // Play launch sound
    context.read<SoundProvider>().playLaunch();

    setState(() {
      _isLaunched = true;
      _time = 0.0;
      _trajectory = [];
      _currentX = 0.0;
      _currentY = 0.0;
      _maxHeight = 0.0;
      _range = 0.0;
    });

    final angleRad = _launchAngle * math.pi / 180;
    final vx = _launchSpeed * math.cos(angleRad);
    final vy = _launchSpeed * math.sin(angleRad);

    speakSimulation(
      'Launching at ${_launchAngle.toStringAsFixed(0)} degrees with speed ${_launchSpeed.toStringAsFixed(0)} metres per second. '
      'Horizontal velocity component is ${vx.toStringAsFixed(1)} metres per second. '
      'Vertical velocity component is ${vy.toStringAsFixed(1)} metres per second.',
      force: true,
    );

    _controller.forward(from: 0.0);
  }

  void _reset() {
    setState(() {
      _isLaunched = false;
      _time = 0.0;
      _trajectory = [];
      _currentX = 0.0;
      _currentY = 0.0;
      _maxHeight = 0.0;
      _range = 0.0;
    });
    _controller.stop();
    _controller.reset();

    speakSimulation('Simulation reset. Adjust the angle and speed, then launch again.', force: true);
  }

  void _onAngleChanged(double value) {
    setState(() {
      _launchAngle = value;
    });

    if (value == 45) {
      speakSimulation(
        'Launch angle set to 45 degrees. This angle gives maximum range for a given speed on level ground.',
        force: true,
      );
    } else if (value > 45) {
      speakSimulation(
        'Launch angle set to ${value.toStringAsFixed(0)} degrees. Higher angles give more height but less range.',
        force: true,
      );
    } else {
      speakSimulation(
        'Launch angle set to ${value.toStringAsFixed(0)} degrees. Lower angles give more range but less height.',
        force: true,
      );
    }
  }

  void _onSpeedChanged(double value) {
    setState(() {
      _launchSpeed = value;
    });
    speakSimulation(
      'Launch speed set to ${value.toStringAsFixed(0)} metres per second.',
    );
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
              color: Colors.lightBlue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _ProjectilePainter(
                  trajectory: _trajectory,
                  currentX: _currentX,
                  currentY: _currentY,
                  isLaunched: _isLaunched,
                  launchAngle: _launchAngle,
                  launchSpeed: _launchSpeed,
                  showVelocityComponents: _showVelocityComponents,
                  time: _time,
                  gravity: _gravity,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),

        // Data display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataCard('Height', '${_currentY.toStringAsFixed(1)} m'),
              _buildDataCard('Distance', '${_currentX.toStringAsFixed(1)} m'),
              _buildDataCard('Max Height', '${_maxHeight.toStringAsFixed(1)} m'),
              _buildDataCard('Time', '${_time.toStringAsFixed(2)} s'),
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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Launch Angle: ${_launchAngle.toStringAsFixed(0)}°',
                              style: const TextStyle(color: Colors.white)),
                          Slider(
                            value: _launchAngle,
                            min: 10,
                            max: 80,
                            divisions: 70,
                            onChanged: _isLaunched ? null : _onAngleChanged,
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Launch Speed: ${_launchSpeed.toStringAsFixed(0)} m/s',
                              style: const TextStyle(color: Colors.white)),
                          Slider(
                            value: _launchSpeed,
                            min: 5,
                            max: 50,
                            divisions: 45,
                            onChanged: _isLaunched ? null : _onSpeedChanged,
                            activeColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Row(
                  children: [
                    Checkbox(
                      value: _showVelocityComponents,
                      onChanged: (v) => setState(() => _showVelocityComponents = v ?? true),
                      activeColor: Colors.blue,
                    ),
                    const Text('Show velocity components', style: TextStyle(color: Colors.white)),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isLaunched ? null : _launch,
                      icon: const Icon(Icons.rocket_launch),
                      label: const Text('Launch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
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

  Widget _buildDataCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _ProjectilePainter extends CustomPainter {
  final List<Offset> trajectory;
  final double currentX;
  final double currentY;
  final bool isLaunched;
  final double launchAngle;
  final double launchSpeed;
  final bool showVelocityComponents;
  final double time;
  final double gravity;

  _ProjectilePainter({
    required this.trajectory,
    required this.currentX,
    required this.currentY,
    required this.isLaunched,
    required this.launchAngle,
    required this.launchSpeed,
    required this.showVelocityComponents,
    required this.time,
    required this.gravity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 100; // Scale factor
    final groundY = size.height - 50;
    final launchX = 50.0;

    // Draw sky gradient
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.lightBlue[200]!, Colors.lightBlue[50]!],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), skyPaint);

    // Draw ground
    final groundPaint = Paint()..color = Colors.green[700]!;
    canvas.drawRect(Rect.fromLTWH(0, groundY, size.width, 50), groundPaint);

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      final x = i * size.width / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, groundY), gridPaint);
    }
    for (int i = 0; i <= 5; i++) {
      final y = i * groundY / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw launcher
    final launcherPaint = Paint()
      ..color = Colors.brown[700]!
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final angleRad = launchAngle * math.pi / 180;
    final launcherLength = 30.0;
    final launcherEndX = launchX + launcherLength * math.cos(angleRad);
    final launcherEndY = groundY - launcherLength * math.sin(angleRad);
    canvas.drawLine(Offset(launchX, groundY), Offset(launcherEndX, launcherEndY), launcherPaint);

    // Draw trajectory path
    if (trajectory.isNotEmpty) {
      final pathPaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(launchX + trajectory[0].dx * scale, groundY - trajectory[0].dy * scale);
      for (final point in trajectory) {
        path.lineTo(launchX + point.dx * scale, groundY - point.dy * scale);
      }
      canvas.drawPath(path, pathPaint);
    }

    // Draw projectile
    final projX = launchX + currentX * scale;
    final projY = groundY - currentY * scale;

    final projectilePaint = Paint()..color = Colors.red[700]!;
    canvas.drawCircle(Offset(projX, projY), 8, projectilePaint);

    // Draw velocity components
    if (showVelocityComponents && (isLaunched || currentX == 0)) {
      final vx = launchSpeed * math.cos(angleRad);
      final vy = launchSpeed * math.sin(angleRad) - gravity * time;

      final arrowScale = 2.0;

      // Horizontal component (red)
      final vxPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 2;
      _drawArrow(canvas, Offset(projX, projY), Offset(projX + vx * arrowScale, projY), vxPaint);

      // Vertical component (blue)
      final vyPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;
      _drawArrow(canvas, Offset(projX, projY), Offset(projX, projY - vy * arrowScale), vyPaint);

      // Resultant velocity (green)
      final vPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3;
      _drawArrow(canvas, Offset(projX, projY), Offset(projX + vx * arrowScale, projY - vy * arrowScale), vPaint);
    }

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Distance markers
    for (int i = 0; i <= 4; i++) {
      final dist = i * 20;
      textPainter.text = TextSpan(
        text: '${dist}m',
        style: const TextStyle(color: Colors.black54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(launchX + dist * scale - 10, groundY + 5));
    }

    // Height markers
    for (int i = 1; i <= 4; i++) {
      final height = i * 10;
      textPainter.text = TextSpan(
        text: '${height}m',
        style: const TextStyle(color: Colors.black54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, groundY - height * scale - 5));
    }

    // Legend
    if (showVelocityComponents) {
      final legendY = 20.0;
      textPainter.text = const TextSpan(
        text: '— Vx (horizontal)  ',
        style: TextStyle(color: Colors.red, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(10, legendY));

      textPainter.text = const TextSpan(
        text: '— Vy (vertical)  ',
        style: TextStyle(color: Colors.blue, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(120, legendY));

      textPainter.text = const TextSpan(
        text: '— V (resultant)',
        style: TextStyle(color: Colors.green, fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(220, legendY));
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    // Arrow head
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowSize = 8.0;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    path.close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _ProjectilePainter oldDelegate) {
    return trajectory.length != oldDelegate.trajectory.length ||
        currentX != oldDelegate.currentX ||
        currentY != oldDelegate.currentY ||
        launchAngle != oldDelegate.launchAngle ||
        showVelocityComponents != oldDelegate.showVelocityComponents;
  }
}
