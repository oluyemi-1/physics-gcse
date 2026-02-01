import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class SolarSystemSimulation extends StatefulWidget {
  const SolarSystemSimulation({super.key});

  @override
  State<SolarSystemSimulation> createState() => _SolarSystemSimulationState();
}

class _SolarSystemSimulationState extends State<SolarSystemSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  double _timeScale = 1.0;
  int? _selectedPlanet;
  bool _showOrbits = true;
  bool _hasSpokenIntro = false;

  final List<Planet> _planets = [
    Planet('Mercury', 40, 4.15, Colors.grey, 4, '88 days', '57.9M km'),
    Planet('Venus', 60, 1.62, Colors.orange.shade200, 6, '225 days', '108.2M km'),
    Planet('Earth', 85, 1.0, Colors.blue, 7, '365 days', '149.6M km'),
    Planet('Mars', 110, 0.53, Colors.red.shade400, 5, '687 days', '227.9M km'),
    Planet('Jupiter', 150, 0.084, Colors.orange.shade700, 14, '12 years', '778.5M km'),
    Planet('Saturn', 190, 0.034, Colors.amber.shade300, 12, '29 years', '1.43B km'),
    Planet('Uranus', 220, 0.012, Colors.cyan.shade200, 8, '84 years', '2.87B km'),
    Planet('Neptune', 250, 0.006, Colors.blue.shade800, 7, '165 years', '4.5B km'),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Solar System Simulation. You can see the Sun at the center with all eight planets orbiting around it. '
          'Tap on any planet to learn more about it. Use the speed slider to make planets orbit faster or slower. '
          'The planets are held in orbit by the Sun\'s gravitational pull.',
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

  void _onTimeScaleChanged(double value) {
    setState(() => _timeScale = value);
    if (value > 3) {
      speakSimulation('Time scale increased to ${value.toStringAsFixed(1)} times. Planets are orbiting much faster now.');
    } else if (value < 0.5) {
      speakSimulation('Time scale decreased to ${value.toStringAsFixed(1)} times. You can see the planets moving slowly.');
    }
  }

  void _onOrbitsToggled() {
    setState(() => _showOrbits = !_showOrbits);
    speakSimulation(
      _showOrbits
          ? 'Orbital paths are now visible. These elliptical paths show how planets travel around the Sun.'
          : 'Orbital paths are now hidden.',
      force: true,
    );
  }

  void _onPlanetSelected(int? index) {
    setState(() => _selectedPlanet = index);
    if (index != null) {
      final planet = _planets[index];
      speakSimulation(
        'You selected ${planet.name}. It orbits the Sun at a distance of ${planet.distance}, '
        'and takes ${planet.orbitalPeriod} to complete one orbit. '
        '${_getPlanetFact(planet.name)}',
        force: true,
      );
    }
  }

  String _getPlanetFact(String name) {
    switch (name) {
      case 'Mercury':
        return 'Mercury is the smallest planet and closest to the Sun.';
      case 'Venus':
        return 'Venus is the hottest planet due to its thick atmosphere.';
      case 'Earth':
        return 'Earth is our home, the only planet known to support life.';
      case 'Mars':
        return 'Mars is called the Red Planet because of iron oxide on its surface.';
      case 'Jupiter':
        return 'Jupiter is the largest planet, with a famous Great Red Spot storm.';
      case 'Saturn':
        return 'Saturn is famous for its beautiful ring system made of ice and rock.';
      case 'Uranus':
        return 'Uranus rotates on its side, possibly due to a past collision.';
      case 'Neptune':
        return 'Neptune is the windiest planet with storms reaching 2000 kilometers per hour.';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              buildTTSToggle(),
              const Text('Speed:', style: TextStyle(color: Colors.white70)),
              Expanded(
                child: Slider(
                  value: _timeScale,
                  min: 0.1,
                  max: 5.0,
                  onChanged: _onTimeScaleChanged,
                  activeColor: Colors.yellow,
                ),
              ),
              Text(
                '${_timeScale.toStringAsFixed(1)}x',
                style: const TextStyle(color: Colors.yellow),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  _showOrbits ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: Colors.cyan,
                ),
                onPressed: _onOrbitsToggled,
                tooltip: 'Toggle orbits',
              ),
            ],
          ),
        ),
        // Solar system view
        Expanded(
          child: GestureDetector(
            onTapUp: (details) => _handleTap(details.localPosition, context),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: SolarSystemPainter(
                    planets: _planets,
                    time: _controller.value * _timeScale * 360,
                    selectedPlanet: _selectedPlanet,
                    showOrbits: _showOrbits,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),
        // Planet info panel
        if (_selectedPlanet != null)
          _buildPlanetInfo(_planets[_selectedPlanet!])
        else
          _buildInstructions(),
      ],
    );
  }

  void _handleTap(Offset position, BuildContext context) {
    final size = context.size!;
    final centerX = size.width / 2;
    final centerY = size.height / 2 - 50;

    for (int i = 0; i < _planets.length; i++) {
      final planet = _planets[i];
      final angle = _controller.value * _timeScale * 360 * planet.speed * math.pi / 180;
      final x = centerX + planet.orbitRadius * math.cos(angle);
      final y = centerY + planet.orbitRadius * math.sin(angle) * 0.4;

      final distance = math.sqrt(math.pow(position.dx - x, 2) + math.pow(position.dy - y, 2));
      if (distance < planet.size + 10) {
        _onPlanetSelected(i);
        return;
      }
    }
    _onPlanetSelected(null);
  }

  Widget _buildPlanetInfo(Planet planet) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: planet.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: planet.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: planet.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                planet.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                onPressed: () => setState(() => _selectedPlanet = null),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Orbital Period', planet.orbitalPeriod),
              _buildInfoItem('Distance from Sun', planet.distance),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Text(
        'Tap on a planet to see more information\nPlanets orbit the Sun due to gravitational attraction',
        style: TextStyle(color: Colors.white54, fontSize: 12),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class Planet {
  final String name;
  final double orbitRadius;
  final double speed;
  final Color color;
  final double size;
  final String orbitalPeriod;
  final String distance;

  Planet(this.name, this.orbitRadius, this.speed, this.color, this.size,
      this.orbitalPeriod, this.distance);
}

class SolarSystemPainter extends CustomPainter {
  final List<Planet> planets;
  final double time;
  final int? selectedPlanet;
  final bool showOrbits;

  SolarSystemPainter({
    required this.planets,
    required this.time,
    this.selectedPlanet,
    required this.showOrbits,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw sun
    final sunPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.yellow, Colors.orange, Colors.red.withValues(alpha: 0)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset(centerX, centerY), radius: 40));
    canvas.drawCircle(Offset(centerX, centerY), 40, sunPaint);

    // Sun glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(Offset(centerX, centerY), 35, glowPaint);

    // Draw orbits and planets
    for (int i = 0; i < planets.length; i++) {
      final planet = planets[i];
      final isSelected = i == selectedPlanet;

      // Draw orbit (ellipse for 3D effect)
      if (showOrbits) {
        final orbitPaint = Paint()
          ..color = isSelected
              ? planet.color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1)
          ..strokeWidth = isSelected ? 2 : 1
          ..style = PaintingStyle.stroke;

        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: planet.orbitRadius * 2,
            height: planet.orbitRadius * 0.8,
          ),
          orbitPaint,
        );
      }

      // Calculate planet position
      final angle = time * planet.speed * math.pi / 180;
      final x = centerX + planet.orbitRadius * math.cos(angle);
      final y = centerY + planet.orbitRadius * math.sin(angle) * 0.4;

      // Draw planet
      final planetPaint = Paint()..color = planet.color;
      final planetSize = isSelected ? planet.size + 3 : planet.size;

      // Planet glow if selected
      if (isSelected) {
        final planetGlow = Paint()
          ..color = planet.color.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
        canvas.drawCircle(Offset(x, y), planetSize + 5, planetGlow);
      }

      canvas.drawCircle(Offset(x, y), planetSize, planetPaint);

      // Planet name
      if (isSelected || planet.size > 10) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: planet.name,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + planetSize + 5));
      }
    }

    // Sun label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Sun',
        style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 12, centerY + 45));
  }

  @override
  bool shouldRepaint(covariant SolarSystemPainter oldDelegate) {
    return oldDelegate.time != time ||
        oldDelegate.selectedPlanet != selectedPlanet ||
        oldDelegate.showOrbits != showOrbits;
  }
}
