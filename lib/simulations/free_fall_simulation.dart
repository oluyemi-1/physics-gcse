import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Free Fall Simulation demonstrating acceleration due to gravity
/// Shows objects falling with constant acceleration (ignoring air resistance)
class FreeFallSimulation extends StatefulWidget {
  const FreeFallSimulation({super.key});

  @override
  State<FreeFallSimulation> createState() => _FreeFallSimulationState();
}

class _FreeFallSimulationState extends State<FreeFallSimulation>
    with TickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _dropHeight = 100.0; // meters
  double _objectMass = 1.0; // kg (doesn't affect fall in vacuum)
  final double _gravity = 9.81; // m/s²

  bool _isDropping = false;
  double _currentHeight = 0.0;
  double _currentVelocity = 0.0;
  double _elapsedTime = 0.0;

  // For comparison drop
  bool _showComparison = false;

  final List<_DropRecord> _dropHistory = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    );

    _controller.addListener(_updateFall);
    _currentHeight = _dropHeight;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Free Fall Simulation. Watch objects fall under gravity with constant acceleration of 9.81 meters per second squared. '
        'In a vacuum, all objects fall at the same rate regardless of mass. '
        'Adjust the drop height and tap Drop to release the object.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateFall() {
    if (!_isDropping) return;

    setState(() {
      // Calculate time step (assuming 60fps)
      const dt = 1 / 60;
      _elapsedTime += dt;

      // Kinematic equations for constant acceleration
      // h = h0 - (1/2)gt²
      // v = gt
      _currentHeight = _dropHeight - (0.5 * _gravity * _elapsedTime * _elapsedTime);
      _currentVelocity = _gravity * _elapsedTime;

      // Check if hit ground
      if (_currentHeight <= 0) {
        _currentHeight = 0;
        _isDropping = false;
        _controller.stop();

        // Record the drop
        final impactVelocity = math.sqrt(2 * _gravity * _dropHeight);
        _dropHistory.add(_DropRecord(
          height: _dropHeight,
          mass: _objectMass,
          fallTime: _elapsedTime,
          impactVelocity: impactVelocity,
        ));

        speakSimulation(
          'Impact! The object fell ${_dropHeight.toStringAsFixed(1)} meters in ${_elapsedTime.toStringAsFixed(2)} seconds, '
          'reaching a final velocity of ${impactVelocity.toStringAsFixed(1)} meters per second.',
        );
      }
    });
  }

  void _startDrop() {
    setState(() {
      _isDropping = true;
      _currentHeight = _dropHeight;
      _currentVelocity = 0;
      _elapsedTime = 0;
    });
    _controller.repeat();

    speakSimulation(
      'Dropping object from ${_dropHeight.toStringAsFixed(0)} meters.',
    );
  }

  void _resetDrop() {
    setState(() {
      _isDropping = false;
      _currentHeight = _dropHeight;
      _currentVelocity = 0;
      _elapsedTime = 0;
    });
    _controller.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Fall'),
        backgroundColor: Colors.deepPurple,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.black],
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
    final theoreticalTime = math.sqrt(2 * _dropHeight / _gravity);
    final theoreticalImpactVelocity = math.sqrt(2 * _gravity * _dropHeight);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'Free Fall Physics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Height', '${_currentHeight.toStringAsFixed(1)} m'),
              _buildInfoItem('Velocity', '${_currentVelocity.toStringAsFixed(1)} m/s'),
              _buildInfoItem('Time', '${_elapsedTime.toStringAsFixed(2)} s'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'Theoretical (from ${_dropHeight.toStringAsFixed(0)}m):',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  't = √(2h/g) = ${theoreticalTime.toStringAsFixed(2)}s    v = √(2gh) = ${theoreticalImpactVelocity.toStringAsFixed(1)} m/s',
                  style: const TextStyle(color: Colors.amber, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _FreeFallPainter(
                dropHeight: _dropHeight,
                currentHeight: _currentHeight,
                velocity: _currentVelocity,
                showComparison: _showComparison,
                mass: _objectMass,
              ),
            ),
            // Height markers
            Positioned(
              left: 10,
              top: 0,
              bottom: 0,
              child: _buildHeightScale(constraints.maxHeight),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeightScale(double height) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(6, (index) {
        final heightValue = _dropHeight * (5 - index) / 5;
        return Text(
          '${heightValue.toStringAsFixed(0)}m',
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        );
      }),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black45,
      child: Column(
        children: [
          // Drop Height Slider
          Row(
            children: [
              const Icon(Icons.height, color: Colors.white70),
              const SizedBox(width: 8),
              const Text('Drop Height:', style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: _dropHeight,
                  min: 10,
                  max: 500,
                  divisions: 49,
                  activeColor: Colors.deepPurple,
                  label: '${_dropHeight.toStringAsFixed(0)} m',
                  onChanged: _isDropping ? null : (value) {
                    setState(() {
                      _dropHeight = value;
                      _currentHeight = value;
                    });
                  },
                ),
              ),
              Text(
                '${_dropHeight.toStringAsFixed(0)} m',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          // Mass Slider (to demonstrate it doesn't affect fall time)
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70),
              const SizedBox(width: 8),
              const Text('Mass:', style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: _objectMass,
                  min: 0.1,
                  max: 100,
                  activeColor: Colors.orange,
                  label: '${_objectMass.toStringAsFixed(1)} kg',
                  onChanged: _isDropping ? null : (value) {
                    setState(() => _objectMass = value);
                  },
                ),
              ),
              Text(
                '${_objectMass.toStringAsFixed(1)} kg',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          // Comparison toggle
          Row(
            children: [
              Checkbox(
                value: _showComparison,
                onChanged: _isDropping ? null : (value) {
                  setState(() => _showComparison = value ?? false);
                  if (_showComparison) {
                    speakSimulation(
                      'Comparison mode enabled. Two objects of different masses will be dropped together. '
                      'In a vacuum, they fall at the same rate, proving gravity accelerates all objects equally.',
                    );
                  }
                },
                activeColor: Colors.deepPurple,
              ),
              const Text(
                'Show comparison (different masses)',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isDropping ? null : _startDrop,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Drop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _resetDrop,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _dropHistory.isEmpty ? null : () {
                  _showDropHistory();
                },
                icon: const Icon(Icons.history),
                label: const Text('History'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Key equations
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Key Equations:  h = ½gt²  |  v = gt  |  v² = 2gh  |  g = 9.81 m/s²',
              style: TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showDropHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text('Drop History', style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _dropHistory.length,
            itemBuilder: (context, index) {
              final record = _dropHistory[_dropHistory.length - 1 - index];
              return ListTile(
                title: Text(
                  'Drop ${_dropHistory.length - index}',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  'Height: ${record.height.toStringAsFixed(1)}m, Time: ${record.fallTime.toStringAsFixed(2)}s, '
                  'Impact: ${record.impactVelocity.toStringAsFixed(1)} m/s',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _dropHistory.clear());
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _DropRecord {
  final double height;
  final double mass;
  final double fallTime;
  final double impactVelocity;

  _DropRecord({
    required this.height,
    required this.mass,
    required this.fallTime,
    required this.impactVelocity,
  });
}

class _FreeFallPainter extends CustomPainter {
  final double dropHeight;
  final double currentHeight;
  final double velocity;
  final bool showComparison;
  final double mass;

  _FreeFallPainter({
    required this.dropHeight,
    required this.currentHeight,
    required this.velocity,
    required this.showComparison,
    required this.mass,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final groundY = size.height - 50;
    final startY = 50.0;
    final fallRange = groundY - startY;

    // Draw background gradient for atmosphere/vacuum
    final bgPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black,
          Colors.deepPurple.shade900,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Draw ground
    final groundPaint = Paint()..color = Colors.brown.shade700;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );

    // Draw grass
    final grassPaint = Paint()..color = Colors.green.shade800;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, 10),
      grassPaint,
    );

    // Calculate object position
    final normalizedHeight = currentHeight / dropHeight;
    final objectY = startY + (1 - normalizedHeight) * fallRange;

    // Draw velocity arrow
    if (velocity > 0) {
      _drawVelocityArrow(canvas, size.width / 2, objectY, velocity);
    }

    // Draw falling object(s)
    final objectX = size.width / 2;
    final objectRadius = 15.0 + (mass / 100) * 10; // Size based on mass (visual only)

    final objectPaint = Paint()..color = Colors.blue.shade400;
    canvas.drawCircle(Offset(objectX, objectY), objectRadius, objectPaint);

    // Draw mass label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${mass.toStringAsFixed(1)} kg',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(objectX - textPainter.width / 2, objectY + objectRadius + 5));

    // Draw comparison object (different mass, same position)
    if (showComparison) {
      final comparisonMass = mass * 10; // 10x heavier
      final comparisonRadius = 15.0 + (comparisonMass / 100) * 10;
      final comparisonX = objectX + 80;

      final comparisonPaint = Paint()..color = Colors.red.shade400;
      canvas.drawCircle(Offset(comparisonX, objectY), math.min(comparisonRadius, 35), comparisonPaint);

      final comparisonText = TextPainter(
        text: TextSpan(
          text: '${comparisonMass.toStringAsFixed(1)} kg',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      comparisonText.layout();
      comparisonText.paint(canvas, Offset(comparisonX - comparisonText.width / 2, objectY + math.min(comparisonRadius, 35) + 5));
    }

    // Draw "VACUUM" label
    final vacuumText = TextPainter(
      text: const TextSpan(
        text: 'VACUUM (No Air Resistance)',
        style: TextStyle(
          color: Colors.white54,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    vacuumText.layout();
    vacuumText.paint(canvas, Offset(size.width / 2 - vacuumText.width / 2, 20));
  }

  void _drawVelocityArrow(Canvas canvas, double x, double y, double velocity) {
    final arrowLength = math.min(velocity * 2, 100.0);
    final arrowPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Arrow shaft
    canvas.drawLine(
      Offset(x + 40, y),
      Offset(x + 40, y + arrowLength),
      arrowPaint,
    );

    // Arrow head
    final headPath = Path()
      ..moveTo(x + 30, y + arrowLength - 10)
      ..lineTo(x + 40, y + arrowLength)
      ..lineTo(x + 50, y + arrowLength - 10);
    canvas.drawPath(headPath, arrowPaint);

    // Velocity label
    final velocityText = TextPainter(
      text: TextSpan(
        text: 'v=${velocity.toStringAsFixed(1)} m/s',
        style: const TextStyle(color: Colors.yellow, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    velocityText.layout();
    velocityText.paint(canvas, Offset(x + 55, y + arrowLength / 2));
  }

  @override
  bool shouldRepaint(covariant _FreeFallPainter oldDelegate) {
    return oldDelegate.currentHeight != currentHeight ||
           oldDelegate.velocity != velocity ||
           oldDelegate.showComparison != showComparison;
  }
}
