import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class RefractionSimulation extends StatefulWidget {
  const RefractionSimulation({super.key});

  @override
  State<RefractionSimulation> createState() => _RefractionSimulationState();
}

class _RefractionSimulationState extends State<RefractionSimulation>
    with SimulationTTSMixin {
  double _incidentAngle = 45.0; // degrees
  bool _showNormal = true;
  bool _showAngles = true;
  bool _hasSpokenIntro = false;

  String _medium1 = 'Air';
  String _medium2 = 'Glass';

  final Map<String, double> _refractiveIndices = {
    'Air': 1.00,
    'Water': 1.33,
    'Glass': 1.50,
    'Diamond': 2.42,
    'Oil': 1.47,
  };

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Refraction simulation! '
          'When light passes from one medium to another, it changes speed and bends. '
          'Light bends towards the normal when entering a denser medium, and away when entering a less dense medium. '
          'Snell\'s Law describes this relationship: n₁ sin θ₁ equals n₂ sin θ₂.',
          force: true,
        );
      }
    });
  }

  double _getRefractedAngle() {
    final n1 = _refractiveIndices[_medium1]!;
    final n2 = _refractiveIndices[_medium2]!;

    // Snell's law: n1 * sin(θ1) = n2 * sin(θ2)
    final sinTheta1 = math.sin(_incidentAngle * math.pi / 180);
    final sinTheta2 = (n1 / n2) * sinTheta1;

    // Check for total internal reflection
    if (sinTheta2.abs() > 1) {
      return double.nan; // Total internal reflection
    }

    return math.asin(sinTheta2) * 180 / math.pi;
  }

  double _getCriticalAngle() {
    final n1 = _refractiveIndices[_medium1]!;
    final n2 = _refractiveIndices[_medium2]!;

    if (n1 <= n2) return double.nan; // No critical angle

    return math.asin(n2 / n1) * 180 / math.pi;
  }

  void _onAngleChanged(double value) {
    setState(() {
      _incidentAngle = value;
    });

    final refracted = _getRefractedAngle();
    final critical = _getCriticalAngle();

    if (refracted.isNaN && !critical.isNaN) {
      speakSimulation(
        'Total internal reflection! The angle exceeds the critical angle of ${critical.toStringAsFixed(1)} degrees. '
        'All light is reflected back into the denser medium.',
      );
    }
  }

  void _onMedium1Changed(String? medium) {
    if (medium == null) return;
    setState(() {
      _medium1 = medium;
    });
    _announceChange();
  }

  void _onMedium2Changed(String? medium) {
    if (medium == null) return;
    setState(() {
      _medium2 = medium;
    });
    _announceChange();
  }

  void _announceChange() {
    final n1 = _refractiveIndices[_medium1]!;
    final n2 = _refractiveIndices[_medium2]!;

    if (n1 > n2) {
      speakSimulation(
        'Light traveling from $_medium1 to $_medium2. '
        'Since $_medium1 is optically denser, light will bend away from the normal. '
        'Total internal reflection is possible above the critical angle.',
        force: true,
      );
    } else if (n1 < n2) {
      speakSimulation(
        'Light traveling from $_medium1 to $_medium2. '
        'Since $_medium2 is optically denser, light will bend towards the normal.',
        force: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final n1 = _refractiveIndices[_medium1]!;
    final n2 = _refractiveIndices[_medium2]!;
    final refractedAngle = _getRefractedAngle();
    final criticalAngle = _getCriticalAngle();

    return Column(
      children: [
        // Refraction visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.yellow.shade700),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: CustomPaint(
                painter: _RefractionPainter(
                  incidentAngle: _incidentAngle,
                  refractedAngle: refractedAngle,
                  showNormal: _showNormal,
                  showAngles: _showAngles,
                  medium1Color: _getMediumColor(_medium1),
                  medium2Color: _getMediumColor(_medium2),
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.yellow.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(_medium1,
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('n = ${n1.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.cyan, fontSize: 14)),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
                  Column(
                    children: [
                      Text(_medium2,
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                      Text('n = ${n2.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.cyan, fontSize: 14)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                refractedAngle.isNaN
                    ? 'TOTAL INTERNAL REFLECTION'
                    : 'Refracted angle: ${refractedAngle.toStringAsFixed(1)}°',
                style: TextStyle(
                  color: refractedAngle.isNaN ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!criticalAngle.isNaN)
                Text(
                  'Critical angle: ${criticalAngle.toStringAsFixed(1)}°',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              const SizedBox(height: 4),
              const Text(
                'n₁ sin θ₁ = n₂ sin θ₂',
                style: TextStyle(
                    color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
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
                // Medium selectors
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('From:',
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 11)),
                          DropdownButton<String>(
                            value: _medium1,
                            dropdownColor: Colors.grey[800],
                            isExpanded: true,
                            items: _refractiveIndices.keys.map((medium) {
                              return DropdownMenuItem(
                                value: medium,
                                child: Text(medium,
                                    style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: _onMedium1Changed,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('To:',
                              style:
                                  TextStyle(color: Colors.white70, fontSize: 11)),
                          DropdownButton<String>(
                            value: _medium2,
                            dropdownColor: Colors.grey[800],
                            isExpanded: true,
                            items: _refractiveIndices.keys.map((medium) {
                              return DropdownMenuItem(
                                value: medium,
                                child: Text(medium,
                                    style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: _onMedium2Changed,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Angle slider
                Row(
                  children: [
                    SizedBox(
                        width: 90,
                        child: Text('Angle: ${_incidentAngle.toStringAsFixed(0)}°',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _incidentAngle,
                        min: 0,
                        max: 89,
                        onChanged: _onAngleChanged,
                        activeColor: Colors.yellow,
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
                          value: _showNormal,
                          onChanged: (v) =>
                              setState(() => _showNormal = v ?? true),
                          activeColor: Colors.white,
                        ),
                        const Text('Normal',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Checkbox(
                          value: _showAngles,
                          onChanged: (v) =>
                              setState(() => _showAngles = v ?? true),
                          activeColor: Colors.cyan,
                        ),
                        const Text('Angles',
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

  Color _getMediumColor(String medium) {
    switch (medium) {
      case 'Air':
        return Colors.lightBlue.shade100.withValues(alpha: 0.2);
      case 'Water':
        return Colors.blue.shade300.withValues(alpha: 0.5);
      case 'Glass':
        return Colors.cyan.shade200.withValues(alpha: 0.4);
      case 'Diamond':
        return Colors.purple.shade100.withValues(alpha: 0.4);
      case 'Oil':
        return Colors.amber.shade200.withValues(alpha: 0.4);
      default:
        return Colors.grey.withValues(alpha: 0.3);
    }
  }
}

class _RefractionPainter extends CustomPainter {
  final double incidentAngle;
  final double refractedAngle;
  final bool showNormal;
  final bool showAngles;
  final Color medium1Color;
  final Color medium2Color;

  _RefractionPainter({
    required this.incidentAngle,
    required this.refractedAngle,
    required this.showNormal,
    required this.showAngles,
    required this.medium1Color,
    required this.medium2Color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw media backgrounds
    final medium1Paint = Paint()..color = medium1Color;
    final medium2Paint = Paint()..color = medium2Color;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, centerY),
      medium1Paint,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, centerY, size.width, centerY),
      medium2Paint,
    );

    // Draw boundary line
    final boundaryPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      boundaryPaint,
    );

    // Draw normal line
    if (showNormal) {
      final normalPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      // Dashed normal line
      const dashLength = 5.0;
      for (double y = 20; y < size.height - 20; y += dashLength * 2) {
        canvas.drawLine(
          Offset(centerX, y),
          Offset(centerX, math.min(y + dashLength, size.height - 20)),
          normalPaint,
        );
      }

      // Normal label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Normal',
          style: TextStyle(color: Colors.white70, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX + 5, 25));
    }

    // Calculate ray positions
    final incidentRadians = incidentAngle * math.pi / 180;
    final rayLength = 120.0;

    // Incident ray (coming from top-left)
    final incidentStartX = centerX - rayLength * math.sin(incidentRadians);
    final incidentStartY = centerY - rayLength * math.cos(incidentRadians);

    final incidentPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(incidentStartX, incidentStartY),
      Offset(centerX, centerY),
      incidentPaint,
    );

    // Arrow on incident ray
    _drawArrowHead(canvas, Offset(centerX, centerY), incidentRadians + math.pi, Colors.yellow);

    // Refracted or reflected ray
    if (refractedAngle.isNaN) {
      // Total internal reflection
      final reflectedRadians = incidentRadians;
      final reflectedEndX = centerX + rayLength * math.sin(reflectedRadians);
      final reflectedEndY = centerY - rayLength * math.cos(reflectedRadians);

      final reflectedPaint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3;

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(reflectedEndX, reflectedEndY),
        reflectedPaint,
      );

      _drawArrowHead(canvas, Offset(reflectedEndX, reflectedEndY), -reflectedRadians, Colors.red);

      // Label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Reflected ray',
          style: TextStyle(color: Colors.red, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(reflectedEndX - 30, reflectedEndY - 20));
    } else {
      // Normal refraction
      final refractedRadians = refractedAngle * math.pi / 180;
      final refractedEndX = centerX + rayLength * math.sin(refractedRadians);
      final refractedEndY = centerY + rayLength * math.cos(refractedRadians);

      final refractedPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3;

      canvas.drawLine(
        Offset(centerX, centerY),
        Offset(refractedEndX, refractedEndY),
        refractedPaint,
      );

      _drawArrowHead(canvas, Offset(refractedEndX, refractedEndY), refractedRadians + math.pi, Colors.green);
    }

    // Draw partial reflection (always present)
    final partialReflectPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    final reflectedEndX = centerX + rayLength * 0.5 * math.sin(incidentRadians);
    final reflectedEndY = centerY - rayLength * 0.5 * math.cos(incidentRadians);

    canvas.drawLine(
      Offset(centerX, centerY),
      Offset(reflectedEndX, reflectedEndY),
      partialReflectPaint,
    );

    // Draw angle arcs
    if (showAngles) {
      final arcPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // Incident angle arc
      arcPaint.color = Colors.yellow;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(centerX, centerY), width: 60, height: 60),
        -math.pi / 2 - incidentRadians,
        incidentRadians,
        false,
        arcPaint,
      );

      // Refracted angle arc
      if (!refractedAngle.isNaN) {
        final refractedRadians = refractedAngle * math.pi / 180;
        arcPaint.color = Colors.green;
        canvas.drawArc(
          Rect.fromCenter(center: Offset(centerX, centerY), width: 60, height: 60),
          math.pi / 2 - refractedRadians,
          refractedRadians,
          false,
          arcPaint,
        );
      }

      // Angle labels
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      textPainter.text = TextSpan(
        text: 'θ₁=${incidentAngle.toStringAsFixed(0)}°',
        style: const TextStyle(color: Colors.yellow, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX - 50, centerY - 50));

      if (!refractedAngle.isNaN) {
        textPainter.text = TextSpan(
          text: 'θ₂=${refractedAngle.toStringAsFixed(0)}°',
          style: const TextStyle(color: Colors.green, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(centerX + 10, centerY + 30));
      }
    }

    // Labels for rays
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'Incident ray',
      style: TextStyle(color: Colors.yellow, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(incidentStartX - 20, incidentStartY));

    if (!refractedAngle.isNaN) {
      textPainter.text = const TextSpan(
        text: 'Refracted ray',
        style: TextStyle(color: Colors.green, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX + 40, size.height - 40));
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const arrowSize = 10.0;
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx + arrowSize * math.cos(angle + 2.5),
      tip.dy + arrowSize * math.sin(angle + 2.5),
    );
    path.lineTo(
      tip.dx + arrowSize * math.cos(angle - 2.5),
      tip.dy + arrowSize * math.sin(angle - 2.5),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _RefractionPainter oldDelegate) {
    return incidentAngle != oldDelegate.incidentAngle ||
        refractedAngle != oldDelegate.refractedAngle ||
        showNormal != oldDelegate.showNormal ||
        showAngles != oldDelegate.showAngles;
  }
}
