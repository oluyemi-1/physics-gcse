import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class TerminalVelocitySimulation extends StatefulWidget {
  const TerminalVelocitySimulation({super.key});

  @override
  State<TerminalVelocitySimulation> createState() =>
      _TerminalVelocitySimulationState();
}

class _TerminalVelocitySimulationState extends State<TerminalVelocitySimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _objectY = 50.0;
  double _velocity = 0.0;
  double _time = 0.0;
  bool _isRunning = false;
  bool _hasSpokenIntro = false;
  bool _reachedTerminal = false;

  double _mass = 70.0; // kg
  String _selectedObject = 'Skydiver';

  final Map<String, Map<String, double>> _objects = {
    'Skydiver': {'mass': 70.0, 'drag': 1.0, 'terminalV': 55.0},
    'Golf Ball': {'mass': 0.045, 'drag': 0.3, 'terminalV': 32.0},
    'Raindrop': {'mass': 0.001, 'drag': 0.5, 'terminalV': 9.0},
    'Feather': {'mass': 0.001, 'drag': 5.0, 'terminalV': 0.4},
  };

  final List<Offset> _velocityData = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateFall);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Terminal Velocity simulation! '
          'When an object falls, gravity accelerates it downward. '
          'As speed increases, air resistance grows until it equals the weight. '
          'At this point, the object reaches terminal velocity and falls at constant speed.',
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

  void _updateFall() {
    if (!_isRunning) return;

    setState(() {
      final dt = 0.016;
      _time += dt;

      final terminalV = _objects[_selectedObject]!['terminalV']!;

      // Simplified model: v approaches terminal velocity exponentially
      // v = vt * (1 - e^(-t/tau))
      final tau = terminalV / 9.8;
      _velocity = terminalV * (1 - math.exp(-_time / tau));

      // Update position
      _objectY += _velocity * dt * 2;

      // Record velocity data
      if (_velocityData.isEmpty || _time - _velocityData.last.dx > 0.1) {
        _velocityData.add(Offset(_time, _velocity));
      }

      // Check if terminal velocity reached
      if (_velocity > terminalV * 0.95 && !_reachedTerminal) {
        _reachedTerminal = true;
        speakSimulation(
          'Terminal velocity reached! Air resistance now equals weight. '
          'The object falls at constant speed of ${terminalV.toStringAsFixed(1)} metres per second.',
        );
      }

      // Reset if off screen
      if (_objectY > 500) {
        _objectY = 50;
      }
    });
  }

  void _toggleSimulation() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      _isRunning = false;
      _controller.stop();
      _objectY = 50;
      _velocity = 0;
      _time = 0;
      _velocityData.clear();
      _reachedTerminal = false;
    });
  }

  void _onObjectChanged(String? object) {
    if (object == null) return;
    _resetSimulation();
    setState(() {
      _selectedObject = object;
      _mass = _objects[object]!['mass']!;
    });

    final terminalV = _objects[object]!['terminalV']!;
    speakSimulation(
      '$object selected. Mass: ${_mass}kg. Terminal velocity: ${terminalV.toStringAsFixed(1)} metres per second. '
      'Heavier objects with less surface area have higher terminal velocities.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final terminalV = _objects[_selectedObject]!['terminalV']!;
    final weight = _mass * 9.8;
    final dragForce = weight * (_velocity / terminalV);

    return Column(
      children: [
        // Falling object visualization
        Expanded(
          flex: 2,
          child: Row(
            children: [
              // Fall animation
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.lightBlue.shade200, Colors.lightBlue.shade400],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _FallingObjectPainter(
                      objectY: _objectY,
                      velocity: _velocity,
                      terminalV: terminalV,
                      objectType: _selectedObject,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              // Force diagram
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomPaint(
                    painter: _ForceDiagramPainter(
                      weight: weight,
                      dragForce: dragForce,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Velocity-time graph
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _VelocityGraphPainter(
                dataPoints: _velocityData,
                terminalV: terminalV,
                maxTime: 10.0,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Velocity',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '${_velocity.toStringAsFixed(1)} m/s',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Terminal V',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '${terminalV.toStringAsFixed(1)} m/s',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Time',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '${_time.toStringAsFixed(1)} s',
                    style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Object selector
              Row(
                children: [
                  const Text('Object: ', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedObject,
                      dropdownColor: Colors.grey[800],
                      isExpanded: true,
                      items: _objects.keys.map((obj) {
                        return DropdownMenuItem(
                          value: obj,
                          child: Text(obj,
                              style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: _onObjectChanged,
                    ),
                  ),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _toggleSimulation,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Drop'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isRunning ? Colors.orange : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _resetSimulation,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  buildTTSToggle(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FallingObjectPainter extends CustomPainter {
  final double objectY;
  final double velocity;
  final double terminalV;
  final String objectType;

  _FallingObjectPainter({
    required this.objectY,
    required this.velocity,
    required this.terminalV,
    required this.objectType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw clouds
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 30), width: 50, height: 25), cloudPaint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width - 50, 60), width: 60, height: 30), cloudPaint);

    // Draw falling object
    final objectPaint = Paint();
    final x = size.width / 2;
    final y = math.min(objectY, size.height - 30);

    switch (objectType) {
      case 'Skydiver':
        // Draw skydiver
        objectPaint.color = Colors.orange;
        canvas.drawCircle(Offset(x, y - 15), 10, objectPaint); // Head
        objectPaint.color = Colors.blue;
        canvas.drawRect(Rect.fromCenter(center: Offset(x, y + 5), width: 20, height: 30), objectPaint); // Body
        // Arms spread
        canvas.drawLine(Offset(x - 10, y), Offset(x - 30, y + 10), objectPaint..strokeWidth = 4);
        canvas.drawLine(Offset(x + 10, y), Offset(x + 30, y + 10), objectPaint..strokeWidth = 4);
        break;
      case 'Golf Ball':
        objectPaint.color = Colors.white;
        canvas.drawCircle(Offset(x, y), 10, objectPaint);
        objectPaint.color = Colors.grey;
        objectPaint.style = PaintingStyle.stroke;
        canvas.drawCircle(Offset(x, y), 10, objectPaint);
        break;
      case 'Raindrop':
        objectPaint.color = Colors.blue.shade300;
        final path = Path()
          ..moveTo(x, y - 10)
          ..quadraticBezierTo(x + 8, y + 5, x, y + 10)
          ..quadraticBezierTo(x - 8, y + 5, x, y - 10);
        canvas.drawPath(path, objectPaint);
        break;
      case 'Feather':
        objectPaint.color = Colors.white;
        objectPaint.strokeWidth = 2;
        canvas.drawLine(Offset(x - 15, y - 5), Offset(x + 15, y + 5), objectPaint);
        for (int i = -3; i <= 3; i++) {
          canvas.drawLine(
            Offset(x + i * 4, y + i * 0.5),
            Offset(x + i * 4 + (i < 0 ? -5 : 5), y + i * 0.5 - 3),
            objectPaint..strokeWidth = 1,
          );
        }
        break;
    }

    // Draw air resistance arrows
    if (velocity > 0.1) {
      final arrowPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.6)
        ..strokeWidth = 2;

      final arrowLength = (velocity / terminalV) * 30;
      for (int i = -1; i <= 1; i++) {
        final arrowX = x + i * 25;
        canvas.drawLine(
          Offset(arrowX, y - 30 - arrowLength),
          Offset(arrowX, y - 30),
          arrowPaint,
        );
        // Arrow head
        canvas.drawLine(Offset(arrowX, y - 30), Offset(arrowX - 5, y - 35), arrowPaint);
        canvas.drawLine(Offset(arrowX, y - 30), Offset(arrowX + 5, y - 35), arrowPaint);
      }
    }

    // Ground
    final groundPaint = Paint()..color = Colors.green.shade700;
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 20, size.width, 20),
      groundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FallingObjectPainter oldDelegate) {
    return objectY != oldDelegate.objectY || velocity != oldDelegate.velocity;
  }
}

class _ForceDiagramPainter extends CustomPainter {
  final double weight;
  final double dragForce;

  _ForceDiagramPainter({
    required this.weight,
    required this.dragForce,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw object representation
    final objectPaint = Paint()..color = Colors.grey;
    canvas.drawCircle(Offset(centerX, centerY), 20, objectPaint);

    // Scale forces for display
    final maxForce = weight;
    final scale = 50.0 / maxForce;

    // Weight arrow (down)
    final weightLength = weight * scale;
    final weightPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(centerX, centerY + 20),
      Offset(centerX, centerY + 20 + weightLength),
      weightPaint,
    );
    _drawArrowHead(canvas, Offset(centerX, centerY + 20 + weightLength), math.pi / 2, Colors.red);

    // Drag arrow (up)
    final dragLength = dragForce * scale;
    final dragPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(centerX, centerY - 20),
      Offset(centerX, centerY - 20 - dragLength),
      dragPaint,
    );
    if (dragLength > 5) {
      _drawArrowHead(canvas, Offset(centerX, centerY - 20 - dragLength), -math.pi / 2, Colors.green);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'Weight (mg)',
      style: TextStyle(color: Colors.red, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 5, centerY + 25 + weightLength / 2));

    textPainter.text = const TextSpan(
      text: 'Air resistance',
      style: TextStyle(color: Colors.green, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 5, centerY - 40 - dragLength / 2));

    // Net force indicator
    final netForce = weight - dragForce;
    textPainter.text = TextSpan(
      text: 'Net: ${netForce.toStringAsFixed(1)}N',
      style: TextStyle(
        color: netForce < 0.1 ? Colors.yellow : Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(5, size.height - 20));
  }

  void _drawArrowHead(Canvas canvas, Offset tip, double angle, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const arrowSize = 8.0;
    final path = Path();
    path.moveTo(tip.dx, tip.dy);
    path.lineTo(
      tip.dx + arrowSize * math.cos(angle + 2.5),
      tip.dy + arrowSize * math.sin(angle + 2.5),
    );
    path.lineTo(
      tip.dx + arrowSize * math.cos(angle - 2.5),
      tip.dy + arrowSize * math.sin(angle - 2.5),
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ForceDiagramPainter oldDelegate) {
    return weight != oldDelegate.weight || dragForce != oldDelegate.dragForce;
  }
}

class _VelocityGraphPainter extends CustomPainter {
  final List<Offset> dataPoints;
  final double terminalV;
  final double maxTime;

  _VelocityGraphPainter({
    required this.dataPoints,
    required this.terminalV,
    required this.maxTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;
    final graphWidth = size.width - padding - 10;
    final graphHeight = size.height - 30;

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, 10),
      Offset(padding, size.height - 20),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, size.height - 20),
      Offset(size.width - 10, size.height - 20),
      axisPaint,
    );

    // Draw terminal velocity line
    final terminalY = 10 + graphHeight * (1 - terminalV / (terminalV * 1.2));
    final terminalPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(padding, terminalY),
      Offset(size.width - 10, terminalY),
      terminalPaint,
    );

    // Draw velocity curve
    if (dataPoints.length > 1) {
      final curvePaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      for (int i = 0; i < dataPoints.length; i++) {
        final point = dataPoints[i];
        final x = padding + (point.dx / maxTime) * graphWidth;
        final y = 10 + graphHeight * (1 - point.dy / (terminalV * 1.2));

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, curvePaint);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'v (m/s)',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(5, 5));

    textPainter.text = const TextSpan(
      text: 't (s)',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 30, size.height - 15));

    textPainter.text = TextSpan(
      text: 'vₜ = ${terminalV.toStringAsFixed(0)}',
      style: const TextStyle(color: Colors.orange, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 50, terminalY - 12));
  }

  @override
  bool shouldRepaint(covariant _VelocityGraphPainter oldDelegate) {
    return dataPoints.length != oldDelegate.dataPoints.length;
  }
}
