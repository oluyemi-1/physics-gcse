import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class OhmsLawSimulation extends StatefulWidget {
  const OhmsLawSimulation({super.key});

  @override
  State<OhmsLawSimulation> createState() => _OhmsLawSimulationState();
}

class _OhmsLawSimulationState extends State<OhmsLawSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _voltage = 6.0; // Volts
  double _resistance = 10.0; // Ohms
  bool _hasSpokenIntro = false;

  double get _current => _voltage / _resistance;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Ohm\'s Law simulation! '
          'Ohm\'s Law states that voltage equals current times resistance, or V equals I times R. '
          'Adjust the voltage and resistance to see how current changes. '
          'The moving dots represent electrons flowing through the circuit.',
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

  void _onVoltageChanged(double value) {
    setState(() {
      _voltage = value;
    });
    speakSimulation(
      'Voltage set to ${value.toStringAsFixed(1)} volts. Current is now ${_current.toStringAsFixed(2)} amps.',
    );
  }

  void _onResistanceChanged(double value) {
    setState(() {
      _resistance = value;
    });
    speakSimulation(
      'Resistance set to ${value.toStringAsFixed(0)} ohms. Current is now ${_current.toStringAsFixed(2)} amps.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Circuit visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _CircuitPainter(
                    voltage: _voltage,
                    resistance: _resistance,
                    current: _current,
                    animationValue: _controller.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),

        // Ohm's Law triangle and data display
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Ohm's Law Triangle
              Container(
                width: 120,
                height: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomPaint(
                  painter: _OhmsTrianglePainter(),
                ),
              ),
              // Values display
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildValueRow('V', _voltage.toStringAsFixed(1), 'V', Colors.red),
                  _buildValueRow('I', _current.toStringAsFixed(3), 'A', Colors.green),
                  _buildValueRow('R', _resistance.toStringAsFixed(0), 'Ω', Colors.blue),
                ],
              ),
              // Formula display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('V = I × R', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      '${_voltage.toStringAsFixed(1)} = ${_current.toStringAsFixed(3)} × ${_resistance.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
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
                // Voltage slider
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Voltage:', style: TextStyle(color: Colors.white))),
                    Expanded(
                      child: Slider(
                        value: _voltage,
                        min: 1,
                        max: 12,
                        divisions: 22,
                        onChanged: _onVoltageChanged,
                        activeColor: Colors.red,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${_voltage.toStringAsFixed(1)} V',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                // Resistance slider
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Resistance:', style: TextStyle(color: Colors.white))),
                    Expanded(
                      child: Slider(
                        value: _resistance,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        onChanged: _onResistanceChanged,
                        activeColor: Colors.blue,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${_resistance.toStringAsFixed(0)} Ω',
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Power calculation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        'Power: P = I × V = ${(_current * _voltage).toStringAsFixed(2)} W',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'P = I²R = ${(_current * _current * _resistance).toStringAsFixed(2)} W',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                buildTTSToggle(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildValueRow(String symbol, String value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(symbol, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 8),
          Text('$value $unit', style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  final double voltage;
  final double resistance;
  final double current;
  final double animationValue;

  _CircuitPainter({
    required this.voltage,
    required this.resistance,
    required this.current,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final circuitWidth = size.width * 0.7;
    final circuitHeight = size.height * 0.6;

    // Circuit wire paint
    final wirePaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw circuit rectangle
    final left = centerX - circuitWidth / 2;
    final top = centerY - circuitHeight / 2;
    final right = centerX + circuitWidth / 2;
    final bottom = centerY + circuitHeight / 2;

    // Top wire
    canvas.drawLine(Offset(left + 40, top), Offset(right - 40, top), wirePaint);
    // Right wire
    canvas.drawLine(Offset(right, top + 40), Offset(right, bottom - 40), wirePaint);
    // Bottom wire
    canvas.drawLine(Offset(left + 40, bottom), Offset(right - 40, bottom), wirePaint);
    // Left wire
    canvas.drawLine(Offset(left, top + 40), Offset(left, bottom - 40), wirePaint);

    // Draw battery (left side)
    _drawBattery(canvas, Offset(left, centerY), voltage);

    // Draw resistor (right side)
    _drawResistor(canvas, Offset(right, centerY), resistance);

    // Draw ammeter (bottom)
    _drawAmmeter(canvas, Offset(centerX, bottom), current);

    // Draw voltmeter (connected across resistor)
    _drawVoltmeter(canvas, Offset(right + 60, centerY), voltage);

    // Draw moving electrons
    _drawElectrons(canvas, size, left, top, right, bottom);

    // Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'Battery',
      style: TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(left - 25, centerY + 40));

    textPainter.text = const TextSpan(
      text: 'Resistor',
      style: TextStyle(color: Colors.black, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(right - 25, centerY + 40));
  }

  void _drawBattery(Canvas canvas, Offset center, double voltage) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Long line (positive)
    canvas.drawLine(
      Offset(center.dx - 15, center.dy - 20),
      Offset(center.dx - 15, center.dy + 20),
      paint,
    );

    // Short line (negative)
    paint.strokeWidth = 6;
    canvas.drawLine(
      Offset(center.dx + 5, center.dy - 12),
      Offset(center.dx + 5, center.dy + 12),
      paint,
    );

    // Plus sign
    final textPainter = TextPainter(
      text: const TextSpan(text: '+', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 30, center.dy - 25));

    // Minus sign
    textPainter.text = const TextSpan(text: '−', style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold));
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + 10, center.dy - 25));

    // Voltage label
    textPainter.text = TextSpan(
      text: '${voltage.toStringAsFixed(1)}V',
      style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 20, center.dy - 45));
  }

  void _drawResistor(Canvas canvas, Offset center, double resistance) {
    final paint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Zigzag resistor symbol
    final path = Path();
    path.moveTo(center.dx, center.dy - 30);
    path.lineTo(center.dx - 8, center.dy - 20);
    path.lineTo(center.dx + 8, center.dy - 10);
    path.lineTo(center.dx - 8, center.dy);
    path.lineTo(center.dx + 8, center.dy + 10);
    path.lineTo(center.dx - 8, center.dy + 20);
    path.lineTo(center.dx, center.dy + 30);

    canvas.drawPath(path, paint);

    // Resistance label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${resistance.toStringAsFixed(0)}Ω',
        style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 20, center.dy - 50));
  }

  void _drawAmmeter(Canvas canvas, Offset center, double current) {
    // Circle
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 18, paint);

    // A label
    final textPainter = TextPainter(
      text: const TextSpan(text: 'A', style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 5, center.dy - 8));

    // Current value
    textPainter.text = TextSpan(
      text: '${current.toStringAsFixed(2)}A',
      style: const TextStyle(color: Colors.green, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 18, center.dy + 22));
  }

  void _drawVoltmeter(Canvas canvas, Offset center, double voltage) {
    // Circle
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 18, paint);

    // V label
    final textPainter = TextPainter(
      text: const TextSpan(text: 'V', style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 5, center.dy - 8));

    // Connecting wires to resistor (dashed)
    final dashPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(center.dx - 18, center.dy - 10), Offset(center.dx - 60, center.dy - 30), dashPaint);
    canvas.drawLine(Offset(center.dx - 18, center.dy + 10), Offset(center.dx - 60, center.dy + 30), dashPaint);
  }

  void _drawElectrons(Canvas canvas, Size size, double left, double top, double right, double bottom) {
    final electronPaint = Paint()..color = Colors.yellow;
    final electronCount = (current * 5).clamp(2, 15).toInt();
    final speed = current / 2;

    for (int i = 0; i < electronCount; i++) {
      final t = (animationValue + i / electronCount) % 1.0;
      final adjustedT = (t * (1 + speed)) % 1.0;

      Offset pos;
      if (adjustedT < 0.25) {
        // Top wire (left to right)
        final progress = adjustedT / 0.25;
        pos = Offset(left + 40 + progress * (right - left - 80), top);
      } else if (adjustedT < 0.5) {
        // Right wire (top to bottom)
        final progress = (adjustedT - 0.25) / 0.25;
        pos = Offset(right, top + 40 + progress * (bottom - top - 80));
      } else if (adjustedT < 0.75) {
        // Bottom wire (right to left)
        final progress = (adjustedT - 0.5) / 0.25;
        pos = Offset(right - 40 - progress * (right - left - 80), bottom);
      } else {
        // Left wire (bottom to top)
        final progress = (adjustedT - 0.75) / 0.25;
        pos = Offset(left, bottom - 40 - progress * (bottom - top - 80));
      }

      canvas.drawCircle(pos, 4, electronPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircuitPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        voltage != oldDelegate.voltage ||
        resistance != oldDelegate.resistance;
  }
}

class _OhmsTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw triangle
    final path = Path();
    path.moveTo(size.width / 2, 10);
    path.lineTo(10, size.height - 10);
    path.lineTo(size.width - 10, size.height - 10);
    path.close();
    canvas.drawPath(path, paint);

    // Draw horizontal line
    canvas.drawLine(
      Offset(10, size.height / 2),
      Offset(size.width - 10, size.height / 2),
      paint,
    );

    // Draw labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // V at top
    textPainter.text = const TextSpan(
      text: 'V',
      style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - 6, 15));

    // I at bottom left
    textPainter.text = const TextSpan(
      text: 'I',
      style: TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(25, size.height / 2 + 10));

    // R at bottom right
    textPainter.text = const TextSpan(
      text: 'R',
      style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 35, size.height / 2 + 10));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
