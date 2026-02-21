import 'dart:ui';

/// Active drawing tool
enum WhiteboardTool {
  pen,
  eraser,
  text,
  line,
  arrow,
  rectangle,
  circle,
}

/// Canvas background type
enum CanvasBackground {
  plain,
  grid,
  graphPaper,
  dotGrid,
}

/// Base sealed class for all drawable elements
sealed class DrawingElement {
  final String id;
  final Color color;
  final double strokeWidth;

  const DrawingElement({
    required this.id,
    required this.color,
    required this.strokeWidth,
  });
}

/// Freehand stroke
class StrokeElement extends DrawingElement {
  final List<Offset> points;

  const StrokeElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.points,
  });

  StrokeElement addPoint(Offset point) {
    return StrokeElement(
      id: id,
      color: color,
      strokeWidth: strokeWidth,
      points: [...points, point],
    );
  }
}

/// Eraser path
class EraserElement extends DrawingElement {
  final List<Offset> points;

  const EraserElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.points,
  });

  EraserElement addPoint(Offset point) {
    return EraserElement(
      id: id,
      color: color,
      strokeWidth: strokeWidth,
      points: [...points, point],
    );
  }
}

/// Text annotation
class TextElement extends DrawingElement {
  final Offset position;
  final String text;
  final double fontSize;

  const TextElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.position,
    required this.text,
    required this.fontSize,
  });
}

/// Straight line
class LineElement extends DrawingElement {
  final Offset start;
  final Offset end;

  const LineElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.start,
    required this.end,
  });
}

/// Arrow (line with arrowhead)
class ArrowElement extends DrawingElement {
  final Offset start;
  final Offset end;

  const ArrowElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.start,
    required this.end,
  });
}

/// Rectangle
class RectangleElement extends DrawingElement {
  final Offset topLeft;
  final Offset bottomRight;

  const RectangleElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.topLeft,
    required this.bottomRight,
  });
}

/// Circle/Ellipse
class CircleElement extends DrawingElement {
  final Offset center;
  final double radiusX;
  final double radiusY;

  const CircleElement({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.center,
    required this.radiusX,
    required this.radiusY,
  });
}
