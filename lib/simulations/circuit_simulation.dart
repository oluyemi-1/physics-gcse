import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class CircuitSimulation extends StatefulWidget {
  const CircuitSimulation({super.key});

  @override
  State<CircuitSimulation> createState() => _CircuitSimulationState();
}

class _CircuitSimulationState extends State<CircuitSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  double _voltage = 12.0;
  double _resistance = 4.0;
  bool _isSwitchOn = true;
  bool _hasSpokenIntro = false;

  double get _current => _isSwitchOn ? _voltage / _resistance : 0;
  double get _power => _voltage * _current;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Circuit Simulation. This demonstrates Ohm\'s Law. '
          'You can see electrons flowing through the circuit when the switch is on. '
          'Adjust the voltage and resistance to see how current changes. '
          'Remember, current equals voltage divided by resistance.',
          force: true,
        );
      }
    });
  }

  void _onSwitchToggled() {
    setState(() => _isSwitchOn = !_isSwitchOn);
    if (_isSwitchOn) {
      speakSimulation(
        'Circuit is now ON. Current is flowing through the circuit. '
        'The electrons are moving from the negative terminal to the positive terminal. '
        'The bulb is lit because current is passing through it.',
        force: true,
      );
    } else {
      speakSimulation(
        'Circuit is now OFF. The circuit is broken, so no current can flow. '
        'The electrons have stopped moving and the bulb is not lit.',
        force: true,
      );
    }
  }

  void _onVoltageChanged(double value) {
    setState(() => _voltage = value);
    final newCurrent = value / _resistance;
    if (value < 6) {
      speakSimulation(
        'Low voltage at ${value.toStringAsFixed(1)} volts. '
        'Current is ${newCurrent.toStringAsFixed(2)} amps. The bulb is dim.',
      );
    } else if (value > 18) {
      speakSimulation(
        'High voltage at ${value.toStringAsFixed(1)} volts. '
        'Current is ${newCurrent.toStringAsFixed(2)} amps. The bulb is very bright.',
      );
    } else {
      speakSimulation(
        'Voltage set to ${value.toStringAsFixed(1)} volts. '
        'Current is ${newCurrent.toStringAsFixed(2)} amps.',
      );
    }
  }

  void _onResistanceChanged(double value) {
    setState(() => _resistance = value);
    final newCurrent = _voltage / value;
    if (value < 3) {
      speakSimulation(
        'Low resistance at ${value.toStringAsFixed(1)} ohms. '
        'More current can flow. Current is ${newCurrent.toStringAsFixed(2)} amps.',
      );
    } else if (value > 9) {
      speakSimulation(
        'High resistance at ${value.toStringAsFixed(1)} ohms. '
        'Less current can flow. Current is ${newCurrent.toStringAsFixed(2)} amps.',
      );
    } else {
      speakSimulation(
        'Resistance set to ${value.toStringAsFixed(1)} ohms. '
        'Current is ${newCurrent.toStringAsFixed(2)} amps.',
      );
    }
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
        // TTS toggle
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [buildTTSToggle()],
          ),
        ),
        // Circuit display
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: CircuitPainter(
                  phase: _controller.value,
                  current: _current,
                  voltage: _voltage,
                  resistance: _resistance,
                  isSwitchOn: _isSwitchOn,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
        // Switch button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: GestureDetector(
            onTap: _onSwitchToggled,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              decoration: BoxDecoration(
                color: _isSwitchOn ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: (_isSwitchOn ? Colors.green : Colors.red).withValues(alpha: 0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isSwitchOn ? Icons.power : Icons.power_off,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isSwitchOn ? 'Circuit ON' : 'Circuit OFF',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildSlider(
                'Voltage (V)',
                _voltage,
                1,
                24,
                '${_voltage.toStringAsFixed(1)} V',
                _onVoltageChanged,
                Colors.yellow,
              ),
              _buildSlider(
                'Resistance (Ω)',
                _resistance,
                1,
                12,
                '${_resistance.toStringAsFixed(1)} Ω',
                _onResistanceChanged,
                Colors.orange,
              ),
              const SizedBox(height: 12),
              // Ohm's Law display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withValues(alpha: 0.3),
                      Colors.purple.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Ohm\'s Law: V = I × R',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildValueDisplay('Voltage', '${_voltage.toStringAsFixed(1)} V', Colors.yellow),
                        _buildValueDisplay('Current', '${_current.toStringAsFixed(2)} A', Colors.cyan),
                        _buildValueDisplay('Power', '${_power.toStringAsFixed(1)} W', Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }
}

class CircuitPainter extends CustomPainter {
  final double phase;
  final double current;
  final double voltage;
  final double resistance;
  final bool isSwitchOn;

  CircuitPainter({
    required this.phase,
    required this.current,
    required this.voltage,
    required this.resistance,
    required this.isSwitchOn,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Circuit rectangle dimensions
    final rectWidth = size.width * 0.6;
    final rectHeight = size.height * 0.5;
    final left = centerX - rectWidth / 2;
    final top = centerY - rectHeight / 2;
    final right = centerX + rectWidth / 2;
    final bottom = centerY + rectHeight / 2;

    // Wire paint
    final wirePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Draw circuit wires
    final path = Path();
    path.moveTo(left, bottom);
    path.lineTo(left, top);
    path.lineTo(right, top);
    path.lineTo(right, bottom);
    path.lineTo(left, bottom);
    canvas.drawPath(path, wirePaint);

    // Draw battery (left side)
    _drawBattery(canvas, left - 10, centerY, voltage);

    // Draw resistor (top)
    _drawResistor(canvas, centerX, top, resistance);

    // Draw switch (right side)
    _drawSwitch(canvas, right + 10, centerY, isSwitchOn);

    // Draw bulb (bottom)
    _drawBulb(canvas, centerX, bottom, current);

    // Draw electrons if switch is on
    if (isSwitchOn && current > 0) {
      _drawElectrons(canvas, size, left, top, right, bottom, phase, current);
    }

    // Draw ammeter reading
    _drawAmmeter(canvas, right - 30, bottom + 5, current);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'Battery\n${voltage.toStringAsFixed(1)}V',
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(left - 50, centerY - 30));

    textPainter.text = TextSpan(
      text: 'Resistor\n${resistance.toStringAsFixed(1)}Ω',
      style: const TextStyle(color: Colors.white70, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 20, top - 40));
  }

  void _drawBattery(Canvas canvas, double x, double y, double voltage) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Long line (positive)
    canvas.drawLine(Offset(x - 15, y - 15), Offset(x - 15, y + 15), paint);
    // Short line (negative)
    canvas.drawLine(Offset(x - 25, y - 8), Offset(x - 25, y + 8), paint);

    // Plus/minus labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: '+',
      style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 12, y - 25));

    textPainter.text = const TextSpan(
      text: '-',
      style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 26, y + 15));
  }

  void _drawResistor(Canvas canvas, double x, double y, double resistance) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x - 40, y);
    for (int i = 0; i < 6; i++) {
      path.lineTo(x - 30 + i * 10, y + (i % 2 == 0 ? -8 : 8));
    }
    path.lineTo(x + 40, y);
    canvas.drawPath(path, paint);
  }

  void _drawSwitch(Canvas canvas, double x, double y, bool isOn) {
    final paint = Paint()
      ..color = isOn ? Colors.green : Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Connection points
    canvas.drawCircle(Offset(x, y - 15), 4, paint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(x, y + 15), 4, paint);

    // Switch lever
    if (isOn) {
      canvas.drawLine(Offset(x, y - 15), Offset(x, y + 15), paint..style = PaintingStyle.stroke);
    } else {
      canvas.drawLine(Offset(x, y - 15), Offset(x + 15, y + 5), paint..style = PaintingStyle.stroke);
    }
  }

  void _drawBulb(Canvas canvas, double x, double y, double current) {
    final brightness = (current / 6).clamp(0.0, 1.0);
    final bulbColor = Color.lerp(Colors.grey, Colors.yellow, brightness)!;

    // Bulb glow
    if (current > 0) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: brightness * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(x, y), 25, glowPaint);
    }

    // Bulb outline
    final paint = Paint()
      ..color = bulbColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(x, y), 15, paint);

    // Filament
    if (current > 0) {
      paint.color = bulbColor;
      paint.strokeWidth = 2;
      final filamentPath = Path();
      filamentPath.moveTo(x - 5, y + 5);
      filamentPath.lineTo(x - 3, y - 3);
      filamentPath.lineTo(x + 3, y + 3);
      filamentPath.lineTo(x + 5, y - 5);
      canvas.drawPath(filamentPath, paint);
    }
  }

  void _drawElectrons(Canvas canvas, Size size, double left, double top, double right, double bottom, double phase, double current) {
    final electronPaint = Paint()..color = Colors.cyan;
    final speed = current / 3;
    final numElectrons = (current * 3).toInt().clamp(3, 15);

    for (int i = 0; i < numElectrons; i++) {
      final t = ((phase * speed + i / numElectrons) % 1);
      Offset pos;

      // Move around the circuit
      if (t < 0.25) {
        // Bottom to left
        final localT = t / 0.25;
        pos = Offset(left + (1 - localT) * (right - left), bottom);
      } else if (t < 0.5) {
        // Left side going up
        final localT = (t - 0.25) / 0.25;
        pos = Offset(left, bottom - localT * (bottom - top));
      } else if (t < 0.75) {
        // Top going right
        final localT = (t - 0.5) / 0.25;
        pos = Offset(left + localT * (right - left), top);
      } else {
        // Right side going down
        final localT = (t - 0.75) / 0.25;
        pos = Offset(right, top + localT * (bottom - top));
      }

      canvas.drawCircle(pos, 4, electronPaint);
    }
  }

  void _drawAmmeter(Canvas canvas, double x, double y, double current) {
    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(Offset(x, y), 12, paint);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: 'A',
      style: TextStyle(color: Colors.cyan, fontSize: 10, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 4, y - 6));
  }

  @override
  bool shouldRepaint(covariant CircuitPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.current != current ||
        oldDelegate.isSwitchOn != isSwitchOn;
  }
}
