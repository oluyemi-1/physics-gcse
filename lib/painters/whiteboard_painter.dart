import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:physics_gcse/models/whiteboard_models.dart';

class WhiteboardPainter extends CustomPainter {
  final List<DrawingElement> elements;
  final DrawingElement? activeElement;
  final CanvasBackground background;
  final bool darkCanvas;

  WhiteboardPainter({
    required this.elements,
    this.activeElement,
    required this.background,
    required this.darkCanvas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);

    for (final element in elements) {
      _drawElement(canvas, element);
    }
    if (activeElement != null) {
      _drawElement(canvas, activeElement!);
    }
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgColor = darkCanvas ? const Color(0xFF1E1E1E) : Colors.white;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    final gridColor = darkCanvas
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.1);
    final majorGridColor = darkCanvas
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.2);
    final axisColor = darkCanvas
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.black.withValues(alpha: 0.4);

    switch (background) {
      case CanvasBackground.plain:
        break;
      case CanvasBackground.grid:
        _drawGrid(canvas, size, 30, gridColor, 0.5);
      case CanvasBackground.graphPaper:
        _drawGrid(canvas, size, 30, gridColor, 0.3);
        _drawGrid(canvas, size, 150, majorGridColor, 1.0);
        _drawAxes(canvas, size, axisColor);
      case CanvasBackground.dotGrid:
        _drawDotGrid(canvas, size, 30, gridColor);
    }
  }

  void _drawGrid(
      Canvas canvas, Size size, double spacing, Color color, double width) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawAxes(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);
  }

  void _drawDotGrid(
      Canvas canvas, Size size, double spacing, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double x = 0; x <= size.width; x += spacing) {
      for (double y = 0; y <= size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  void _drawElement(Canvas canvas, DrawingElement element) {
    switch (element) {
      case StrokeElement e:
        _drawStroke(canvas, e);
      case EraserElement e:
        _drawEraser(canvas, e);
      case TextElement e:
        _drawText(canvas, e);
      case LineElement e:
        _drawLine(canvas, e);
      case ArrowElement e:
        _drawArrow(canvas, e);
      case RectangleElement e:
        _drawRectangle(canvas, e);
      case CircleElement e:
        _drawCircle(canvas, e);
    }
  }

  void _drawStroke(Canvas canvas, StrokeElement stroke) {
    if (stroke.points.length < 2) {
      if (stroke.points.length == 1) {
        canvas.drawCircle(
          stroke.points.first,
          stroke.strokeWidth / 2,
          Paint()
            ..color = stroke.color
            ..style = PaintingStyle.fill,
        );
      }
      return;
    }

    final paint = Paint()
      ..color = stroke.color
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(stroke.points.first.dx, stroke.points.first.dy);

    for (int i = 1; i < stroke.points.length; i++) {
      if (i < stroke.points.length - 1) {
        final mid = Offset(
          (stroke.points[i].dx + stroke.points[i + 1].dx) / 2,
          (stroke.points[i].dy + stroke.points[i + 1].dy) / 2,
        );
        path.quadraticBezierTo(
          stroke.points[i].dx,
          stroke.points[i].dy,
          mid.dx,
          mid.dy,
        );
      } else {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
    }
    canvas.drawPath(path, paint);
  }

  void _drawEraser(Canvas canvas, EraserElement eraser) {
    if (eraser.points.isEmpty) return;

    final paint = Paint()
      ..color = eraser.color
      ..strokeWidth = eraser.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (eraser.points.length == 1) {
      canvas.drawCircle(
        eraser.points.first,
        eraser.strokeWidth / 2,
        Paint()..color = eraser.color..style = PaintingStyle.fill,
      );
      return;
    }

    final path = Path()
      ..moveTo(eraser.points.first.dx, eraser.points.first.dy);
    for (int i = 1; i < eraser.points.length; i++) {
      path.lineTo(eraser.points[i].dx, eraser.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, TextElement te) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: te.text,
        style: TextStyle(
          color: te.color,
          fontSize: te.fontSize,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, te.position);
  }

  void _drawLine(Canvas canvas, LineElement line) {
    final paint = Paint()
      ..color = line.color
      ..strokeWidth = line.strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(line.start, line.end, paint);
  }

  void _drawArrow(Canvas canvas, ArrowElement arrow) {
    final paint = Paint()
      ..color = arrow.color
      ..strokeWidth = arrow.strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(arrow.start, arrow.end, paint);

    // Arrowhead
    final angle = math.atan2(
      arrow.end.dy - arrow.start.dy,
      arrow.end.dx - arrow.start.dx,
    );
    final arrowSize = arrow.strokeWidth * 4;
    final headPaint = Paint()
      ..color = arrow.color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(arrow.end.dx, arrow.end.dy)
      ..lineTo(
        arrow.end.dx - arrowSize * math.cos(angle - 0.4),
        arrow.end.dy - arrowSize * math.sin(angle - 0.4),
      )
      ..lineTo(
        arrow.end.dx - arrowSize * math.cos(angle + 0.4),
        arrow.end.dy - arrowSize * math.sin(angle + 0.4),
      )
      ..close();
    canvas.drawPath(path, headPaint);
  }

  void _drawRectangle(Canvas canvas, RectangleElement rect) {
    final paint = Paint()
      ..color = rect.color
      ..strokeWidth = rect.strokeWidth
      ..style = PaintingStyle.stroke;
    canvas.drawRect(
      Rect.fromPoints(rect.topLeft, rect.bottomRight),
      paint,
    );
  }

  void _drawCircle(Canvas canvas, CircleElement circle) {
    final paint = Paint()
      ..color = circle.color
      ..strokeWidth = circle.strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromCenter(
      center: circle.center,
      width: circle.radiusX * 2,
      height: circle.radiusY * 2,
    );
    canvas.drawOval(rect, paint);
  }

  @override
  bool shouldRepaint(covariant WhiteboardPainter old) =>
      old.elements != elements ||
      old.activeElement != activeElement ||
      old.background != background ||
      old.darkCanvas != darkCanvas;
}
