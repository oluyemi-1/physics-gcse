import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class ParticleSimulation extends StatefulWidget {
  const ParticleSimulation({super.key});

  @override
  State<ParticleSimulation> createState() => _ParticleSimulationState();
}

class _ParticleSimulationState extends State<ParticleSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  String _state = 'solid'; // 'solid', 'liquid', 'gas'
  double _temperature = 20;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  bool _hasSpokenIntro = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);
    _initParticles();
    _controller.repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Particle Model Simulation. This shows how particles behave in different states of matter. '
          'In a solid, particles are tightly packed and only vibrate. In a liquid, they can move past each other. '
          'In a gas, particles move freely in all directions. Tap the buttons to change state, and use the slider to adjust temperature.',
          force: true,
        );
      }
    });
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 50; i++) {
      _particles.add(Particle(
        x: 50 + _random.nextDouble() * 200,
        y: 50 + _random.nextDouble() * 150,
        vx: 0,
        vy: 0,
      ));
    }
    _arrangeParticles();
  }

  void _arrangeParticles() {
    if (_state == 'solid') {
      // Grid arrangement
      int cols = 10;
      for (int i = 0; i < _particles.length; i++) {
        _particles[i].x = 80 + (i % cols) * 20.0;
        _particles[i].y = 60 + (i ~/ cols) * 20.0;
        _particles[i].vx = 0;
        _particles[i].vy = 0;
      }
    }
  }

  void _updateParticles() {
    final energy = _getEnergy();

    setState(() {
      for (var particle in _particles) {
        if (_state == 'solid') {
          // Vibrate in place
          particle.baseX ??= particle.x;
          particle.baseY ??= particle.y;
          particle.x = particle.baseX! + (math.sin(_controller.value * math.pi * 20 + particle.phase) * energy * 3);
          particle.y = particle.baseY! + (math.cos(_controller.value * math.pi * 20 + particle.phase) * energy * 3);
        } else {
          // Move freely
          particle.baseX = null;
          particle.baseY = null;

          // Add random motion based on temperature
          particle.vx += (_random.nextDouble() - 0.5) * energy * 0.5;
          particle.vy += (_random.nextDouble() - 0.5) * energy * 0.5;

          // Apply velocity
          particle.x += particle.vx;
          particle.y += particle.vy;

          // Damping
          particle.vx *= 0.98;
          particle.vy *= 0.98;

          // Boundaries
          final maxX = _state == 'gas' ? 280.0 : 250.0;
          final maxY = _state == 'gas' ? 180.0 : 160.0;

          if (particle.x < 50) {
            particle.x = 50;
            particle.vx = -particle.vx * 0.8;
          }
          if (particle.x > maxX) {
            particle.x = maxX;
            particle.vx = -particle.vx * 0.8;
          }
          if (particle.y < 40) {
            particle.y = 40;
            particle.vy = -particle.vy * 0.8;
          }
          if (particle.y > maxY) {
            particle.y = maxY;
            particle.vy = -particle.vy * 0.8;
          }
        }
      }
    });
  }

  double _getEnergy() {
    return (_temperature + 273) / 300; // Normalize temperature
  }

  void _changeState(String newState) {
    setState(() {
      _state = newState;
      if (newState == 'solid') {
        _arrangeParticles();
      } else {
        // Give particles initial velocity
        for (var particle in _particles) {
          particle.vx = (_random.nextDouble() - 0.5) * _getEnergy() * 5;
          particle.vy = (_random.nextDouble() - 0.5) * _getEnergy() * 5;
        }
      }
    });
    _speakStateChange(newState);
  }

  void _speakStateChange(String state) {
    switch (state) {
      case 'solid':
        speakSimulation(
          'Solid state selected. In a solid, particles are held in fixed positions by strong forces. '
          'They can only vibrate about their fixed positions. This is why solids have a definite shape and volume.',
          force: true,
        );
        break;
      case 'liquid':
        speakSimulation(
          'Liquid state selected. In a liquid, particles are close together but can move past each other. '
          'They have more energy than in a solid. Liquids have a fixed volume but take the shape of their container.',
          force: true,
        );
        break;
      case 'gas':
        speakSimulation(
          'Gas state selected. In a gas, particles are far apart and move quickly in random directions. '
          'They have the most kinetic energy. Gases have no fixed shape or volume and will fill any container.',
          force: true,
        );
        break;
    }
  }

  void _onTemperatureChanged(double value) {
    setState(() => _temperature = value);
    final tempDescription = value < 0
        ? 'below freezing'
        : value < 100
            ? 'between freezing and boiling'
            : 'above boiling point of water';
    speakSimulation(
      'Temperature set to ${value.toInt()} degrees Celsius, which is $tempDescription. '
      'Higher temperature means particles have more kinetic energy and move faster.',
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
        // State selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTTSToggle(),
              const SizedBox(width: 12),
              _buildStateButton('Solid', 'solid', Colors.blue),
              const SizedBox(width: 12),
              _buildStateButton('Liquid', 'liquid', Colors.cyan),
              const SizedBox(width: 12),
              _buildStateButton('Gas', 'gas', Colors.orange),
            ],
          ),
        ),
        // Particle visualization
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Stack(
              children: [
                // Container walls visualization
                CustomPaint(
                  painter: ContainerPainter(state: _state),
                  size: Size.infinite,
                ),
                // Particles
                ..._particles.map((p) => Positioned(
                      left: p.x - 6,
                      top: p.y - 6,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getParticleColor(),
                          boxShadow: [
                            BoxShadow(
                              color: _getParticleColor().withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
        // Info panel
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStateColor().withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getStateColor().withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Text(
                _getStateTitle(),
                style: TextStyle(
                  color: _getStateColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getStateDescription(),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Temperature slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Icon(Icons.ac_unit, color: Colors.blue, size: 20),
              Expanded(
                child: Slider(
                  value: _temperature,
                  min: -50,
                  max: 200,
                  onChanged: _onTemperatureChanged,
                  activeColor: Color.lerp(
                    Colors.blue,
                    Colors.red,
                    (_temperature + 50) / 250,
                  ),
                ),
              ),
              const Icon(Icons.whatshot, color: Colors.red, size: 20),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Temperature: ${_temperature.toInt()}°C (${(_temperature + 273).toInt()} K)',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildStateButton(String label, String state, Color color) {
    final isSelected = _state == state;
    return GestureDetector(
      onTap: () => _changeState(state),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Icon(
              state == 'solid'
                  ? Icons.grid_view
                  : state == 'liquid'
                      ? Icons.water_drop
                      : Icons.cloud,
              color: isSelected ? Colors.white : color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getParticleColor() {
    switch (_state) {
      case 'solid':
        return Colors.blue;
      case 'liquid':
        return Colors.cyan;
      case 'gas':
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  Color _getStateColor() {
    switch (_state) {
      case 'solid':
        return Colors.blue;
      case 'liquid':
        return Colors.cyan;
      case 'gas':
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  String _getStateTitle() {
    switch (_state) {
      case 'solid':
        return 'Solid State';
      case 'liquid':
        return 'Liquid State';
      case 'gas':
        return 'Gas State';
      default:
        return '';
    }
  }

  String _getStateDescription() {
    switch (_state) {
      case 'solid':
        return 'Particles are closely packed in a fixed, regular arrangement.\nThey vibrate but cannot move from their positions.\nFixed shape and volume.';
      case 'liquid':
        return 'Particles are close together but can move past each other.\nThey have more energy than in a solid.\nFixed volume but takes shape of container.';
      case 'gas':
        return 'Particles are far apart and move quickly in all directions.\nThey have the most energy.\nNo fixed shape or volume - fills container.';
      default:
        return '';
    }
  }
}

class Particle {
  double x;
  double y;
  double vx;
  double vy;
  double? baseX;
  double? baseY;
  late double phase;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
  }) {
    phase = math.Random().nextDouble() * math.pi * 2;
  }
}

class ContainerPainter extends CustomPainter {
  final String state;

  ContainerPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    if (state == 'solid') {
      // Draw solid container (box)
      canvas.drawRect(
        Rect.fromLTWH(40, 30, 220, 150),
        paint,
      );
    } else if (state == 'liquid') {
      // Draw liquid container (beaker shape)
      final path = Path();
      path.moveTo(40, 30);
      path.lineTo(40, 170);
      path.lineTo(260, 170);
      path.lineTo(260, 30);
      canvas.drawPath(path, paint);

      // Water level
      final waterPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: 0.1);
      canvas.drawRect(
        Rect.fromLTWH(42, 50, 216, 118),
        waterPaint,
      );
    } else {
      // Draw gas container (larger)
      canvas.drawRect(
        Rect.fromLTWH(30, 20, 280, 180),
        paint,
      );
    }

    // State label
    final textPainter = TextPainter(
      text: TextSpan(
        text: state.toUpperCase(),
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 10,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 8));
  }

  @override
  bool shouldRepaint(covariant ContainerPainter oldDelegate) {
    return oldDelegate.state != state;
  }
}
