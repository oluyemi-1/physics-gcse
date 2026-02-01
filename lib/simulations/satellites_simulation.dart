import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Satellites Simulation demonstrating orbital mechanics
/// Shows geostationary, polar, and low Earth orbits
class SatellitesSimulation extends StatefulWidget {
  const SatellitesSimulation({super.key});

  @override
  State<SatellitesSimulation> createState() => _SatellitesSimulationState();
}

class _SatellitesSimulationState extends State<SatellitesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _time = 0.0;
  String _orbitType = 'LEO';
  bool _showOrbitalPath = true;
  bool _showCoverage = true;
  double _timeScale = 1.0;

  final Map<String, Map<String, dynamic>> _orbitTypes = {
    'LEO': {
      'name': 'Low Earth Orbit',
      'altitude': '200-2000 km',
      'period': '90-120 min',
      'speed': '7.8 km/s',
      'uses': 'ISS, Hubble, Earth observation',
      'radius': 0.25,
      'periodFactor': 0.02,
      'color': Colors.cyan,
    },
    'MEO': {
      'name': 'Medium Earth Orbit',
      'altitude': '2000-35786 km',
      'period': '2-24 hours',
      'speed': '3-7 km/s',
      'uses': 'GPS, Navigation',
      'radius': 0.45,
      'periodFactor': 0.008,
      'color': Colors.orange,
    },
    'GEO': {
      'name': 'Geostationary Orbit',
      'altitude': '35,786 km',
      'period': '24 hours (matches Earth)',
      'speed': '3.07 km/s',
      'uses': 'TV, Weather, Communications',
      'radius': 0.65,
      'periodFactor': 0.004,
      'color': Colors.green,
    },
    'Polar': {
      'name': 'Polar Orbit',
      'altitude': '700-800 km',
      'period': '~100 min',
      'speed': '7.5 km/s',
      'uses': 'Earth mapping, Spy satellites',
      'radius': 0.3,
      'periodFactor': 0.018,
      'color': Colors.purple,
      'isPolar': true,
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _time += 0.016 * _timeScale;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Satellites Simulation. Explore different types of satellite orbits. '
        'Low Earth Orbit satellites are close and fast, used for the International Space Station. '
        'Geostationary satellites orbit at exactly 24 hours, staying above the same point on Earth. '
        'Polar orbits pass over the poles, allowing satellites to scan the entire Earth surface.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Satellites & Orbits'),
        backgroundColor: Colors.indigo.shade800,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [Color(0xFF1a1a2e), Colors.black],
          ),
        ),
        child: Column(
          children: [
            _buildInfoPanel(),
            Expanded(child: _buildSimulationArea()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    final orbit = _orbitTypes[_orbitType]!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (orbit['color'] as Color).withAlpha(150)),
      ),
      child: Column(
        children: [
          Text(
            orbit['name'] as String,
            style: TextStyle(
              color: orbit['color'] as Color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Altitude', orbit['altitude'] as String),
              _buildInfoItem('Period', orbit['period'] as String),
              _buildInfoItem('Speed', orbit['speed'] as String),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Uses: ${orbit['uses']}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _SatellitesPainter(
            time: _time,
            orbitType: _orbitType,
            orbitTypes: _orbitTypes,
            showOrbitalPath: _showOrbitalPath,
            showCoverage: _showCoverage,
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black45,
      child: Column(
        children: [
          // Orbit type selector
          Wrap(
            spacing: 8,
            children: _orbitTypes.keys.map((type) {
              final orbit = _orbitTypes[type]!;
              return ChoiceChip(
                label: Text(type, style: const TextStyle(fontSize: 11)),
                selected: _orbitType == type,
                selectedColor: orbit['color'] as Color,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _orbitType = type);
                    speakSimulation(
                      '${orbit['name']}. Altitude: ${orbit['altitude']}. '
                      'Orbital period: ${orbit['period']}. Used for: ${orbit['uses']}.',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Time scale slider
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Time Scale:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _timeScale,
                  min: 0.1,
                  max: 5.0,
                  activeColor: Colors.indigo,
                  onChanged: (value) => setState(() => _timeScale = value),
                ),
              ),
              Text('${_timeScale.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Toggle switches
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _showOrbitalPath,
                    onChanged: (v) => setState(() => _showOrbitalPath = v ?? true),
                    activeColor: Colors.indigo,
                  ),
                  const Text('Show Orbit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: _showCoverage,
                    onChanged: (v) => setState(() => _showCoverage = v ?? true),
                    activeColor: Colors.indigo,
                  ),
                  const Text('Show Coverage', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ],
          ),

          // Key facts
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Orbital Speed: v = √(GM/r)  |  Period: T = 2π√(r³/GM)  |  Higher orbit = slower speed, longer period',
              style: TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SatellitesPainter extends CustomPainter {
  final double time;
  final String orbitType;
  final Map<String, Map<String, dynamic>> orbitTypes;
  final bool showOrbitalPath;
  final bool showCoverage;

  _SatellitesPainter({
    required this.time,
    required this.orbitType,
    required this.orbitTypes,
    required this.showOrbitalPath,
    required this.showCoverage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final maxRadius = math.min(size.width, size.height) / 2 - 30;

    // Draw stars background
    _drawStars(canvas, size);

    // Draw Earth
    _drawEarth(canvas, Offset(centerX, centerY), maxRadius * 0.2);

    // Draw all orbit paths (faded) for comparison
    if (showOrbitalPath) {
      for (final entry in orbitTypes.entries) {
        final orbit = entry.value;
        final radius = maxRadius * (orbit['radius'] as double);
        final color = orbit['color'] as Color;
        final isSelected = entry.key == orbitType;
        final isPolar = orbit['isPolar'] == true;

        _drawOrbitPath(canvas, Offset(centerX, centerY), radius,
            color.withAlpha(isSelected ? 100 : 30), isPolar);
      }
    }

    // Draw the selected satellite
    final selectedOrbit = orbitTypes[orbitType]!;
    final orbitRadius = maxRadius * (selectedOrbit['radius'] as double);
    final periodFactor = selectedOrbit['periodFactor'] as double;
    final color = selectedOrbit['color'] as Color;
    final isPolar = selectedOrbit['isPolar'] == true;

    // Calculate satellite position
    final angle = time * periodFactor * 2 * math.pi;
    Offset satellitePos;

    if (isPolar) {
      // Polar orbit - satellite moves around the poles
      final x = centerX + orbitRadius * math.sin(angle);
      final y = centerY + orbitRadius * math.cos(angle) * 0.3; // Compressed view
      satellitePos = Offset(x, y);
    } else {
      // Equatorial orbit
      final x = centerX + orbitRadius * math.cos(angle);
      final y = centerY + orbitRadius * math.sin(angle) * 0.3; // Slight tilt for 3D effect
      satellitePos = Offset(x, y);
    }

    // Draw coverage cone
    if (showCoverage) {
      _drawCoverage(canvas, satellitePos, Offset(centerX, centerY), color);
    }

    // Draw satellite
    _drawSatellite(canvas, satellitePos, color);

    // Draw GEO marker showing it stays above same point
    if (orbitType == 'GEO') {
      _drawGeoMarker(canvas, centerX, centerY, orbitRadius);
    }

    // Draw orbital info
    _drawOrbitalInfo(canvas, size, selectedOrbit);
  }

  void _drawStars(Canvas canvas, Size size) {
    final random = math.Random(42);
    final starPaint = Paint()..color = Colors.white;

    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      starPaint.color = Colors.white.withAlpha((random.nextDouble() * 155 + 100).toInt());
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _drawEarth(Canvas canvas, Offset center, double radius) {
    // Earth gradient
    final earthGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [Colors.lightBlue.shade300, Colors.blue.shade700, Colors.blue.shade900],
    );

    final earthPaint = Paint()
      ..shader = earthGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );

    canvas.drawCircle(center, radius, earthPaint);

    // Simple continent shapes
    final landPaint = Paint()..color = Colors.green.shade700;

    // Draw some land masses (simplified)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx - radius * 0.3, center.dy - radius * 0.2),
          width: radius * 0.4, height: radius * 0.3),
      landPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(center.dx + radius * 0.2, center.dy + radius * 0.1),
          width: radius * 0.5, height: radius * 0.4),
      landPaint,
    );

    // Atmosphere glow
    final atmospherePaint = Paint()
      ..color = Colors.lightBlue.withAlpha(50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius + 3, atmospherePaint);

    // Earth label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Earth',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy + radius + 10));
  }

  void _drawOrbitPath(Canvas canvas, Offset center, double radius, Color color, bool isPolar) {
    final orbitPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (isPolar) {
      // Draw ellipse for polar orbit (viewed from side)
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.6),
        orbitPaint,
      );
    } else {
      // Draw ellipse for equatorial orbit (slight tilt)
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2, height: radius * 0.6),
        orbitPaint,
      );
    }
  }

  void _drawSatellite(Canvas canvas, Offset position, Color color) {
    // Satellite body
    final bodyPaint = Paint()..color = Colors.grey.shade400;
    canvas.drawRect(
      Rect.fromCenter(center: position, width: 12, height: 8),
      bodyPaint,
    );

    // Solar panels
    final panelPaint = Paint()..color = color;
    canvas.drawRect(
      Rect.fromCenter(center: Offset(position.dx - 15, position.dy), width: 15, height: 6),
      panelPaint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset(position.dx + 15, position.dy), width: 15, height: 6),
      panelPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withAlpha(100)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(position, 10, glowPaint);
  }

  void _drawCoverage(Canvas canvas, Offset satellite, Offset earth, Color color) {
    final coveragePaint = Paint()
      ..color = color.withAlpha(30)
      ..style = PaintingStyle.fill;

    // Draw cone from satellite to Earth
    final path = Path();
    path.moveTo(satellite.dx, satellite.dy);

    // Calculate coverage angle based on altitude (lower = smaller coverage)
    final distance = (satellite - earth).distance;
    final coverageWidth = distance * 0.5;

    path.lineTo(earth.dx - coverageWidth, earth.dy);
    path.lineTo(earth.dx + coverageWidth, earth.dy);
    path.close();

    canvas.drawPath(path, coveragePaint);

    // Coverage arc on Earth
    final arcPaint = Paint()
      ..color = color.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawArc(
      Rect.fromCenter(center: earth, width: coverageWidth * 2, height: coverageWidth * 0.6),
      0,
      math.pi,
      false,
      arcPaint,
    );
  }

  void _drawGeoMarker(Canvas canvas, double centerX, double centerY, double radius) {
    // Show that GEO satellite stays above same point
    final markerPaint = Paint()
      ..color = Colors.green.withAlpha(150)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dashed line from Earth to satellite
    final dashPath = Path();
    for (var i = 0; i < 10; i++) {
      final startY = centerY + (radius * 0.2) + i * (radius * 0.8 / 10);
      dashPath.moveTo(centerX + radius, startY);
      dashPath.lineTo(centerX + radius, startY + (radius * 0.8 / 20));
    }
    canvas.drawPath(dashPath, markerPaint);

    // "Fixed point" label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Stays above\nsame point',
        style: TextStyle(color: Colors.green, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + radius + 5, centerY));
  }

  void _drawOrbitalInfo(Canvas canvas, Size size, Map<String, dynamic> orbit) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Altitude: ${orbit['altitude']}\nPeriod: ${orbit['period']}',
        style: TextStyle(color: (orbit['color'] as Color).withAlpha(200), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));
  }

  @override
  bool shouldRepaint(covariant _SatellitesPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.orbitType != orbitType ||
           oldDelegate.showOrbitalPath != showOrbitalPath ||
           oldDelegate.showCoverage != showCoverage;
  }
}
