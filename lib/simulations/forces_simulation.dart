import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class ForcesSimulation extends StatefulWidget {
  const ForcesSimulation({super.key});

  @override
  State<ForcesSimulation> createState() => _ForcesSimulationState();
}

class _ForcesSimulationState extends State<ForcesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _initialVelocity = 0;
  double _velocity = 0;
  double _position = 50;
  double _time = 0;
  double _acceleration = 2.0;
  bool _isRunning = false;
  bool _hasSpokenIntro = false;

  final List<_DataPoint> _velocityData = [];
  final List<_DataPoint> _positionData = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateSimulation);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Forces and Motion Simulation. This demonstrates Newton\'s equations of motion. '
          'Adjust the acceleration and initial velocity using the sliders, then press Start to see the object move. '
          'Watch the velocity-time graph update in real time. Remember: velocity equals initial velocity plus acceleration times time.',
          force: true,
        );
      }
    });
  }

  void _updateSimulation() {
    if (!_isRunning) return;

    setState(() {
      _time += 0.016;
      _velocity = _initialVelocity + _acceleration * _time;
      _position += _velocity * 0.016 * 50; // Scale for display

      // Collect data points
      if (_velocityData.length < 200) {
        _velocityData.add(_DataPoint(_time, _velocity));
        _positionData.add(_DataPoint(_time, _position - 50));
      }

      // Reset if off screen
      if (_position > 350) {
        _stopSimulation();
      }
    });
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _time = 0;
      _velocity = _initialVelocity;
      _position = 50;
      _velocityData.clear();
      _positionData.clear();
    });
    _controller.repeat();

    final accelDescription = _acceleration > 0
        ? 'positive acceleration, so it will speed up'
        : _acceleration < 0
            ? 'negative acceleration or deceleration, so it will slow down'
            : 'zero acceleration, so it moves at constant velocity';
    speakSimulation(
      'Simulation started! The object has $accelDescription. '
      'Initial velocity is ${_initialVelocity.toStringAsFixed(1)} meters per second. '
      'Watch the velocity increase on the graph as time passes.',
      force: true,
    );
  }

  void _stopSimulation() {
    setState(() {
      _isRunning = false;
    });
    _controller.stop();
    speakSimulation(
      'Simulation stopped. The object traveled ${((_position - 50) / 50).toStringAsFixed(2)} meters '
      'and reached a velocity of ${_velocity.toStringAsFixed(2)} meters per second.',
      force: true,
    );
  }

  void _resetSimulation() {
    _stopSimulation();
    setState(() {
      _time = 0;
      _velocity = _initialVelocity;
      _position = 50;
      _velocityData.clear();
      _positionData.clear();
    });
    speakSimulation('Simulation reset. Adjust the sliders and press Start to begin again.', force: true);
  }

  void _onAccelerationChanged(double value) {
    setState(() => _acceleration = value);
    final description = value > 0
        ? 'positive, the object will speed up'
        : value < 0
            ? 'negative, the object will slow down or decelerate'
            : 'zero, the object will maintain constant velocity';
    speakSimulation(
      'Acceleration set to ${value.toStringAsFixed(1)} meters per second squared. '
      'Since acceleration is $description.',
    );
  }

  void _onInitialVelocityChanged(double value) {
    setState(() => _initialVelocity = value);
    speakSimulation(
      'Initial velocity set to ${value.toStringAsFixed(1)} meters per second. '
      'This is how fast the object starts moving.',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Motion display
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: MotionPainter(
                position: _position,
                velocity: _velocity,
                acceleration: _acceleration,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        // Velocity-Time Graph
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Velocity-Time Graph',
                  style: TextStyle(color: Colors.cyan, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: GraphPainter(
                      dataPoints: _velocityData,
                      color: Colors.cyan,
                      maxY: 15,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Data display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataCard('Time', '${_time.toStringAsFixed(2)} s', Colors.white),
              _buildDataCard('Velocity', '${_velocity.toStringAsFixed(2)} m/s', Colors.cyan),
              _buildDataCard('Distance', '${((_position - 50) / 50).toStringAsFixed(2)} m', Colors.green),
            ],
          ),
        ),
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [buildTTSToggle()],
              ),
              _buildSlider(
                'Acceleration',
                _acceleration,
                -5,
                5,
                '${_acceleration.toStringAsFixed(1)} m/s²',
                _onAccelerationChanged,
                Colors.orange,
              ),
              _buildSlider(
                'Initial Velocity',
                _initialVelocity,
                0,
                10,
                '${_initialVelocity.toStringAsFixed(1)} m/s',
                _onInitialVelocityChanged,
                Colors.cyan,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isRunning ? null : _startSimulation,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isRunning ? _stopSimulation : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _resetSimulation,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Equation: v = u + at    |    s = ut + ½at²',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 13),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.3),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: _isRunning ? null : onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 80,
          child: Text(
            displayValue,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class MotionPainter extends CustomPainter {
  final double position;
  final double velocity;
  final double acceleration;

  MotionPainter({
    required this.position,
    required this.velocity,
    required this.acceleration,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Draw track
    final trackPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(30, centerY),
      Offset(size.width - 30, centerY),
      trackPaint,
    );

    // Draw distance markers
    final markerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    for (int i = 0; i <= 6; i++) {
      final x = 50 + i * 50.0;
      canvas.drawLine(Offset(x, centerY - 10), Offset(x, centerY + 10), markerPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i}m',
          style: const TextStyle(color: Colors.white38, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 8, centerY + 15));
    }

    // Draw car/object
    final carX = position.clamp(50.0, size.width - 50);
    final carPaint = Paint()..color = Colors.cyan;

    // Car body
    final carRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(carX, centerY - 15), width: 40, height: 20),
      const Radius.circular(4),
    );
    canvas.drawRRect(carRect, carPaint);

    // Wheels
    final wheelPaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(carX - 12, centerY - 5), 6, wheelPaint);
    canvas.drawCircle(Offset(carX + 12, centerY - 5), 6, wheelPaint);

    // Draw velocity arrow
    if (velocity.abs() > 0.1) {
      final arrowLength = velocity * 5;
      final arrowPaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 3;

      canvas.drawLine(
        Offset(carX, centerY - 35),
        Offset(carX + arrowLength, centerY - 35),
        arrowPaint,
      );

      // Arrow head
      final direction = arrowLength > 0 ? 1 : -1;
      canvas.drawLine(
        Offset(carX + arrowLength, centerY - 35),
        Offset(carX + arrowLength - direction * 8, centerY - 40),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(carX + arrowLength, centerY - 35),
        Offset(carX + arrowLength - direction * 8, centerY - 30),
        arrowPaint,
      );

      // Label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'v',
          style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(carX + arrowLength / 2 - 4, centerY - 55));
    }

    // Draw acceleration arrow
    if (acceleration.abs() > 0.1) {
      final arrowLength = acceleration * 10;
      final arrowPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 3;

      canvas.drawLine(
        Offset(carX, centerY + 25),
        Offset(carX + arrowLength, centerY + 25),
        arrowPaint,
      );

      // Arrow head
      final direction = arrowLength > 0 ? 1 : -1;
      canvas.drawLine(
        Offset(carX + arrowLength, centerY + 25),
        Offset(carX + arrowLength - direction * 8, centerY + 20),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(carX + arrowLength, centerY + 25),
        Offset(carX + arrowLength - direction * 8, centerY + 30),
        arrowPaint,
      );

      // Label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'a',
          style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(carX + arrowLength / 2 - 4, centerY + 35));
    }
  }

  @override
  bool shouldRepaint(covariant MotionPainter oldDelegate) {
    return oldDelegate.position != position ||
        oldDelegate.velocity != velocity ||
        oldDelegate.acceleration != acceleration;
  }
}

class _DataPoint {
  final double x;
  final double y;
  _DataPoint(this.x, this.y);
}

class GraphPainter extends CustomPainter {
  final List<_DataPoint> dataPoints;
  final Color color;
  final double maxY;

  GraphPainter({
    required this.dataPoints,
    required this.color,
    required this.maxY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    canvas.drawLine(Offset(30, 0), Offset(30, size.height - 20), axisPaint);
    canvas.drawLine(Offset(30, size.height - 20), Offset(size.width, size.height - 20), axisPaint);

    if (dataPoints.isEmpty) return;

    // Draw data
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool first = true;

    for (final point in dataPoints) {
      final x = 30 + (point.x / 5) * (size.width - 40);
      final y = size.height - 20 - (point.y / maxY) * (size.height - 30);

      if (first) {
        path.moveTo(x, y.clamp(0, size.height - 20));
        first = false;
      } else {
        path.lineTo(x, y.clamp(0, size.height - 20));
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant GraphPainter oldDelegate) {
    return oldDelegate.dataPoints.length != dataPoints.length;
  }
}
