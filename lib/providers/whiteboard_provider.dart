import 'package:flutter/material.dart';
import 'package:physics_gcse/models/whiteboard_models.dart';

/// Stores the state of a single whiteboard page.
class _PageState {
  final List<DrawingElement> elements = [];
  final List<List<DrawingElement>> undoStack = [];
  final List<List<DrawingElement>> redoStack = [];
}

class WhiteboardProvider extends ChangeNotifier {
  // Current tool state
  WhiteboardTool _currentTool = WhiteboardTool.pen;
  Color _currentColor = Colors.white;
  double _currentStrokeWidth = 3.0;
  double _currentFontSize = 18.0;
  CanvasBackground _background = CanvasBackground.plain;
  bool _snapToGrid = false;
  bool _darkCanvas = true;

  // Pages
  final List<_PageState> _pages = [_PageState()];
  int _currentPageIndex = 0;

  // Active drawing element
  DrawingElement? _activeElement;
  int _idCounter = 0;
  static const int _maxUndoSteps = 50;

  // Shape drawing state
  Offset? _shapeStart;

  // Current page shortcut
  _PageState get _page => _pages[_currentPageIndex];

  // Getters
  WhiteboardTool get currentTool => _currentTool;
  Color get currentColor => _currentColor;
  double get currentStrokeWidth => _currentStrokeWidth;
  double get currentFontSize => _currentFontSize;
  CanvasBackground get background => _background;
  bool get snapToGrid => _snapToGrid;
  bool get darkCanvas => _darkCanvas;
  List<DrawingElement> get elements => List.unmodifiable(_page.elements);
  DrawingElement? get activeElement => _activeElement;
  bool get canUndo => _page.undoStack.isNotEmpty;
  bool get canRedo => _page.redoStack.isNotEmpty;

  // Page getters
  int get currentPageIndex => _currentPageIndex;
  int get pageCount => _pages.length;

  String _nextId() => 'el_${_idCounter++}';

  // Page management
  void addPage() {
    _pages.add(_PageState());
    _currentPageIndex = _pages.length - 1;
    _activeElement = null;
    _shapeStart = null;
    notifyListeners();
  }

  void goToPage(int index) {
    if (index < 0 || index >= _pages.length) return;
    _currentPageIndex = index;
    _activeElement = null;
    _shapeStart = null;
    notifyListeners();
  }

  void previousPage() {
    if (_currentPageIndex > 0) goToPage(_currentPageIndex - 1);
  }

  void nextPage() {
    if (_currentPageIndex < _pages.length - 1) {
      goToPage(_currentPageIndex + 1);
    } else {
      addPage();
    }
  }

  void deletePage() {
    if (_pages.length <= 1) return;
    _pages.removeAt(_currentPageIndex);
    if (_currentPageIndex >= _pages.length) {
      _currentPageIndex = _pages.length - 1;
    }
    _activeElement = null;
    _shapeStart = null;
    notifyListeners();
  }

  // Tool selection
  void setTool(WhiteboardTool tool) {
    _currentTool = tool;
    notifyListeners();
  }

  void setColor(Color color) {
    _currentColor = color;
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    _currentStrokeWidth = width;
    notifyListeners();
  }

  void setFontSize(double size) {
    _currentFontSize = size;
    notifyListeners();
  }

  void setBackground(CanvasBackground bg) {
    _background = bg;
    notifyListeners();
  }

  void toggleSnapToGrid() {
    _snapToGrid = !_snapToGrid;
    notifyListeners();
  }

  void toggleCanvasTheme() {
    _darkCanvas = !_darkCanvas;
    notifyListeners();
  }

  Offset _maybeSnap(Offset point, {double spacing = 30.0}) {
    if (!_snapToGrid) return point;
    return Offset(
      (point.dx / spacing).round() * spacing,
      (point.dy / spacing).round() * spacing,
    );
  }

  // Drawing operations
  void onPanStart(Offset point) {
    final snapped = _maybeSnap(point);

    switch (_currentTool) {
      case WhiteboardTool.pen:
        _activeElement = StrokeElement(
          id: _nextId(),
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          points: [snapped],
        );
      case WhiteboardTool.eraser:
        _activeElement = EraserElement(
          id: _nextId(),
          color: _darkCanvas ? const Color(0xFF1E1E1E) : Colors.white,
          strokeWidth: _currentStrokeWidth * 6,
          points: [snapped],
        );
      case WhiteboardTool.line:
      case WhiteboardTool.arrow:
      case WhiteboardTool.rectangle:
      case WhiteboardTool.circle:
        _shapeStart = snapped;
        _updateActiveShape(snapped);
      case WhiteboardTool.text:
        return;
    }
    notifyListeners();
  }

  void onPanUpdate(Offset point) {
    final snapped = _maybeSnap(point);

    switch (_currentTool) {
      case WhiteboardTool.pen:
        if (_activeElement is StrokeElement) {
          _activeElement = (_activeElement as StrokeElement).addPoint(snapped);
        }
      case WhiteboardTool.eraser:
        if (_activeElement is EraserElement) {
          _activeElement = (_activeElement as EraserElement).addPoint(snapped);
        }
      case WhiteboardTool.line:
      case WhiteboardTool.arrow:
      case WhiteboardTool.rectangle:
      case WhiteboardTool.circle:
        _updateActiveShape(snapped);
      case WhiteboardTool.text:
        return;
    }
    notifyListeners();
  }

  void onPanEnd() {
    if (_activeElement == null) return;
    _commitElement();
  }

  void _updateActiveShape(Offset current) {
    if (_shapeStart == null) return;
    final start = _shapeStart!;

    switch (_currentTool) {
      case WhiteboardTool.line:
        _activeElement = LineElement(
          id: _nextId(),
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          start: start,
          end: current,
        );
      case WhiteboardTool.arrow:
        _activeElement = ArrowElement(
          id: _nextId(),
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          start: start,
          end: current,
        );
      case WhiteboardTool.rectangle:
        _activeElement = RectangleElement(
          id: _nextId(),
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          topLeft: Offset(
            start.dx < current.dx ? start.dx : current.dx,
            start.dy < current.dy ? start.dy : current.dy,
          ),
          bottomRight: Offset(
            start.dx > current.dx ? start.dx : current.dx,
            start.dy > current.dy ? start.dy : current.dy,
          ),
        );
      case WhiteboardTool.circle:
        final center = Offset(
          (start.dx + current.dx) / 2,
          (start.dy + current.dy) / 2,
        );
        _activeElement = CircleElement(
          id: _nextId(),
          color: _currentColor,
          strokeWidth: _currentStrokeWidth,
          center: center,
          radiusX: (current.dx - start.dx).abs() / 2,
          radiusY: (current.dy - start.dy).abs() / 2,
        );
      default:
        break;
    }
  }

  void addText(Offset position, String text) {
    if (text.trim().isEmpty) return;
    _saveStateForUndo();
    _page.elements.add(TextElement(
      id: _nextId(),
      color: _currentColor,
      strokeWidth: _currentStrokeWidth,
      position: _maybeSnap(position),
      text: text,
      fontSize: _currentFontSize,
    ));
    _page.redoStack.clear();
    notifyListeners();
  }

  void _commitElement() {
    if (_activeElement == null) return;
    _saveStateForUndo();
    _page.elements.add(_activeElement!);
    _activeElement = null;
    _shapeStart = null;
    _page.redoStack.clear();
    notifyListeners();
  }

  void _saveStateForUndo() {
    _page.undoStack.add(List.from(_page.elements));
    if (_page.undoStack.length > _maxUndoSteps) {
      _page.undoStack.removeAt(0);
    }
  }

  // History
  void undo() {
    if (_page.undoStack.isEmpty) return;
    _page.redoStack.add(List.from(_page.elements));
    _page.elements
      ..clear()
      ..addAll(_page.undoStack.removeLast());
    notifyListeners();
  }

  void redo() {
    if (_page.redoStack.isEmpty) return;
    _page.undoStack.add(List.from(_page.elements));
    _page.elements
      ..clear()
      ..addAll(_page.redoStack.removeLast());
    notifyListeners();
  }

  void clearAll() {
    if (_page.elements.isEmpty) return;
    _saveStateForUndo();
    _page.elements.clear();
    _page.redoStack.clear();
    notifyListeners();
  }
}
