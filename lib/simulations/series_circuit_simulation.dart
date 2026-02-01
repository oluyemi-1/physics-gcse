import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class SeriesCircuitSimulation extends StatefulWidget {
  const SeriesCircuitSimulation({super.key});

  @override
  State<SeriesCircuitSimulation> createState() => _SeriesCircuitSimulationState();
}

class _SeriesCircuitSimulationState extends State<SeriesCircuitSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _voltage = 12.0;
  double _r1 = 100.0;
  double _r2 = 200.0;
  double _r3 = 100.0;
  int _numResistors = 3;
  double _electronPhase = 0.0;
  bool _hasSpokenIntro = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateElectrons);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Series Circuit simulation! '
          'In a series circuit, components are connected end to end in a single loop. '
          'The same current flows through all components. '
          'Total resistance equals the sum of all resistances. '
          'The supply voltage is shared between components.',
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

  void _updateElectrons() {
    setState(() {
      final current = _getCurrent();
      _electronPhase += 0.02 * (current / 0.05);
      if (_electronPhase > 1.0) {
        _electronPhase -= 1.0;
      }
    });
  }

  double _getTotalResistance() {
    double total = _r1;
    if (_numResistors >= 2) total += _r2;
    if (_numResistors >= 3) total += _r3;
    return total;
  }

  double _getCurrent() {
    return _voltage / _getTotalResistance();
  }

  double _getVoltageAcross(double resistance) {
    return _getCurrent() * resistance;
  }

  void _announceChanges() {
    final totalR = _getTotalResistance();
    final current = _getCurrent();
    speakSimulation(
      'Total resistance: ${totalR.toStringAsFixed(0)} ohms. '
      'Current: ${(current * 1000).toStringAsFixed(1)} milliamps. '
      'Same current flows through all resistors.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalR = _getTotalResistance();
    final current = _getCurrent();
    final v1 = _getVoltageAcross(_r1);
    final v2 = _numResistors >= 2 ? _getVoltageAcross(_r2) : 0.0;
    final v3 = _numResistors >= 3 ? _getVoltageAcross(_r3) : 0.0;

    return Column(
      children: [
        // Circuit visualization
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
              painter: _SeriesCircuitPainter(
                voltage: _voltage,
                r1: _r1,
                r2: _r2,
                r3: _r3,
                numResistors: _numResistors,
                electronPhase: _electronPhase,
                current: current,
                v1: v1,
                v2: v2,
                v3: v3,
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
                      const Text('Total R',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${totalR.toStringAsFixed(0)} Ω',
                        style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Current',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${(current * 1000).toStringAsFixed(1)} mA',
                        style: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Supply V',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${_voltage.toStringAsFixed(0)} V',
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Rₜ = R₁ + R₂ + R₃',
                style: TextStyle(
                    color: Colors.cyan, fontFamily: 'monospace', fontSize: 12),
              ),
              Text(
                'Vₜ = V₁ + V₂ + V₃ = ${v1.toStringAsFixed(1)} + ${v2.toStringAsFixed(1)} + ${v3.toStringAsFixed(1)} V',
                style: const TextStyle(
                    color: Colors.white70, fontFamily: 'monospace', fontSize: 10),
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
                  // Number of resistors
                  Row(
                    children: [
                      const Text('Resistors: ',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('1'),
                        selected: _numResistors == 1,
                        onSelected: (_) {
                          setState(() => _numResistors = 1);
                          _announceChanges();
                        },
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: const Text('2'),
                        selected: _numResistors == 2,
                        onSelected: (_) {
                          setState(() => _numResistors = 2);
                          _announceChanges();
                        },
                      ),
                      const SizedBox(width: 4),
                      ChoiceChip(
                        label: const Text('3'),
                        selected: _numResistors == 3,
                        onSelected: (_) {
                          setState(() => _numResistors = 3);
                          _announceChanges();
                        },
                      ),
                    ],
                  ),

                  // Voltage slider
                  Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text('V: ${_voltage.toStringAsFixed(0)}V',
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _voltage,
                          min: 1,
                          max: 24,
                          onChanged: (v) {
                            setState(() => _voltage = v);
                          },
                          activeColor: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  // R1 slider
                  Row(
                    children: [
                      SizedBox(
                          width: 80,
                          child: Text('R₁: ${_r1.toStringAsFixed(0)}Ω',
                              style: const TextStyle(
                                  color: Colors.orange, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _r1,
                          min: 10,
                          max: 500,
                          onChanged: (v) {
                            setState(() => _r1 = v);
                            _announceChanges();
                          },
                          activeColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  if (_numResistors >= 2)
                    Row(
                      children: [
                        SizedBox(
                            width: 80,
                            child: Text('R₂: ${_r2.toStringAsFixed(0)}Ω',
                                style: const TextStyle(
                                    color: Colors.cyan, fontSize: 12))),
                        Expanded(
                          child: Slider(
                            value: _r2,
                            min: 10,
                            max: 500,
                            onChanged: (v) {
                              setState(() => _r2 = v);
                              _announceChanges();
                            },
                            activeColor: Colors.cyan,
                          ),
                        ),
                      ],
                    ),

                  if (_numResistors >= 3)
                    Row(
                      children: [
                        SizedBox(
                            width: 80,
                            child: Text('R₃: ${_r3.toStringAsFixed(0)}Ω',
                                style: const TextStyle(
                                    color: Colors.purple, fontSize: 12))),
                        Expanded(
                          child: Slider(
                            value: _r3,
                            min: 10,
                            max: 500,
                            onChanged: (v) {
                              setState(() => _r3 = v);
                              _announceChanges();
                            },
                            activeColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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

class _SeriesCircuitPainter extends CustomPainter {
  final double voltage;
  final double r1;
  final double r2;
  final double r3;
  final int numResistors;
  final double electronPhase;
  final double current;
  final double v1;
  final double v2;
  final double v3;

  _SeriesCircuitPainter({
    required this.voltage,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.numResistors,
    required this.electronPhase,
    required this.current,
    required this.v1,
    required this.v2,
    required this.v3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final wirePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3;

    // Circuit layout - rectangular loop
    final leftX = 60.0;
    final rightX = size.width - 60;
    final topY = 50.0;
    final bottomY = size.height - 50;
    final centerY = (topY + bottomY) / 2;

    // Battery on left side
    _drawBattery(canvas, Offset(leftX, centerY), voltage);

    // Top wire
    canvas.drawLine(Offset(leftX, topY), Offset(rightX, topY), wirePaint);

    // Bottom wire
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), wirePaint);

    // Left wire (from battery)
    canvas.drawLine(Offset(leftX, centerY - 20), Offset(leftX, topY), wirePaint);
    canvas.drawLine(Offset(leftX, centerY + 20), Offset(leftX, bottomY), wirePaint);

    // Resistors on right side
    final resistorSpacing = (bottomY - topY) / (numResistors + 1);

    for (int i = 0; i < numResistors; i++) {
      final y = topY + resistorSpacing * (i + 1);
      double resistance;
      Color color;
      String label;
      double voltageAcross;

      switch (i) {
        case 0:
          resistance = r1;
          color = Colors.orange;
          label = 'R₁';
          voltageAcross = v1;
          break;
        case 1:
          resistance = r2;
          color = Colors.cyan;
          label = 'R₂';
          voltageAcross = v2;
          break;
        default:
          resistance = r3;
          color = Colors.purple;
          label = 'R₃';
          voltageAcross = v3;
      }

      // Wires to resistor
      if (i == 0) {
        canvas.drawLine(Offset(rightX, topY), Offset(rightX, y - 30), wirePaint);
      }
      if (i == numResistors - 1) {
        canvas.drawLine(Offset(rightX, y + 30), Offset(rightX, bottomY), wirePaint);
      }
      if (i > 0) {
        final prevY = topY + resistorSpacing * i;
        canvas.drawLine(Offset(rightX, prevY + 30), Offset(rightX, y - 30), wirePaint);
      }

      _drawResistor(canvas, Offset(rightX, y), resistance, color, label, voltageAcross);
    }

    // Draw current arrows
    _drawCurrentArrow(canvas, Offset(leftX + 60, topY), current, true);
    _drawCurrentArrow(canvas, Offset(rightX - 60, bottomY), current, false);

    // Draw electrons
    _drawElectrons(canvas, size, topY, bottomY, leftX, rightX);

    // Current label
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: 'I = ${(current * 1000).toStringAsFixed(1)} mA (same throughout)',
      style: const TextStyle(color: Colors.yellow, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, topY + 5));
  }

  void _drawBattery(Canvas canvas, Offset center, double v) {
    final batteryPaint = Paint()..strokeWidth = 4;

    // Positive terminal (longer line) - top
    batteryPaint.color = Colors.red;
    canvas.drawLine(
      Offset(center.dx - 15, center.dy - 15),
      Offset(center.dx + 15, center.dy - 15),
      batteryPaint,
    );

    // Negative terminal (shorter line) - bottom
    batteryPaint.color = Colors.blue;
    canvas.drawLine(
      Offset(center.dx - 8, center.dy + 15),
      Offset(center.dx + 8, center.dy + 15),
      batteryPaint,
    );

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${v.toStringAsFixed(0)}V',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 10, center.dy - 5));
  }

  void _drawResistor(Canvas canvas, Offset center, double resistance, Color color, String label, double voltageAcross) {
    final resistorPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Vertical zigzag resistor
    final path = Path();
    path.moveTo(center.dx, center.dy - 25);
    for (int i = 0; i < 6; i++) {
      final y = center.dy - 20 + i * 8;
      final x = center.dx + (i.isEven ? -10 : 10);
      path.lineTo(x, y);
    }
    path.lineTo(center.dx, center.dy + 25);

    canvas.drawPath(path, resistorPaint);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: '$label = ${resistance.toStringAsFixed(0)}Ω',
      style: TextStyle(color: color, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + 15, center.dy - 15));

    textPainter.text = TextSpan(
      text: 'V = ${voltageAcross.toStringAsFixed(1)}V',
      style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + 15, center.dy + 5));
  }

  void _drawCurrentArrow(Canvas canvas, Offset position, double currentVal, bool rightward) {
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    final dir = rightward ? 1.0 : -1.0;
    const length = 20.0;

    canvas.drawLine(
      Offset(position.dx - length * dir, position.dy),
      Offset(position.dx + length * dir, position.dy),
      arrowPaint,
    );

    canvas.drawLine(
      Offset(position.dx + length * dir, position.dy),
      Offset(position.dx + (length - 7) * dir, position.dy - 5),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(position.dx + length * dir, position.dy),
      Offset(position.dx + (length - 7) * dir, position.dy + 5),
      arrowPaint,
    );
  }

  void _drawElectrons(Canvas canvas, Size size, double topY, double bottomY, double leftX, double rightX) {
    final electronPaint = Paint()..color = Colors.yellow;

    // Calculate total path length
    final topLength = rightX - leftX;
    final rightLength = bottomY - topY;
    final bottomLength = rightX - leftX;
    final leftLength = bottomY - topY;
    final totalLength = topLength + rightLength + bottomLength + leftLength;

    // Draw multiple electrons
    for (int i = 0; i < 8; i++) {
      final t = (electronPhase + i / 8) % 1.0;
      final distance = t * totalLength;

      double x, y;

      if (distance < topLength) {
        // Top edge (left to right)
        x = leftX + distance;
        y = topY;
      } else if (distance < topLength + rightLength) {
        // Right edge (top to bottom)
        x = rightX;
        y = topY + (distance - topLength);
      } else if (distance < topLength + rightLength + bottomLength) {
        // Bottom edge (right to left)
        x = rightX - (distance - topLength - rightLength);
        y = bottomY;
      } else {
        // Left edge (bottom to top)
        x = leftX;
        y = bottomY - (distance - topLength - rightLength - bottomLength);
      }

      canvas.drawCircle(Offset(x, y), 4, electronPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SeriesCircuitPainter oldDelegate) {
    return electronPhase != oldDelegate.electronPhase ||
        r1 != oldDelegate.r1 ||
        r2 != oldDelegate.r2 ||
        r3 != oldDelegate.r3 ||
        numResistors != oldDelegate.numResistors ||
        voltage != oldDelegate.voltage;
  }
}
