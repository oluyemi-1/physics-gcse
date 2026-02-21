import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physics_gcse/models/whiteboard_models.dart';
import 'package:physics_gcse/painters/whiteboard_painter.dart';
import 'package:physics_gcse/providers/whiteboard_provider.dart';

class WhiteboardCanvas extends StatelessWidget {
  const WhiteboardCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WhiteboardProvider>();

    return Listener(
      onPointerDown: (event) {
        // Ignore touch when stylus is active
        if (event.kind == PointerDeviceKind.touch && _hasStylusActive) return;
        if (event.kind == PointerDeviceKind.stylus) _hasStylusActive = true;

        if (provider.currentTool == WhiteboardTool.text) return;
        provider.onPanStart(event.localPosition);
      },
      onPointerMove: (event) {
        if (event.kind == PointerDeviceKind.touch && _hasStylusActive) return;
        provider.onPanUpdate(event.localPosition);
      },
      onPointerUp: (event) {
        if (event.kind == PointerDeviceKind.stylus) _hasStylusActive = false;
        provider.onPanEnd();
      },
      child: GestureDetector(
        onTapUp: (details) {
          if (provider.currentTool == WhiteboardTool.text) {
            _showTextInputDialog(context, details.localPosition);
          }
        },
        child: ClipRect(
          child: CustomPaint(
            painter: WhiteboardPainter(
              elements: provider.elements,
              activeElement: provider.activeElement,
              background: provider.background,
              darkCanvas: provider.darkCanvas,
            ),
            size: Size.infinite,
            isComplex: true,
            willChange: provider.activeElement != null,
          ),
        ),
      ),
    );
  }

  static bool _hasStylusActive = false;

  void _showTextInputDialog(BuildContext context, Offset position) {
    final provider = context.read<WhiteboardProvider>();
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Add Text', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter text...',
            hintStyle: TextStyle(color: Colors.white38),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF00BCD4)),
            ),
          ),
          onSubmitted: (text) {
            provider.addText(position, text);
            Navigator.pop(ctx);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.addText(position, controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
