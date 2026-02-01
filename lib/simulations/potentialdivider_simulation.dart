import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

/// Potential Divider Simulation demonstrating voltage division
/// Shows how voltage is split proportionally across resistors in series
class PotentialDividerSimulation extends StatefulWidget {
  const PotentialDividerSimulation({super.key});

  @override
  State<PotentialDividerSimulation> createState() => _PotentialDividerSimulationState();
}

class _PotentialDividerSimulationState extends State<PotentialDividerSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _supplyVoltage = 12.0; // V
  double _r1 = 1000.0; // Ω
  double _r2 = 1000.0; // Ω
  bool _useLDR = false;
  bool _useThermistor = false;

  double _lightLevel = 50.0; // 0-100%
  double _temperature = 25.0; // °C

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Potential Divider Simulation. A potential divider splits the supply voltage '
        'across two resistors in series. The output voltage depends on the ratio of resistances. '
        'You can replace R2 with an LDR or thermistor to create a light or temperature sensor.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _effectiveR2 {
    if (_useLDR) {
      // LDR resistance decreases with light
      return 10000 * (1 - _lightLevel / 100) + 100;
    } else if (_useThermistor) {
      // NTC thermistor resistance decreases with temperature
      return 10000 * (1 - (_temperature - 10) / 90) + 100;
    }
    return _r2;
  }

  double get _totalResistance => _r1 + _effectiveR2;
  double get _current => _supplyVoltage / _totalResistance;
  double get _vOut => _supplyVoltage * _effectiveR2 / _totalResistance;
  double get _v1 => _supplyVoltage * _r1 / _totalResistance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Potential Divider'),
        backgroundColor: Colors.amber.shade800,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade900, Colors.grey.shade900],
          ),
        ),
        child: Column(
          children: [
            _buildInfoPanel(),
            Expanded(child: _buildCircuitDiagram()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'Potential Divider Circuit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Vₛ', '${_supplyVoltage.toStringAsFixed(1)} V', Colors.red),
              _buildInfoItem('R₁', '${_r1.toStringAsFixed(0)} Ω'),
              _buildInfoItem('R₂${_useLDR ? " (LDR)" : _useThermistor ? " (Therm)" : ""}',
                  '${_effectiveR2.toStringAsFixed(0)} Ω'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Total R', '${_totalResistance.toStringAsFixed(0)} Ω'),
              _buildInfoItem('Current', '${(_current * 1000).toStringAsFixed(2)} mA'),
              _buildInfoItem('V₁', '${_v1.toStringAsFixed(2)} V', Colors.orange),
              _buildInfoItem('Vₒᵤₜ', '${_vOut.toStringAsFixed(2)} V', Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Vₒᵤₜ = Vₛ × R₂/(R₁+R₂) = ${_supplyVoltage.toStringAsFixed(1)} × ${_effectiveR2.toStringAsFixed(0)}/${_totalResistance.toStringAsFixed(0)} = ${_vOut.toStringAsFixed(2)} V',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color ?? Colors.white70, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCircuitDiagram() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _PotentialDividerPainter(
            supplyVoltage: _supplyVoltage,
            r1: _r1,
            r2: _effectiveR2,
            v1: _v1,
            vOut: _vOut,
            current: _current,
            useLDR: _useLDR,
            useThermistor: _useThermistor,
            lightLevel: _lightLevel,
            temperature: _temperature,
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
          // Supply voltage slider
          Row(
            children: [
              const Icon(Icons.battery_charging_full, color: Colors.red, size: 18),
              const SizedBox(width: 8),
              const Text('Supply:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _supplyVoltage,
                  min: 1,
                  max: 24,
                  activeColor: Colors.red,
                  onChanged: (value) => setState(() => _supplyVoltage = value),
                ),
              ),
              Text('${_supplyVoltage.toStringAsFixed(1)} V', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // R1 slider
          Row(
            children: [
              const Text('R₁:', style: TextStyle(color: Colors.orange, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _r1,
                  min: 100,
                  max: 10000,
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => _r1 = value),
                ),
              ),
              Text('${_r1.toStringAsFixed(0)} Ω', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // R2 slider (or sensor controls)
          if (!_useLDR && !_useThermistor)
            Row(
              children: [
                const Text('R₂:', style: TextStyle(color: Colors.green, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _r2,
                    min: 100,
                    max: 10000,
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() => _r2 = value),
                  ),
                ),
                Text('${_r2.toStringAsFixed(0)} Ω', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),

          // LDR light level control
          if (_useLDR)
            Row(
              children: [
                const Icon(Icons.light_mode, color: Colors.yellow, size: 18),
                const SizedBox(width: 8),
                const Text('Light:', style: TextStyle(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _lightLevel,
                    min: 0,
                    max: 100,
                    activeColor: Colors.yellow,
                    onChanged: (value) => setState(() => _lightLevel = value),
                  ),
                ),
                Text('${_lightLevel.toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),

          // Thermistor temperature control
          if (_useThermistor)
            Row(
              children: [
                const Icon(Icons.thermostat, color: Colors.cyan, size: 18),
                const SizedBox(width: 8),
                const Text('Temp:', style: TextStyle(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _temperature,
                    min: 10,
                    max: 100,
                    activeColor: Colors.cyan,
                    onChanged: (value) => setState(() => _temperature = value),
                  ),
                ),
                Text('${_temperature.toStringAsFixed(0)}°C', style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),

          const SizedBox(height: 8),

          // Sensor selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ChoiceChip(
                label: const Text('Resistor'),
                selected: !_useLDR && !_useThermistor,
                selectedColor: Colors.amber.shade600,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _useLDR = false;
                      _useThermistor = false;
                    });
                  }
                },
              ),
              ChoiceChip(
                label: const Text('LDR'),
                selected: _useLDR,
                selectedColor: Colors.amber.shade600,
                onSelected: (selected) {
                  setState(() {
                    _useLDR = selected;
                    _useThermistor = false;
                  });
                  if (selected) {
                    speakSimulation(
                      'LDR selected. An LDR is a light-dependent resistor. Its resistance decreases as light intensity increases, '
                      'causing the output voltage to decrease in bright light.',
                    );
                  }
                },
              ),
              ChoiceChip(
                label: const Text('Thermistor'),
                selected: _useThermistor,
                selectedColor: Colors.amber.shade600,
                onSelected: (selected) {
                  setState(() {
                    _useThermistor = selected;
                    _useLDR = false;
                  });
                  if (selected) {
                    speakSimulation(
                      'NTC Thermistor selected. Its resistance decreases as temperature increases, '
                      'causing the output voltage to decrease at higher temperatures.',
                    );
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Output voltage indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.output, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'Output Voltage: ${_vOut.toStringAsFixed(2)} V',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Key equation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Vₒᵤₜ = Vₛ × R₂/(R₁+R₂)  |  V₁ + Vₒᵤₜ = Vₛ',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PotentialDividerPainter extends CustomPainter {
  final double supplyVoltage;
  final double r1;
  final double r2;
  final double v1;
  final double vOut;
  final double current;
  final bool useLDR;
  final bool useThermistor;
  final double lightLevel;
  final double temperature;

  _PotentialDividerPainter({
    required this.supplyVoltage,
    required this.r1,
    required this.r2,
    required this.v1,
    required this.vOut,
    required this.current,
    required this.useLDR,
    required this.useThermistor,
    required this.lightLevel,
    required this.temperature,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final topY = 40.0;
    final bottomY = size.height - 40;
    final midY = (topY + bottomY) / 2;

    final wirePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3;

    // Draw main circuit loop
    // Top horizontal wire (positive)
    canvas.drawLine(Offset(centerX - 80, topY), Offset(centerX + 80, topY), wirePaint);

    // Left vertical wire
    canvas.drawLine(Offset(centerX - 80, topY), Offset(centerX - 80, bottomY), wirePaint);

    // Bottom horizontal wire (negative/ground)
    canvas.drawLine(Offset(centerX - 80, bottomY), Offset(centerX + 80, bottomY), wirePaint);

    // Right vertical wire segments
    canvas.drawLine(Offset(centerX + 80, topY), Offset(centerX + 80, midY - 60), wirePaint);
    canvas.drawLine(Offset(centerX + 80, midY + 60), Offset(centerX + 80, bottomY), wirePaint);

    // Draw battery
    _drawBattery(canvas, Offset(centerX - 80, (topY + bottomY) / 2), supplyVoltage);

    // Draw R1
    _drawResistor(canvas, Offset(centerX + 80, topY + 60), r1, 'R₁', false, false);

    // Draw R2 (or LDR/Thermistor)
    _drawResistor(canvas, Offset(centerX + 80, bottomY - 60), r2, 'R₂', useLDR, useThermistor);

    // Draw output point
    final outputX = centerX + 80;
    final outputY = midY;

    final outputPaint = Paint()..color = Colors.green;
    canvas.drawCircle(Offset(outputX, outputY), 8, outputPaint);

    // Output wire
    canvas.drawLine(
      Offset(outputX, outputY),
      Offset(outputX + 60, outputY),
      wirePaint,
    );

    // Output terminal
    canvas.drawLine(
      Offset(outputX + 60, outputY - 10),
      Offset(outputX + 60, outputY + 10),
      Paint()..color = Colors.green..strokeWidth = 4,
    );

    // Labels
    _drawLabel(canvas, 'Vₒᵤₜ = ${vOut.toStringAsFixed(2)}V', Offset(outputX + 65, outputY - 5), Colors.green);
    _drawLabel(canvas, '+', Offset(centerX - 90, topY - 10), Colors.red);
    _drawLabel(canvas, '−', Offset(centerX - 90, bottomY + 5), Colors.blue);

    // Voltage labels on resistors
    _drawLabel(canvas, 'V₁ = ${v1.toStringAsFixed(2)}V', Offset(centerX + 100, topY + 60), Colors.orange);
    _drawLabel(canvas, 'V₂ = ${vOut.toStringAsFixed(2)}V', Offset(centerX + 100, bottomY - 60), Colors.green);

    // Current direction arrow
    _drawCurrentArrow(canvas, Offset(centerX + 95, topY + 30), 20, true);

    // Ground symbol
    _drawGround(canvas, Offset(centerX + 80, bottomY + 5));
  }

  void _drawBattery(Canvas canvas, Offset position, double voltage) {
    final batteryPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 2;

    // Long line (positive)
    canvas.drawLine(
      Offset(position.dx - 15, position.dy - 20),
      Offset(position.dx - 15, position.dy + 20),
      batteryPaint,
    );

    // Short line (negative)
    canvas.drawLine(
      Offset(position.dx - 25, position.dy - 10),
      Offset(position.dx - 25, position.dy + 10),
      Paint()..color = Colors.grey.shade300..strokeWidth = 4,
    );

    // Voltage label
    _drawLabel(canvas, '${voltage.toStringAsFixed(1)}V', Offset(position.dx - 50, position.dy - 8), Colors.red);
  }

  void _drawResistor(Canvas canvas, Offset position, double resistance, String label, bool isLDR, bool isThermistor) {
    if (isLDR) {
      _drawLDR(canvas, position, resistance);
    } else if (isThermistor) {
      _drawThermistor(canvas, position, resistance);
    } else {
      // Standard resistor zigzag
      final path = Path();
      path.moveTo(position.dx, position.dy - 30);

      final zigzags = 4;
      final zigWidth = 15.0;
      final zigHeight = 60.0 / zigzags;

      for (var i = 0; i < zigzags; i++) {
        final y1 = position.dy - 30 + i * zigHeight + zigHeight / 2;
        path.lineTo(position.dx + zigWidth, y1);
        path.lineTo(position.dx - zigWidth, y1 + zigHeight / 2);
      }
      path.lineTo(position.dx, position.dy + 30);

      final resistorPaint = Paint()
        ..color = Colors.orange.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawPath(path, resistorPaint);
    }

    // Label
    _drawLabel(canvas, '$label\n${resistance.toStringAsFixed(0)}Ω', Offset(position.dx - 60, position.dy - 10), Colors.white70);
  }

  void _drawLDR(Canvas canvas, Offset position, double resistance) {
    // Draw LDR symbol (resistor in circle with arrows)
    final circlePaint = Paint()
      ..color = Colors.yellow.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, 25, circlePaint);

    // Resistor inside
    final path = Path();
    path.moveTo(position.dx, position.dy - 25);
    path.lineTo(position.dx, position.dy - 15);
    path.lineTo(position.dx + 8, position.dy - 10);
    path.lineTo(position.dx - 8, position.dy);
    path.lineTo(position.dx + 8, position.dy + 10);
    path.lineTo(position.dx, position.dy + 15);
    path.lineTo(position.dx, position.dy + 25);

    canvas.drawPath(path, Paint()..color = Colors.orange..style = PaintingStyle.stroke..strokeWidth = 2);

    // Light arrows
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    canvas.drawLine(Offset(position.dx - 35, position.dy - 15), Offset(position.dx - 28, position.dy - 8), arrowPaint);
    canvas.drawLine(Offset(position.dx - 35, position.dy), Offset(position.dx - 28, position.dy), arrowPaint);
  }

  void _drawThermistor(Canvas canvas, Offset position, double resistance) {
    // Draw thermistor symbol (resistor in circle with T)
    final circlePaint = Paint()
      ..color = Colors.cyan.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, 25, circlePaint);

    // Resistor inside
    final path = Path();
    path.moveTo(position.dx, position.dy - 25);
    path.lineTo(position.dx, position.dy - 15);
    path.lineTo(position.dx + 8, position.dy - 10);
    path.lineTo(position.dx - 8, position.dy);
    path.lineTo(position.dx + 8, position.dy + 10);
    path.lineTo(position.dx, position.dy + 15);
    path.lineTo(position.dx, position.dy + 25);

    canvas.drawPath(path, Paint()..color = Colors.orange..style = PaintingStyle.stroke..strokeWidth = 2);

    // Temperature symbol
    _drawLabel(canvas, 'T', Offset(position.dx - 40, position.dy - 8), Colors.cyan);
  }

  void _drawGround(Canvas canvas, Offset position) {
    final groundPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2;

    canvas.drawLine(Offset(position.dx - 15, position.dy), Offset(position.dx + 15, position.dy), groundPaint);
    canvas.drawLine(Offset(position.dx - 10, position.dy + 5), Offset(position.dx + 10, position.dy + 5), groundPaint);
    canvas.drawLine(Offset(position.dx - 5, position.dy + 10), Offset(position.dx + 5, position.dy + 10), groundPaint);
  }

  void _drawCurrentArrow(Canvas canvas, Offset position, double length, bool down) {
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    final endY = down ? position.dy + length : position.dy - length;
    canvas.drawLine(position, Offset(position.dx, endY), arrowPaint);

    final headPath = Path();
    if (down) {
      headPath.moveTo(position.dx - 5, endY - 8);
      headPath.lineTo(position.dx, endY);
      headPath.lineTo(position.dx + 5, endY - 8);
    } else {
      headPath.moveTo(position.dx - 5, endY + 8);
      headPath.lineTo(position.dx, endY);
      headPath.lineTo(position.dx + 5, endY + 8);
    }
    canvas.drawPath(headPath, arrowPaint);

    _drawLabel(canvas, 'I', Offset(position.dx + 8, position.dy + length / 2 - 5), Colors.yellow);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _PotentialDividerPainter oldDelegate) {
    return oldDelegate.r1 != r1 ||
           oldDelegate.r2 != r2 ||
           oldDelegate.vOut != vOut ||
           oldDelegate.useLDR != useLDR ||
           oldDelegate.useThermistor != useThermistor;
  }
}
