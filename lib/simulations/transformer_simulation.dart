import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class TransformerSimulation extends StatefulWidget {
  const TransformerSimulation({super.key});

  @override
  State<TransformerSimulation> createState() => _TransformerSimulationState();
}

class _TransformerSimulationState extends State<TransformerSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  int _primaryTurns = 100;
  int _secondaryTurns = 200;
  double _primaryVoltage = 230.0;
  bool _hasSpokenIntro = false;
  bool _isStepUp = true;

  double get _secondaryVoltage => _primaryVoltage * _secondaryTurns / _primaryTurns;
  double get _turnsRatio => _secondaryTurns / _primaryTurns;

  // Assuming 100% efficiency for ideal transformer
  double get _primaryCurrent => 1.0; // Arbitrary 1A input
  double get _secondaryCurrent => _primaryCurrent * _primaryTurns / _secondaryTurns;

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
          'Welcome to the Transformer simulation! '
          'A transformer changes AC voltage using electromagnetic induction. '
          'It has two coils: the primary coil connected to input, and the secondary coil for output. '
          'The voltage ratio equals the turns ratio. '
          'A step-up transformer increases voltage, a step-down transformer decreases it.',
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

  void _onPrimaryTurnsChanged(double value) {
    setState(() {
      _primaryTurns = value.toInt();
      _isStepUp = _secondaryTurns > _primaryTurns;
    });
    _announceChange();
  }

  void _onSecondaryTurnsChanged(double value) {
    setState(() {
      _secondaryTurns = value.toInt();
      _isStepUp = _secondaryTurns > _primaryTurns;
    });
    _announceChange();
  }

  void _onPrimaryVoltageChanged(double value) {
    setState(() {
      _primaryVoltage = value;
    });
    speakSimulation(
      'Primary voltage set to ${value.toStringAsFixed(0)} volts. '
      'Secondary voltage is now ${_secondaryVoltage.toStringAsFixed(1)} volts.',
    );
  }

  void _announceChange() {
    final type = _isStepUp ? 'step-up' : 'step-down';
    speakSimulation(
      'This is now a $type transformer. '
      'Primary coil has $_primaryTurns turns, secondary has $_secondaryTurns turns. '
      'Turns ratio is ${_turnsRatio.toStringAsFixed(2)}. '
      'Output voltage is ${_secondaryVoltage.toStringAsFixed(1)} volts.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Transformer diagram
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade300),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _TransformerPainter(
                    primaryTurns: _primaryTurns,
                    secondaryTurns: _secondaryTurns,
                    primaryVoltage: _primaryVoltage,
                    secondaryVoltage: _secondaryVoltage,
                    animationValue: _controller.value,
                    isStepUp: _isStepUp,
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
        ),

        // Data display
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _isStepUp ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                _isStepUp ? 'STEP-UP TRANSFORMER' : 'STEP-DOWN TRANSFORMER',
                style: TextStyle(
                  color: _isStepUp ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDataColumn('Primary', '$_primaryTurns turns', '${_primaryVoltage.toStringAsFixed(0)} V', '${_primaryCurrent.toStringAsFixed(2)} A'),
                  const Icon(Icons.arrow_forward, color: Colors.grey),
                  _buildDataColumn('Secondary', '$_secondaryTurns turns', '${_secondaryVoltage.toStringAsFixed(1)} V', '${_secondaryCurrent.toStringAsFixed(3)} A'),
                ],
              ),
            ],
          ),
        ),

        // Formula
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Transformer Equation',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Vp/Vs = Np/Ns = Is/Ip',
                style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
              ),
              Text(
                '${_primaryVoltage.toStringAsFixed(0)}/${_secondaryVoltage.toStringAsFixed(1)} = $_primaryTurns/$_secondaryTurns',
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
                // Primary turns slider
                Row(
                  children: [
                    const SizedBox(width: 110, child: Text('Primary Turns:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _primaryTurns.toDouble(),
                        min: 10,
                        max: 500,
                        divisions: 49,
                        onChanged: _onPrimaryTurnsChanged,
                        activeColor: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 50, child: Text('$_primaryTurns', style: const TextStyle(color: Colors.white))),
                  ],
                ),

                // Secondary turns slider
                Row(
                  children: [
                    const SizedBox(width: 110, child: Text('Secondary Turns:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _secondaryTurns.toDouble(),
                        min: 10,
                        max: 500,
                        divisions: 49,
                        onChanged: _onSecondaryTurnsChanged,
                        activeColor: Colors.red,
                      ),
                    ),
                    SizedBox(width: 50, child: Text('$_secondaryTurns', style: const TextStyle(color: Colors.white))),
                  ],
                ),

                // Input voltage slider
                Row(
                  children: [
                    const SizedBox(width: 110, child: Text('Input Voltage:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _primaryVoltage,
                        min: 10,
                        max: 400,
                        divisions: 39,
                        onChanged: _onPrimaryVoltageChanged,
                        activeColor: Colors.yellow,
                      ),
                    ),
                    SizedBox(width: 50, child: Text('${_primaryVoltage.toStringAsFixed(0)}V', style: const TextStyle(color: Colors.white))),
                  ],
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

  Widget _buildDataColumn(String title, String turns, String voltage, String current) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        Text(turns, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(voltage, style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
        Text(current, style: const TextStyle(color: Colors.cyan, fontSize: 12)),
      ],
    );
  }
}

class _TransformerPainter extends CustomPainter {
  final int primaryTurns;
  final int secondaryTurns;
  final double primaryVoltage;
  final double secondaryVoltage;
  final double animationValue;
  final bool isStepUp;

  _TransformerPainter({
    required this.primaryTurns,
    required this.secondaryTurns,
    required this.primaryVoltage,
    required this.secondaryVoltage,
    required this.animationValue,
    required this.isStepUp,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw iron core
    _drawIronCore(canvas, centerX, centerY);

    // Draw primary coil (left side)
    _drawCoil(canvas, centerX - 80, centerY, primaryTurns, Colors.blue, 'Primary');

    // Draw secondary coil (right side)
    _drawCoil(canvas, centerX + 80, centerY, secondaryTurns, Colors.red, 'Secondary');

    // Draw magnetic field lines (animated)
    _drawMagneticField(canvas, centerX, centerY);

    // Draw AC input symbol
    _drawACSymbol(canvas, 30, centerY, primaryVoltage, Colors.blue);

    // Draw output
    _drawACSymbol(canvas, size.width - 50, centerY, secondaryVoltage, Colors.red);

    // Draw labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'AC Input',
      style: TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(15, 20));

    textPainter.text = const TextSpan(
      text: 'AC Output',
      style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 70, 20));

    // Draw transformer type label
    textPainter.text = TextSpan(
      text: isStepUp ? 'Step-Up' : 'Step-Down',
      style: TextStyle(
        color: isStepUp ? Colors.green : Colors.orange,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, 10));

    // Draw efficiency note
    textPainter.text = const TextSpan(
      text: 'Power in = Power out (ideal)',
      style: TextStyle(color: Colors.grey, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, size.height - 25));

    textPainter.text = TextSpan(
      text: 'Vp × Ip = Vs × Is = ${(primaryVoltage * 1.0).toStringAsFixed(0)} W',
      style: const TextStyle(color: Colors.grey, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, size.height - 12));
  }

  void _drawIronCore(Canvas canvas, double centerX, double centerY) {
    final corePaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;

    // Draw E-shaped core pieces
    final coreHeight = 100.0;

    // Left vertical bar
    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX - 50, centerY), width: 15, height: coreHeight),
      corePaint,
    );

    // Right vertical bar
    canvas.drawRect(
      Rect.fromCenter(center: Offset(centerX + 50, centerY), width: 15, height: coreHeight),
      corePaint,
    );

    // Top horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(centerX - 57, centerY - coreHeight / 2, 114, 12),
      corePaint,
    );

    // Bottom horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(centerX - 57, centerY + coreHeight / 2 - 12, 114, 12),
      corePaint,
    );

    // Center horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(centerX - 57, centerY - 6, 114, 12),
      corePaint,
    );

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Iron Core',
        style: TextStyle(color: Colors.grey, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 22, centerY - 3));
  }

  void _drawCoil(Canvas canvas, double x, double y, int turns, Color color, String label) {
    final coilPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw coil representation (simplified as loops)
    final displayTurns = (turns / 20).clamp(3, 15).toInt();
    final coilHeight = 70.0;
    final turnSpacing = coilHeight / displayTurns;

    for (int i = 0; i < displayTurns; i++) {
      final ty = y - coilHeight / 2 + i * turnSpacing + turnSpacing / 2;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, ty), width: 30, height: turnSpacing * 0.8),
        0,
        math.pi,
        false,
        coilPaint,
      );
      canvas.drawArc(
        Rect.fromCenter(center: Offset(x, ty), width: 30, height: turnSpacing * 0.8),
        math.pi,
        math.pi,
        false,
        coilPaint..color = color.withValues(alpha: 0.5),
      );
      coilPaint.color = color;
    }

    // Draw connection wires
    final wirePaint = Paint()
      ..color = color
      ..strokeWidth = 2;

    if (label == 'Primary') {
      canvas.drawLine(Offset(x - 15, y - coilHeight / 2), Offset(30, y - 30), wirePaint);
      canvas.drawLine(Offset(x - 15, y + coilHeight / 2), Offset(30, y + 30), wirePaint);
    } else {
      canvas.drawLine(Offset(x + 15, y - coilHeight / 2), Offset(x + 80, y - 30), wirePaint);
      canvas.drawLine(Offset(x + 15, y + coilHeight / 2), Offset(x + 80, y + 30), wirePaint);
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$label\n$turns turns',
        style: TextStyle(color: color, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + coilHeight / 2 + 10));
  }

  void _drawMagneticField(Canvas canvas, double centerX, double centerY) {
    final fieldPaint = Paint()
      ..color = Colors.purple.withValues(alpha: 0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Animated field lines inside core
    final offset = animationValue * 20;

    for (int i = 0; i < 3; i++) {
      final y = centerY - 20 + i * 20;
      final dashOffset = (offset + i * 7) % 20;

      // Draw dashed line to show field direction
      for (double x = centerX - 40 + dashOffset; x < centerX + 40; x += 20) {
        canvas.drawLine(Offset(x, y), Offset(x + 10, y), fieldPaint);
      }

      // Arrow heads
      final arrowX = centerX + 30 - ((animationValue * 60) % 60);
      _drawArrowHead(canvas, arrowX, y, true, fieldPaint.color);
    }
  }

  void _drawArrowHead(Canvas canvas, double x, double y, bool rightFacing, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (rightFacing) {
      path.moveTo(x + 5, y);
      path.lineTo(x - 3, y - 4);
      path.lineTo(x - 3, y + 4);
    } else {
      path.moveTo(x - 5, y);
      path.lineTo(x + 3, y - 4);
      path.lineTo(x + 3, y + 4);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawACSymbol(Canvas canvas, double x, double y, double voltage, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw sine wave symbol
    final path = Path();
    path.moveTo(x - 15, y);
    path.quadraticBezierTo(x - 7, y - 15, x, y);
    path.quadraticBezierTo(x + 7, y + 15, x + 15, y);
    canvas.drawPath(path, paint);

    // Voltage label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${voltage.toStringAsFixed(0)}V',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y + 20));
  }

  @override
  bool shouldRepaint(covariant _TransformerPainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        primaryTurns != oldDelegate.primaryTurns ||
        secondaryTurns != oldDelegate.secondaryTurns ||
        primaryVoltage != oldDelegate.primaryVoltage;
  }
}
