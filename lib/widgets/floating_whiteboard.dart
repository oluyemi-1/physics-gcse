import 'package:flutter/material.dart';
import 'package:physics_gcse/screens/whiteboard_screen.dart';

/// Adds a floating pen button on every screen that opens the whiteboard.
class FloatingWhiteboardWrapper extends StatelessWidget {
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  const FloatingWhiteboardWrapper({
    super.key,
    required this.child,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          right: 16,
          bottom: 24,
          child: FloatingActionButton(
            heroTag: 'whiteboard_fab',
            mini: true,
            backgroundColor: const Color(0xFF1A237E),
            onPressed: () {
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (_) => const WhiteboardScreen(),
                ),
              );
            },
            child: const Icon(Icons.draw, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }
}
