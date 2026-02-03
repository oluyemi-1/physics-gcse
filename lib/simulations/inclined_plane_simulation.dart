import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

/// Inclined Plane Simulation demonstrating forces on a slope
/// Shows how weight is resolved into components parallel and perpendicular to the plane
class InclinedPlaneSimulation extends StatefulWidget {
  const InclinedPlaneSimulation({super.key});

  @override
  State<InclinedPlaneSimulation> createState() => _InclinedPlaneSimulationState();
}

class _InclinedPlaneSimulationState extends State<InclinedPlaneSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _angle = 30.0; // degrees
  double _mass = 5.0; // kg
  double _frictionCoefficient = 0.3;
  final double _gravity = 9.81;

  double _position = 0.0;
  double _velocity = 0.0;
  bool _isReleased = false;
  bool _showForceComponents = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updatePhysics);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Inclined Plane Simulation. Explore how forces act on an object on a slope. '
        'The weight is resolved into two components: one parallel to the slope causing motion, '
        'and one perpendicular providing the normal force. '
        'Adjust the angle and friction to see when the object slides.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    if (!_isReleased) return;

    setState(() {
      const dt = 1 / 60;

      final angleRad = _angle * math.pi / 180;
      final weight = _mass * _gravity;

      // Force components
      final parallelForce = weight * math.sin(angleRad);
      final normalForce = weight * math.cos(angleRad);
      final frictionForce = _frictionCoefficient * normalForce;

      // Net force (parallel component minus friction)
      final netForce = parallelForce - frictionForce;

      if (netForce > 0) {
        // Object accelerates down the slope
        final acceleration = netForce / _mass;
        _velocity += acceleration * dt;
        _position += _velocity * dt;
      }

      // Check if reached bottom
      if (_position > 250) {
        _position = 250;
        _velocity = 0;
        _isReleased = false;
        context.read<SoundProvider>().playCollision();
      }
    });
  }

  void _release() {
    context.read<SoundProvider>().playWhoosh();

    setState(() {
      _isReleased = true;
      _position = 0;
      _velocity = 0;
    });

    final angleRad = _angle * math.pi / 180;
    final weight = _mass * _gravity;
    final parallelForce = weight * math.sin(angleRad);
    final normalForce = weight * math.cos(angleRad);
    final frictionForce = _frictionCoefficient * normalForce;

    if (parallelForce > frictionForce) {
      speakSimulation(
        'Object released! The parallel component of ${parallelForce.toStringAsFixed(1)} newtons '
        'exceeds friction of ${frictionForce.toStringAsFixed(1)} newtons, so it slides down.',
      );
    } else {
      speakSimulation(
        'Object released but friction is too strong. It stays in place.',
      );
    }
  }

  void _reset() {
    setState(() {
      _isReleased = false;
      _position = 0;
      _velocity = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inclined Plane'),
        backgroundColor: Colors.teal,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade800, Colors.teal.shade900],
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
    final angleRad = _angle * math.pi / 180;
    final weight = _mass * _gravity;
    final parallelForce = weight * math.sin(angleRad);
    final normalForce = weight * math.cos(angleRad);
    final frictionForce = _frictionCoefficient * normalForce;
    final netForce = parallelForce - frictionForce;
    final willSlide = parallelForce > frictionForce;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade300),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Angle', '${_angle.toStringAsFixed(0)}°'),
              _buildInfoItem('Mass', '${_mass.toStringAsFixed(1)} kg'),
              _buildInfoItem('Weight', '${weight.toStringAsFixed(1)} N'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('W∥ (parallel)', '${parallelForce.toStringAsFixed(1)} N', Colors.red),
              _buildInfoItem('N (normal)', '${normalForce.toStringAsFixed(1)} N', Colors.orange),
              _buildInfoItem('f (friction)', '${frictionForce.toStringAsFixed(1)} N', Colors.yellow),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: willSlide ? Colors.green.shade800 : Colors.red.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              willSlide
                  ? 'Net Force: ${netForce.toStringAsFixed(1)} N → Will Slide!'
                  : 'Net Force: ${netForce.toStringAsFixed(1)} N → Stays Put (friction wins)',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color ?? Colors.white70, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final angleRad = _angle * math.pi / 180;
        final weight = _mass * _gravity;
        final parallelForce = weight * math.sin(angleRad);
        final normalForce = weight * math.cos(angleRad);
        final frictionForce = _frictionCoefficient * normalForce;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _InclinedPlanePainter(
            angle: _angle,
            position: _position,
            mass: _mass,
            weight: weight,
            parallelForce: parallelForce,
            normalForce: normalForce,
            frictionForce: frictionForce,
            showComponents: _showForceComponents,
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
          // Angle slider
          Row(
            children: [
              const Icon(Icons.rotate_right, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Angle:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _angle,
                  min: 5,
                  max: 85,
                  activeColor: Colors.teal,
                  onChanged: _isReleased ? null : (value) {
                    setState(() => _angle = value);
                  },
                ),
              ),
              Text('${_angle.toStringAsFixed(0)}°', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Mass slider
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Mass:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _mass,
                  min: 1,
                  max: 20,
                  activeColor: Colors.orange,
                  onChanged: _isReleased ? null : (value) {
                    setState(() => _mass = value);
                  },
                ),
              ),
              Text('${_mass.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Friction slider
          Row(
            children: [
              const Icon(Icons.texture, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('μ:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _frictionCoefficient,
                  min: 0,
                  max: 1,
                  activeColor: Colors.yellow,
                  onChanged: _isReleased ? null : (value) {
                    setState(() => _frictionCoefficient = value);
                  },
                ),
              ),
              Text(_frictionCoefficient.toStringAsFixed(2), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _showForceComponents,
                    onChanged: (v) => setState(() => _showForceComponents = v ?? true),
                    activeColor: Colors.teal,
                  ),
                  const Text('Show Forces', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _isReleased ? null : _release,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Release'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Key equations
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'W∥ = mg sin θ  |  N = mg cos θ  |  f = μN  |  Slides if W∥ > f',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _InclinedPlanePainter extends CustomPainter {
  final double angle;
  final double position;
  final double mass;
  final double weight;
  final double parallelForce;
  final double normalForce;
  final double frictionForce;
  final bool showComponents;

  _InclinedPlanePainter({
    required this.angle,
    required this.position,
    required this.mass,
    required this.weight,
    required this.parallelForce,
    required this.normalForce,
    required this.frictionForce,
    required this.showComponents,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final angleRad = angle * math.pi / 180;
    final planeLength = size.width * 0.7;
    final planeHeight = planeLength * math.sin(angleRad);

    // Calculate plane position
    final bottomLeft = Offset(size.width * 0.1, size.height * 0.8);
    final bottomRight = Offset(bottomLeft.dx + planeLength * math.cos(angleRad), bottomLeft.dy);
    final topLeft = Offset(bottomLeft.dx, bottomLeft.dy - planeHeight);

    // Draw the inclined plane
    final planePath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(topLeft.dx, topLeft.dy)
      ..close();

    final planePaint = Paint()
      ..color = Colors.brown.shade600
      ..style = PaintingStyle.fill;
    canvas.drawPath(planePath, planePaint);

    // Draw plane surface
    final surfacePaint = Paint()
      ..color = Colors.brown.shade400
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(topLeft, bottomRight, surfacePaint);

    // Draw angle arc
    _drawAngleArc(canvas, bottomRight, angleRad);

    // Calculate object position on plane
    final distanceAlongPlane = position;
    final objectX = topLeft.dx + distanceAlongPlane * math.cos(angleRad);
    final objectY = topLeft.dy + distanceAlongPlane * math.sin(angleRad);
    final objectPos = Offset(objectX, objectY);

    // Draw object (box)
    final boxSize = 30.0 + mass;
    _drawBox(canvas, objectPos, boxSize, angleRad);

    // Draw force vectors
    if (showComponents) {
      final forceScale = 1.5;

      // Weight (straight down)
      _drawArrow(canvas, objectPos, Offset(objectPos.dx, objectPos.dy + weight * forceScale),
          Colors.green, 'W');

      // Parallel component (along slope)
      final parallelEnd = Offset(
        objectPos.dx + parallelForce * forceScale * math.cos(angleRad),
        objectPos.dy + parallelForce * forceScale * math.sin(angleRad),
      );
      _drawArrow(canvas, objectPos, parallelEnd, Colors.red, 'W∥');

      // Normal force (perpendicular to slope, away from surface)
      final normalEnd = Offset(
        objectPos.dx - normalForce * forceScale * math.sin(angleRad),
        objectPos.dy + normalForce * forceScale * math.cos(angleRad) * -1,
      );
      _drawArrow(canvas, objectPos, normalEnd, Colors.orange, 'N');

      // Friction (opposing motion, up the slope)
      final frictionEnd = Offset(
        objectPos.dx - frictionForce * forceScale * math.cos(angleRad),
        objectPos.dy - frictionForce * forceScale * math.sin(angleRad),
      );
      _drawArrow(canvas, objectPos, frictionEnd, Colors.yellow, 'f');
    }

    // Draw legend
    _drawLegend(canvas, size);
  }

  void _drawAngleArc(Canvas canvas, Offset vertex, double angleRad) {
    final arcRadius = 40.0;
    final arcPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final arcRect = Rect.fromCircle(center: vertex, radius: arcRadius);
    canvas.drawArc(arcRect, math.pi, -angleRad, false, arcPaint);

    // Angle label
    final labelX = vertex.dx - arcRadius * 0.7 * math.cos(angleRad / 2);
    final labelY = vertex.dy - arcRadius * 0.7 * math.sin(angleRad / 2);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${angle.toStringAsFixed(0)}°',
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(labelX - 15, labelY - 10));
  }

  void _drawBox(Canvas canvas, Offset center, double size, double angleRad) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleRad);

    final boxRect = Rect.fromCenter(center: Offset.zero, width: size, height: size);
    final boxPaint = Paint()..color = Colors.blue.shade600;
    canvas.drawRect(boxRect, boxPaint);

    final borderPaint = Paint()
      ..color = Colors.blue.shade300
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawRect(boxRect, borderPaint);

    // Mass label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${mass.toStringAsFixed(0)}kg',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));

    canvas.restore();
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color, String label) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, arrowPaint);

    // Arrow head
    final direction = end - start;
    final length = direction.distance;
    if (length > 10) {
      final unitDir = direction / length;
      final perpDir = Offset(-unitDir.dy, unitDir.dx);
      final headSize = 8.0;

      final headPath = Path()
        ..moveTo(end.dx, end.dy)
        ..lineTo(end.dx - unitDir.dx * headSize + perpDir.dx * headSize / 2,
                 end.dy - unitDir.dy * headSize + perpDir.dy * headSize / 2)
        ..lineTo(end.dx - unitDir.dx * headSize - perpDir.dx * headSize / 2,
                 end.dy - unitDir.dy * headSize - perpDir.dy * headSize / 2)
        ..close();
      canvas.drawPath(headPath, Paint()..color = color);

      // Label
      final textPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(end.dx + 5, end.dy - 5));
    }
  }

  void _drawLegend(Canvas canvas, Size size) {
    final legends = [
      ('W', 'Weight', Colors.green),
      ('W∥', 'Parallel', Colors.red),
      ('N', 'Normal', Colors.orange),
      ('f', 'Friction', Colors.yellow),
    ];

    var y = 20.0;
    for (final legend in legends) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${legend.$1}: ${legend.$2}',
          style: TextStyle(color: legend.$3, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width - 100, y));
      y += 18;
    }
  }

  @override
  bool shouldRepaint(covariant _InclinedPlanePainter oldDelegate) {
    return oldDelegate.angle != angle ||
           oldDelegate.position != position ||
           oldDelegate.showComponents != showComponents;
  }
}
