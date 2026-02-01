import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class MagnetSimulation extends StatefulWidget {
  const MagnetSimulation({super.key});

  @override
  State<MagnetSimulation> createState() => _MagnetSimulationState();
}

class _MagnetSimulationState extends State<MagnetSimulation>
    with SimulationTTSMixin {
  Offset _magnet1Position = const Offset(100, 200);
  Offset _magnet2Position = const Offset(250, 200);
  bool _magnet1Flipped = false;
  bool _magnet2Flipped = false;
  bool _showFieldLines = true;
  bool _hasSpokenIntro = false;
  String _lastForceState = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Magnet Simulation. You can see two bar magnets with north and south poles. '
          'Drag the magnets to move them closer or further apart. '
          'Flip magnets to change their polarity and observe attraction or repulsion. '
          'The cyan lines show the magnetic field between the magnets.',
          force: true,
        );
      }
    });
  }

  void _onMagnet1Flipped() {
    setState(() => _magnet1Flipped = !_magnet1Flipped);
    _speakForceChange(force: true);
  }

  void _onMagnet2Flipped() {
    setState(() => _magnet2Flipped = !_magnet2Flipped);
    _speakForceChange(force: true);
  }

  void _onFieldLinesToggled(bool value) {
    setState(() => _showFieldLines = value);
    if (value) {
      speakSimulation(
        'Field lines are now visible. These lines show how the magnetic field flows from north to south poles.',
        force: true,
      );
    } else {
      speakSimulation('Field lines are now hidden.', force: true);
    }
  }

  void _speakForceChange({bool force = false}) {
    final forceState = _getForceText();
    if (forceState != _lastForceState || force) {
      _lastForceState = forceState;

      final magnet1RightPole = _magnet1Flipped ? 'south' : 'north';
      final magnet2LeftPole = _magnet2Flipped ? 'north' : 'south';

      if (_isAttracting()) {
        speakSimulation(
          'The magnets are attracting! The $magnet1RightPole pole of magnet 1 faces the $magnet2LeftPole pole of magnet 2. '
          'Opposite poles attract each other. This is a fundamental rule of magnetism.',
          force: force,
        );
      } else {
        speakSimulation(
          'The magnets are repelling! The $magnet1RightPole pole of magnet 1 faces the $magnet2LeftPole pole of magnet 2. '
          'Like poles repel each other. You can feel the push if they get close.',
          force: force,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildTTSToggle(),
              _buildButton('Flip Magnet 1', _onMagnet1Flipped, Colors.blue),
              _buildButton('Flip Magnet 2', _onMagnet2Flipped, Colors.orange),
              _buildToggle('Field Lines', _showFieldLines, _onFieldLinesToggled),
            ],
          ),
        ),
        // Simulation area
        Expanded(
          child: GestureDetector(
            onPanUpdate: (details) {
              _handleDrag(details.localPosition);
            },
            child: CustomPaint(
              painter: MagnetFieldPainter(
                magnet1Position: _magnet1Position,
                magnet2Position: _magnet2Position,
                magnet1Flipped: _magnet1Flipped,
                magnet2Flipped: _magnet2Flipped,
                showFieldLines: _showFieldLines,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        // Force indicator
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                _getForceText(),
                style: TextStyle(
                  color: _isAttracting() ? Colors.green : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getForceExplanation(),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        // Instructions
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Drag the magnets to move them. Flip to change polarity.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  bool _isAttracting() {
    // N-S attract, N-N and S-S repel
    // Right side of magnet1 faces left side of magnet2
    final magnet1RightIsNorth = !_magnet1Flipped;
    final magnet2LeftIsNorth = _magnet2Flipped;
    return magnet1RightIsNorth != magnet2LeftIsNorth;
  }

  String _getForceText() {
    final distance = (_magnet1Position - _magnet2Position).distance;
    if (distance < 100) {
      return _isAttracting() ? '🧲 STRONG ATTRACTION!' : '💥 STRONG REPULSION!';
    } else if (distance < 200) {
      return _isAttracting() ? '🧲 Attracting' : '↔️ Repelling';
    }
    return 'Move magnets closer';
  }

  String _getForceExplanation() {
    final magnet1RightPole = _magnet1Flipped ? 'S' : 'N';
    final magnet2LeftPole = _magnet2Flipped ? 'N' : 'S';

    if (_isAttracting()) {
      return 'Opposite poles ($magnet1RightPole and $magnet2LeftPole) attract each other';
    }
    return 'Like poles ($magnet1RightPole and $magnet2LeftPole) repel each other';
  }

  void _handleDrag(Offset position) {
    setState(() {
      final dist1 = (position - _magnet1Position).distance;
      final dist2 = (position - _magnet2Position).distance;

      if (dist1 < dist2 && dist1 < 60) {
        _magnet1Position = position;
      } else if (dist2 < 60) {
        _magnet2Position = position;
      }
    });
  }

  Widget _buildButton(String label, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(color: color, fontSize: 12),
        ),
      ),
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
}

class MagnetFieldPainter extends CustomPainter {
  final Offset magnet1Position;
  final Offset magnet2Position;
  final bool magnet1Flipped;
  final bool magnet2Flipped;
  final bool showFieldLines;

  MagnetFieldPainter({
    required this.magnet1Position,
    required this.magnet2Position,
    required this.magnet1Flipped,
    required this.magnet2Flipped,
    required this.showFieldLines,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw field lines if enabled
    if (showFieldLines) {
      _drawFieldLines(canvas, size);
    }

    // Draw magnets
    _drawMagnet(canvas, magnet1Position, magnet1Flipped, 'Magnet 1');
    _drawMagnet(canvas, magnet2Position, magnet2Flipped, 'Magnet 2');

    // Draw force arrows
    _drawForceArrows(canvas);
  }

  void _drawMagnet(Canvas canvas, Offset position, bool flipped, String label) {
    const magnetWidth = 80.0;
    const magnetHeight = 40.0;

    final rect = Rect.fromCenter(
      center: position,
      width: magnetWidth,
      height: magnetHeight,
    );

    // North pole (red)
    final northPaint = Paint()..color = Colors.red;
    // South pole (blue)
    final southPaint = Paint()..color = Colors.blue;

    final leftRect = Rect.fromLTWH(rect.left, rect.top, magnetWidth / 2, magnetHeight);
    final rightRect = Rect.fromLTWH(rect.left + magnetWidth / 2, rect.top, magnetWidth / 2, magnetHeight);

    canvas.drawRRect(
      RRect.fromRectAndCorners(leftRect, topLeft: const Radius.circular(8), bottomLeft: const Radius.circular(8)),
      flipped ? northPaint : southPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndCorners(rightRect, topRight: const Radius.circular(8), bottomRight: const Radius.circular(8)),
      flipped ? southPaint : northPaint,
    );

    // Draw pole labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: flipped ? 'N' : 'S',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - magnetWidth / 4 - 5, position.dy - 8));

    textPainter.text = TextSpan(
      text: flipped ? 'S' : 'N',
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx + magnetWidth / 4 - 5, position.dy - 8));
  }

  void _drawFieldLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Simplified field line representation
    for (int i = -2; i <= 2; i++) {
      final yOffset = i * 15.0;

      // Lines from magnet 1 north pole
      final start1 = Offset(
        magnet1Position.dx + (magnet1Flipped ? -40 : 40),
        magnet1Position.dy + yOffset,
      );

      // Lines to magnet 2
      final end2 = Offset(
        magnet2Position.dx + (magnet2Flipped ? 40 : -40),
        magnet2Position.dy + yOffset,
      );

      final path = Path();
      path.moveTo(start1.dx, start1.dy);

      // Create curved field lines
      final controlPoint1 = Offset(
        (start1.dx + end2.dx) / 2,
        start1.dy + (i * 30),
      );

      path.quadraticBezierTo(controlPoint1.dx, controlPoint1.dy, end2.dx, end2.dy);
      canvas.drawPath(path, paint);
    }
  }

  void _drawForceArrows(Canvas canvas) {
    final distance = (magnet1Position - magnet2Position).distance;
    if (distance > 250) return;

    final magnet1RightIsNorth = !magnet1Flipped;
    final magnet2LeftIsNorth = magnet2Flipped;
    final isAttracting = magnet1RightIsNorth != magnet2LeftIsNorth;

    final arrowPaint = Paint()
      ..color = isAttracting ? Colors.green : Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final strength = (1 - distance / 250) * 30;

    if (isAttracting) {
      // Arrows pointing towards each other
      _drawArrow(canvas, magnet1Position + const Offset(50, 0), magnet1Position + Offset(50 + strength, 0), arrowPaint);
      _drawArrow(canvas, magnet2Position - const Offset(50, 0), magnet2Position - Offset(50 + strength, 0), arrowPaint);
    } else {
      // Arrows pointing away from each other
      _drawArrow(canvas, magnet1Position + Offset(50 + strength, 0), magnet1Position + const Offset(50, 0), arrowPaint);
      _drawArrow(canvas, magnet2Position - Offset(50 + strength, 0), magnet2Position - const Offset(50, 0), arrowPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);

    // Arrow head
    final direction = (to - from).direction;
    final arrowSize = 8.0;

    final arrowPoint1 = to - Offset(
      arrowSize * math.cos(direction - 0.5),
      arrowSize * math.sin(direction - 0.5),
    );
    final arrowPoint2 = to - Offset(
      arrowSize * math.cos(direction + 0.5),
      arrowSize * math.sin(direction + 0.5),
    );

    canvas.drawLine(to, arrowPoint1, paint);
    canvas.drawLine(to, arrowPoint2, paint);
  }

  @override
  bool shouldRepaint(covariant MagnetFieldPainter oldDelegate) {
    return oldDelegate.magnet1Position != magnet1Position ||
        oldDelegate.magnet2Position != magnet2Position ||
        oldDelegate.magnet1Flipped != magnet1Flipped ||
        oldDelegate.magnet2Flipped != magnet2Flipped ||
        oldDelegate.showFieldLines != showFieldLines;
  }
}
