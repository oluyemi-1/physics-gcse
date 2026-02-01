import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class ParallelCircuitSimulation extends StatefulWidget {
  const ParallelCircuitSimulation({super.key});

  @override
  State<ParallelCircuitSimulation> createState() => _ParallelCircuitSimulationState();
}

class _ParallelCircuitSimulationState extends State<ParallelCircuitSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _voltage = 12.0;
  double _r1 = 100.0;
  double _r2 = 200.0;
  double _r3 = 300.0;
  bool _r2Connected = true;
  bool _r3Connected = true;
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
          'Welcome to the Parallel Circuit simulation! '
          'In a parallel circuit, components are connected across common points, providing multiple paths for current. '
          'The voltage across each branch is the same as the supply voltage. '
          'Total current equals the sum of currents through each branch.',
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
      _electronPhase += 0.03 * (_getTotalCurrent() / 0.1);
      if (_electronPhase > 2 * math.pi) {
        _electronPhase -= 2 * math.pi;
      }
    });
  }

  double _getTotalResistance() {
    double reciprocal = 1 / _r1;
    if (_r2Connected) reciprocal += 1 / _r2;
    if (_r3Connected) reciprocal += 1 / _r3;
    return 1 / reciprocal;
  }

  double _getTotalCurrent() {
    return _voltage / _getTotalResistance();
  }

  double _getBranchCurrent(double resistance) {
    return _voltage / resistance;
  }

  void _onR1Changed(double value) {
    setState(() => _r1 = value);
    _announceChanges();
  }

  void _onR2Changed(double value) {
    setState(() => _r2 = value);
    _announceChanges();
  }

  void _onR3Changed(double value) {
    setState(() => _r3 = value);
    _announceChanges();
  }

  void _announceChanges() {
    final totalR = _getTotalResistance();
    final totalI = _getTotalCurrent();
    speakSimulation(
      'Total resistance: ${totalR.toStringAsFixed(1)} ohms. Total current: ${(totalI * 1000).toStringAsFixed(1)} milliamps. '
      'Notice how adding parallel resistors decreases total resistance.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalR = _getTotalResistance();
    final totalI = _getTotalCurrent();
    final i1 = _getBranchCurrent(_r1);
    final i2 = _r2Connected ? _getBranchCurrent(_r2) : 0.0;
    final i3 = _r3Connected ? _getBranchCurrent(_r3) : 0.0;

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
              border: Border.all(color: Colors.green.shade700),
            ),
            child: CustomPaint(
              painter: _ParallelCircuitPainter(
                voltage: _voltage,
                r1: _r1,
                r2: _r2,
                r3: _r3,
                r2Connected: _r2Connected,
                r3Connected: _r3Connected,
                electronPhase: _electronPhase,
                i1: i1,
                i2: i2,
                i3: i3,
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
            color: Colors.green.withValues(alpha: 0.2),
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
                        '${totalR.toStringAsFixed(1)} Ω',
                        style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Total I',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        '${(totalI * 1000).toStringAsFixed(1)} mA',
                        style: const TextStyle(
                            color: Colors.yellow,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Voltage',
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
                '1/Rₜ = 1/R₁ + 1/R₂ + 1/R₃',
                style: TextStyle(
                    color: Colors.cyan, fontFamily: 'monospace', fontSize: 12),
              ),
              Text(
                'Iₜ = I₁ + I₂ + I₃ = ${(i1 * 1000).toStringAsFixed(1)} + ${(i2 * 1000).toStringAsFixed(1)} + ${(i3 * 1000).toStringAsFixed(1)} mA',
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
                          onChanged: (v) => setState(() => _voltage = v),
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
                          onChanged: _onR1Changed,
                          activeColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  // R2 slider with switch
                  Row(
                    children: [
                      Switch(
                        value: _r2Connected,
                        onChanged: (v) => setState(() => _r2Connected = v),
                        activeColor: Colors.cyan,
                      ),
                      SizedBox(
                          width: 60,
                          child: Text('R₂: ${_r2.toStringAsFixed(0)}Ω',
                              style: TextStyle(
                                  color: _r2Connected ? Colors.cyan : Colors.grey,
                                  fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _r2,
                          min: 10,
                          max: 500,
                          onChanged: _r2Connected ? _onR2Changed : null,
                          activeColor: Colors.cyan,
                        ),
                      ),
                    ],
                  ),

                  // R3 slider with switch
                  Row(
                    children: [
                      Switch(
                        value: _r3Connected,
                        onChanged: (v) => setState(() => _r3Connected = v),
                        activeColor: Colors.purple,
                      ),
                      SizedBox(
                          width: 60,
                          child: Text('R₃: ${_r3.toStringAsFixed(0)}Ω',
                              style: TextStyle(
                                  color: _r3Connected ? Colors.purple : Colors.grey,
                                  fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _r3,
                          min: 10,
                          max: 500,
                          onChanged: _r3Connected ? _onR3Changed : null,
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

class _ParallelCircuitPainter extends CustomPainter {
  final double voltage;
  final double r1;
  final double r2;
  final double r3;
  final bool r2Connected;
  final bool r3Connected;
  final double electronPhase;
  final double i1;
  final double i2;
  final double i3;

  _ParallelCircuitPainter({
    required this.voltage,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r2Connected,
    required this.r3Connected,
    required this.electronPhase,
    required this.i1,
    required this.i2,
    required this.i3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final wirePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3;

    final disconnectedPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 3;

    // Main wire connections
    final leftX = 40.0;
    final rightX = size.width - 40;
    final topY = 40.0;
    final bottomY = size.height - 40;

    // Left vertical wire
    canvas.drawLine(Offset(leftX, topY), Offset(leftX, bottomY), wirePaint);

    // Right vertical wire
    canvas.drawLine(Offset(rightX, topY), Offset(rightX, bottomY), wirePaint);

    // Battery (at top)
    _drawBattery(canvas, Offset(centerX, topY), voltage);
    canvas.drawLine(Offset(leftX, topY), Offset(centerX - 25, topY), wirePaint);
    canvas.drawLine(Offset(centerX + 25, topY), Offset(rightX, topY), wirePaint);

    // Bottom connecting wire
    canvas.drawLine(Offset(leftX, bottomY), Offset(rightX, bottomY), wirePaint);

    // Branch heights
    final branch1Y = centerY - 50;
    final branch2Y = centerY;
    final branch3Y = centerY + 50;

    // Branch 1 (R1 - always connected)
    canvas.drawLine(Offset(leftX, branch1Y), Offset(centerX - 40, branch1Y), wirePaint);
    _drawResistor(canvas, Offset(centerX, branch1Y), r1, Colors.orange, 'R₁');
    canvas.drawLine(Offset(centerX + 40, branch1Y), Offset(rightX, branch1Y), wirePaint);
    _drawCurrentArrow(canvas, Offset(centerX - 60, branch1Y), i1, true);

    // Branch 2 (R2)
    final paint2 = r2Connected ? wirePaint : disconnectedPaint;
    canvas.drawLine(Offset(leftX, branch2Y), Offset(centerX - 40, branch2Y), paint2);
    _drawResistor(canvas, Offset(centerX, branch2Y), r2, r2Connected ? Colors.cyan : Colors.grey, 'R₂');
    canvas.drawLine(Offset(centerX + 40, branch2Y), Offset(rightX, branch2Y), paint2);
    if (r2Connected) {
      _drawCurrentArrow(canvas, Offset(centerX - 60, branch2Y), i2, true);
    }

    // Branch 3 (R3)
    final paint3 = r3Connected ? wirePaint : disconnectedPaint;
    canvas.drawLine(Offset(leftX, branch3Y), Offset(centerX - 40, branch3Y), paint3);
    _drawResistor(canvas, Offset(centerX, branch3Y), r3, r3Connected ? Colors.purple : Colors.grey, 'R₃');
    canvas.drawLine(Offset(centerX + 40, branch3Y), Offset(rightX, branch3Y), paint3);
    if (r3Connected) {
      _drawCurrentArrow(canvas, Offset(centerX - 60, branch3Y), i3, true);
    }

    // Draw electrons
    _drawElectrons(canvas, size, branch1Y, branch2Y, branch3Y);

    // Draw current labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'I₁=${(i1 * 1000).toStringAsFixed(0)}mA',
      style: const TextStyle(color: Colors.orange, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rightX + 5, branch1Y - 6));

    if (r2Connected) {
      textPainter.text = TextSpan(
        text: 'I₂=${(i2 * 1000).toStringAsFixed(0)}mA',
        style: const TextStyle(color: Colors.cyan, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rightX + 5, branch2Y - 6));
    }

    if (r3Connected) {
      textPainter.text = TextSpan(
        text: 'I₃=${(i3 * 1000).toStringAsFixed(0)}mA',
        style: const TextStyle(color: Colors.purple, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(rightX + 5, branch3Y - 6));
    }

    // Voltage labels
    textPainter.text = TextSpan(
      text: 'V=${voltage.toStringAsFixed(0)}V across each branch',
      style: const TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, bottomY + 5));
  }

  void _drawBattery(Canvas canvas, Offset center, double v) {
    final batteryPaint = Paint()..strokeWidth = 4;

    // Positive terminal (longer line)
    batteryPaint.color = Colors.red;
    canvas.drawLine(
      Offset(center.dx + 10, center.dy - 15),
      Offset(center.dx + 10, center.dy + 15),
      batteryPaint,
    );

    // Negative terminal (shorter line)
    batteryPaint.color = Colors.blue;
    canvas.drawLine(
      Offset(center.dx - 10, center.dy - 8),
      Offset(center.dx - 10, center.dy + 8),
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
    textPainter.paint(canvas, Offset(center.dx - 10, center.dy - 25));
  }

  void _drawResistor(Canvas canvas, Offset center, double resistance, Color color, String label) {
    final resistorPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Zigzag resistor symbol
    final path = Path();
    path.moveTo(center.dx - 30, center.dy);
    for (int i = 0; i < 6; i++) {
      final x = center.dx - 25 + i * 10;
      final y = center.dy + (i.isEven ? -8 : 8);
      path.lineTo(x, y);
    }
    path.lineTo(center.dx + 30, center.dy);

    canvas.drawPath(path, resistorPaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label\n${resistance.toStringAsFixed(0)}Ω',
        style: TextStyle(color: color, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - 15, center.dy + 10));
  }

  void _drawCurrentArrow(Canvas canvas, Offset position, double current, bool rightward) {
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    final dir = rightward ? 1.0 : -1.0;
    final length = 15.0 * (current / 0.1).clamp(0.3, 1.5);

    canvas.drawLine(
      Offset(position.dx - length * dir, position.dy),
      Offset(position.dx + length * dir, position.dy),
      arrowPaint,
    );

    // Arrow head
    canvas.drawLine(
      Offset(position.dx + length * dir, position.dy),
      Offset(position.dx + (length - 5) * dir, position.dy - 4),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(position.dx + length * dir, position.dy),
      Offset(position.dx + (length - 5) * dir, position.dy + 4),
      arrowPaint,
    );
  }

  void _drawElectrons(Canvas canvas, Size size, double y1, double y2, double y3) {
    final electronPaint = Paint()..color = Colors.yellow;
    final leftX = 40.0;
    final rightX = size.width - 40;

    // Electrons in branch 1
    for (int i = 0; i < 4; i++) {
      final t = (electronPhase + i * 0.25) % 1.0;
      final x = leftX + t * (rightX - leftX);
      canvas.drawCircle(Offset(x, y1), 3, electronPaint);
    }

    // Electrons in branch 2 if connected
    if (r2Connected) {
      for (int i = 0; i < 3; i++) {
        final t = (electronPhase * 0.7 + i * 0.33) % 1.0;
        final x = leftX + t * (rightX - leftX);
        canvas.drawCircle(Offset(x, y2), 3, electronPaint);
      }
    }

    // Electrons in branch 3 if connected
    if (r3Connected) {
      for (int i = 0; i < 2; i++) {
        final t = (electronPhase * 0.5 + i * 0.5) % 1.0;
        final x = leftX + t * (rightX - leftX);
        canvas.drawCircle(Offset(x, y3), 3, electronPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParallelCircuitPainter oldDelegate) {
    return electronPhase != oldDelegate.electronPhase ||
        r1 != oldDelegate.r1 ||
        r2 != oldDelegate.r2 ||
        r3 != oldDelegate.r3 ||
        r2Connected != oldDelegate.r2Connected ||
        r3Connected != oldDelegate.r3Connected ||
        voltage != oldDelegate.voltage;
  }
}
