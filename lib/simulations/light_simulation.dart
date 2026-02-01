import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class LightSimulation extends StatefulWidget {
  const LightSimulation({super.key});

  @override
  State<LightSimulation> createState() => _LightSimulationState();
}

class _LightSimulationState extends State<LightSimulation>
    with SimulationTTSMixin {
  double _incidentAngle = 45;
  double _refractiveIndex = 1.5;
  bool _showReflection = true;
  bool _showRefraction = true;
  String _mode = 'refraction'; // 'refraction', 'lens', 'prism'
  bool _hasSpokenIntro = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Light Simulation. You can explore three modes: Refraction, Lens, and Prism. '
          'In refraction mode, see how light bends when passing from air into glass. '
          'Adjust the incident angle and refractive index to observe Snell\'s Law in action.',
          force: true,
        );
      }
    });
  }

  void _onModeChanged(String mode) {
    setState(() => _mode = mode);
    switch (mode) {
      case 'refraction':
        speakSimulation(
          'Refraction mode selected. Light bends when it passes from one medium to another. '
          'The yellow ray is the incident light, and the cyan ray shows how it refracts into the glass. '
          'If the angle is too steep, you\'ll see total internal reflection.',
          force: true,
        );
        break;
      case 'lens':
        speakSimulation(
          'Lens mode selected. A convex lens focuses parallel light rays to a focal point. '
          'Adjust the focal length to see how the lens converges light differently. '
          'This is how magnifying glasses and camera lenses work.',
          force: true,
        );
        break;
      case 'prism':
        speakSimulation(
          'Prism mode selected. White light contains all colors of the spectrum. '
          'When white light enters a prism, different wavelengths refract at different angles. '
          'This is called dispersion, and it creates the rainbow pattern: red, orange, yellow, green, blue, indigo, violet.',
          force: true,
        );
        break;
    }
  }

  void _onIncidentAngleChanged(double value) {
    setState(() => _incidentAngle = value);
    final criticalAngle = math.asin(1 / _refractiveIndex) * 180 / math.pi;
    if (value > criticalAngle && _refractiveIndex > 1) {
      speakSimulation(
        'Incident angle is ${value.toInt()} degrees, which exceeds the critical angle of ${criticalAngle.toStringAsFixed(1)} degrees. '
        'Total internal reflection occurs! All light is reflected back into the medium.',
      );
    } else {
      speakSimulation(
        'Incident angle set to ${value.toInt()} degrees. '
        'The light ray bends towards the normal as it enters the denser medium.',
      );
    }
  }

  void _onRefractiveIndexChanged(double value) {
    setState(() => _refractiveIndex = value);
    final criticalAngle = math.asin(1 / value) * 180 / math.pi;
    speakSimulation(
      'Refractive index set to ${value.toStringAsFixed(2)}. '
      'Higher values mean the material bends light more. '
      'The critical angle for this material is ${criticalAngle.toStringAsFixed(1)} degrees.',
    );
  }

  void _onReflectionToggled(bool value) {
    setState(() => _showReflection = value);
    speakSimulation(
      value ? 'Reflection ray is now visible.' : 'Reflection ray is now hidden.',
      force: true,
    );
  }

  void _onRefractionToggled(bool value) {
    setState(() => _showRefraction = value);
    speakSimulation(
      value ? 'Refraction ray is now visible.' : 'Refraction ray is now hidden.',
      force: true,
    );
  }

  void _onFocalLengthChanged(double value) {
    setState(() => _refractiveIndex = value);
    speakSimulation(
      'Focal length set to ${(value * 50).toInt()} pixels. '
      'A shorter focal length means the lens is more powerful and bends light more sharply.',
    );
  }

  void _onPrismAngleChanged(double value) {
    setState(() => _incidentAngle = value);
    speakSimulation(
      'Light angle adjusted to ${value.toInt()} degrees. '
      'Notice how the spectrum spreads out as the light passes through the prism.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTTSToggle(),
              const SizedBox(width: 8),
              _buildModeButton('Refraction', 'refraction'),
              const SizedBox(width: 12),
              _buildModeButton('Lens', 'lens'),
              const SizedBox(width: 12),
              _buildModeButton('Prism', 'prism'),
            ],
          ),
        ),
        // Simulation display
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomPaint(
                painter: _mode == 'refraction'
                    ? RefractionPainter(
                        incidentAngle: _incidentAngle,
                        refractiveIndex: _refractiveIndex,
                        showReflection: _showReflection,
                        showRefraction: _showRefraction,
                      )
                    : _mode == 'lens'
                        ? LensPainter(focalLength: _refractiveIndex * 50)
                        : PrismPainter(angle: _incidentAngle),
                size: Size.infinite,
              ),
            ),
          ),
        ),
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (_mode == 'refraction') ...[
                _buildSlider(
                  'Incident Angle',
                  _incidentAngle,
                  0,
                  85,
                  '${_incidentAngle.toInt()}°',
                  _onIncidentAngleChanged,
                  Colors.yellow,
                ),
                _buildSlider(
                  'Refractive Index',
                  _refractiveIndex,
                  1.0,
                  2.5,
                  'n = ${_refractiveIndex.toStringAsFixed(2)}',
                  _onRefractiveIndexChanged,
                  Colors.cyan,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildToggle('Reflection', _showReflection, _onReflectionToggled),
                    const SizedBox(width: 20),
                    _buildToggle('Refraction', _showRefraction, _onRefractionToggled),
                  ],
                ),
                const SizedBox(height: 8),
                _buildInfoCard(),
              ] else if (_mode == 'lens') ...[
                _buildSlider(
                  'Focal Length',
                  _refractiveIndex,
                  0.5,
                  3.0,
                  '${(_refractiveIndex * 50).toInt()} px',
                  _onFocalLengthChanged,
                  Colors.cyan,
                ),
                const Text(
                  'Convex lens focuses parallel light rays to a focal point',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                _buildSlider(
                  'Light Angle',
                  _incidentAngle,
                  20,
                  70,
                  '${_incidentAngle.toInt()}°',
                  _onPrismAngleChanged,
                  Colors.yellow,
                ),
                const Text(
                  'White light disperses into spectrum through a prism',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, String mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => _onModeChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
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
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: TextStyle(color: color, fontSize: 13)),
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
          width: 70,
          child: Text(
            displayValue,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.cyan,
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final incidentRad = _incidentAngle * math.pi / 180;
    final sinRefracted = math.sin(incidentRad) / _refractiveIndex;
    final refractedAngle = sinRefracted <= 1
        ? math.asin(sinRefracted) * 180 / math.pi
        : 90.0;
    final criticalAngle = math.asin(1 / _refractiveIndex) * 180 / math.pi;
    final isTotalInternalReflection = _incidentAngle > criticalAngle && _refractiveIndex > 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Snell's Law: n₁ sin θ₁ = n₂ sin θ₂",
            style: TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildValueDisplay('Refracted', '${refractedAngle.toStringAsFixed(1)}°', Colors.cyan),
              _buildValueDisplay('Critical', '${criticalAngle.toStringAsFixed(1)}°', Colors.orange),
              if (isTotalInternalReflection)
                const Text(
                  'TIR!',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}

class RefractionPainter extends CustomPainter {
  final double incidentAngle;
  final double refractiveIndex;
  final bool showReflection;
  final bool showRefraction;

  RefractionPainter({
    required this.incidentAngle,
    required this.refractiveIndex,
    required this.showReflection,
    required this.showRefraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw medium (glass block)
    final glassPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2);
    canvas.drawRect(
      Rect.fromLTWH(0, centerY, size.width, size.height / 2),
      glassPaint,
    );

    // Draw boundary line
    final boundaryPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), boundaryPaint);

    // Draw normal line
    final normalPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final dashPath = Path();
    for (double y = centerY - 80; y < centerY + 80; y += 10) {
      dashPath.moveTo(centerX, y);
      dashPath.lineTo(centerX, y + 5);
    }
    canvas.drawPath(dashPath, normalPaint);

    // Calculate angles
    final incidentRad = incidentAngle * math.pi / 180;
    final sinRefracted = math.sin(incidentRad) / refractiveIndex;
    final criticalAngle = math.asin(1 / refractiveIndex);
    final isTIR = incidentRad > criticalAngle && refractiveIndex > 1;

    // Draw incident ray
    final rayLength = 120.0;
    final incidentStart = Offset(
      centerX - rayLength * math.sin(incidentRad),
      centerY - rayLength * math.cos(incidentRad),
    );

    final incidentPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3;
    canvas.drawLine(incidentStart, Offset(centerX, centerY), incidentPaint);

    // Draw arrow on incident ray
    _drawArrowHead(canvas, incidentStart, Offset(centerX, centerY), Colors.yellow);

    // Draw reflected ray
    if (showReflection) {
      final reflectedEnd = Offset(
        centerX + rayLength * math.sin(incidentRad),
        centerY - rayLength * math.cos(incidentRad),
      );

      final reflectedPaint = Paint()
        ..color = isTIR ? Colors.yellow : Colors.yellow.withValues(alpha: 0.5)
        ..strokeWidth = isTIR ? 3 : 2;
      canvas.drawLine(Offset(centerX, centerY), reflectedEnd, reflectedPaint);
      _drawArrowHead(canvas, Offset(centerX, centerY), reflectedEnd,
          isTIR ? Colors.yellow : Colors.yellow.withValues(alpha: 0.5));
    }

    // Draw refracted ray
    if (showRefraction && !isTIR && sinRefracted <= 1) {
      final refractedRad = math.asin(sinRefracted);
      final refractedEnd = Offset(
        centerX + rayLength * math.sin(refractedRad),
        centerY + rayLength * math.cos(refractedRad),
      );

      final refractedPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 3;
      canvas.drawLine(Offset(centerX, centerY), refractedEnd, refractedPaint);
      _drawArrowHead(canvas, Offset(centerX, centerY), refractedEnd, Colors.cyan);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'Air (n=1)',
      style: TextStyle(color: Colors.white54, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, centerY - 20));

    textPainter.text = TextSpan(
      text: 'Glass (n=${refractiveIndex.toStringAsFixed(2)})',
      style: const TextStyle(color: Colors.white54, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, centerY + 10));

    textPainter.text = const TextSpan(
      text: 'Normal',
      style: TextStyle(color: Colors.white38, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 5, centerY - 70));

    // Angle indicators
    _drawAngleArc(canvas, Offset(centerX, centerY), incidentRad, false, Colors.yellow);
    if (showRefraction && !isTIR && sinRefracted <= 1) {
      final refractedRad = math.asin(sinRefracted);
      _drawAngleArc(canvas, Offset(centerX, centerY), refractedRad, true, Colors.cyan);
    }
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3;

    final direction = math.atan2(to.dy - from.dy, to.dx - from.dx);
    final arrowLength = 10.0;

    final midPoint = Offset(
      (from.dx + to.dx) / 2,
      (from.dy + to.dy) / 2,
    );

    canvas.drawLine(
      midPoint,
      Offset(
        midPoint.dx - arrowLength * math.cos(direction - 0.4),
        midPoint.dy - arrowLength * math.sin(direction - 0.4),
      ),
      paint,
    );
    canvas.drawLine(
      midPoint,
      Offset(
        midPoint.dx - arrowLength * math.cos(direction + 0.4),
        midPoint.dy - arrowLength * math.sin(direction + 0.4),
      ),
      paint,
    );
  }

  void _drawAngleArc(Canvas canvas, Offset center, double angle, bool below, Color color) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCircle(center: center, radius: 30);
    if (below) {
      canvas.drawArc(rect, math.pi / 2 - angle, angle, false, paint);
    } else {
      canvas.drawArc(rect, -math.pi / 2, angle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant RefractionPainter oldDelegate) {
    return oldDelegate.incidentAngle != incidentAngle ||
        oldDelegate.refractiveIndex != refractiveIndex ||
        oldDelegate.showReflection != showReflection ||
        oldDelegate.showRefraction != showRefraction;
  }
}

class LensPainter extends CustomPainter {
  final double focalLength;

  LensPainter({required this.focalLength});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw lens
    final lensPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final lensPath = Path();
    lensPath.moveTo(centerX - 5, centerY - 60);
    lensPath.quadraticBezierTo(centerX - 20, centerY, centerX - 5, centerY + 60);
    lensPath.lineTo(centerX + 5, centerY + 60);
    lensPath.quadraticBezierTo(centerX + 20, centerY, centerX + 5, centerY - 60);
    lensPath.close();
    canvas.drawPath(lensPath, lensPaint);

    // Draw lens outline
    final outlinePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(lensPath, outlinePaint);

    // Draw principal axis
    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, centerY), Offset(size.width, centerY), axisPaint);

    // Draw focal points
    final focalPaint = Paint()..color = Colors.orange;
    canvas.drawCircle(Offset(centerX + focalLength, centerY), 5, focalPaint);
    canvas.drawCircle(Offset(centerX - focalLength, centerY), 5, focalPaint);

    // Draw parallel rays
    final rayPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    for (int i = -2; i <= 2; i++) {
      if (i == 0) continue;
      final yOffset = i * 20.0;

      // Incoming ray (parallel)
      canvas.drawLine(
        Offset(0, centerY + yOffset),
        Offset(centerX, centerY + yOffset),
        rayPaint,
      );

      // Outgoing ray (to focal point)
      final focalPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(centerX, centerY + yOffset),
        Offset(centerX + focalLength * 2, centerY + (yOffset > 0 ? 1 : -1) *
            (math.sqrt(yOffset.abs()) * focalLength / 10)),
        focalPaint,
      );
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'F',
      style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + focalLength - 4, centerY + 10));
    textPainter.paint(canvas, Offset(centerX - focalLength - 4, centerY + 10));

    textPainter.text = const TextSpan(
      text: 'Convex Lens',
      style: TextStyle(color: Colors.white54, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 35, centerY - 80));
  }

  @override
  bool shouldRepaint(covariant LensPainter oldDelegate) {
    return oldDelegate.focalLength != focalLength;
  }
}

class PrismPainter extends CustomPainter {
  final double angle;

  PrismPainter({required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw prism
    final prismPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final prismPath = Path();
    prismPath.moveTo(centerX, centerY - 60);
    prismPath.lineTo(centerX - 50, centerY + 40);
    prismPath.lineTo(centerX + 50, centerY + 40);
    prismPath.close();
    canvas.drawPath(prismPath, prismPaint);

    // Prism outline
    final outlinePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawPath(prismPath, outlinePaint);

    // Draw incoming white light
    final angleRad = angle * math.pi / 180;
    final rayStart = Offset(centerX - 120, centerY - 40);
    final rayEnd = Offset(centerX - 25, centerY);

    final whitePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;
    canvas.drawLine(rayStart, rayEnd, whitePaint);

    // Draw spectrum
    final spectrumColors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.indigo,
      Colors.purple,
    ];

    for (int i = 0; i < spectrumColors.length; i++) {
      final spreadAngle = (i - 3) * 3 * math.pi / 180;
      final baseAngle = -0.3 + (angle - 45) * 0.01;

      final rayPaint = Paint()
        ..color = spectrumColors[i]
        ..strokeWidth = 3;

      final endX = centerX + 25 + 150 * math.cos(baseAngle + spreadAngle);
      final endY = centerY + 150 * math.sin(baseAngle + spreadAngle);

      canvas.drawLine(
        Offset(centerX + 25, centerY + 10),
        Offset(endX, endY),
        rayPaint,
      );
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'White Light',
      style: TextStyle(color: Colors.white, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rayStart.dx, rayStart.dy - 15));

    textPainter.text = const TextSpan(
      text: 'ROYGBIV',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 80, centerY + 60));

    textPainter.text = const TextSpan(
      text: 'Dispersion: Different wavelengths refract at different angles',
      style: TextStyle(color: Colors.white38, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(20, size.height - 30));
  }

  @override
  bool shouldRepaint(covariant PrismPainter oldDelegate) {
    return oldDelegate.angle != angle;
  }
}
