import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:physics_gcse/models/whiteboard_models.dart';
import 'package:physics_gcse/providers/whiteboard_provider.dart';
import 'package:physics_gcse/widgets/whiteboard_canvas.dart';
import 'package:physics_gcse/widgets/whiteboard_toolbar.dart';

class WhiteboardScreen extends StatelessWidget {
  const WhiteboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Uses the global WhiteboardProvider from main.dart
    // so drawings persist across navigation
    return const _WhiteboardBody();
  }
}

class _WhiteboardBody extends StatelessWidget {
  const _WhiteboardBody();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WhiteboardProvider>();

    return Scaffold(
      backgroundColor: provider.darkCanvas
          ? const Color(0xFF1E1E1E)
          : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Whiteboard',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Undo
          IconButton(
            icon: const Icon(Icons.undo, size: 20),
            onPressed: provider.canUndo ? provider.undo : null,
            tooltip: 'Undo',
          ),
          // Redo
          IconButton(
            icon: const Icon(Icons.redo, size: 20),
            onPressed: provider.canRedo ? provider.redo : null,
            tooltip: 'Redo',
          ),
          // Background selector
          PopupMenuButton<CanvasBackground>(
            icon: const Icon(Icons.grid_on, size: 20),
            tooltip: 'Background',
            color: const Color(0xFF252525),
            onSelected: provider.setBackground,
            itemBuilder: (_) => [
              _bgMenuItem(CanvasBackground.plain, 'Plain', Icons.crop_square,
                  provider.background),
              _bgMenuItem(CanvasBackground.grid, 'Grid', Icons.grid_on,
                  provider.background),
              _bgMenuItem(CanvasBackground.graphPaper, 'Graph Paper',
                  Icons.grid_4x4, provider.background),
              _bgMenuItem(CanvasBackground.dotGrid, 'Dot Grid',
                  Icons.grain, provider.background),
            ],
          ),
          // Dark/light toggle
          IconButton(
            icon: Icon(
              provider.darkCanvas ? Icons.light_mode : Icons.dark_mode,
              size: 20,
            ),
            onPressed: provider.toggleCanvasTheme,
            tooltip: provider.darkCanvas ? 'Light canvas' : 'Dark canvas',
          ),
          // Snap to grid toggle
          IconButton(
            icon: Icon(
              Icons.grid_3x3,
              size: 20,
              color: provider.snapToGrid
                  ? const Color(0xFF00BCD4)
                  : Colors.white,
            ),
            onPressed: provider.toggleSnapToGrid,
            tooltip: 'Snap to grid',
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: provider.elements.isEmpty
                ? null
                : () => _confirmClear(context, provider),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: Column(
        children: [
          // Page navigation bar
          Container(
            height: 40,
            color: const Color(0xFF252525),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                // Previous page
                IconButton(
                  icon: const Icon(Icons.chevron_left, size: 20),
                  color: provider.currentPageIndex > 0
                      ? Colors.white
                      : Colors.white24,
                  onPressed: provider.currentPageIndex > 0
                      ? provider.previousPage
                      : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                  tooltip: 'Previous page',
                ),
                // Page indicator
                Text(
                  'Page ${provider.currentPageIndex + 1} of ${provider.pageCount}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                // Next page
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  color: provider.currentPageIndex < provider.pageCount - 1
                      ? Colors.white
                      : Colors.white24,
                  onPressed:
                      provider.currentPageIndex < provider.pageCount - 1
                          ? provider.nextPage
                          : null,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                  tooltip: 'Next page',
                ),
                const SizedBox(width: 8),
                // Add page
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20),
                  color: Colors.white70,
                  onPressed: provider.addPage,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36),
                  tooltip: 'Add new page',
                ),
                const Spacer(),
                // Delete page (only if more than 1 page)
                if (provider.pageCount > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.red.shade300,
                    onPressed: () => _confirmDeletePage(context, provider),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36),
                    tooltip: 'Delete this page',
                  ),
              ],
            ),
          ),
          const Expanded(child: WhiteboardCanvas()),
          const WhiteboardToolbar(),
        ],
      ),
    );
  }

  PopupMenuEntry<CanvasBackground> _bgMenuItem(
    CanvasBackground value,
    String label,
    IconData icon,
    CanvasBackground current,
  ) {
    final isSelected = current == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? const Color(0xFF00BCD4) : Colors.white70,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00BCD4) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeletePage(BuildContext context, WhiteboardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title:
            const Text('Delete Page', style: TextStyle(color: Colors.white)),
        content: Text(
          'Delete page ${provider.currentPageIndex + 1} of ${provider.pageCount}? This cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deletePage();
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WhiteboardProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF252525),
        title: const Text('Clear Canvas', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to clear everything? You can undo this.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearAll();
              Navigator.pop(ctx);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
