import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physics_gcse/models/whiteboard_models.dart';
import 'package:physics_gcse/providers/whiteboard_provider.dart';
import 'package:physics_gcse/widgets/whiteboard_color_picker.dart';

class WhiteboardToolbar extends StatefulWidget {
  const WhiteboardToolbar({super.key});

  @override
  State<WhiteboardToolbar> createState() => _WhiteboardToolbarState();
}

class _WhiteboardToolbarState extends State<WhiteboardToolbar> {
  bool _showColorPicker = false;
  bool _showStrokeSlider = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WhiteboardProvider>();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252525),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Expandable color picker
            if (_showColorPicker)
              WhiteboardColorPicker(
                selectedColor: provider.currentColor,
                onColorSelected: (color) {
                  provider.setColor(color);
                },
              ),

            // Expandable stroke width slider
            if (_showStrokeSlider)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.line_weight, color: Colors.white54, size: 16),
                    Expanded(
                      child: Slider(
                        value: provider.currentStrokeWidth,
                        min: 1,
                        max: 20,
                        activeColor: const Color(0xFF00BCD4),
                        inactiveColor: Colors.white24,
                        onChanged: (v) => provider.setStrokeWidth(v),
                      ),
                    ),
                    Text(
                      provider.currentStrokeWidth.toStringAsFixed(1),
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),

            // Main tool row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _toolButton(Icons.edit, WhiteboardTool.pen, provider),
                  _toolButton(Icons.auto_fix_high, WhiteboardTool.eraser, provider),
                  _toolButton(Icons.text_fields, WhiteboardTool.text, provider),
                  _toolButton(Icons.horizontal_rule, WhiteboardTool.line, provider),
                  _toolButton(Icons.arrow_forward, WhiteboardTool.arrow, provider),
                  _toolButton(Icons.rectangle_outlined, WhiteboardTool.rectangle, provider),
                  _toolButton(Icons.circle_outlined, WhiteboardTool.circle, provider),

                  // Color swatch toggle
                  GestureDetector(
                    onTap: () => setState(() {
                      _showColorPicker = !_showColorPicker;
                      _showStrokeSlider = false;
                    }),
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: provider.currentColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _showColorPicker
                              ? const Color(0xFF00BCD4)
                              : Colors.white54,
                          width: _showColorPicker ? 2 : 1,
                        ),
                      ),
                    ),
                  ),

                  // Stroke width toggle
                  _actionButton(
                    Icons.line_weight,
                    _showStrokeSlider,
                    () => setState(() {
                      _showStrokeSlider = !_showStrokeSlider;
                      _showColorPicker = false;
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(
      IconData icon, WhiteboardTool tool, WhiteboardProvider provider) {
    final isSelected = provider.currentTool == tool;
    return GestureDetector(
      onTap: () => provider.setTool(tool),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00BCD4).withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: isSelected ? const Color(0xFF00BCD4) : Colors.white70,
          size: 20,
        ),
      ),
    );
  }

  Widget _actionButton(IconData icon, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF00BCD4).withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: active ? const Color(0xFF00BCD4) : Colors.white70,
          size: 20,
        ),
      ),
    );
  }
}
