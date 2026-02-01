import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class MirrorsSimulation extends StatefulWidget {
  const MirrorsSimulation({super.key});

  @override
  State<MirrorsSimulation> createState() => _MirrorsSimulationState();
}

class _MirrorsSimulationState extends State<MirrorsSimulation>
    with SimulationTTSMixin {
  double _objectDistance = 150.0; // pixels from mirror
  final double _objectHeight = 40.0;
  bool _isConcave = true;
  double _focalLength = 80.0;
  bool _showRays = true;
  bool _hasSpokenIntro = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Curved Mirrors simulation! '
          'Concave mirrors converge light rays and can form real or virtual images. '
          'Convex mirrors diverge light rays and always form virtual, diminished images. '
          'Use the mirror equation: 1/f = 1/u + 1/v to calculate image position.',
          force: true,
        );
      }
    });
  }

  double _getImageDistance() {
    // Mirror equation: 1/f = 1/u + 1/v
    // v = fu/(u-f)
    final f = _isConcave ? _focalLength : -_focalLength;
    final u = _objectDistance;

    if ((u - f).abs() < 0.01) return double.infinity;
    return (f * u) / (u - f);
  }

  double _getMagnification() {
    final v = _getImageDistance();
    if (v.isInfinite) return 0;
    return -v / _objectDistance;
  }

  String _getImageType() {
    final v = _getImageDistance();
    final m = _getMagnification();

    if (v.isInfinite) return 'At infinity';

    final position = v > 0 ? 'Real' : 'Virtual';
    final orientation = m > 0 ? 'Upright' : 'Inverted';
    final size = m.abs() > 1 ? 'Magnified' : (m.abs() < 1 ? 'Diminished' : 'Same size');

    return '$position, $orientation, $size';
  }

  void _onDistanceChanged(double value) {
    setState(() {
      _objectDistance = value;
    });

    final imageType = _getImageType();
    if (_objectDistance < _focalLength && _isConcave) {
      speakSimulation(
        'Object inside focal point. Image is $imageType. '
        'This is how a magnifying mirror works.',
      );
    } else if (_objectDistance > 2 * _focalLength && _isConcave) {
      speakSimulation(
        'Object beyond centre of curvature. Image is $imageType.',
      );
    }
  }

  void _toggleMirrorType() {
    setState(() {
      _isConcave = !_isConcave;
    });

    if (_isConcave) {
      speakSimulation(
        'Concave mirror selected. Concave mirrors can form real or virtual images depending on object position.',
        force: true,
      );
    } else {
      speakSimulation(
        'Convex mirror selected. Convex mirrors always form virtual, upright, diminished images. '
        'They are used as car wing mirrors for a wider field of view.',
        force: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageDistance = _getImageDistance();
    final magnification = _getMagnification();
    final imageType = _getImageType();

    return Column(
      children: [
        // Mirror visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.shade700),
            ),
            child: CustomPaint(
              painter: _MirrorPainter(
                objectDistance: _objectDistance,
                objectHeight: _objectHeight,
                imageDistance: imageDistance,
                magnification: magnification,
                isConcave: _isConcave,
                focalLength: _focalLength,
                showRays: _showRays,
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
            color: Colors.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                _isConcave ? 'Concave Mirror' : 'Convex Mirror',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                imageType,
                style: TextStyle(
                  color: imageDistance > 0 ? Colors.green : Colors.orange,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'u = ${_objectDistance.toStringAsFixed(0)}',
                    style:
                        const TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                  Text(
                    'v = ${imageDistance.isInfinite ? "∞" : imageDistance.toStringAsFixed(0)}',
                    style:
                        const TextStyle(color: Colors.green, fontSize: 12),
                  ),
                  Text(
                    'm = ${magnification.toStringAsFixed(2)}',
                    style:
                        const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
              const Text(
                '1/f = 1/u + 1/v',
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
                // Mirror type toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Concave',
                        style: TextStyle(color: Colors.white)),
                    Switch(
                      value: !_isConcave,
                      onChanged: (_) => _toggleMirrorType(),
                      activeColor: Colors.cyan,
                    ),
                    const Text('Convex',
                        style: TextStyle(color: Colors.white)),
                  ],
                ),

                // Object distance slider
                Row(
                  children: [
                    SizedBox(
                        width: 90,
                        child: Text('Object (u):',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _objectDistance,
                        min: 30,
                        max: 250,
                        onChanged: _onDistanceChanged,
                        activeColor: Colors.blue,
                      ),
                    ),
                  ],
                ),

                // Focal length slider
                Row(
                  children: [
                    SizedBox(
                        width: 90,
                        child: Text('Focal (f):',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _focalLength,
                        min: 40,
                        max: 120,
                        onChanged: (v) => setState(() => _focalLength = v),
                        activeColor: Colors.red,
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
                          value: _showRays,
                          onChanged: (v) =>
                              setState(() => _showRays = v ?? true),
                          activeColor: Colors.yellow,
                        ),
                        const Text('Show Rays',
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

class _MirrorPainter extends CustomPainter {
  final double objectDistance;
  final double objectHeight;
  final double imageDistance;
  final double magnification;
  final bool isConcave;
  final double focalLength;
  final bool showRays;

  _MirrorPainter({
    required this.objectDistance,
    required this.objectHeight,
    required this.imageDistance,
    required this.magnification,
    required this.isConcave,
    required this.focalLength,
    required this.showRays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final mirrorX = size.width - 60;
    final axisY = size.height / 2;

    // Draw principal axis
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(20, axisY),
      Offset(size.width - 20, axisY),
      axisPaint,
    );

    // Draw mirror
    _drawMirror(canvas, mirrorX, axisY);

    // Draw focal point and centre of curvature
    final focalX = mirrorX - focalLength;
    final centreX = mirrorX - 2 * focalLength;

    final pointPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(focalX, axisY), 4, pointPaint);

    pointPaint.color = Colors.purple;
    canvas.drawCircle(Offset(centreX, axisY), 4, pointPaint);

    // Labels for F and C
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: 'F',
      style: TextStyle(color: Colors.red, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(focalX - 5, axisY + 8));

    textPainter.text = const TextSpan(
      text: 'C',
      style: TextStyle(color: Colors.purple, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centreX - 5, axisY + 8));

    // Draw object
    final objectX = mirrorX - objectDistance;
    final objectPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(objectX, axisY),
      Offset(objectX, axisY - objectHeight),
      objectPaint,
    );
    _drawArrowHead(canvas, Offset(objectX, axisY - objectHeight), -math.pi / 2, Colors.blue);

    // Draw image if not at infinity
    if (!imageDistance.isInfinite && imageDistance.abs() < 400) {
      final imageX = mirrorX - imageDistance;
      final imageHeight = objectHeight * magnification;

      final imagePaint = Paint()
        ..color = imageDistance > 0 ? Colors.green : Colors.green.withValues(alpha: 0.6)
        ..strokeWidth = 3;

      // For virtual images (negative v), show as dashed
      if (imageDistance < 0) {
        // Virtual image - behind mirror
        final virtualX = mirrorX + imageDistance.abs();
        _drawDashedLine(
          canvas,
          Offset(virtualX, axisY),
          Offset(virtualX, axisY - imageHeight),
          imagePaint,
        );
      } else {
        canvas.drawLine(
          Offset(imageX, axisY),
          Offset(imageX, axisY - imageHeight),
          imagePaint,
        );
        _drawArrowHead(
          canvas,
          Offset(imageX, axisY - imageHeight),
          imageHeight > 0 ? -math.pi / 2 : math.pi / 2,
          Colors.green,
        );
      }
    }

    // Draw rays if enabled
    if (showRays) {
      _drawRays(canvas, mirrorX, axisY, objectX, focalX, centreX);
    }

    // Labels
    textPainter.text = const TextSpan(
      text: 'Object',
      style: TextStyle(color: Colors.blue, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(objectX - 15, axisY - objectHeight - 15));

    if (!imageDistance.isInfinite && imageDistance.abs() < 400) {
      textPainter.text = TextSpan(
        text: imageDistance > 0 ? 'Real Image' : 'Virtual Image',
        style: TextStyle(color: Colors.green, fontSize: 10),
      );
      textPainter.layout();
      final labelX = imageDistance > 0 ? mirrorX - imageDistance : mirrorX + imageDistance.abs();
      textPainter.paint(canvas, Offset(labelX - 25, axisY + 20));
    }
  }

  void _drawMirror(Canvas canvas, double x, double y) {
    final mirrorPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final path = Path();
    final curveAmount = isConcave ? 30.0 : -30.0;

    // Draw curved mirror
    path.moveTo(x + curveAmount, y - 80);
    path.quadraticBezierTo(x, y, x + curveAmount, y + 80);

    canvas.drawPath(path, mirrorPaint);

    // Draw mirror backing
    final backingPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 6;
    canvas.drawLine(
      Offset(x + curveAmount + 5, y - 78),
      Offset(x + curveAmount + 5, y + 78),
      backingPaint,
    );
  }

  void _drawRays(Canvas canvas, double mirrorX, double axisY, double objectX, double focalX, double centreX) {
    final rayPaint = Paint()
      ..strokeWidth = 1.5;

    final objectTop = Offset(objectX, axisY - objectHeight);

    // Ray 1: Parallel to axis, reflects through F (or appears to come from F for convex)
    rayPaint.color = Colors.yellow;
    canvas.drawLine(objectTop, Offset(mirrorX, axisY - objectHeight), rayPaint);

    if (isConcave) {
      // Reflects through focal point
      final slope = (axisY - (axisY - objectHeight)) / (focalX - mirrorX);
      final endY = axisY + slope * (20 - focalX);
      canvas.drawLine(Offset(mirrorX, axisY - objectHeight), Offset(20, endY.clamp(0.0, axisY * 2)), rayPaint);
    } else {
      // Appears to come from F behind mirror
      rayPaint.color = Colors.yellow.withValues(alpha: 0.5);
      _drawDashedLine(canvas, Offset(mirrorX, axisY - objectHeight), Offset(mirrorX + focalLength, axisY), rayPaint);
      rayPaint.color = Colors.yellow;
      // Diverges
      canvas.drawLine(Offset(mirrorX, axisY - objectHeight), Offset(20, 20), rayPaint);
    }

    // Ray 2: Through centre (or towards centre), reflects back on itself
    rayPaint.color = Colors.purple;
    if (isConcave) {
      canvas.drawLine(objectTop, Offset(mirrorX, axisY - objectHeight * (mirrorX - centreX) / (objectX - centreX)), rayPaint);
    }

    // Ray 3: Through F (or towards F), reflects parallel
    rayPaint.color = Colors.cyan;
    if (isConcave && objectX < focalX) {
      // Object inside F
      final extendedX = mirrorX;
      final slope = (objectTop.dy - axisY) / (objectTop.dx - focalX);
      final hitY = axisY + slope * (extendedX - focalX);
      canvas.drawLine(objectTop, Offset(extendedX, hitY), rayPaint);
      canvas.drawLine(Offset(extendedX, hitY), Offset(20, hitY), rayPaint);
    } else if (isConcave) {
      final hitY = axisY - objectHeight * (mirrorX - focalX) / (objectX - focalX);
      canvas.drawLine(objectTop, Offset(mirrorX, hitY), rayPaint);
      canvas.drawLine(Offset(mirrorX, hitY), Offset(20, hitY), rayPaint);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const arrowSize = 8.0;
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

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    final dashCount = (length / 8).floor();

    for (int i = 0; i < dashCount; i += 2) {
      final startFrac = i / dashCount;
      final endFrac = math.min((i + 1) / dashCount, 1.0);
      canvas.drawLine(
        Offset(start.dx + dx * startFrac, start.dy + dy * startFrac),
        Offset(start.dx + dx * endFrac, start.dy + dy * endFrac),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MirrorPainter oldDelegate) {
    return objectDistance != oldDelegate.objectDistance ||
        isConcave != oldDelegate.isConcave ||
        focalLength != oldDelegate.focalLength ||
        showRays != oldDelegate.showRays;
  }
}
