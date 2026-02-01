import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class ThermalSimulation extends StatefulWidget {
  const ThermalSimulation({super.key});

  @override
  State<ThermalSimulation> createState() => _ThermalSimulationState();
}

class _ThermalSimulationState extends State<ThermalSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _temperature = 20; // °C
  double _energy = 0; // J added
  final double _mass = 1.0; // kg
  String _substance = 'water';
  bool _isHeating = false;
  bool _isCooling = false;
  bool _hasSpokenIntro = false;
  String _lastState = 'liquid';

  // State tracking
  String _currentState = 'liquid';
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  final List<DataPoint> _heatingCurveData = [];

  // Substance properties
  static const Map<String, SubstanceProperties> _substances = {
    'water': SubstanceProperties(
      meltingPoint: 0,
      boilingPoint: 100,
      specificHeatSolid: 2100,
      specificHeatLiquid: 4200,
      specificHeatGas: 2000,
      latentHeatFusion: 334000,
      latentHeatVaporization: 2260000,
    ),
    'ethanol': SubstanceProperties(
      meltingPoint: -114,
      boilingPoint: 78,
      specificHeatSolid: 1200,
      specificHeatLiquid: 2440,
      specificHeatGas: 1430,
      latentHeatFusion: 108000,
      latentHeatVaporization: 846000,
    ),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateSimulation);
    _initParticles();
    _controller.repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Thermal Physics Simulation. This demonstrates how substances change state when heated or cooled. '
          'Press and hold the HEAT button to add energy, or COOL to remove it. '
          'Watch the heating curve show how temperature changes. During state changes, temperature stays constant '
          'as energy goes into breaking molecular bonds - this is called latent heat.',
          force: true,
        );
      }
    });
  }

  void _initParticles() {
    _particles.clear();
    for (int i = 0; i < 40; i++) {
      _particles.add(Particle(
        x: 50 + _random.nextDouble() * 180,
        y: 50 + _random.nextDouble() * 100,
        vx: 0,
        vy: 0,
        baseX: 0,
        baseY: 0,
      ));
    }
    _arrangeParticlesForState();
  }

  void _arrangeParticlesForState() {
    if (_currentState == 'solid') {
      int cols = 8;
      for (int i = 0; i < _particles.length; i++) {
        _particles[i].baseX = 60 + (i % cols) * 22.0;
        _particles[i].baseY = 50 + (i ~/ cols) * 22.0;
        _particles[i].x = _particles[i].baseX;
        _particles[i].y = _particles[i].baseY;
        _particles[i].vx = 0;
        _particles[i].vy = 0;
      }
    }
  }

  void _updateSimulation() {
    final props = _substances[_substance]!;

    setState(() {
      // Apply heating or cooling
      if (_isHeating) {
        _addEnergy(500); // Add energy per frame
      } else if (_isCooling) {
        _addEnergy(-500);
      }

      // Update particles based on state
      _updateParticles();

      // Record data for heating curve
      if (_isHeating && _heatingCurveData.length < 500) {
        _heatingCurveData.add(DataPoint(_energy / 1000, _temperature));
      }

      // Announce state changes
      if (_currentState != _lastState) {
        _speakStateChange(_currentState);
        _lastState = _currentState;
      }
    });
  }

  void _speakStateChange(String state) {
    switch (state) {
      case 'solid':
        speakSimulation(
          'The substance is now a solid. Particles are locked in fixed positions and can only vibrate.',
          force: true,
        );
        break;
      case 'melting':
        speakSimulation(
          'Melting has begun! The temperature stays constant at the melting point while energy breaks bonds between particles. '
          'This energy is called the latent heat of fusion.',
          force: true,
        );
        break;
      case 'liquid':
        speakSimulation(
          'The substance is now a liquid. Particles can move past each other but are still close together.',
          force: true,
        );
        break;
      case 'boiling':
        speakSimulation(
          'Boiling has begun! The temperature stays constant at the boiling point while energy breaks more bonds. '
          'This energy is called the latent heat of vaporization.',
          force: true,
        );
        break;
      case 'gas':
        speakSimulation(
          'The substance is now a gas. Particles move quickly and spread out to fill the container.',
          force: true,
        );
        break;
    }
  }

  void _addEnergy(double deltaEnergy) {
    final props = _substances[_substance]!;
    _energy += deltaEnergy;
    _energy = _energy.clamp(0, 5000000);

    // Calculate temperature based on energy and state changes
    double remainingEnergy = _energy;

    // Heating solid to melting point
    if (remainingEnergy <= _mass * props.specificHeatSolid * (props.meltingPoint - (-50))) {
      _temperature = -50 + remainingEnergy / (_mass * props.specificHeatSolid);
      _currentState = 'solid';
      return;
    }
    remainingEnergy -= _mass * props.specificHeatSolid * (props.meltingPoint - (-50));

    // Melting (latent heat of fusion)
    if (remainingEnergy <= _mass * props.latentHeatFusion) {
      _temperature = props.meltingPoint.toDouble();
      _currentState = 'melting';
      return;
    }
    remainingEnergy -= _mass * props.latentHeatFusion;

    // Heating liquid to boiling point
    if (remainingEnergy <= _mass * props.specificHeatLiquid * (props.boilingPoint - props.meltingPoint)) {
      _temperature = props.meltingPoint + remainingEnergy / (_mass * props.specificHeatLiquid);
      _currentState = 'liquid';
      return;
    }
    remainingEnergy -= _mass * props.specificHeatLiquid * (props.boilingPoint - props.meltingPoint);

    // Boiling (latent heat of vaporization)
    if (remainingEnergy <= _mass * props.latentHeatVaporization) {
      _temperature = props.boilingPoint.toDouble();
      _currentState = 'boiling';
      return;
    }
    remainingEnergy -= _mass * props.latentHeatVaporization;

    // Heating gas
    _temperature = props.boilingPoint + remainingEnergy / (_mass * props.specificHeatGas);
    _temperature = _temperature.clamp(-50, 200);
    _currentState = 'gas';
  }

  void _updateParticles() {
    final vibrationStrength = (_temperature + 50) / 100;

    for (var particle in _particles) {
      if (_currentState == 'solid') {
        // Vibrate in place
        particle.x = particle.baseX + math.sin(_controller.value * math.pi * 10 + particle.phase) * vibrationStrength * 3;
        particle.y = particle.baseY + math.cos(_controller.value * math.pi * 10 + particle.phase) * vibrationStrength * 3;
      } else if (_currentState == 'melting') {
        // Transition - some particles start moving
        if (_random.nextDouble() < 0.02) {
          particle.vx = (_random.nextDouble() - 0.5) * vibrationStrength;
          particle.vy = (_random.nextDouble() - 0.5) * vibrationStrength;
        }
        particle.x += particle.vx;
        particle.y += particle.vy;
        _applyBoundaries(particle, 240, 150);
      } else if (_currentState == 'liquid' || _currentState == 'boiling') {
        // Move freely but stay close
        particle.vx += (_random.nextDouble() - 0.5) * vibrationStrength * 0.3;
        particle.vy += (_random.nextDouble() - 0.5) * vibrationStrength * 0.3;
        particle.vx *= 0.95;
        particle.vy *= 0.95;
        particle.x += particle.vx;
        particle.y += particle.vy;
        _applyBoundaries(particle, _currentState == 'boiling' ? 260 : 240, _currentState == 'boiling' ? 160 : 140);
      } else if (_currentState == 'gas') {
        // Move fast, fill container
        particle.vx += (_random.nextDouble() - 0.5) * vibrationStrength * 0.5;
        particle.vy += (_random.nextDouble() - 0.5) * vibrationStrength * 0.5;
        particle.vx *= 0.98;
        particle.vy *= 0.98;
        particle.x += particle.vx;
        particle.y += particle.vy;
        _applyBoundaries(particle, 280, 180);
      }
    }
  }

  void _applyBoundaries(Particle particle, double maxX, double maxY) {
    if (particle.x < 40) {
      particle.x = 40;
      particle.vx = -particle.vx * 0.8;
    }
    if (particle.x > maxX) {
      particle.x = maxX;
      particle.vx = -particle.vx * 0.8;
    }
    if (particle.y < 30) {
      particle.y = 30;
      particle.vy = -particle.vy * 0.8;
    }
    if (particle.y > maxY) {
      particle.y = maxY;
      particle.vy = -particle.vy * 0.8;
    }
  }

  void _reset() {
    setState(() {
      _temperature = 20;
      _energy = 0;
      _currentState = 'liquid';
      _lastState = 'liquid';
      _isHeating = false;
      _isCooling = false;
      _heatingCurveData.clear();
      _initParticles();
    });
    speakSimulation('Simulation reset. The substance starts as a liquid at room temperature.', force: true);
  }

  void _onSubstanceChanged(String substance) {
    setState(() {
      _substance = substance;
    });
    _reset();

    final props = _substances[substance]!;
    speakSimulation(
      'Substance changed to $substance. Melting point: ${props.meltingPoint} degrees Celsius. '
      'Boiling point: ${props.boilingPoint} degrees Celsius.',
      force: true,
    );
  }

  void _onHeatingStart() {
    setState(() => _isHeating = true);
    speakSimulation('Heating started. Energy is being added to the substance.');
  }

  void _onHeatingStop() {
    setState(() => _isHeating = false);
  }

  void _onCoolingStart() {
    setState(() => _isCooling = true);
    speakSimulation('Cooling started. Energy is being removed from the substance.');
  }

  void _onCoolingStop() {
    setState(() => _isCooling = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final props = _substances[_substance]!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Substance selector
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildTTSToggle(),
                const SizedBox(width: 12),
                _buildSubstanceButton('Water', 'water', Colors.blue),
                const SizedBox(width: 12),
                _buildSubstanceButton('Ethanol', 'ethanol', Colors.purple),
              ],
            ),
          ),
          // Particle visualization
          Container(
            height: 220,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              painter: ThermalParticlePainter(
                particles: _particles,
                currentState: _currentState,
                temperature: _temperature,
                isHeating: _isHeating,
                isCooling: _isCooling,
              ),
              size: Size.infinite,
            ),
          ),
          // Temperature and state display
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStateColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _getStateColor()),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoCard('Temperature', '${_temperature.toStringAsFixed(1)}°C', _getTemperatureColor()),
                    _buildInfoCard('State', _getStateLabel(), _getStateColor()),
                    _buildInfoCard('Energy', '${(_energy / 1000).toStringAsFixed(1)} kJ', Colors.orange),
                  ],
                ),
                if (_currentState == 'melting' || _currentState == 'boiling')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _currentState == 'melting'
                          ? 'Latent Heat of Fusion: Temperature stays constant while state changes'
                          : 'Latent Heat of Vaporization: Temperature stays constant while state changes',
                      style: const TextStyle(color: Colors.amber, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
          // Heating curve
          Container(
            height: 120,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Heating Curve',
                  style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: HeatingCurvePainter(
                      dataPoints: _heatingCurveData,
                      meltingPoint: props.meltingPoint.toDouble(),
                      boilingPoint: props.boilingPoint.toDouble(),
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTapDown: (_) => _onHeatingStart(),
                  onTapUp: (_) => _onHeatingStop(),
                  onTapCancel: () => _onHeatingStop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isHeating ? Colors.red : Colors.red.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.whatshot, color: Colors.white),
                        SizedBox(width: 8),
                        Text('HEAT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTapDown: (_) => _onCoolingStart(),
                  onTapUp: (_) => _onCoolingStop(),
                  onTapCancel: () => _onCoolingStop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isCooling ? Colors.blue : Colors.blue.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.ac_unit, color: Colors.white),
                        SizedBox(width: 8),
                        Text('COOL', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: _reset,
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  style: IconButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            ),
          ),
          // Info panel
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Key Equations:', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text(
                  'Energy for temperature change: E = m × c × ΔT\n'
                  'Energy for state change: E = m × L\n'
                  'c = specific heat capacity, L = latent heat',
                  style: TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubstanceButton(String label, String substance, Color color) {
    final isSelected = _substance == substance;
    return GestureDetector(
      onTap: () => _onSubstanceChanged(substance),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Color _getStateColor() {
    switch (_currentState) {
      case 'solid': return Colors.blue;
      case 'melting': return Colors.cyan;
      case 'liquid': return Colors.teal;
      case 'boiling': return Colors.orange;
      case 'gas': return Colors.red;
      default: return Colors.white;
    }
  }

  Color _getTemperatureColor() {
    if (_temperature < 0) return Colors.blue;
    if (_temperature < 50) return Colors.cyan;
    if (_temperature < 100) return Colors.orange;
    return Colors.red;
  }

  String _getStateLabel() {
    switch (_currentState) {
      case 'solid': return 'SOLID';
      case 'melting': return 'MELTING';
      case 'liquid': return 'LIQUID';
      case 'boiling': return 'BOILING';
      case 'gas': return 'GAS';
      default: return '';
    }
  }
}

class SubstanceProperties {
  final int meltingPoint;
  final int boilingPoint;
  final double specificHeatSolid;
  final double specificHeatLiquid;
  final double specificHeatGas;
  final double latentHeatFusion;
  final double latentHeatVaporization;

  const SubstanceProperties({
    required this.meltingPoint,
    required this.boilingPoint,
    required this.specificHeatSolid,
    required this.specificHeatLiquid,
    required this.specificHeatGas,
    required this.latentHeatFusion,
    required this.latentHeatVaporization,
  });
}

class Particle {
  double x, y, vx, vy;
  double baseX, baseY;
  late double phase;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.baseX,
    required this.baseY,
  }) {
    phase = math.Random().nextDouble() * math.pi * 2;
  }
}

class DataPoint {
  final double energy;
  final double temperature;
  DataPoint(this.energy, this.temperature);
}

class ThermalParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final String currentState;
  final double temperature;
  final bool isHeating;
  final bool isCooling;

  ThermalParticlePainter({
    required this.particles,
    required this.currentState,
    required this.temperature,
    required this.isHeating,
    required this.isCooling,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw container (beaker)
    final containerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final beakerPath = Path();
    beakerPath.moveTo(30, 20);
    beakerPath.lineTo(30, 190);
    beakerPath.lineTo(290, 190);
    beakerPath.lineTo(290, 20);
    canvas.drawPath(beakerPath, containerPaint);

    // Draw heat source if heating
    if (isHeating) {
      final flamePaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.7);
      for (int i = 0; i < 5; i++) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(100 + i * 40.0, 200),
            width: 20,
            height: 30,
          ),
          flamePaint,
        );
      }
    }

    // Draw ice if cooling
    if (isCooling) {
      final icePaint = Paint()..color = Colors.lightBlue.withValues(alpha: 0.5);
      canvas.drawRect(Rect.fromLTWH(30, 190, 260, 15), icePaint);
    }

    // Draw particles
    Color particleColor;
    switch (currentState) {
      case 'solid':
        particleColor = Colors.blue;
        break;
      case 'melting':
        particleColor = Colors.cyan;
        break;
      case 'liquid':
        particleColor = Colors.teal;
        break;
      case 'boiling':
        particleColor = Colors.orange;
        break;
      case 'gas':
        particleColor = Colors.red;
        break;
      default:
        particleColor = Colors.white;
    }

    for (var particle in particles) {
      final paint = Paint()..color = particleColor;
      canvas.drawCircle(Offset(particle.x, particle.y), 6, paint);

      // Glow effect for hot particles
      if (temperature > 50) {
        final glowPaint = Paint()
          ..color = particleColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(particle.x, particle.y), 8, glowPaint);
      }
    }

    // State label
    final statePainter = TextPainter(
      text: TextSpan(
        text: currentState.toUpperCase(),
        style: TextStyle(color: particleColor, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    statePainter.layout();
    statePainter.paint(canvas, Offset(size.width / 2 - statePainter.width / 2, 5));
  }

  @override
  bool shouldRepaint(covariant ThermalParticlePainter oldDelegate) => true;
}

class HeatingCurvePainter extends CustomPainter {
  final List<DataPoint> dataPoints;
  final double meltingPoint;
  final double boilingPoint;

  HeatingCurvePainter({
    required this.dataPoints,
    required this.meltingPoint,
    required this.boilingPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    // Draw axes
    canvas.drawLine(Offset(30, 5), Offset(30, size.height - 15), axisPaint);
    canvas.drawLine(Offset(30, size.height - 15), Offset(size.width - 5, size.height - 15), axisPaint);

    // Draw melting and boiling point lines
    final meltY = size.height - 15 - ((meltingPoint + 50) / 250) * (size.height - 25);
    final boilY = size.height - 15 - ((boilingPoint + 50) / 250) * (size.height - 25);

    canvas.drawLine(
      Offset(30, meltY),
      Offset(size.width - 5, meltY),
      Paint()..color = Colors.cyan.withValues(alpha: 0.3)..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(30, boilY),
      Offset(size.width - 5, boilY),
      Paint()..color = Colors.orange.withValues(alpha: 0.3)..strokeWidth = 1,
    );

    // Labels
    final meltLabel = TextPainter(
      text: TextSpan(text: '${meltingPoint.toInt()}°C', style: const TextStyle(color: Colors.cyan, fontSize: 8)),
      textDirection: TextDirection.ltr,
    );
    meltLabel.layout();
    meltLabel.paint(canvas, Offset(5, meltY - 5));

    final boilLabel = TextPainter(
      text: TextSpan(text: '${boilingPoint.toInt()}°C', style: const TextStyle(color: Colors.orange, fontSize: 8)),
      textDirection: TextDirection.ltr,
    );
    boilLabel.layout();
    boilLabel.paint(canvas, Offset(5, boilY - 5));

    // Draw data
    if (dataPoints.isEmpty) return;

    final maxEnergy = dataPoints.isNotEmpty ? dataPoints.last.energy : 1000;

    final dataPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool first = true;

    for (final point in dataPoints) {
      final x = 30 + (point.energy / maxEnergy.clamp(100, 5000)) * (size.width - 40);
      final y = size.height - 15 - ((point.temperature + 50) / 250) * (size.height - 25);

      if (first) {
        path.moveTo(x.clamp(30, size.width - 5), y.clamp(5, size.height - 15));
        first = false;
      } else {
        path.lineTo(x.clamp(30, size.width - 5), y.clamp(5, size.height - 15));
      }
    }

    canvas.drawPath(path, dataPaint);
  }

  @override
  bool shouldRepaint(covariant HeatingCurvePainter oldDelegate) =>
      oldDelegate.dataPoints.length != dataPoints.length;
}
