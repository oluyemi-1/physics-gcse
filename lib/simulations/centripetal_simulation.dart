import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Centripetal Force Simulation demonstrating circular motion
/// Shows how centripetal force keeps objects moving in a circle
class CentripetalSimulation extends StatefulWidget {
  const CentripetalSimulation({super.key});

  @override
  State<CentripetalSimulation> createState() => _CentripetalSimulationState();
}

class _CentripetalSimulationState extends State<CentripetalSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _radius = 100.0; // meters (scaled)
  double _mass = 2.0; // kg
  double _angularVelocity = 2.0; // rad/s
  double _angle = 0.0;

  bool _showVelocityVector = true;
  bool _showForceVector = true;
  bool _showPath = true;
  bool _isRunning = true;

  String _exampleType = 'Ball on String';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updateRotation);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Centripetal Force Simulation. Watch an object move in a circular path. '
        'The centripetal force always points toward the center, keeping the object in its circular orbit. '
        'The velocity vector is always tangent to the circle. '
        'Adjust the radius, mass, and angular velocity to see how they affect the centripetal force.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateRotation() {
    if (!_isRunning) return;
    setState(() {
      _angle += _angularVelocity / 60; // 60 fps
      if (_angle > 2 * math.pi) {
        _angle -= 2 * math.pi;
      }
    });
  }

  double get _linearVelocity => _angularVelocity * _radius;
  double get _centripetalForce => _mass * _angularVelocity * _angularVelocity * _radius;
  double get _centripetalAcceleration => _angularVelocity * _angularVelocity * _radius;
  double get _period => 2 * math.pi / _angularVelocity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Centripetal Force'),
        backgroundColor: Colors.indigo,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade900, Colors.black],
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
        border: Border.all(color: Colors.indigo.shade300),
      ),
      child: Column(
        children: [
          Text(
            'Example: $_exampleType',
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
              _buildInfoItem('Radius (r)', '${_radius.toStringAsFixed(0)} m'),
              _buildInfoItem('Mass (m)', '${_mass.toStringAsFixed(1)} kg'),
              _buildInfoItem('ω', '${_angularVelocity.toStringAsFixed(1)} rad/s'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Linear v', '${_linearVelocity.toStringAsFixed(1)} m/s'),
              _buildInfoItem('F centripetal', '${_centripetalForce.toStringAsFixed(1)} N'),
              _buildInfoItem('Period', '${_period.toStringAsFixed(2)} s'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'a = v²/r = ω²r = ${_centripetalAcceleration.toStringAsFixed(1)} m/s²',
              style: const TextStyle(color: Colors.amber, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            setState(() => _isRunning = !_isRunning);
          },
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _CentripetalPainter(
              radius: _radius,
              angle: _angle,
              showVelocity: _showVelocityVector,
              showForce: _showForceVector,
              showPath: _showPath,
              mass: _mass,
              linearVelocity: _linearVelocity,
              centripetalForce: _centripetalForce,
              exampleType: _exampleType,
            ),
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
          // Example type selector
          Wrap(
            spacing: 8,
            children: ['Ball on String', 'Car on Track', 'Satellite'].map((type) {
              return ChoiceChip(
                label: Text(type, style: const TextStyle(fontSize: 11)),
                selected: _exampleType == type,
                selectedColor: Colors.indigo.shade400,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _exampleType = type;
                      // Set realistic values for each example
                      if (type == 'Ball on String') {
                        _radius = 100;
                        _mass = 2;
                        _angularVelocity = 2;
                      } else if (type == 'Car on Track') {
                        _radius = 150;
                        _mass = 10;
                        _angularVelocity = 1;
                      } else {
                        _radius = 180;
                        _mass = 5;
                        _angularVelocity = 0.5;
                      }
                    });
                    speakSimulation(
                      '$type example selected. The centripetal force in this case '
                      '${type == "Ball on String" ? "is provided by the tension in the string" : type == "Car on Track" ? "is provided by friction between the tires and road" : "is provided by gravitational attraction"}.',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Radius slider
          Row(
            children: [
              const Icon(Icons.radio_button_unchecked, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Radius:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _radius,
                  min: 50,
                  max: 200,
                  activeColor: Colors.indigo,
                  onChanged: (value) => setState(() => _radius = value),
                ),
              ),
              Text('${_radius.toStringAsFixed(0)} m', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Angular velocity slider
          Row(
            children: [
              const Icon(Icons.speed, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('ω:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _angularVelocity,
                  min: 0.5,
                  max: 5,
                  activeColor: Colors.green,
                  onChanged: (value) => setState(() => _angularVelocity = value),
                ),
              ),
              Text('${_angularVelocity.toStringAsFixed(1)} rad/s', style: const TextStyle(color: Colors.white, fontSize: 12)),
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
                  min: 0.5,
                  max: 20,
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => _mass = value),
                ),
              ),
              Text('${_mass.toStringAsFixed(1)} kg', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Vector toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildToggle('Path', _showPath, (v) => setState(() => _showPath = v)),
              _buildToggle('Velocity', _showVelocityVector, (v) => setState(() => _showVelocityVector = v)),
              _buildToggle('Force', _showForceVector, (v) => setState(() => _showForceVector = v)),
              IconButton(
                onPressed: () => setState(() => _isRunning = !_isRunning),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
              ),
            ],
          ),

          // Key equation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'F = mv²/r = mω²r  |  a = v²/r = ω²r  |  v = ωr',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, Function(bool) onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: Colors.indigo,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _CentripetalPainter extends CustomPainter {
  final double radius;
  final double angle;
  final bool showVelocity;
  final bool showForce;
  final bool showPath;
  final double mass;
  final double linearVelocity;
  final double centripetalForce;
  final String exampleType;

  _CentripetalPainter({
    required this.radius,
    required this.angle,
    required this.showVelocity,
    required this.showForce,
    required this.showPath,
    required this.mass,
    required this.linearVelocity,
    required this.centripetalForce,
    required this.exampleType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scaledRadius = radius * 0.8;

    // Calculate object position
    final objectX = center.dx + scaledRadius * math.cos(angle);
    final objectY = center.dy + scaledRadius * math.sin(angle);
    final objectPos = Offset(objectX, objectY);

    // Draw path
    if (showPath) {
      final pathPaint = Paint()
        ..color = Colors.white24
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(center, scaledRadius, pathPaint);

      // Draw dashed radius line
      _drawDashedLine(canvas, center, objectPos, Colors.white30);
    }

    // Draw center point
    final centerPaint = Paint()..color = Colors.white54;
    canvas.drawCircle(center, 5, centerPaint);

    // Draw string/connection for ball on string
    if (exampleType == 'Ball on String') {
      final stringPaint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 2;
      canvas.drawLine(center, objectPos, stringPaint);
    }

    // Draw the object
    _drawObject(canvas, objectPos);

    // Draw velocity vector (tangent to circle)
    if (showVelocity) {
      final velocityAngle = angle + math.pi / 2;
      final velocityScale = linearVelocity * 0.3;
      final velocityEnd = Offset(
        objectX + velocityScale * math.cos(velocityAngle),
        objectY + velocityScale * math.sin(velocityAngle),
      );
      _drawArrow(canvas, objectPos, velocityEnd, Colors.green, 'v');
    }

    // Draw centripetal force vector (toward center)
    if (showForce) {
      final forceAngle = angle + math.pi; // Points toward center
      final forceScale = centripetalForce * 0.3;
      final forceEnd = Offset(
        objectX + forceScale * math.cos(forceAngle),
        objectY + forceScale * math.sin(forceAngle),
      );
      _drawArrow(canvas, objectPos, forceEnd, Colors.red, 'F');
    }

    // Draw labels
    _drawLabels(canvas, size, center, scaledRadius);
  }

  void _drawObject(Canvas canvas, Offset position) {
    final objectSize = 12.0 + mass * 1.5;

    Color objectColor;

    switch (exampleType) {
      case 'Ball on String':
        objectColor = Colors.blue;
        break;
      case 'Car on Track':
        objectColor = Colors.red;
        break;
      case 'Satellite':
        objectColor = Colors.grey;
        break;
      default:
        objectColor = Colors.blue;
    }

    final objectPaint = Paint()..color = objectColor;
    canvas.drawCircle(position, objectSize, objectPaint);

    // Add highlight
    final highlightPaint = Paint()
      ..color = Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, objectSize, highlightPaint);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Color color, String label) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, end, arrowPaint);

    // Arrow head
    final direction = (end - start);
    final length = direction.distance;
    if (length > 0) {
      final unitDir = direction / length;
      final perpDir = Offset(-unitDir.dy, unitDir.dx);

      final headSize = 10.0;
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
          style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(end.dx + 5, end.dy - 10));
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final direction = end - start;
    final length = direction.distance;
    final unitDir = direction / length;

    const dashLength = 5.0;
    const gapLength = 5.0;
    var currentLength = 0.0;

    while (currentLength < length) {
      final dashStart = start + unitDir * currentLength;
      final dashEnd = start + unitDir * math.min(currentLength + dashLength, length);
      canvas.drawLine(dashStart, dashEnd, paint);
      currentLength += dashLength + gapLength;
    }
  }

  void _drawLabels(Canvas canvas, Size size, Offset center, double scaledRadius) {
    // Draw 'r' label on radius
    final rLabelPos = Offset(
      center.dx + scaledRadius / 2 * math.cos(angle) - 15,
      center.dy + scaledRadius / 2 * math.sin(angle) - 15,
    );
    final rText = TextPainter(
      text: const TextSpan(
        text: 'r',
        style: TextStyle(color: Colors.white54, fontSize: 14, fontStyle: FontStyle.italic),
      ),
      textDirection: TextDirection.ltr,
    );
    rText.layout();
    rText.paint(canvas, rLabelPos);

    // Legend
    final legendY = size.height - 30;

    if (showVelocity) {
      final vLegend = TextPainter(
        text: const TextSpan(
          text: '→ v (velocity, tangent)',
          style: TextStyle(color: Colors.green, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      vLegend.layout();
      vLegend.paint(canvas, Offset(10, legendY));
    }

    if (showForce) {
      final fLegend = TextPainter(
        text: const TextSpan(
          text: '→ F (centripetal, toward center)',
          style: TextStyle(color: Colors.red, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      fLegend.layout();
      fLegend.paint(canvas, Offset(size.width / 2, legendY));
    }
  }

  @override
  bool shouldRepaint(covariant _CentripetalPainter oldDelegate) {
    return oldDelegate.angle != angle ||
           oldDelegate.radius != radius ||
           oldDelegate.showVelocity != showVelocity ||
           oldDelegate.showForce != showForce;
  }
}
