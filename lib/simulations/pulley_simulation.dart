import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

/// Pulley System Simulation demonstrating mechanical advantage
/// Shows how pulleys reduce the force needed to lift objects
class PulleySimulation extends StatefulWidget {
  const PulleySimulation({super.key});

  @override
  State<PulleySimulation> createState() => _PulleySimulationState();
}

class _PulleySimulationState extends State<PulleySimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _loadMass = 10.0; // kg
  int _numPulleys = 1;
  final double _gravity = 9.81;

  double _ropePosition = 0.0;
  double _pullForce = 0.0;
  bool _isPulling = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updateSystem);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Pulley System Simulation. Explore how pulleys provide mechanical advantage. '
        'A single fixed pulley changes the direction of force. '
        'Multiple pulleys reduce the force needed but increase the distance you must pull. '
        'The mechanical advantage equals the number of supporting rope sections.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateSystem() {
    if (!_isPulling) return;

    setState(() {
      // Move rope based on applied force
      final requiredForce = (_loadMass * _gravity) / _numPulleys;
      if (_pullForce >= requiredForce) {
        _ropePosition += 2 / _numPulleys; // Distance trade-off
      }

      if (_ropePosition > 150) {
        _ropePosition = 150;
        _isPulling = false;
      }
    });
  }

  double get _weight => _loadMass * _gravity;
  double get _mechanicalAdvantage => _numPulleys.toDouble();
  double get _effortRequired => _weight / _mechanicalAdvantage;
  double get _distanceMultiplier => _mechanicalAdvantage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pulley Systems'),
        backgroundColor: Colors.blueGrey,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade800, Colors.blueGrey.shade900],
          ),
        ),
        child: Column(
          children: [
            _buildInfoPanel(),
            Expanded(child: _buildSimulationArea()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade300),
      ),
      child: Column(
        children: [
          Text(
            _getPulleyTypeName(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Load', '${_loadMass.toStringAsFixed(1)} kg'),
              _buildInfoItem('Weight', '${_weight.toStringAsFixed(1)} N'),
              _buildInfoItem('MA', '${_mechanicalAdvantage.toStringAsFixed(0)}x'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Effort Needed', '${_effortRequired.toStringAsFixed(1)} N', Colors.green),
              _buildInfoItem('Pull Distance', '${_distanceMultiplier.toStringAsFixed(0)}x load distance', Colors.orange),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade700,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Work In = Work Out: Effort × Distance (pull) = Load × Distance (lift)',
              style: const TextStyle(color: Colors.amber, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getPulleyTypeName() {
    switch (_numPulleys) {
      case 1:
        return 'Single Fixed Pulley (MA = 1)';
      case 2:
        return 'Single Movable Pulley (MA = 2)';
      case 3:
        return 'Block and Tackle - 3 Pulleys (MA = 3)';
      case 4:
        return 'Block and Tackle - 4 Pulleys (MA = 4)';
      default:
        return 'Pulley System (MA = $_numPulleys)';
    }
  }

  Widget _buildInfoItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color ?? Colors.white70, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _PulleyPainter(
            numPulleys: _numPulleys,
            loadMass: _loadMass,
            ropePosition: _ropePosition,
            pullForce: _pullForce,
            effortRequired: _effortRequired,
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black45,
      child: Column(
        children: [
          // Pulley type selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [1, 2, 3, 4].map((n) {
              return ChoiceChip(
                label: Text('$n Pulley${n > 1 ? 's' : ''}'),
                selected: _numPulleys == n,
                selectedColor: Colors.blueGrey.shade400,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _numPulleys = n;
                      _ropePosition = 0;
                    });
                    speakSimulation(
                      '$n pulley system selected. Mechanical advantage is $n. '
                      'You need ${(_weight / n).toStringAsFixed(1)} newtons to lift the ${_loadMass.toStringAsFixed(1)} kilogram load.',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Mass slider
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Load Mass:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _loadMass,
                  min: 1,
                  max: 50,
                  activeColor: Colors.blueGrey,
                  onChanged: (value) {
                    setState(() {
                      _loadMass = value;
                      _ropePosition = 0;
                    });
                  },
                ),
              ),
              Text('${_loadMass.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Pull force slider (simulates user pulling)
          Row(
            children: [
              const Icon(Icons.pan_tool, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Pull Force:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _pullForce,
                  min: 0,
                  max: 500,
                  activeColor: _pullForce >= _effortRequired ? Colors.green : Colors.red,
                  onChanged: (value) {
                    setState(() {
                      _pullForce = value;
                      _isPulling = value >= _effortRequired;
                    });
                  },
                ),
              ),
              Text('${_pullForce.toStringAsFixed(0)} N', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Status indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _pullForce >= _effortRequired ? Colors.green.shade800 : Colors.red.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _pullForce >= _effortRequired
                  ? 'Lifting! Force (${_pullForce.toStringAsFixed(0)} N) ≥ Required (${_effortRequired.toStringAsFixed(0)} N)'
                  : 'Not enough force! Need ${_effortRequired.toStringAsFixed(0)} N, applying ${_pullForce.toStringAsFixed(0)} N',
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _ropePosition = 0;
                _pullForce = 0;
                _isPulling = false;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
          ),

          const SizedBox(height: 8),

          // Key equation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'MA = Load/Effort = Distance pulled/Distance lifted  |  Work = Force × Distance',
              style: TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _PulleyPainter extends CustomPainter {
  final int numPulleys;
  final double loadMass;
  final double ropePosition;
  final double pullForce;
  final double effortRequired;

  _PulleyPainter({
    required this.numPulleys,
    required this.loadMass,
    required this.ropePosition,
    required this.pullForce,
    required this.effortRequired,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (numPulleys) {
      case 1:
        _drawSingleFixedPulley(canvas, size);
        break;
      case 2:
        _drawMovablePulley(canvas, size);
        break;
      case 3:
      case 4:
        _drawBlockAndTackle(canvas, size);
        break;
    }
  }

  void _drawSingleFixedPulley(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final pulleyY = 60.0;
    final pulleyRadius = 25.0;

    // Draw support beam
    final beamPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 8;
    canvas.drawLine(Offset(0, 30), Offset(size.width, 30), beamPaint);

    // Draw pulley wheel
    _drawPulleyWheel(canvas, Offset(centerX, pulleyY), pulleyRadius);

    // Draw rope
    final ropePaint = Paint()
      ..color = Colors.amber.shade700
      ..strokeWidth = 3;

    final loadY = pulleyY + 100 + ropePosition / numPulleys;
    final loadHeight = loadY;

    // Rope over pulley
    canvas.drawLine(Offset(centerX - pulleyRadius, pulleyY), Offset(centerX - pulleyRadius, loadHeight), ropePaint);
    canvas.drawLine(Offset(centerX + pulleyRadius, pulleyY), Offset(centerX + pulleyRadius, size.height - 50), ropePaint);

    // Draw load
    _drawLoad(canvas, Offset(centerX - pulleyRadius, loadHeight), loadMass);

    // Draw hand pulling
    _drawHand(canvas, Offset(centerX + pulleyRadius, size.height - 80), pullForce >= effortRequired);

    // Draw arrows showing force direction
    _drawForceArrow(canvas, Offset(centerX + pulleyRadius + 30, size.height - 100), 50, true, 'Effort');
    _drawForceArrow(canvas, Offset(centerX - pulleyRadius - 30, loadHeight - 30), 50, false, 'Load');
  }

  void _drawMovablePulley(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final fixedPulleyY = 60.0;
    final pulleyRadius = 20.0;

    // Draw support beam
    final beamPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 8;
    canvas.drawLine(Offset(0, 30), Offset(size.width, 30), beamPaint);

    // Draw fixed pulley
    _drawPulleyWheel(canvas, Offset(centerX, fixedPulleyY), pulleyRadius);

    // Movable pulley position
    final movablePulleyY = fixedPulleyY + 120 + ropePosition / numPulleys;

    // Draw movable pulley
    _drawPulleyWheel(canvas, Offset(centerX - 40, movablePulleyY), pulleyRadius);

    // Draw rope
    final ropePaint = Paint()
      ..color = Colors.amber.shade700
      ..strokeWidth = 3;

    // Rope path: anchor -> movable pulley -> fixed pulley -> hand
    canvas.drawLine(Offset(centerX - 60, 30), Offset(centerX - 60, movablePulleyY), ropePaint);
    canvas.drawLine(Offset(centerX - 60, movablePulleyY), Offset(centerX - 20, movablePulleyY), ropePaint);
    canvas.drawLine(Offset(centerX - 20, movablePulleyY), Offset(centerX, fixedPulleyY), ropePaint);
    canvas.drawLine(Offset(centerX + pulleyRadius, fixedPulleyY), Offset(centerX + pulleyRadius, size.height - 50), ropePaint);

    // Draw load attached to movable pulley
    _drawLoad(canvas, Offset(centerX - 40, movablePulleyY + 30), loadMass);

    // Draw hand
    _drawHand(canvas, Offset(centerX + pulleyRadius, size.height - 80), pullForce >= effortRequired);

    // Labels
    _drawLabel(canvas, Offset(centerX, fixedPulleyY - 30), 'Fixed');
    _drawLabel(canvas, Offset(centerX - 40, movablePulleyY - 30), 'Movable');
  }

  void _drawBlockAndTackle(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final topY = 50.0;
    final pulleyRadius = 15.0;
    final spacing = 35.0;

    // Draw support beam
    final beamPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 8;
    canvas.drawLine(Offset(0, 30), Offset(size.width, 30), beamPaint);

    // Calculate positions
    final fixedBlockY = topY;
    final movableBlockY = topY + 100 + ropePosition / numPulleys;

    // Draw fixed block (top)
    final fixedPulleys = (numPulleys / 2).ceil();
    for (var i = 0; i < fixedPulleys; i++) {
      _drawPulleyWheel(canvas, Offset(centerX - 30 + i * spacing, fixedBlockY), pulleyRadius);
    }

    // Draw movable block (bottom)
    final movablePulleys = numPulleys ~/ 2;
    for (var i = 0; i < movablePulleys; i++) {
      _drawPulleyWheel(canvas, Offset(centerX - 15 + i * spacing, movableBlockY), pulleyRadius);
    }

    // Draw rope (simplified representation)
    final ropePaint = Paint()
      ..color = Colors.amber.shade700
      ..strokeWidth = 2;

    for (var i = 0; i < numPulleys; i++) {
      final x = centerX - 30 + (i % fixedPulleys) * spacing;
      if (i < fixedPulleys) {
        canvas.drawLine(Offset(x, fixedBlockY), Offset(x, movableBlockY), ropePaint);
      }
    }

    // Free end of rope
    canvas.drawLine(
      Offset(centerX + (fixedPulleys - 1) * spacing - 15, fixedBlockY),
      Offset(centerX + (fixedPulleys - 1) * spacing - 15, size.height - 50),
      ropePaint,
    );

    // Draw load
    _drawLoad(canvas, Offset(centerX, movableBlockY + 40), loadMass);

    // Draw hand
    _drawHand(canvas, Offset(centerX + (fixedPulleys - 1) * spacing - 15, size.height - 80), pullForce >= effortRequired);

    // Block labels
    _drawLabel(canvas, Offset(centerX, fixedBlockY - 25), 'Fixed Block');
    _drawLabel(canvas, Offset(centerX, movableBlockY + 80), 'Movable Block');
  }

  void _drawPulleyWheel(Canvas canvas, Offset center, double radius) {
    // Wheel
    final wheelPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, wheelPaint);

    // Groove
    final groovePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 3, groovePaint);

    // Axle
    final axlePaint = Paint()..color = Colors.grey.shade800;
    canvas.drawCircle(center, 5, axlePaint);

    // Mounting bracket
    final bracketPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 4;
    canvas.drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy - radius - 15), bracketPaint);
  }

  void _drawLoad(Canvas canvas, Offset position, double mass) {
    final boxSize = 40.0 + mass * 0.5;

    final boxPaint = Paint()..color = Colors.blue.shade700;
    final boxRect = Rect.fromCenter(center: position, width: boxSize, height: boxSize);
    canvas.drawRect(boxRect, boxPaint);

    final borderPaint = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(boxRect, borderPaint);

    // Mass label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${mass.toStringAsFixed(0)} kg',
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2));
  }

  void _drawHand(Canvas canvas, Offset position, bool pulling) {
    final handPaint = Paint()
      ..color = pulling ? Colors.green.shade400 : Colors.red.shade400;
    canvas.drawCircle(position, 15, handPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: pulling ? '↓' : '•',
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2));
  }

  void _drawForceArrow(Canvas canvas, Offset start, double length, bool down, String label) {
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2;

    final end = down ? Offset(start.dx, start.dy + length) : Offset(start.dx, start.dy - length);
    canvas.drawLine(start, end, arrowPaint);

    // Arrow head
    final headPath = Path();
    if (down) {
      headPath
        ..moveTo(end.dx - 8, end.dy - 10)
        ..lineTo(end.dx, end.dy)
        ..lineTo(end.dx + 8, end.dy - 10);
    } else {
      headPath
        ..moveTo(end.dx - 8, end.dy + 10)
        ..lineTo(end.dx, end.dy)
        ..lineTo(end.dx + 8, end.dy + 10);
    }
    canvas.drawPath(headPath, arrowPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.yellow, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(start.dx - textPainter.width / 2, down ? end.dy + 5 : end.dy - 20));
  }

  void _drawLabel(Canvas canvas, Offset position, String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white70, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy));
  }

  @override
  bool shouldRepaint(covariant _PulleyPainter oldDelegate) {
    return oldDelegate.ropePosition != ropePosition ||
           oldDelegate.numPulleys != numPulleys ||
           oldDelegate.pullForce != pullForce;
  }
}
