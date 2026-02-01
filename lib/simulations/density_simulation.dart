import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class DensitySimulation extends StatefulWidget {
  const DensitySimulation({super.key});

  @override
  State<DensitySimulation> createState() => _DensitySimulationState();
}

class _DensitySimulationState extends State<DensitySimulation>
    with SimulationTTSMixin {
  double _mass = 100.0; // grams
  double _volume = 50.0; // cm³
  bool _hasSpokenIntro = false;
  bool _showWaterComparison = true;

  String _selectedMaterial = 'Custom';

  final Map<String, Map<String, double>> _materials = {
    'Custom': {'density': 0},
    'Gold': {'density': 19.3, 'mass': 193, 'volume': 10},
    'Iron': {'density': 7.87, 'mass': 78.7, 'volume': 10},
    'Aluminium': {'density': 2.7, 'mass': 27, 'volume': 10},
    'Water': {'density': 1.0, 'mass': 100, 'volume': 100},
    'Ice': {'density': 0.92, 'mass': 92, 'volume': 100},
    'Wood (Oak)': {'density': 0.75, 'mass': 75, 'volume': 100},
    'Cork': {'density': 0.24, 'mass': 24, 'volume': 100},
    'Air': {'density': 0.0012, 'mass': 0.12, 'volume': 100},
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Density simulation! '
          'Density is mass per unit volume, measured in kilograms per cubic metre or grams per cubic centimetre. '
          'Objects with density less than water will float. Objects denser than water will sink. '
          'Use the formula: density equals mass divided by volume.',
          force: true,
        );
      }
    });
  }

  double _getDensity() {
    if (_selectedMaterial != 'Custom') {
      return _materials[_selectedMaterial]!['density']!;
    }
    return _mass / _volume;
  }

  bool _willFloat() {
    return _getDensity() < 1.0; // Less than water density
  }

  void _onMaterialChanged(String? material) {
    if (material == null) return;
    setState(() {
      _selectedMaterial = material;
      if (material != 'Custom') {
        _mass = _materials[material]!['mass']!;
        _volume = _materials[material]!['volume']!;
      }
    });

    final density = _getDensity();
    final floatSink = density < 1.0 ? 'floats in' : 'sinks in';
    speakSimulation(
      '$material selected. Density: ${density.toStringAsFixed(3)} grams per cubic centimetre. '
      'This material $floatSink water.',
      force: true,
    );
  }

  void _onMassChanged(double value) {
    setState(() {
      _mass = value;
      _selectedMaterial = 'Custom';
    });
  }

  void _onVolumeChanged(double value) {
    setState(() {
      _volume = value;
      _selectedMaterial = 'Custom';
    });
  }

  @override
  Widget build(BuildContext context) {
    final density = _getDensity();
    final willFloat = _willFloat();

    return Column(
      children: [
        // Density visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade700),
            ),
            child: CustomPaint(
              painter: _DensityPainter(
                mass: _mass,
                volume: _volume,
                density: density,
                willFloat: willFloat,
                showWaterComparison: _showWaterComparison,
                materialName: _selectedMaterial,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Mass',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${_mass.toStringAsFixed(1)} g',
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Volume',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${_volume.toStringAsFixed(1)} cm³',
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Density',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${density.toStringAsFixed(3)} g/cm³',
                        style: const TextStyle(
                            color: Colors.cyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    willFloat ? Icons.arrow_upward : Icons.arrow_downward,
                    color: willFloat ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    willFloat ? 'FLOATS in water' : 'SINKS in water',
                    style: TextStyle(
                      color: willFloat ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'ρ = m / V',
                style: TextStyle(
                    color: Colors.white70, fontFamily: 'monospace', fontSize: 14),
              ),
            ],
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Material selector
                  Row(
                    children: [
                      const Text('Material: ',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedMaterial,
                          dropdownColor: Colors.grey[800],
                          isExpanded: true,
                          items: _materials.keys.map((material) {
                            return DropdownMenuItem(
                              value: material,
                              child: Text(material,
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }).toList(),
                          onChanged: _onMaterialChanged,
                        ),
                      ),
                    ],
                  ),

                  // Mass slider
                  Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text('Mass:',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _mass.clamp(1, 500),
                          min: 1,
                          max: 500,
                          onChanged: _onMassChanged,
                          activeColor: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  // Volume slider
                  Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text('Volume:',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _volume.clamp(10, 200),
                          min: 10,
                          max: 200,
                          onChanged: _onVolumeChanged,
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
                            value: _showWaterComparison,
                            onChanged: (v) =>
                                setState(() => _showWaterComparison = v ?? true),
                            activeColor: Colors.blue,
                          ),
                          const Text('Water test',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                      buildTTSToggle(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DensityPainter extends CustomPainter {
  final double mass;
  final double volume;
  final double density;
  final bool willFloat;
  final bool showWaterComparison;
  final String materialName;

  _DensityPainter({
    required this.mass,
    required this.volume,
    required this.density,
    required this.willFloat,
    required this.showWaterComparison,
    required this.materialName,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (showWaterComparison) {
      _drawWaterTest(canvas, size);
    } else {
      _drawMassVolumeDiagram(canvas, size);
    }
  }

  void _drawWaterTest(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Draw beaker
    final beakerPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final beakerLeft = centerX - 80;
    final beakerRight = centerX + 80;
    final beakerTop = 40.0;
    final beakerBottom = size.height - 40;
    final waterTop = beakerTop + 40;

    // Beaker outline
    canvas.drawLine(Offset(beakerLeft, beakerTop), Offset(beakerLeft, beakerBottom), beakerPaint);
    canvas.drawLine(Offset(beakerRight, beakerTop), Offset(beakerRight, beakerBottom), beakerPaint);
    canvas.drawLine(Offset(beakerLeft, beakerBottom), Offset(beakerRight, beakerBottom), beakerPaint);

    // Water
    final waterPaint = Paint()..color = Colors.blue.withValues(alpha: 0.4);
    canvas.drawRect(
      Rect.fromLTRB(beakerLeft + 3, waterTop, beakerRight - 3, beakerBottom - 3),
      waterPaint,
    );

    // Water surface line
    final surfacePaint = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 2;
    canvas.drawLine(Offset(beakerLeft + 3, waterTop), Offset(beakerRight - 3, waterTop), surfacePaint);

    // Draw object
    final objectSize = math.sqrt(volume) * 3;
    final objectY = willFloat
        ? waterTop - objectSize * 0.3 // Floating - partly above water
        : beakerBottom - objectSize - 10; // Sinking - at bottom

    final objectPaint = Paint()..color = _getMaterialColor();
    final objectRect = Rect.fromCenter(
      center: Offset(centerX, objectY + objectSize / 2),
      width: objectSize,
      height: objectSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(objectRect, const Radius.circular(5)),
      objectPaint,
    );

    // Draw density comparison bar
    _drawDensityBar(canvas, size);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: materialName,
      style: const TextStyle(color: Colors.white, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, objectY + objectSize + 5));

    textPainter.text = const TextSpan(
      text: 'Water (ρ = 1.0 g/cm³)',
      style: TextStyle(color: Colors.blue, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(beakerRight + 10, waterTop + 20));
  }

  void _drawMassVolumeDiagram(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw cube representing volume
    final cubeSize = math.sqrt(volume) * 4;

    // 3D cube effect
    final cubePaint = Paint()..color = _getMaterialColor();

    // Front face
    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX, centerY), width: cubeSize, height: cubeSize),
      cubePaint,
    );

    // Top face (darker)
    final topPath = Path()
      ..moveTo(centerX - cubeSize / 2, centerY - cubeSize / 2)
      ..lineTo(centerX - cubeSize / 2 + 20, centerY - cubeSize / 2 - 15)
      ..lineTo(centerX + cubeSize / 2 + 20, centerY - cubeSize / 2 - 15)
      ..lineTo(centerX + cubeSize / 2, centerY - cubeSize / 2)
      ..close();
    canvas.drawPath(topPath, cubePaint..color = _getMaterialColor().withValues(alpha: 0.7));

    // Right face (darker)
    final rightPath = Path()
      ..moveTo(centerX + cubeSize / 2, centerY - cubeSize / 2)
      ..lineTo(centerX + cubeSize / 2 + 20, centerY - cubeSize / 2 - 15)
      ..lineTo(centerX + cubeSize / 2 + 20, centerY + cubeSize / 2 - 15)
      ..lineTo(centerX + cubeSize / 2, centerY + cubeSize / 2)
      ..close();
    canvas.drawPath(rightPath, cubePaint..color = _getMaterialColor().withValues(alpha: 0.5));

    // Mass indicator (particles inside)
    final particlePaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    final particleCount = (mass / 20).round().clamp(1, 25);
    final random = math.Random(42);

    for (int i = 0; i < particleCount; i++) {
      final px = centerX - cubeSize / 2 + 10 + random.nextDouble() * (cubeSize - 20);
      final py = centerY - cubeSize / 2 + 10 + random.nextDouble() * (cubeSize - 20);
      canvas.drawCircle(Offset(px, py), 4, particlePaint);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'V = ${volume.toStringAsFixed(1)} cm³',
      style: const TextStyle(color: Colors.green, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + cubeSize / 2 + 30, centerY));

    textPainter.text = TextSpan(
      text: 'm = ${mass.toStringAsFixed(1)} g',
      style: const TextStyle(color: Colors.red, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - cubeSize / 2 - 80, centerY));
  }

  void _drawDensityBar(Canvas canvas, Size size) {
    final barLeft = 20.0;
    final barRight = 60.0;
    final barTop = 60.0;
    final barBottom = size.height - 60;
    final barHeight = barBottom - barTop;

    // Background
    final bgPaint = Paint()..color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromLTRB(barLeft, barTop, barRight, barBottom), bgPaint);

    // Gradient for density scale
    final gradientPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.red, Colors.yellow, Colors.green],
      ).createShader(Rect.fromLTRB(barLeft, barTop, barRight, barBottom));
    canvas.drawRect(Rect.fromLTRB(barLeft, barTop, barRight, barBottom), gradientPaint);

    // Water line (density = 1.0)
    final waterY = barTop + barHeight * 0.5; // Assuming scale 0-2
    final waterLinePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;
    canvas.drawLine(Offset(barLeft - 5, waterY), Offset(barRight + 5, waterY), waterLinePaint);

    // Current density marker
    final densityY = barTop + barHeight * (1 - density.clamp(0, 2) / 2);
    final markerPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(barLeft - 8, densityY), Offset(barRight + 8, densityY), markerPaint);

    // Arrow
    final arrowPath = Path()
      ..moveTo(barRight + 10, densityY)
      ..lineTo(barRight + 18, densityY - 5)
      ..lineTo(barRight + 18, densityY + 5)
      ..close();
    canvas.drawPath(arrowPath, markerPaint..style = PaintingStyle.fill);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: '2.0',
      style: TextStyle(color: Colors.white54, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(barLeft, barTop - 12));

    textPainter.text = const TextSpan(
      text: '1.0',
      style: TextStyle(color: Colors.blue, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(barLeft, waterY - 5));

    textPainter.text = const TextSpan(
      text: '0',
      style: TextStyle(color: Colors.white54, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(barLeft + 5, barBottom + 2));
  }

  Color _getMaterialColor() {
    switch (materialName) {
      case 'Gold':
        return Colors.amber;
      case 'Iron':
        return Colors.grey;
      case 'Aluminium':
        return Colors.grey.shade400;
      case 'Water':
        return Colors.blue.shade300;
      case 'Ice':
        return Colors.lightBlue.shade100;
      case 'Wood (Oak)':
        return Colors.brown;
      case 'Cork':
        return Colors.brown.shade300;
      case 'Air':
        return Colors.white.withValues(alpha: 0.2);
      default:
        // Custom - color based on density
        if (density < 1) return Colors.green;
        if (density < 5) return Colors.orange;
        return Colors.red;
    }
  }

  @override
  bool shouldRepaint(covariant _DensityPainter oldDelegate) {
    return mass != oldDelegate.mass ||
        volume != oldDelegate.volume ||
        showWaterComparison != oldDelegate.showWaterComparison;
  }
}
