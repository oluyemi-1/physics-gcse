import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class LensesSimulation extends StatefulWidget {
  const LensesSimulation({super.key});

  @override
  State<LensesSimulation> createState() => _LensesSimulationState();
}

class _LensesSimulationState extends State<LensesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  bool _isConvex = true; // true = converging lens, false = diverging lens
  double _objectDistance = 150.0; // pixels from lens
  double _focalLength = 80.0; // pixels
  bool _showRays = true;
  bool _hasSpokenIntro = false;

  double get _imageDistance {
    // Using lens equation: 1/f = 1/u + 1/v
    // v = fu / (u - f)
    final u = _objectDistance;
    final f = _isConvex ? _focalLength : -_focalLength;
    if ((u - f).abs() < 0.1) return double.infinity;
    return (f * u) / (u - f);
  }

  double get _magnification {
    if (_imageDistance.isInfinite) return double.infinity;
    return -_imageDistance / _objectDistance;
  }

  String get _imageType {
    if (_imageDistance.isInfinite) return 'At infinity';
    if (_imageDistance > 0) {
      return _magnification.abs() > 1 ? 'Real, Inverted, Magnified' : 'Real, Inverted, Diminished';
    } else {
      return _magnification.abs() > 1 ? 'Virtual, Upright, Magnified' : 'Virtual, Upright, Diminished';
    }
  }

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
          'Welcome to the Lenses simulation! '
          'A convex or converging lens brings parallel light rays to a focus. '
          'A concave or diverging lens spreads light rays apart. '
          'Move the object to see how the image changes. '
          'The lens equation is 1 over f equals 1 over u plus 1 over v.',
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

  void _toggleLensType() {
    setState(() {
      _isConvex = !_isConvex;
    });

    if (_isConvex) {
      speakSimulation(
        'Switched to convex lens, also called a converging lens. '
        'It is thicker in the middle and brings light rays together to a focal point. '
        'Used in magnifying glasses, cameras, and the eye.',
        force: true,
      );
    } else {
      speakSimulation(
        'Switched to concave lens, also called a diverging lens. '
        'It is thinner in the middle and spreads light rays apart. '
        'Used to correct short-sightedness and in some optical instruments.',
        force: true,
      );
    }
  }

  void _onObjectDistanceChanged(double value) {
    setState(() {
      _objectDistance = value;
    });

    if (value < _focalLength && _isConvex) {
      speakSimulation(
        'Object is closer than the focal point. '
        'With a convex lens, this creates a virtual, upright, magnified image. '
        'This is how a magnifying glass works!',
      );
    } else if ((value - _focalLength).abs() < 10 && _isConvex) {
      speakSimulation(
        'Object is at the focal point. '
        'Rays emerge parallel - no image is formed, or it is at infinity.',
      );
    } else if (value > _focalLength * 2 && _isConvex) {
      speakSimulation(
        'Object is beyond twice the focal length. '
        'The image is real, inverted, and smaller than the object.',
      );
    }
  }

  void _onFocalLengthChanged(double value) {
    setState(() {
      _focalLength = value;
    });
    speakSimulation(
      'Focal length changed to ${value.toStringAsFixed(0)} units. '
      'A shorter focal length means a more powerful lens.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Lens diagram
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _LensPainter(
                  isConvex: _isConvex,
                  objectDistance: _objectDistance,
                  focalLength: _focalLength,
                  imageDistance: _imageDistance,
                  magnification: _magnification,
                  showRays: _showRays,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),

        // Image information
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoCard('Object Dist (u)', _objectDistance.toStringAsFixed(0)),
              _buildInfoCard('Image Dist (v)', _imageDistance.isInfinite ? '∞' : _imageDistance.toStringAsFixed(0)),
              _buildInfoCard('Magnification', _magnification.isInfinite ? '∞' : _magnification.toStringAsFixed(2)),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Image: $_imageType',
            style: TextStyle(
              color: _imageDistance > 0 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Lens type toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Lens Type: ', style: TextStyle(color: Colors.white)),
                    ChoiceChip(
                      label: const Text('Convex (Converging)'),
                      selected: _isConvex,
                      onSelected: (_) => _toggleLensType(),
                      selectedColor: Colors.blue,
                      labelStyle: TextStyle(color: _isConvex ? Colors.white : Colors.black),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Concave (Diverging)'),
                      selected: !_isConvex,
                      onSelected: (_) => _toggleLensType(),
                      selectedColor: Colors.purple,
                      labelStyle: TextStyle(color: !_isConvex ? Colors.white : Colors.black),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Object distance slider
                Row(
                  children: [
                    const SizedBox(width: 100, child: Text('Object Distance:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _objectDistance,
                        min: 30,
                        max: 250,
                        onChanged: _onObjectDistanceChanged,
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                // Focal length slider
                Row(
                  children: [
                    const SizedBox(width: 100, child: Text('Focal Length:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _focalLength,
                        min: 40,
                        max: 120,
                        onChanged: _onFocalLengthChanged,
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
                          value: _showRays,
                          onChanged: (v) => setState(() => _showRays = v ?? true),
                          activeColor: Colors.yellow,
                        ),
                        const Text('Show Ray Diagram', style: TextStyle(color: Colors.white)),
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

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

class _LensPainter extends CustomPainter {
  final bool isConvex;
  final double objectDistance;
  final double focalLength;
  final double imageDistance;
  final double magnification;
  final bool showRays;

  _LensPainter({
    required this.isConvex,
    required this.objectDistance,
    required this.focalLength,
    required this.imageDistance,
    required this.magnification,
    required this.showRays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw principal axis
    final axisPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);

    // Draw lens
    _drawLens(canvas, centerX, centerY, size.height * 0.35);

    // Draw focal points
    final focalPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2;

    // F on both sides
    canvas.drawCircle(Offset(centerX - focalLength, centerY), 5, focalPaint);
    canvas.drawCircle(Offset(centerX + focalLength, centerY), 5, focalPaint);

    // 2F points
    final twofPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(centerX - focalLength * 2, centerY), 4, twofPaint);
    canvas.drawCircle(Offset(centerX + focalLength * 2, centerY), 4, twofPaint);

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(text: 'F', style: TextStyle(color: Colors.blue, fontSize: 12));
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - focalLength - 4, centerY + 10));
    textPainter.paint(canvas, Offset(centerX + focalLength - 4, centerY + 10));

    textPainter.text = const TextSpan(text: '2F', style: TextStyle(color: Colors.blue, fontSize: 10));
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - focalLength * 2 - 8, centerY + 10));
    textPainter.paint(canvas, Offset(centerX + focalLength * 2 - 8, centerY + 10));

    // Draw object (arrow on left side)
    final objectX = centerX - objectDistance;
    final objectHeight = 40.0;
    _drawArrow(canvas, Offset(objectX, centerY), Offset(objectX, centerY - objectHeight), Colors.green, 3);

    textPainter.text = const TextSpan(text: 'Object', style: TextStyle(color: Colors.green, fontSize: 11));
    textPainter.layout();
    textPainter.paint(canvas, Offset(objectX - 20, centerY - objectHeight - 15));

    // Draw image (if not at infinity)
    if (!imageDistance.isInfinite && imageDistance.abs() < size.width) {
      final imageX = centerX + imageDistance;
      final imageHeight = objectHeight * magnification;

      if (imageX > 0 && imageX < size.width) {
        final imageColor = imageDistance > 0 ? Colors.red : Colors.red.withValues(alpha: 0.5);
        _drawArrow(canvas, Offset(imageX, centerY), Offset(imageX, centerY - imageHeight), imageColor, 3);

        textPainter.text = TextSpan(
          text: imageDistance > 0 ? 'Real Image' : 'Virtual Image',
          style: TextStyle(color: imageColor, fontSize: 11),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(imageX - 30, centerY - imageHeight + (imageHeight > 0 ? -15 : 5)));
      }
    }

    // Draw ray diagram
    if (showRays) {
      _drawRays(canvas, size, centerX, centerY, objectX, objectHeight);
    }

    // Draw lens type label
    textPainter.text = TextSpan(
      text: isConvex ? 'Convex (Converging) Lens' : 'Concave (Diverging) Lens',
      style: TextStyle(color: isConvex ? Colors.blue : Colors.purple, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, 10));
  }

  void _drawLens(Canvas canvas, double centerX, double centerY, double height) {
    final lensPaint = Paint()
      ..color = isConvex ? Colors.blue.withValues(alpha: 0.3) : Colors.purple.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final lensOutlinePaint = Paint()
      ..color = isConvex ? Colors.blue : Colors.purple
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isConvex) {
      // Convex lens - thicker in middle
      path.moveTo(centerX, centerY - height);
      path.quadraticBezierTo(centerX + 20, centerY, centerX, centerY + height);
      path.quadraticBezierTo(centerX - 20, centerY, centerX, centerY - height);
    } else {
      // Concave lens - thinner in middle
      path.moveTo(centerX - 8, centerY - height);
      path.quadraticBezierTo(centerX + 5, centerY, centerX - 8, centerY + height);
      path.lineTo(centerX + 8, centerY + height);
      path.quadraticBezierTo(centerX - 5, centerY, centerX + 8, centerY - height);
      path.close();
    }

    canvas.drawPath(path, lensPaint);
    canvas.drawPath(path, lensOutlinePaint);

    // Draw arrows on lens to indicate type
    final arrowPaint = Paint()
      ..color = isConvex ? Colors.blue : Colors.purple
      ..strokeWidth = 2;

    if (isConvex) {
      // Arrows pointing outward
      canvas.drawLine(Offset(centerX, centerY - height - 5), Offset(centerX - 8, centerY - height + 5), arrowPaint);
      canvas.drawLine(Offset(centerX, centerY - height - 5), Offset(centerX + 8, centerY - height + 5), arrowPaint);
      canvas.drawLine(Offset(centerX, centerY + height + 5), Offset(centerX - 8, centerY + height - 5), arrowPaint);
      canvas.drawLine(Offset(centerX, centerY + height + 5), Offset(centerX + 8, centerY + height - 5), arrowPaint);
    } else {
      // Arrows pointing inward
      canvas.drawLine(Offset(centerX - 8, centerY - height - 5), Offset(centerX, centerY - height + 5), arrowPaint);
      canvas.drawLine(Offset(centerX + 8, centerY - height - 5), Offset(centerX, centerY - height + 5), arrowPaint);
      canvas.drawLine(Offset(centerX - 8, centerY + height + 5), Offset(centerX, centerY + height - 5), arrowPaint);
      canvas.drawLine(Offset(centerX + 8, centerY + height + 5), Offset(centerX, centerY + height - 5), arrowPaint);
    }
  }

  void _drawRays(Canvas canvas, Size size, double centerX, double centerY, double objectX, double objectHeight) {
    final rayPaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final objectTop = Offset(objectX, centerY - objectHeight);

    if (isConvex) {
      // Ray 1: Parallel to axis, then through F
      rayPaint.color = Colors.red;
      canvas.drawLine(objectTop, Offset(centerX, centerY - objectHeight), rayPaint);
      if (!imageDistance.isInfinite) {
        canvas.drawLine(Offset(centerX, centerY - objectHeight), Offset(size.width, centerY + (size.width - centerX) * objectHeight / focalLength), rayPaint);
      }

      // Ray 2: Through optical center (straight line)
      rayPaint.color = Colors.green;
      final slope = -objectHeight / objectDistance;
      canvas.drawLine(objectTop, Offset(size.width, centerY - objectHeight + slope * (size.width - objectX)), rayPaint);

      // Ray 3: Through F on object side, then parallel
      rayPaint.color = Colors.blue;
      final toF = (centerY - objectHeight - centerY) / (objectX - (centerX - focalLength));
      canvas.drawLine(objectTop, Offset(centerX, centerY - objectHeight + toF * (centerX - objectX)), rayPaint);
      // This ray continues parallel after lens
      final yAtLens = centerY - objectHeight + toF * (centerX - objectX);
      canvas.drawLine(Offset(centerX, yAtLens), Offset(size.width, yAtLens), rayPaint);
    } else {
      // Diverging lens rays
      // Ray 1: Parallel to axis, diverges as if from F on same side
      rayPaint.color = Colors.red;
      canvas.drawLine(objectTop, Offset(centerX, centerY - objectHeight), rayPaint);
      // Diverges - appears to come from F on left
      final slope1 = objectHeight / focalLength;
      canvas.drawLine(Offset(centerX, centerY - objectHeight), Offset(size.width, centerY - objectHeight + slope1 * (size.width - centerX)), rayPaint);
      // Virtual ray extension (dashed)
      rayPaint.color = Colors.red.withValues(alpha: 0.3);
      canvas.drawLine(Offset(centerX, centerY - objectHeight), Offset(centerX - focalLength, centerY), rayPaint);

      // Ray 2: Through center (straight)
      rayPaint.color = Colors.green;
      final slope2 = -objectHeight / objectDistance;
      canvas.drawLine(objectTop, Offset(size.width, centerY - objectHeight + slope2 * (size.width - objectX)), rayPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color, double strokeWidth) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, paint);

    // Arrow head
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    final arrowSize = 10.0;

    final path = Path();
    path.moveTo(end.dx, end.dy);
    path.lineTo(
      end.dx - arrowSize * math.cos(angle - math.pi / 6),
      end.dy - arrowSize * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      end.dx - arrowSize * math.cos(angle + math.pi / 6),
      end.dy - arrowSize * math.sin(angle + math.pi / 6),
    );
    path.close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _LensPainter oldDelegate) {
    return isConvex != oldDelegate.isConvex ||
        objectDistance != oldDelegate.objectDistance ||
        focalLength != oldDelegate.focalLength ||
        showRays != oldDelegate.showRays;
  }
}
