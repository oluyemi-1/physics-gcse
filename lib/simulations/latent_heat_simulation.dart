import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Latent Heat Simulation demonstrating energy during phase changes
/// Shows how temperature stays constant during melting/boiling
class LatentHeatSimulation extends StatefulWidget {
  const LatentHeatSimulation({super.key});

  @override
  State<LatentHeatSimulation> createState() => _LatentHeatSimulationState();
}

class _LatentHeatSimulationState extends State<LatentHeatSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _currentTemp = -20.0; // °C
  double _energyAdded = 0.0; // kJ
  double _heatingRate = 50.0; // W (J/s scaled)
  bool _isHeating = false;

  String _substance = 'Water';

  // Substance properties
  final Map<String, Map<String, double>> _substances = {
    'Water': {
      'meltingPoint': 0.0,
      'boilingPoint': 100.0,
      'latentFusion': 334.0, // kJ/kg
      'latentVaporization': 2260.0, // kJ/kg
      'specificHeatSolid': 2.1, // kJ/(kg·K)
      'specificHeatLiquid': 4.18,
      'specificHeatGas': 2.0,
    },
    'Ethanol': {
      'meltingPoint': -114.0,
      'boilingPoint': 78.0,
      'latentFusion': 108.0,
      'latentVaporization': 846.0,
      'specificHeatSolid': 2.3,
      'specificHeatLiquid': 2.44,
      'specificHeatGas': 1.4,
    },
    'Iron': {
      'meltingPoint': 1538.0,
      'boilingPoint': 2862.0,
      'latentFusion': 247.0,
      'latentVaporization': 6090.0,
      'specificHeatSolid': 0.45,
      'specificHeatLiquid': 0.82,
      'specificHeatGas': 0.5,
    },
  };

  final double _mass = 1.0; // kg
  double _meltingProgress = 0.0; // 0 to 1
  double _boilingProgress = 0.0; // 0 to 1

  String get _currentPhase {
    final props = _substances[_substance]!;
    if (_currentTemp < props['meltingPoint']!) return 'Solid';
    if (_currentTemp == props['meltingPoint']! && _meltingProgress < 1.0) return 'Melting';
    if (_currentTemp < props['boilingPoint']!) return 'Liquid';
    if (_currentTemp == props['boilingPoint']! && _boilingProgress < 1.0) return 'Boiling';
    return 'Gas';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updateHeating);
    _resetSimulation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Latent Heat Simulation. Observe how energy is absorbed during phase changes '
        'without temperature increase. The flat sections on the heating curve show '
        'latent heat of fusion during melting, and latent heat of vaporization during boiling.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetSimulation() {
    final props = _substances[_substance]!;
    setState(() {
      _currentTemp = props['meltingPoint']! - 20;
      _energyAdded = 0;
      _meltingProgress = 0;
      _boilingProgress = 0;
      _isHeating = false;
    });
  }

  void _updateHeating() {
    if (!_isHeating) return;

    final props = _substances[_substance]!;
    final dt = 1 / 60; // Time step
    final energyIncrement = _heatingRate * dt / 1000; // Convert to kJ

    setState(() {
      _energyAdded += energyIncrement;

      if (_currentTemp < props['meltingPoint']!) {
        // Heating solid
        final specificHeat = props['specificHeatSolid']!;
        _currentTemp += energyIncrement / (_mass * specificHeat);
        if (_currentTemp >= props['meltingPoint']!) {
          _currentTemp = props['meltingPoint']!;
        }
      } else if (_currentTemp == props['meltingPoint']! && _meltingProgress < 1.0) {
        // Phase change: melting
        final latentFusion = props['latentFusion']!;
        _meltingProgress += energyIncrement / (_mass * latentFusion);
        if (_meltingProgress >= 1.0) {
          _meltingProgress = 1.0;
          _currentTemp = props['meltingPoint']! + 0.01;
        }
      } else if (_currentTemp < props['boilingPoint']!) {
        // Heating liquid
        final specificHeat = props['specificHeatLiquid']!;
        _currentTemp += energyIncrement / (_mass * specificHeat);
        if (_currentTemp >= props['boilingPoint']!) {
          _currentTemp = props['boilingPoint']!;
        }
      } else if (_currentTemp == props['boilingPoint']! && _boilingProgress < 1.0) {
        // Phase change: boiling
        final latentVaporization = props['latentVaporization']!;
        _boilingProgress += energyIncrement / (_mass * latentVaporization);
        if (_boilingProgress >= 1.0) {
          _boilingProgress = 1.0;
          _currentTemp = props['boilingPoint']! + 0.01;
        }
      } else {
        // Heating gas
        final specificHeat = props['specificHeatGas']!;
        _currentTemp += energyIncrement / (_mass * specificHeat);

        // Cap at reasonable temperature
        if (_currentTemp > props['boilingPoint']! + 100) {
          _currentTemp = props['boilingPoint']! + 100;
          _isHeating = false;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latent Heat'),
        backgroundColor: Colors.deepOrange,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepOrange.shade800, Colors.grey.shade900],
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
    final props = _substances[_substance]!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _substance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPhaseColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentPhase,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Temperature', '${_currentTemp.toStringAsFixed(1)} °C'),
              _buildInfoItem('Energy Added', '${_energyAdded.toStringAsFixed(1)} kJ'),
              _buildInfoItem('Mass', '${_mass.toStringAsFixed(1)} kg'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Melting Pt', '${props['meltingPoint']!.toStringAsFixed(0)} °C'),
              _buildInfoItem('Boiling Pt', '${props['boilingPoint']!.toStringAsFixed(0)} °C'),
              _buildInfoItem('Lf', '${props['latentFusion']!.toStringAsFixed(0)} kJ/kg'),
              _buildInfoItem('Lv', '${props['latentVaporization']!.toStringAsFixed(0)} kJ/kg'),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPhaseColor() {
    switch (_currentPhase) {
      case 'Solid':
        return Colors.blue.shade700;
      case 'Melting':
        return Colors.cyan.shade600;
      case 'Liquid':
        return Colors.blue.shade400;
      case 'Boiling':
        return Colors.orange.shade600;
      case 'Gas':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
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
        final props = _substances[_substance]!;

        return Row(
          children: [
            // Substance visualization
            Expanded(
              flex: 2,
              child: CustomPaint(
                size: Size(constraints.maxWidth * 0.6, constraints.maxHeight),
                painter: _SubstancePainter(
                  phase: _currentPhase,
                  meltingProgress: _meltingProgress,
                  boilingProgress: _boilingProgress,
                  temperature: _currentTemp,
                  isHeating: _isHeating,
                ),
              ),
            ),
            // Heating curve graph
            Expanded(
              flex: 3,
              child: CustomPaint(
                size: Size(constraints.maxWidth * 0.4, constraints.maxHeight),
                painter: _HeatingCurvePainter(
                  currentTemp: _currentTemp,
                  energyAdded: _energyAdded,
                  meltingPoint: props['meltingPoint']!,
                  boilingPoint: props['boilingPoint']!,
                  meltingProgress: _meltingProgress,
                  boilingProgress: _boilingProgress,
                ),
              ),
            ),
          ],
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
          // Substance selector
          Wrap(
            spacing: 8,
            children: _substances.keys.map((substance) {
              return ChoiceChip(
                label: Text(substance, style: const TextStyle(fontSize: 12)),
                selected: _substance == substance,
                selectedColor: Colors.deepOrange.shade400,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _substance = substance);
                    _resetSimulation();
                    speakSimulation(
                      '$substance selected. Melting point: ${_substances[substance]!['meltingPoint']!.toStringAsFixed(0)} degrees, '
                      'Boiling point: ${_substances[substance]!['boilingPoint']!.toStringAsFixed(0)} degrees.',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Heating rate slider
          Row(
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              const Text('Heating Rate:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _heatingRate,
                  min: 10,
                  max: 200,
                  activeColor: Colors.deepOrange,
                  onChanged: (value) => setState(() => _heatingRate = value),
                ),
              ),
              Text('${_heatingRate.toStringAsFixed(0)} W', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isHeating = !_isHeating);
                  if (_isHeating) {
                    speakSimulation('Heating started. Watch the temperature and phase changes.');
                  }
                },
                icon: Icon(_isHeating ? Icons.pause : Icons.play_arrow),
                label: Text(_isHeating ? 'Pause' : 'Heat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isHeating ? Colors.orange : Colors.green,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetSimulation,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Key equations
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepOrange.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Q = mcΔT (heating)  |  Q = mL (phase change)  |  Lf = latent heat of fusion  |  Lv = latent heat of vaporization',
              style: TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubstancePainter extends CustomPainter {
  final String phase;
  final double meltingProgress;
  final double boilingProgress;
  final double temperature;
  final bool isHeating;

  _SubstancePainter({
    required this.phase,
    required this.meltingProgress,
    required this.boilingProgress,
    required this.temperature,
    required this.isHeating,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw container/beaker
    _drawBeaker(canvas, centerX, centerY, size);

    // Draw substance based on phase
    _drawSubstance(canvas, centerX, centerY, size);

    // Draw heat source if heating
    if (isHeating) {
      _drawHeatSource(canvas, centerX, size);
    }
  }

  void _drawBeaker(Canvas canvas, double centerX, double centerY, Size size) {
    final beakerPath = Path();
    final beakerWidth = 100.0;
    final beakerHeight = 120.0;
    final left = centerX - beakerWidth / 2;
    final right = centerX + beakerWidth / 2;
    final top = centerY - beakerHeight / 2;
    final bottom = centerY + beakerHeight / 2;

    beakerPath.moveTo(left, top);
    beakerPath.lineTo(left, bottom);
    beakerPath.lineTo(right, bottom);
    beakerPath.lineTo(right, top);

    final beakerPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(beakerPath, beakerPaint);
  }

  void _drawSubstance(Canvas canvas, double centerX, double centerY, Size size) {
    final beakerWidth = 100.0;
    final beakerHeight = 120.0;
    final left = centerX - beakerWidth / 2 + 5;
    final right = centerX + beakerWidth / 2 - 5;
    final bottom = centerY + beakerHeight / 2 - 5;
    final fillHeight = beakerHeight - 20;

    switch (phase) {
      case 'Solid':
        // Draw solid crystals
        final solidPaint = Paint()..color = Colors.lightBlue.shade200;
        canvas.drawRect(
          Rect.fromLTRB(left, bottom - fillHeight, right, bottom),
          solidPaint,
        );
        // Crystal pattern
        final crystalPaint = Paint()
          ..color = Colors.lightBlue.shade100
          ..strokeWidth = 1;
        for (var i = 0; i < 5; i++) {
          for (var j = 0; j < 4; j++) {
            canvas.drawLine(
              Offset(left + i * 20, bottom - j * 25 - 10),
              Offset(left + i * 20 + 15, bottom - j * 25 - 20),
              crystalPaint,
            );
          }
        }
        break;

      case 'Melting':
        // Partial solid, partial liquid
        final solidHeight = fillHeight * (1 - meltingProgress);
        final liquidHeight = fillHeight * meltingProgress;

        // Liquid
        final liquidPaint = Paint()..color = Colors.blue.shade400;
        canvas.drawRect(
          Rect.fromLTRB(left, bottom - liquidHeight, right, bottom),
          liquidPaint,
        );

        // Remaining solid
        final solidPaint = Paint()..color = Colors.lightBlue.shade200;
        canvas.drawRect(
          Rect.fromLTRB(left, bottom - liquidHeight - solidHeight, right, bottom - liquidHeight),
          solidPaint,
        );
        break;

      case 'Liquid':
        // Draw liquid with slight wave motion
        final liquidPaint = Paint()..color = Colors.blue.shade400;
        canvas.drawRect(
          Rect.fromLTRB(left, bottom - fillHeight, right, bottom),
          liquidPaint,
        );
        break;

      case 'Boiling':
        // Liquid with bubbles
        final liquidPaint = Paint()..color = Colors.blue.shade400;
        canvas.drawRect(
          Rect.fromLTRB(left, bottom - fillHeight * (1 - boilingProgress * 0.3), right, bottom),
          liquidPaint,
        );

        // Bubbles
        final bubblePaint = Paint()..color = Colors.white54;
        final random = math.Random(42);
        for (var i = 0; i < 10; i++) {
          final bx = left + random.nextDouble() * (right - left);
          final by = bottom - random.nextDouble() * fillHeight * 0.8;
          canvas.drawCircle(Offset(bx, by), 3 + random.nextDouble() * 5, bubblePaint);
        }

        // Steam
        _drawSteam(canvas, centerX, bottom - fillHeight);
        break;

      case 'Gas':
        // Draw gas particles
        _drawGasParticles(canvas, centerX, centerY, beakerWidth, beakerHeight);
        break;
    }
  }

  void _drawSteam(Canvas canvas, double centerX, double topY) {
    final steamPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 5; i++) {
      final path = Path();
      final startX = centerX - 30 + i * 15;
      path.moveTo(startX, topY);
      path.quadraticBezierTo(
        startX + 5, topY - 20,
        startX - 5, topY - 40,
      );
      path.quadraticBezierTo(
        startX + 5, topY - 60,
        startX, topY - 80,
      );
      canvas.drawPath(path, steamPaint);
    }
  }

  void _drawGasParticles(Canvas canvas, double centerX, double centerY, double width, double height) {
    final particlePaint = Paint()..color = Colors.white38;
    final random = math.Random(42);

    for (var i = 0; i < 30; i++) {
      final px = centerX - width / 2 + random.nextDouble() * width;
      final py = centerY - height / 2 + random.nextDouble() * height;
      canvas.drawCircle(Offset(px, py), 3, particlePaint);
    }
  }

  void _drawHeatSource(Canvas canvas, double centerX, Size size) {
    final flameY = size.height / 2 + 80;

    // Draw flames
    for (var i = 0; i < 5; i++) {
      final flamePath = Path();
      final flameX = centerX - 30 + i * 15;
      flamePath.moveTo(flameX, flameY);
      flamePath.quadraticBezierTo(
        flameX - 5, flameY - 15,
        flameX, flameY - 30,
      );
      flamePath.quadraticBezierTo(
        flameX + 5, flameY - 15,
        flameX, flameY,
      );

      final flamePaint = Paint()
        ..color = i % 2 == 0 ? Colors.orange : Colors.yellow
        ..style = PaintingStyle.fill;
      canvas.drawPath(flamePath, flamePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SubstancePainter oldDelegate) {
    return oldDelegate.phase != phase ||
           oldDelegate.meltingProgress != meltingProgress ||
           oldDelegate.boilingProgress != boilingProgress;
  }
}

class _HeatingCurvePainter extends CustomPainter {
  final double currentTemp;
  final double energyAdded;
  final double meltingPoint;
  final double boilingPoint;
  final double meltingProgress;
  final double boilingProgress;

  _HeatingCurvePainter({
    required this.currentTemp,
    required this.energyAdded,
    required this.meltingPoint,
    required this.boilingPoint,
    required this.meltingProgress,
    required this.boilingProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final padding = 40.0;
    final graphWidth = size.width - padding * 2;
    final graphHeight = size.height - padding * 2;

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(padding, padding),
      Offset(padding, size.height - padding),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, size.height - padding),
      Offset(size.width - padding, size.height - padding),
      axisPaint,
    );

    // Draw axis labels
    _drawLabel(canvas, 'Temperature (°C)', Offset(10, size.height / 2), true);
    _drawLabel(canvas, 'Energy Added', Offset(size.width / 2, size.height - 10), false);

    // Draw theoretical heating curve
    _drawTheoreticalCurve(canvas, padding, graphWidth, graphHeight, size.height);

    // Draw current point
    _drawCurrentPoint(canvas, padding, graphWidth, graphHeight, size.height);
  }

  void _drawTheoreticalCurve(Canvas canvas, double padding, double graphWidth, double graphHeight, double height) {
    final curvePaint = Paint()
      ..color = Colors.deepOrange.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Simplified heating curve representation
    // Segment 1: Solid heating
    path.moveTo(padding, height - padding - graphHeight * 0.1);
    path.lineTo(padding + graphWidth * 0.15, height - padding - graphHeight * 0.3);

    // Segment 2: Melting (flat)
    path.lineTo(padding + graphWidth * 0.35, height - padding - graphHeight * 0.3);

    // Segment 3: Liquid heating
    path.lineTo(padding + graphWidth * 0.55, height - padding - graphHeight * 0.6);

    // Segment 4: Boiling (flat)
    path.lineTo(padding + graphWidth * 0.85, height - padding - graphHeight * 0.6);

    // Segment 5: Gas heating
    path.lineTo(padding + graphWidth, height - padding - graphHeight * 0.9);

    canvas.drawPath(path, curvePaint);

    // Labels for phase regions
    _drawSmallLabel(canvas, 'Solid', Offset(padding + graphWidth * 0.05, height - padding - graphHeight * 0.15));
    _drawSmallLabel(canvas, 'Melting\n(Lf)', Offset(padding + graphWidth * 0.22, height - padding - graphHeight * 0.35));
    _drawSmallLabel(canvas, 'Liquid', Offset(padding + graphWidth * 0.42, height - padding - graphHeight * 0.45));
    _drawSmallLabel(canvas, 'Boiling\n(Lv)', Offset(padding + graphWidth * 0.67, height - padding - graphHeight * 0.65));
    _drawSmallLabel(canvas, 'Gas', Offset(padding + graphWidth * 0.9, height - padding - graphHeight * 0.8));
  }

  void _drawCurrentPoint(Canvas canvas, double padding, double graphWidth, double graphHeight, double height) {
    // Simplified position calculation
    double x, y;

    final energyScale = energyAdded / 5000; // Normalize to 0-1
    x = padding + energyScale.clamp(0, 1) * graphWidth;

    // Temperature normalized
    final tempRange = boilingPoint + 100 - (meltingPoint - 20);
    final tempNormalized = (currentTemp - (meltingPoint - 20)) / tempRange;
    y = height - padding - tempNormalized.clamp(0, 1) * graphHeight;

    final pointPaint = Paint()..color = Colors.yellow;
    canvas.drawCircle(Offset(x, y), 8, pointPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(x, y), 8, borderPaint);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, bool vertical) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    if (vertical) {
      canvas.save();
      canvas.translate(position.dx, position.dy);
      canvas.rotate(-math.pi / 2);
      textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));
      canvas.restore();
    } else {
      textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height));
    }
  }

  void _drawSmallLabel(Canvas canvas, String text, Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white38, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _HeatingCurvePainter oldDelegate) {
    return oldDelegate.currentTemp != currentTemp ||
           oldDelegate.energyAdded != energyAdded;
  }
}
