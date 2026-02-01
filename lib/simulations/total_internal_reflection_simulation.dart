import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Total Internal Reflection Simulation demonstrating critical angle
/// Shows how light reflects completely when angle exceeds critical angle
class TotalInternalReflectionSimulation extends StatefulWidget {
  const TotalInternalReflectionSimulation({super.key});

  @override
  State<TotalInternalReflectionSimulation> createState() => _TotalInternalReflectionSimulationState();
}

class _TotalInternalReflectionSimulationState extends State<TotalInternalReflectionSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _incidentAngle = 30.0; // degrees
  double _n1 = 1.5; // Refractive index of medium 1 (glass)
  double _n2 = 1.0; // Refractive index of medium 2 (air)

  String _medium1 = 'Glass';
  String _medium2 = 'Air';

  final Map<String, double> _refractiveIndices = {
    'Air': 1.0,
    'Water': 1.33,
    'Glass': 1.5,
    'Diamond': 2.42,
    'Acrylic': 1.49,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Total Internal Reflection Simulation. When light travels from a denser to a less dense medium, '
        'it bends away from the normal. At the critical angle, the refracted ray travels along the boundary. '
        'Beyond the critical angle, all light is reflected back - this is total internal reflection, '
        'used in optical fibres and prisms.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _criticalAngle {
    if (_n1 <= _n2) return 90.0; // No TIR possible
    return math.asin(_n2 / _n1) * 180 / math.pi;
  }

  bool get _isTIR => _incidentAngle > _criticalAngle;

  double get _refractedAngle {
    if (_isTIR) return double.nan;
    final sinRefracted = (_n1 / _n2) * math.sin(_incidentAngle * math.pi / 180);
    if (sinRefracted > 1) return double.nan;
    return math.asin(sinRefracted) * 180 / math.pi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Internal Reflection'),
        backgroundColor: Colors.cyan.shade800,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.cyan.shade900, Colors.black],
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
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isTIR ? Colors.yellow : Colors.cyan.shade300,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isTIR)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.yellow.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'TOTAL INTERNAL REFLECTION',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                )
              else
                const Text(
                  'Refraction Occurring',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('n₁ ($_medium1)', _n1.toStringAsFixed(2)),
              _buildInfoItem('n₂ ($_medium2)', _n2.toStringAsFixed(2)),
              _buildInfoItem('Critical Angle', '${_criticalAngle.toStringAsFixed(1)}°', Colors.yellow),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Incident Angle', '${_incidentAngle.toStringAsFixed(1)}°', Colors.blue),
              _buildInfoItem(
                'Refracted Angle',
                _isTIR ? 'N/A (TIR)' : '${_refractedAngle.toStringAsFixed(1)}°',
                _isTIR ? Colors.grey : Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'sin(θc) = n₂/n₁ = ${_n2.toStringAsFixed(2)}/${_n1.toStringAsFixed(2)} → θc = ${_criticalAngle.toStringAsFixed(1)}°',
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _TIRPainter(
                incidentAngle: _incidentAngle,
                refractedAngle: _refractedAngle,
                criticalAngle: _criticalAngle,
                isTIR: _isTIR,
                n1: _n1,
                n2: _n2,
                medium1: _medium1,
                medium2: _medium2,
                animationValue: _controller.value,
              ),
            );
          },
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
          // Medium selectors
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medium 1 (denser):', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    DropdownButton<String>(
                      value: _medium1,
                      dropdownColor: Colors.grey.shade800,
                      style: const TextStyle(color: Colors.white),
                      items: ['Glass', 'Water', 'Diamond', 'Acrylic'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && _refractiveIndices[value]! > _n2) {
                          setState(() {
                            _medium1 = value;
                            _n1 = _refractiveIndices[value]!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Medium 2 (less dense):', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    DropdownButton<String>(
                      value: _medium2,
                      dropdownColor: Colors.grey.shade800,
                      style: const TextStyle(color: Colors.white),
                      items: ['Air', 'Water'].map((m) {
                        return DropdownMenuItem(value: m, child: Text(m));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null && _refractiveIndices[value]! < _n1) {
                          setState(() {
                            _medium2 = value;
                            _n2 = _refractiveIndices[value]!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Incident angle slider
          Row(
            children: [
              const Icon(Icons.rotate_right, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              const Text('Incident Angle:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _incidentAngle,
                  min: 0,
                  max: 89,
                  activeColor: _isTIR ? Colors.yellow : Colors.blue,
                  onChanged: (value) {
                    setState(() => _incidentAngle = value);
                    if (_isTIR && value > _criticalAngle) {
                      // Crossed into TIR
                    }
                  },
                ),
              ),
              Text(
                '${_incidentAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: _isTIR ? Colors.yellow : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Critical angle indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isTIR ? Colors.yellow.shade900 : Colors.cyan.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isTIR ? Icons.flash_on : Icons.arrow_forward,
                  color: _isTIR ? Colors.yellow : Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _isTIR
                      ? 'θ > θc: Light is totally internally reflected!'
                      : 'θ < θc: Light refracts into medium 2',
                  style: TextStyle(
                    color: _isTIR ? Colors.yellow : Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Applications
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Applications: Optical fibres, Prisms in binoculars, Diamond sparkle, Endoscopes',
              style: TextStyle(color: Colors.white54, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _TIRPainter extends CustomPainter {
  final double incidentAngle;
  final double refractedAngle;
  final double criticalAngle;
  final bool isTIR;
  final double n1;
  final double n2;
  final String medium1;
  final String medium2;
  final double animationValue;

  _TIRPainter({
    required this.incidentAngle,
    required this.refractedAngle,
    required this.criticalAngle,
    required this.isTIR,
    required this.n1,
    required this.n2,
    required this.medium1,
    required this.medium2,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final boundaryY = size.height / 2;

    // Draw media
    _drawMedia(canvas, size, boundaryY);

    // Draw boundary
    final boundaryPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, boundaryY), Offset(size.width, boundaryY), boundaryPaint);

    // Draw normal
    _drawNormal(canvas, centerX, boundaryY);

    // Draw critical angle indicator
    _drawCriticalAngleArc(canvas, centerX, boundaryY);

    // Draw incident ray
    _drawIncidentRay(canvas, centerX, boundaryY);

    // Draw reflected ray (always present, but stronger during TIR)
    _drawReflectedRay(canvas, centerX, boundaryY);

    // Draw refracted ray (only if not TIR)
    if (!isTIR) {
      _drawRefractedRay(canvas, centerX, boundaryY);
    }

    // Draw angle labels
    _drawAngleLabels(canvas, centerX, boundaryY);

    // Draw media labels
    _drawMediaLabels(canvas, size, boundaryY);
  }

  void _drawMedia(Canvas canvas, Size size, double boundaryY) {
    // Medium 1 (denser, bottom)
    final medium1Paint = Paint()..color = Colors.blue.shade900.withAlpha(150);
    canvas.drawRect(
      Rect.fromLTWH(0, boundaryY, size.width, size.height - boundaryY),
      medium1Paint,
    );

    // Medium 2 (less dense, top)
    final medium2Paint = Paint()..color = Colors.lightBlue.shade100.withAlpha(50);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, boundaryY),
      medium2Paint,
    );
  }

  void _drawNormal(Canvas canvas, double centerX, double boundaryY) {
    final normalPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Dashed normal line
    const dashLength = 10.0;
    const gapLength = 5.0;
    var y = boundaryY - 120;
    while (y < boundaryY + 120) {
      canvas.drawLine(
        Offset(centerX, y),
        Offset(centerX, math.min(y + dashLength, boundaryY + 120)),
        normalPaint,
      );
      y += dashLength + gapLength;
    }

    // Normal label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Normal',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 5, boundaryY - 130));
  }

  void _drawCriticalAngleArc(Canvas canvas, double centerX, double boundaryY) {
    final arcPaint = Paint()
      ..color = Colors.yellow.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final arcRadius = 40.0;
    final startAngle = math.pi / 2; // From normal (pointing down)
    final sweepAngle = criticalAngle * math.pi / 180;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, boundaryY), radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      arcPaint,
    );

    // Critical angle label
    final criticalX = centerX + arcRadius * math.sin(criticalAngle * math.pi / 180);
    final criticalY = boundaryY + arcRadius * math.cos(criticalAngle * math.pi / 180);

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'θc = ${criticalAngle.toStringAsFixed(1)}°',
        style: const TextStyle(color: Colors.yellow, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(criticalX + 5, criticalY));
  }

  void _drawIncidentRay(Canvas canvas, double centerX, double boundaryY) {
    final angleRad = incidentAngle * math.pi / 180;
    final rayLength = 150.0;

    final startX = centerX - rayLength * math.sin(angleRad);
    final startY = boundaryY + rayLength * math.cos(angleRad);

    // Animated ray
    final progress = animationValue;
    final currentX = startX + (centerX - startX) * progress;
    final currentY = startY + (boundaryY - startY) * progress;

    final rayPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    canvas.drawLine(Offset(startX, startY), Offset(currentX, currentY), rayPaint);

    // Arrow head at boundary
    if (progress > 0.9) {
      _drawArrowHead(canvas, Offset(centerX, boundaryY), angleRad + math.pi, Colors.blue);
    }

    // Incident ray label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Incident ray',
        style: TextStyle(color: Colors.blue, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX - 30, startY + 10));
  }

  void _drawReflectedRay(Canvas canvas, double centerX, double boundaryY) {
    final angleRad = incidentAngle * math.pi / 180;
    final rayLength = 150.0;

    final endX = centerX + rayLength * math.sin(angleRad);
    final endY = boundaryY + rayLength * math.cos(angleRad);

    // Reflected ray (stronger during TIR)
    final alpha = isTIR ? 255 : 100;
    final rayPaint = Paint()
      ..color = Colors.orange.withAlpha(alpha)
      ..strokeWidth = isTIR ? 3 : 2;

    final progress = animationValue;
    final currentX = centerX + (endX - centerX) * progress;
    final currentY = boundaryY + (endY - boundaryY) * progress;

    canvas.drawLine(Offset(centerX, boundaryY), Offset(currentX, currentY), rayPaint);

    // Arrow head
    if (progress > 0.8) {
      _drawArrowHead(canvas, Offset(endX, endY), -angleRad, Colors.orange.withAlpha(alpha));
    }

    // Reflected ray label
    final textPainter = TextPainter(
      text: TextSpan(
        text: isTIR ? 'Totally reflected' : 'Partial reflection',
        style: TextStyle(color: Colors.orange.withAlpha(alpha), fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(endX + 5, endY));
  }

  void _drawRefractedRay(Canvas canvas, double centerX, double boundaryY) {
    if (refractedAngle.isNaN) return;

    final angleRad = refractedAngle * math.pi / 180;
    final rayLength = 150.0;

    final endX = centerX + rayLength * math.sin(angleRad);
    final endY = boundaryY - rayLength * math.cos(angleRad);

    final rayPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;

    final progress = animationValue;
    final currentX = centerX + (endX - centerX) * progress;
    final currentY = boundaryY + (endY - boundaryY) * progress;

    canvas.drawLine(Offset(centerX, boundaryY), Offset(currentX, currentY), rayPaint);

    // Arrow head
    if (progress > 0.8) {
      _drawArrowHead(canvas, Offset(endX, endY), angleRad + math.pi, Colors.green);
    }

    // Refracted ray label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Refracted ray',
        style: TextStyle(color: Colors.green, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(endX + 5, endY - 20));
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final headLength = 12.0;
    final headAngle = 0.4;

    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx - headLength * math.cos(angle - headAngle),
      tip.dy - headLength * math.sin(angle - headAngle),
    );
    path.lineTo(
      tip.dx - headLength * math.cos(angle + headAngle),
      tip.dy - headLength * math.sin(angle + headAngle),
    );
    path.close();

    canvas.drawPath(path, arrowPaint);
  }

  void _drawAngleLabels(Canvas canvas, double centerX, double boundaryY) {
    // Incident angle arc
    final incidentArcPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(centerX, boundaryY), radius: 30),
      math.pi / 2,
      incidentAngle * math.pi / 180,
      false,
      incidentArcPaint,
    );

    // Angle label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'θ₁ = ${incidentAngle.toStringAsFixed(1)}°',
        style: const TextStyle(color: Colors.blue, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 35, boundaryY + 20));

    // Refracted angle arc (if applicable)
    if (!isTIR && !refractedAngle.isNaN) {
      final refractedArcPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, boundaryY), radius: 30),
        -math.pi / 2,
        -refractedAngle * math.pi / 180,
        false,
        refractedArcPaint,
      );

      final refractedText = TextPainter(
        text: TextSpan(
          text: 'θ₂ = ${refractedAngle.toStringAsFixed(1)}°',
          style: const TextStyle(color: Colors.green, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      refractedText.layout();
      refractedText.paint(canvas, Offset(centerX + 35, boundaryY - 35));
    }
  }

  void _drawMediaLabels(Canvas canvas, Size size, double boundaryY) {
    // Medium 2 label (top)
    final medium2Text = TextPainter(
      text: TextSpan(
        text: '$medium2 (n = ${n2.toStringAsFixed(2)})',
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    medium2Text.layout();
    medium2Text.paint(canvas, Offset(10, 10));

    // Medium 1 label (bottom)
    final medium1Text = TextPainter(
      text: TextSpan(
        text: '$medium1 (n = ${n1.toStringAsFixed(2)})',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    medium1Text.layout();
    medium1Text.paint(canvas, Offset(10, size.height - 30));
  }

  @override
  bool shouldRepaint(covariant _TIRPainter oldDelegate) {
    return oldDelegate.incidentAngle != incidentAngle ||
           oldDelegate.animationValue != animationValue ||
           oldDelegate.isTIR != isTIR;
  }
}
