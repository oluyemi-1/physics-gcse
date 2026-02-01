import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class GeneratorSimulation extends StatefulWidget {
  const GeneratorSimulation({super.key});

  @override
  State<GeneratorSimulation> createState() => _GeneratorSimulationState();
}

class _GeneratorSimulationState extends State<GeneratorSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _coilAngle = 0.0;
  double _rotationSpeed = 1.0;
  bool _showMagneticField = true;
  bool _isRotating = true;
  bool _hasSpokenIntro = false;

  // AC generator mode or DC generator mode
  bool _isACGenerator = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateRotation);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Generator simulation! '
          'A generator converts kinetic energy into electrical energy using electromagnetic induction. '
          'When a coil rotates in a magnetic field, the changing magnetic flux induces an EMF. '
          'Notice how the voltage alternates as the coil rotates through different positions.',
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

  void _updateRotation() {
    if (_isRotating) {
      setState(() {
        _coilAngle += 0.03 * _rotationSpeed;
        if (_coilAngle > 2 * math.pi) {
          _coilAngle -= 2 * math.pi;
        }
      });
    }
  }

  double _getInducedEMF() {
    // EMF = NABω sin(ωt) - maximum when coil is parallel to field
    return math.cos(_coilAngle);
  }

  void _onSpeedChanged(double value) {
    setState(() {
      _rotationSpeed = value;
    });

    if (value > 2.0) {
      speakSimulation(
        'Higher rotation speed increases the frequency and peak voltage of the induced EMF. '
        'This is why power stations use high-speed turbines.',
      );
    }
  }

  void _toggleGeneratorType() {
    setState(() {
      _isACGenerator = !_isACGenerator;
    });

    if (_isACGenerator) {
      speakSimulation(
        'AC generator selected. Uses slip rings to maintain continuous contact. '
        'The output voltage alternates between positive and negative.',
        force: true,
      );
    } else {
      speakSimulation(
        'DC generator selected. Uses a split-ring commutator to reverse connections every half turn. '
        'This produces a pulsating direct current that always flows in one direction.',
        force: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final emf = _getInducedEMF();

    return Column(
      children: [
        // Generator visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade700),
            ),
            child: CustomPaint(
              painter: _GeneratorPainter(
                coilAngle: _coilAngle,
                showMagneticField: _showMagneticField,
                isACGenerator: _isACGenerator,
                emf: emf,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // EMF display
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                _isACGenerator ? 'AC Generator' : 'DC Generator',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Induced EMF: ',
                      style: TextStyle(color: Colors.white70)),
                  Text(
                    '${(_isACGenerator ? emf : emf.abs()).toStringAsFixed(2)} V',
                    style: TextStyle(
                      color: emf >= 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'EMF = NABω sin(θ)',
                style: TextStyle(
                    color: Colors.cyan, fontFamily: 'monospace', fontSize: 12),
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
                // Generator type toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('AC', style: TextStyle(color: Colors.white)),
                    Switch(
                      value: !_isACGenerator,
                      onChanged: (_) => _toggleGeneratorType(),
                      activeColor: Colors.orange,
                    ),
                    const Text('DC', style: TextStyle(color: Colors.white)),
                  ],
                ),

                // Speed slider
                Row(
                  children: [
                    const SizedBox(
                        width: 90,
                        child: Text('Speed:',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _rotationSpeed,
                        min: 0.2,
                        max: 3.0,
                        onChanged: _onSpeedChanged,
                        activeColor: Colors.orange,
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
                          value: _isRotating,
                          onChanged: (v) =>
                              setState(() => _isRotating = v ?? true),
                          activeColor: Colors.green,
                        ),
                        const Text('Rotate',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 16),
                        Checkbox(
                          value: _showMagneticField,
                          onChanged: (v) =>
                              setState(() => _showMagneticField = v ?? true),
                          activeColor: Colors.blue,
                        ),
                        const Text('B Field',
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
      ],
    );
  }
}

class _GeneratorPainter extends CustomPainter {
  final double coilAngle;
  final bool showMagneticField;
  final bool isACGenerator;
  final double emf;

  _GeneratorPainter({
    required this.coilAngle,
    required this.showMagneticField,
    required this.isACGenerator,
    required this.emf,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw magnetic field lines
    if (showMagneticField) {
      _drawMagneticField(canvas, size);
    }

    // Draw magnets
    _drawMagnets(canvas, size);

    // Draw rotating coil
    _drawCoil(canvas, centerX, centerY);

    // Draw slip rings or commutator
    if (isACGenerator) {
      _drawSlipRings(canvas, centerX, centerY + 60);
    } else {
      _drawCommutator(canvas, centerX, centerY + 60);
    }

    // Draw output graph
    _drawOutputGraph(canvas, size);
  }

  void _drawMagneticField(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    for (double y = 30; y < size.height - 80; y += 25) {
      // Draw field lines from N to S
      canvas.drawLine(
        Offset(30, y),
        Offset(size.width - 30, y),
        fieldPaint,
      );

      // Arrows
      final arrowPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;

      final path = Path();
      path.moveTo(size.width / 2 + 20, y);
      path.lineTo(size.width / 2 + 10, y - 5);
      path.lineTo(size.width / 2 + 10, y + 5);
      path.close();
      canvas.drawPath(path, arrowPaint);
    }
  }

  void _drawMagnets(Canvas canvas, Size size) {
    // North pole (left)
    final nPaint = Paint()..color = Colors.red;
    canvas.drawRect(
      Rect.fromLTWH(10, size.height / 2 - 60, 30, 120),
      nPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(18, size.height / 2 - 10));

    // South pole (right)
    final sPaint = Paint()..color = Colors.blue;
    canvas.drawRect(
      Rect.fromLTWH(size.width - 40, size.height / 2 - 60, 30, 120),
      sPaint,
    );

    textPainter.text = const TextSpan(
      text: 'S',
      style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 32, size.height / 2 - 10));
  }

  void _drawCoil(Canvas canvas, double cx, double cy) {
    final coilPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Coil dimensions
    const coilWidth = 80.0;
    const coilHeight = 60.0;

    // Calculate coil appearance based on rotation
    final perspectiveWidth = coilWidth * math.cos(coilAngle);

    // Draw coil as a rectangle with perspective
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy - 20),
        width: perspectiveWidth.abs() + 10,
        height: coilHeight,
      ),
      const Radius.circular(5),
    );
    canvas.drawRRect(rect, coilPaint);

    // Draw coil sides with depth
    if (perspectiveWidth > 0) {
      coilPaint.color = Colors.orange.shade300;
    } else {
      coilPaint.color = Colors.orange.shade700;
    }

    // Axle
    final axlePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 6;
    canvas.drawLine(
      Offset(cx, cy - 20),
      Offset(cx, cy + 60),
      axlePaint,
    );

    // Rotation indicator
    final indicatorPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3;
    final indicatorLength = 25.0;
    canvas.drawLine(
      Offset(cx, cy - 20),
      Offset(
        cx + indicatorLength * math.cos(coilAngle),
        cy - 20 + indicatorLength * math.sin(coilAngle),
      ),
      indicatorPaint,
    );
  }

  void _drawSlipRings(Canvas canvas, double cx, double cy) {
    // Two separate rings for AC
    final ringPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(Offset(cx - 15, cy), 12, ringPaint);
    canvas.drawCircle(Offset(cx + 15, cy), 12, ringPaint);

    // Brushes
    final brushPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 6;
    canvas.drawLine(Offset(cx - 15, cy + 12), Offset(cx - 15, cy + 25), brushPaint);
    canvas.drawLine(Offset(cx + 15, cy + 12), Offset(cx + 15, cy + 25), brushPaint);

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Slip Rings',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - 25, cy + 30));
  }

  void _drawCommutator(Canvas canvas, double cx, double cy) {
    // Split ring commutator
    final ringPaint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw two half circles
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 30),
      -math.pi / 2 + coilAngle,
      math.pi,
      false,
      ringPaint,
    );

    ringPaint.color = Colors.amber.shade700;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, cy), width: 30, height: 30),
      math.pi / 2 + coilAngle,
      math.pi,
      false,
      ringPaint,
    );

    // Brushes (fixed position)
    final brushPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 6;
    canvas.drawLine(Offset(cx, cy + 15), Offset(cx, cy + 28), brushPaint);

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Commutator',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - 30, cy + 32));
  }

  void _drawOutputGraph(Canvas canvas, Size size) {
    final graphLeft = size.width - 120;
    final graphTop = 20.0;
    const graphWidth = 100.0;
    const graphHeight = 60.0;

    // Background
    final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawRect(
      Rect.fromLTWH(graphLeft, graphTop, graphWidth, graphHeight),
      bgPaint,
    );

    // Axes
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(graphLeft, graphTop + graphHeight / 2),
      Offset(graphLeft + graphWidth, graphTop + graphHeight / 2),
      axisPaint,
    );

    // Draw waveform
    final wavePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i <= graphWidth.toInt(); i++) {
      final x = graphLeft + i;
      final angle = (i / graphWidth) * 4 * math.pi + coilAngle;
      double y;
      if (isACGenerator) {
        y = graphTop + graphHeight / 2 - math.cos(angle) * (graphHeight / 2 - 5);
      } else {
        y = graphTop + graphHeight / 2 - math.cos(angle).abs() * (graphHeight / 2 - 5);
      }

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, wavePaint);

    // Current position marker
    final markerX = graphLeft + (coilAngle / (4 * math.pi)) * graphWidth % graphWidth;
    final markerPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(markerX, graphTop),
      Offset(markerX, graphTop + graphHeight),
      markerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GeneratorPainter oldDelegate) {
    return coilAngle != oldDelegate.coilAngle ||
        showMagneticField != oldDelegate.showMagneticField ||
        isACGenerator != oldDelegate.isACGenerator;
  }
}
