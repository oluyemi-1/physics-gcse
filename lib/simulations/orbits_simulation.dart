import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class OrbitsSimulation extends StatefulWidget {
  const OrbitsSimulation({super.key});

  @override
  State<OrbitsSimulation> createState() => _OrbitsSimulationState();
}

class _OrbitsSimulationState extends State<OrbitsSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _orbitRadius = 150.0;
  double _satelliteAngle = 0.0;
  double _orbitalSpeed = 1.0;
  bool _showForces = true;
  bool _showVelocity = true;
  bool _hasSpokenIntro = false;

  String _selectedBody = 'Earth';

  final Map<String, Map<String, dynamic>> _bodies = {
    'Earth': {'radius': 40.0, 'color': Colors.blue, 'mass': '5.97×10²⁴ kg'},
    'Moon': {'radius': 25.0, 'color': Colors.grey, 'mass': '7.35×10²² kg'},
    'Sun': {'radius': 50.0, 'color': Colors.orange, 'mass': '1.99×10³⁰ kg'},
    'Mars': {'radius': 35.0, 'color': Colors.red, 'mass': '6.42×10²³ kg'},
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateOrbit);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Orbits simulation! '
          'Satellites stay in orbit because gravity provides the centripetal force needed for circular motion. '
          'The satellite is constantly falling towards the planet, but also moving sideways fast enough to keep missing it. '
          'Notice how the velocity is always tangent to the orbit, while gravity pulls towards the centre.',
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

  void _updateOrbit() {
    setState(() {
      // Orbital speed is inversely related to square root of radius (Kepler's law)
      final speedFactor = 1 / math.sqrt(_orbitRadius / 150);
      _satelliteAngle += 0.02 * _orbitalSpeed * speedFactor;
      if (_satelliteAngle > 2 * math.pi) {
        _satelliteAngle -= 2 * math.pi;
      }
    });
  }

  void _onRadiusChanged(double value) {
    setState(() {
      _orbitRadius = value;
    });

    if (value > 200) {
      speakSimulation(
        'Higher orbit selected. At greater distances, orbital speed is slower and the period is longer. '
        'Geostationary satellites orbit at about 36,000 kilometres.',
      );
    } else if (value < 100) {
      speakSimulation(
        'Lower orbit selected. Closer to the planet, the satellite must travel faster to stay in orbit. '
        'The International Space Station orbits at about 400 kilometres.',
      );
    }
  }

  void _onBodyChanged(String? body) {
    if (body == null) return;
    setState(() {
      _selectedBody = body;
    });
    speakSimulation(
      'Changed to $body. Mass: ${_bodies[body]!['mass']}. '
      'Different masses create different gravitational fields.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Orbit visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade700),
            ),
            child: CustomPaint(
              painter: _OrbitPainter(
                bodyRadius: _bodies[_selectedBody]!['radius'] as double,
                bodyColor: _bodies[_selectedBody]!['color'] as Color,
                orbitRadius: _orbitRadius,
                satelliteAngle: _satelliteAngle,
                showForces: _showForces,
                showVelocity: _showVelocity,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Satellite orbiting $_selectedBody',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Centripetal Force = Gravitational Force',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Text(
                'F = mv²/r = GMm/r²',
                style: TextStyle(color: Colors.cyan, fontFamily: 'monospace', fontSize: 14),
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
                // Body selector
                Row(
                  children: [
                    const Text('Central Body: ', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedBody,
                        dropdownColor: Colors.grey[800],
                        isExpanded: true,
                        items: _bodies.keys.map((body) {
                          return DropdownMenuItem(
                            value: body,
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _bodies[body]!['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(body, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _onBodyChanged,
                      ),
                    ),
                  ],
                ),

                // Orbit radius slider
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text('Orbit Height:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _orbitRadius,
                        min: 80,
                        max: 250,
                        onChanged: _onRadiusChanged,
                        activeColor: Colors.cyan,
                      ),
                    ),
                  ],
                ),

                // Speed slider
                Row(
                  children: [
                    const SizedBox(width: 90, child: Text('Speed:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _orbitalSpeed,
                        min: 0.1,
                        max: 3.0,
                        onChanged: (v) => setState(() => _orbitalSpeed = v),
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _showForces,
                          onChanged: (v) => setState(() => _showForces = v ?? true),
                          activeColor: Colors.red,
                        ),
                        const Text('Forces', style: TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 16),
                        Checkbox(
                          value: _showVelocity,
                          onChanged: (v) => setState(() => _showVelocity = v ?? true),
                          activeColor: Colors.green,
                        ),
                        const Text('Velocity', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
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

class _OrbitPainter extends CustomPainter {
  final double bodyRadius;
  final Color bodyColor;
  final double orbitRadius;
  final double satelliteAngle;
  final bool showForces;
  final bool showVelocity;

  _OrbitPainter({
    required this.bodyRadius,
    required this.bodyColor,
    required this.orbitRadius,
    required this.satelliteAngle,
    required this.showForces,
    required this.showVelocity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw stars background
    _drawStars(canvas, size);

    // Draw orbit path
    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(centerX, centerY), orbitRadius, orbitPaint);

    // Draw central body with glow
    final glowPaint = Paint()
      ..color = bodyColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(Offset(centerX, centerY), bodyRadius + 10, glowPaint);

    final bodyPaint = Paint()..color = bodyColor;
    canvas.drawCircle(Offset(centerX, centerY), bodyRadius, bodyPaint);

    // Draw satellite
    final satX = centerX + orbitRadius * math.cos(satelliteAngle);
    final satY = centerY + orbitRadius * math.sin(satelliteAngle);

    final satPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(satX, satY), 8, satPaint);

    // Draw satellite body details
    final satDetailPaint = Paint()
      ..color = Colors.blue[300]!
      ..strokeWidth = 2;
    // Solar panels
    canvas.drawLine(Offset(satX - 15, satY), Offset(satX - 8, satY), satDetailPaint);
    canvas.drawLine(Offset(satX + 8, satY), Offset(satX + 15, satY), satDetailPaint);

    // Draw gravitational force arrow (towards center)
    if (showForces) {
      final forceLength = 40.0;
      final forceEndX = satX - forceLength * math.cos(satelliteAngle);
      final forceEndY = satY - forceLength * math.sin(satelliteAngle);

      final forcePaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3;
      _drawArrow(canvas, Offset(satX, satY), Offset(forceEndX, forceEndY), forcePaint);

      // Label
      final textPainter = TextPainter(
        text: const TextSpan(text: 'F (gravity)', style: TextStyle(color: Colors.red, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(forceEndX - 25, forceEndY - 15));
    }

    // Draw velocity arrow (tangent to orbit)
    if (showVelocity) {
      final velocityLength = 50.0;
      final velAngle = satelliteAngle + math.pi / 2; // Perpendicular to radius
      final velEndX = satX + velocityLength * math.cos(velAngle);
      final velEndY = satY + velocityLength * math.sin(velAngle);

      final velPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3;
      _drawArrow(canvas, Offset(satX, satY), Offset(velEndX, velEndY), velPaint);

      // Label
      final textPainter = TextPainter(
        text: const TextSpan(text: 'v (velocity)', style: TextStyle(color: Colors.green, fontSize: 10)),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(velEndX - 25, velEndY));
    }

    // Draw radius line (dashed)
    final radiusPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    _drawDashedLine(canvas, Offset(centerX, centerY), Offset(satX, satY), radiusPaint);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: 'r (orbital radius)',
      style: TextStyle(color: Colors.white54, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((centerX + satX) / 2 - 30, (centerY + satY) / 2 - 15));
  }

  void _drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white;
    final random = math.Random(42);
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    canvas.drawLine(start, end, paint);

    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowSize = 10.0;

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

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final dashCount = (length / 10).floor();

    for (int i = 0; i < dashCount; i += 2) {
      final startFrac = i / dashCount;
      final endFrac = (i + 1) / dashCount;
      canvas.drawLine(
        Offset(start.dx + dx * startFrac, start.dy + dy * startFrac),
        Offset(start.dx + dx * endFrac, start.dy + dy * endFrac),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return satelliteAngle != oldDelegate.satelliteAngle ||
        orbitRadius != oldDelegate.orbitRadius ||
        showForces != oldDelegate.showForces ||
        showVelocity != oldDelegate.showVelocity;
  }
}
