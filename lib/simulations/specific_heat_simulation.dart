import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class SpecificHeatSimulation extends StatefulWidget {
  const SpecificHeatSimulation({super.key});

  @override
  State<SpecificHeatSimulation> createState() => _SpecificHeatSimulationState();
}

class _SpecificHeatSimulationState extends State<SpecificHeatSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  String _selectedMaterial = 'Water';
  double _mass = 1.0; // kg
  final double _initialTemp = 20.0; // °C
  double _finalTemp = 20.0; // °C
  final double _targetTemp = 100.0; // °C
  final double _power = 1000.0; // W (heater power)
  bool _isHeating = false;
  bool _hasSpokenIntro = false;
  double _energySupplied = 0.0;

  final Map<String, Map<String, dynamic>> _materials = {
    'Water': {'shc': 4200.0, 'color': Colors.blue},
    'Copper': {'shc': 385.0, 'color': Colors.orange},
    'Aluminium': {'shc': 900.0, 'color': Colors.grey},
    'Iron': {'shc': 450.0, 'color': Colors.brown},
    'Oil': {'shc': 2000.0, 'color': Colors.amber},
    'Glass': {'shc': 840.0, 'color': Colors.teal},
  };

  double get _specificHeatCapacity => _materials[_selectedMaterial]!['shc'] as double;
  Color get _materialColor => _materials[_selectedMaterial]!['color'] as Color;

  double get _energyRequired => _mass * _specificHeatCapacity * (_targetTemp - _initialTemp);
  double get _timeRequired => _energyRequired / _power;

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
          'Welcome to the Specific Heat Capacity simulation! '
          'Specific heat capacity is the energy needed to raise 1 kilogram of a substance by 1 degree Celsius. '
          'Water has a high specific heat capacity of 4200 joules per kilogram per degree Celsius, '
          'which is why it takes a long time to boil. '
          'Compare different materials to see how they heat up at different rates.',
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
    if (!_isHeating) return;

    setState(() {
      // Energy supplied in this frame (power × time)
      final energyThisFrame = _power * 0.016; // 16ms frame
      _energySupplied += energyThisFrame;

      // Calculate temperature rise: ΔT = E / (m × c)
      final tempRise = energyThisFrame / (_mass * _specificHeatCapacity);
      _finalTemp += tempRise;

      // Check if target reached
      if (_finalTemp >= _targetTemp) {
        _finalTemp = _targetTemp;
        _isHeating = false;
        _controller.stop();
        speakSimulation(
          'Target temperature reached! '
          'Total energy supplied was ${_energySupplied.toStringAsFixed(0)} joules. '
          'This matches the formula: Energy equals mass times specific heat capacity times temperature change.',
          force: true,
        );
      }
    });
  }

  void _startHeating() {
    if (_finalTemp >= _targetTemp) return;

    setState(() {
      _isHeating = true;
    });
    _controller.repeat();

    speakSimulation(
      'Heating ${_mass.toStringAsFixed(1)} kilograms of $_selectedMaterial from ${_initialTemp.toStringAsFixed(0)} to ${_targetTemp.toStringAsFixed(0)} degrees. '
      'Specific heat capacity is ${_specificHeatCapacity.toStringAsFixed(0)} joules per kilogram per degree Celsius. '
      'Energy required is ${_energyRequired.toStringAsFixed(0)} joules.',
      force: true,
    );
  }

  void _stopHeating() {
    setState(() {
      _isHeating = false;
    });
    _controller.stop();
  }

  void _reset() {
    setState(() {
      _isHeating = false;
      _finalTemp = _initialTemp;
      _energySupplied = 0.0;
    });
    _controller.stop();
    speakSimulation('Simulation reset.', force: true);
  }

  void _onMaterialChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedMaterial = value;
      _reset();
    });
    speakSimulation(
      '$value selected. Specific heat capacity is ${_materials[value]!['shc'].toStringAsFixed(0)} joules per kilogram per degree Celsius. '
      '${value == 'Water' ? 'Water has the highest specific heat capacity of common substances.' : ''}',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_finalTemp - _initialTemp) / (_targetTemp - _initialTemp);

    return Column(
      children: [
        // Visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _materialColor.withValues(alpha: 0.5)),
            ),
            child: CustomPaint(
              painter: _HeatingPainter(
                materialColor: _materialColor,
                temperature: _finalTemp,
                isHeating: _isHeating,
                progress: progress.clamp(0, 1),
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Data display
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataCard('Temperature', '${_finalTemp.toStringAsFixed(1)}°C', _getTemperatureColor()),
              _buildDataCard('Energy Supplied', '${_energySupplied.toStringAsFixed(0)} J', Colors.orange),
              _buildDataCard('Energy Required', '${_energyRequired.toStringAsFixed(0)} J', Colors.blue),
              _buildDataCard('Time (est)', '${_timeRequired.toStringAsFixed(1)} s', Colors.green),
            ],
          ),
        ),

        // Formula
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text('E = m × c × ΔT', style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16)),
              Text(
                '${_energyRequired.toStringAsFixed(0)} = ${_mass.toStringAsFixed(1)} × ${_specificHeatCapacity.toStringAsFixed(0)} × ${(_targetTemp - _initialTemp).toStringAsFixed(0)}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
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
                // Material selector
                Row(
                  children: [
                    const Text('Material: ', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedMaterial,
                        dropdownColor: Colors.grey[800],
                        isExpanded: true,
                        items: _materials.keys.map((material) {
                          return DropdownMenuItem(
                            value: material,
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _materials[material]!['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('$material (c = ${(_materials[material]!['shc'] as double).toStringAsFixed(0)} J/kg°C)',
                                    style: const TextStyle(color: Colors.white, fontSize: 12)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: _isHeating ? null : _onMaterialChanged,
                      ),
                    ),
                  ],
                ),

                // Mass slider
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Mass:', style: TextStyle(color: Colors.white))),
                    Expanded(
                      child: Slider(
                        value: _mass,
                        min: 0.1,
                        max: 5.0,
                        divisions: 49,
                        onChanged: _isHeating ? null : (v) => setState(() { _mass = v; _reset(); }),
                        activeColor: Colors.cyan,
                      ),
                    ),
                    SizedBox(width: 60, child: Text('${_mass.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white))),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isHeating ? _stopHeating : _startHeating,
                      icon: Icon(_isHeating ? Icons.pause : Icons.local_fire_department),
                      label: Text(_isHeating ? 'Stop' : 'Heat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isHeating ? Colors.orange : Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
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

  Widget _buildDataCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Color _getTemperatureColor() {
    if (_finalTemp < 30) return Colors.blue;
    if (_finalTemp < 50) return Colors.cyan;
    if (_finalTemp < 70) return Colors.yellow;
    if (_finalTemp < 90) return Colors.orange;
    return Colors.red;
  }
}

class _HeatingPainter extends CustomPainter {
  final Color materialColor;
  final double temperature;
  final bool isHeating;
  final double progress;

  _HeatingPainter({
    required this.materialColor,
    required this.temperature,
    required this.isHeating,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw beaker
    _drawBeaker(canvas, centerX, centerY, size);

    // Draw liquid
    _drawLiquid(canvas, centerX, centerY + 20, size);

    // Draw heater
    _drawHeater(canvas, centerX, centerY + 60, size);

    // Draw thermometer
    _drawThermometer(canvas, centerX + 80, centerY, temperature);

    // Draw temperature label
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: '${temperature.toStringAsFixed(1)}°C',
      style: TextStyle(
        color: _getTemperatureColor(),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, 20));

    // Draw energy flow arrows if heating
    if (isHeating) {
      _drawEnergyFlow(canvas, centerX, centerY + 40);
    }
  }

  void _drawBeaker(Canvas canvas, double x, double y, Size size) {
    final beakerPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x - 60, y - 50);
    path.lineTo(x - 50, y + 50);
    path.lineTo(x + 50, y + 50);
    path.lineTo(x + 60, y - 50);
    canvas.drawPath(path, beakerPaint);

    // Beaker rim
    canvas.drawLine(Offset(x - 65, y - 50), Offset(x + 65, y - 50), beakerPaint);
  }

  void _drawLiquid(Canvas canvas, double x, double y, Size size) {
    // Liquid color changes with temperature
    final liquidColor = Color.lerp(materialColor, Colors.red, progress * 0.5)!;

    final liquidPaint = Paint()
      ..color = liquidColor.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(x - 48, y - 60);
    path.lineTo(x - 45, y + 25);
    path.lineTo(x + 45, y + 25);
    path.lineTo(x + 48, y - 60);
    path.close();
    canvas.drawPath(path, liquidPaint);

    // Bubbles if heating and near boiling
    if (isHeating && temperature > 80) {
      final bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.5);
      final random = math.Random(42);
      for (int i = 0; i < 5; i++) {
        final bx = x - 30 + random.nextDouble() * 60;
        final by = y - 40 + random.nextDouble() * 50;
        canvas.drawCircle(Offset(bx, by), 3 + random.nextDouble() * 4, bubblePaint);
      }
    }
  }

  void _drawHeater(Canvas canvas, double x, double y, Size size) {
    // Heater element
    final heaterPaint = Paint()
      ..color = isHeating ? Colors.red : Colors.grey[600]!
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x - 40, y);
    for (int i = 0; i < 8; i++) {
      path.lineTo(x - 35 + i * 10, i % 2 == 0 ? y + 5 : y - 5);
    }
    canvas.drawPath(path, heaterPaint);

    // Glow effect if heating
    if (isHeating) {
      final glowPaint = Paint()
        ..color = Colors.orange.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 90, height: 20), glowPaint);
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: isHeating ? 'Heating (1000W)' : 'Heater Off',
        style: TextStyle(color: isHeating ? Colors.red : Colors.grey, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 15));
  }

  void _drawThermometer(Canvas canvas, double x, double y, double temp) {
    // Thermometer outline
    final outlinePaint = Paint()
      ..color = Colors.grey[600]!
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Bulb
    canvas.drawCircle(Offset(x, y + 50), 12, outlinePaint);

    // Tube
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 10, height: 80),
        const Radius.circular(5),
      ),
      outlinePaint,
    );

    // Mercury level (based on temperature)
    final mercuryHeight = (temp / 100) * 70;
    final mercuryPaint = Paint()..color = Colors.red;

    canvas.drawCircle(Offset(x, y + 50), 10, mercuryPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - 3, y + 50 - mercuryHeight, 6, mercuryHeight),
        const Radius.circular(3),
      ),
      mercuryPaint,
    );

    // Scale marks
    final scalePaint = Paint()
      ..color = Colors.black54
      ..strokeWidth = 1;
    for (int i = 0; i <= 5; i++) {
      final markY = y + 40 - i * 14;
      canvas.drawLine(Offset(x + 8, markY), Offset(x + 15, markY), scalePaint);
    }
  }

  void _drawEnergyFlow(Canvas canvas, double x, double y) {
    final arrowPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.7)
      ..strokeWidth = 2;

    // Draw upward arrows representing energy transfer
    for (int i = 0; i < 3; i++) {
      final ax = x - 20 + i * 20;
      canvas.drawLine(Offset(ax, y + 10), Offset(ax, y - 10), arrowPaint);
      // Arrow head
      canvas.drawLine(Offset(ax, y - 10), Offset(ax - 4, y - 2), arrowPaint);
      canvas.drawLine(Offset(ax, y - 10), Offset(ax + 4, y - 2), arrowPaint);
    }
  }

  Color _getTemperatureColor() {
    if (temperature < 30) return Colors.blue;
    if (temperature < 50) return Colors.cyan;
    if (temperature < 70) return Colors.yellow;
    if (temperature < 90) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant _HeatingPainter oldDelegate) {
    return temperature != oldDelegate.temperature ||
        isHeating != oldDelegate.isHeating ||
        materialColor != oldDelegate.materialColor;
  }
}
