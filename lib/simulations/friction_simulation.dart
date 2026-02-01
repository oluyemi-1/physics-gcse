import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Friction Simulation demonstrating static and kinetic friction
/// Shows how friction opposes motion and depends on surface properties
class FrictionSimulation extends StatefulWidget {
  const FrictionSimulation({super.key});

  @override
  State<FrictionSimulation> createState() => _FrictionSimulationState();
}

class _FrictionSimulationState extends State<FrictionSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _appliedForce = 0.0; // N
  double _objectMass = 10.0; // kg
  double _staticCoefficient = 0.5;
  double _kineticCoefficient = 0.3;
  final double _gravity = 9.81;

  double _position = 0.0;
  double _velocity = 0.0;
  bool _isMoving = false;

  String _surfaceType = 'Wood on Wood';

  final Map<String, List<double>> _surfaceCoefficients = {
    'Wood on Wood': [0.5, 0.3],
    'Rubber on Concrete': [0.8, 0.6],
    'Steel on Steel': [0.7, 0.5],
    'Ice on Ice': [0.1, 0.03],
    'Teflon on Teflon': [0.04, 0.04],
  };

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
        'Friction Simulation. Explore how friction opposes motion between surfaces. '
        'Static friction keeps objects stationary until overcome by enough force. '
        'Kinetic friction acts on moving objects and is usually less than static friction. '
        'Apply force using the slider and observe when the object starts moving.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    setState(() {
      const dt = 1 / 60;

      final normalForce = _objectMass * _gravity;
      final maxStaticFriction = _staticCoefficient * normalForce;
      final kineticFriction = _kineticCoefficient * normalForce;

      if (!_isMoving) {
        // Check if applied force overcomes static friction
        if (_appliedForce.abs() > maxStaticFriction) {
          _isMoving = true;
          speakSimulation('Object started moving! Applied force overcame static friction.');
        }
      }

      if (_isMoving) {
        // Calculate net force (applied - kinetic friction)
        final frictionDirection = _velocity >= 0 ? -1.0 : 1.0;
        final netForce = _appliedForce + (frictionDirection * kineticFriction);

        // F = ma, so a = F/m
        final acceleration = netForce / _objectMass;

        // Update velocity and position
        _velocity += acceleration * dt;
        _position += _velocity * dt;

        // Stop if velocity becomes zero or changes direction with no applied force
        if (_appliedForce == 0 && _velocity.abs() < 0.1) {
          _velocity = 0;
          _isMoving = false;
        }

        // Boundary check
        if (_position > 300) {
          _position = 300;
          _velocity = 0;
        } else if (_position < -300) {
          _position = -300;
          _velocity = 0;
        }
      }
    });
  }

  void _setSurface(String surface) {
    final coefficients = _surfaceCoefficients[surface]!;
    setState(() {
      _surfaceType = surface;
      _staticCoefficient = coefficients[0];
      _kineticCoefficient = coefficients[1];
      _resetSimulation();
    });

    speakSimulation(
      '$surface selected. Static friction coefficient: ${_staticCoefficient.toStringAsFixed(2)}, '
      'Kinetic friction coefficient: ${_kineticCoefficient.toStringAsFixed(2)}.',
    );
  }

  void _resetSimulation() {
    setState(() {
      _position = 0;
      _velocity = 0;
      _isMoving = false;
      _appliedForce = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friction'),
        backgroundColor: Colors.brown,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.brown.shade800, Colors.brown.shade900],
          ),
        ),
        child: Column(
          children: [
            _buildInfoPanel(),
            Expanded(child: _buildSimulationArea()),
            _buildForceDisplay(),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    final normalForce = _objectMass * _gravity;
    final maxStaticFriction = _staticCoefficient * normalForce;
    final kineticFriction = _kineticCoefficient * normalForce;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade300),
      ),
      child: Column(
        children: [
          Text(
            'Surface: $_surfaceType',
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
              _buildInfoItem('μₛ (static)', _staticCoefficient.toStringAsFixed(2)),
              _buildInfoItem('μₖ (kinetic)', _kineticCoefficient.toStringAsFixed(2)),
              _buildInfoItem('Normal (N)', normalForce.toStringAsFixed(1)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Max Static (N)', maxStaticFriction.toStringAsFixed(1)),
              _buildInfoItem('Kinetic (N)', kineticFriction.toStringAsFixed(1)),
              _buildInfoItem('Velocity', '${_velocity.toStringAsFixed(2)} m/s'),
            ],
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
        final normalForce = _objectMass * _gravity;
        final maxStaticFriction = _staticCoefficient * normalForce;
        final kineticFriction = _kineticCoefficient * normalForce;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _FrictionPainter(
            position: _position,
            appliedForce: _appliedForce,
            frictionForce: _isMoving ? kineticFriction : math.min(_appliedForce.abs(), maxStaticFriction),
            normalForce: normalForce,
            weight: normalForce,
            isMoving: _isMoving,
            mass: _objectMass,
            surfaceType: _surfaceType,
          ),
        );
      },
    );
  }

  Widget _buildForceDisplay() {
    final normalForce = _objectMass * _gravity;
    final maxStaticFriction = _staticCoefficient * normalForce;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Force comparison bar
          Row(
            children: [
              const Text('Applied vs Max Static:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade800,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: math.min(_appliedForce.abs() / (maxStaticFriction * 1.5), 1.0),
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: _appliedForce.abs() > maxStaticFriction ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (maxStaticFriction / (maxStaticFriction * 1.5)) * 200,
                      child: Container(
                        width: 2,
                        height: 20,
                        color: Colors.yellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isMoving ? 'MOVING - Kinetic friction active' : 'STATIONARY - Static friction active',
            style: TextStyle(
              color: _isMoving ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black45,
      child: Column(
        children: [
          // Surface type selector
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _surfaceCoefficients.keys.map((surface) {
              return ChoiceChip(
                label: Text(surface, style: const TextStyle(fontSize: 11)),
                selected: _surfaceType == surface,
                selectedColor: Colors.brown.shade400,
                onSelected: (selected) {
                  if (selected) _setSurface(surface);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Applied Force Slider
          Row(
            children: [
              const Icon(Icons.arrow_forward, color: Colors.white70),
              const SizedBox(width: 8),
              const Text('Applied Force:', style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: _appliedForce,
                  min: -200,
                  max: 200,
                  activeColor: Colors.blue,
                  onChanged: (value) {
                    setState(() => _appliedForce = value);
                  },
                ),
              ),
              Text(
                '${_appliedForce.toStringAsFixed(0)} N',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          // Mass Slider
          Row(
            children: [
              const Icon(Icons.fitness_center, color: Colors.white70),
              const SizedBox(width: 8),
              const Text('Mass:', style: TextStyle(color: Colors.white)),
              Expanded(
                child: Slider(
                  value: _objectMass,
                  min: 1,
                  max: 50,
                  activeColor: Colors.orange,
                  onChanged: (value) {
                    setState(() {
                      _objectMass = value;
                      _resetSimulation();
                    });
                  },
                ),
              ),
              Text(
                '${_objectMass.toStringAsFixed(1)} kg',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: _resetSimulation,
            icon: const Icon(Icons.refresh),
            label: const Text('Reset'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
          ),

          const SizedBox(height: 8),

          // Key equations
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.brown.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Friction = μ × Normal Force  |  fₛ = μₛN (static)  |  fₖ = μₖN (kinetic)',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _FrictionPainter extends CustomPainter {
  final double position;
  final double appliedForce;
  final double frictionForce;
  final double normalForce;
  final double weight;
  final bool isMoving;
  final double mass;
  final String surfaceType;

  _FrictionPainter({
    required this.position,
    required this.appliedForce,
    required this.frictionForce,
    required this.normalForce,
    required this.weight,
    required this.isMoving,
    required this.mass,
    required this.surfaceType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2 + position;
    final groundY = size.height * 0.7;
    final boxSize = 50.0 + mass;

    // Draw surface
    _drawSurface(canvas, size, groundY);

    // Draw box
    final boxRect = Rect.fromCenter(
      center: Offset(centerX, groundY - boxSize / 2),
      width: boxSize,
      height: boxSize,
    );

    final boxPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.fill;
    canvas.drawRect(boxRect, boxPaint);

    final boxBorder = Paint()
      ..color = Colors.blue.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(boxRect, boxBorder);

    // Draw mass label on box
    final massText = TextPainter(
      text: TextSpan(
        text: '${mass.toStringAsFixed(0)} kg',
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    massText.layout();
    massText.paint(canvas, Offset(centerX - massText.width / 2, groundY - boxSize / 2 - 8));

    // Draw force arrows
    final forceScale = 0.5;
    final arrowY = groundY - boxSize / 2;

    // Applied force (blue, pointing right if positive)
    if (appliedForce.abs() > 0) {
      _drawForceArrow(
        canvas,
        appliedForce > 0 ? boxRect.right : boxRect.left,
        arrowY,
        appliedForce * forceScale,
        Colors.blue,
        'F = ${appliedForce.abs().toStringAsFixed(0)} N',
        appliedForce > 0,
      );
    }

    // Friction force (red, opposing motion/applied force)
    if (frictionForce > 0) {
      final frictionDirection = appliedForce >= 0 ? -1 : 1;
      _drawForceArrow(
        canvas,
        frictionDirection > 0 ? boxRect.right : boxRect.left,
        arrowY + 20,
        frictionForce * forceScale * frictionDirection,
        Colors.red,
        'f = ${frictionForce.toStringAsFixed(0)} N',
        frictionDirection > 0,
      );
    }

    // Weight (green, pointing down)
    _drawVerticalArrow(
      canvas,
      centerX,
      groundY,
      weight * forceScale * 0.5,
      Colors.green,
      'W = ${weight.toStringAsFixed(0)} N',
      true,
    );

    // Normal force (orange, pointing up)
    _drawVerticalArrow(
      canvas,
      centerX + 30,
      groundY - boxSize,
      normalForce * forceScale * 0.5,
      Colors.orange,
      'N = ${normalForce.toStringAsFixed(0)} N',
      false,
    );

    // Draw motion indicators
    if (isMoving) {
      _drawMotionLines(canvas, centerX, groundY - boxSize / 2, boxSize);
    }
  }

  void _drawSurface(Canvas canvas, Size size, double groundY) {
    // Surface color based on type
    Color surfaceColor;
    switch (surfaceType) {
      case 'Ice on Ice':
        surfaceColor = Colors.lightBlue.shade200;
        break;
      case 'Rubber on Concrete':
        surfaceColor = Colors.grey.shade600;
        break;
      case 'Steel on Steel':
        surfaceColor = Colors.blueGrey.shade400;
        break;
      case 'Teflon on Teflon':
        surfaceColor = Colors.white70;
        break;
      default:
        surfaceColor = Colors.brown.shade600;
    }

    final surfacePaint = Paint()..color = surfaceColor;
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      surfacePaint,
    );

    // Draw texture lines
    final texturePaint = Paint()
      ..color = surfaceColor.withOpacity(0.5)
      ..strokeWidth = 1;
    for (var i = 0; i < size.width; i += 20) {
      canvas.drawLine(
        Offset(i.toDouble(), groundY),
        Offset(i.toDouble() + 10, groundY + 5),
        texturePaint,
      );
    }
  }

  void _drawForceArrow(Canvas canvas, double x, double y, double force, Color color, String label, bool pointRight) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final endX = x + force;
    canvas.drawLine(Offset(x, y), Offset(endX, y), arrowPaint);

    // Arrow head
    final headSize = 10.0;
    final headDirection = force > 0 ? 1.0 : -1.0;
    final headPath = Path()
      ..moveTo(endX, y)
      ..lineTo(endX - headDirection * headSize, y - headSize / 2)
      ..lineTo(endX - headDirection * headSize, y + headSize / 2)
      ..close();
    canvas.drawPath(headPath, Paint()..color = color);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((x + endX) / 2 - textPainter.width / 2, y - 20));
  }

  void _drawVerticalArrow(Canvas canvas, double x, double y, double force, Color color, String label, bool pointDown) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final direction = pointDown ? 1.0 : -1.0;
    final endY = y + force * direction;
    canvas.drawLine(Offset(x, y), Offset(x, endY), arrowPaint);

    // Arrow head
    final headSize = 8.0;
    final headPath = Path()
      ..moveTo(x, endY)
      ..lineTo(x - headSize / 2, endY - direction * headSize)
      ..lineTo(x + headSize / 2, endY - direction * headSize)
      ..close();
    canvas.drawPath(headPath, Paint()..color = color);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(text: label, style: TextStyle(color: color, fontSize: 10)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 5, (y + endY) / 2 - 5));
  }

  void _drawMotionLines(Canvas canvas, double x, double y, double size) {
    final linePaint = Paint()
      ..color = Colors.white30
      ..strokeWidth = 2;

    for (var i = 0; i < 3; i++) {
      final offset = (i + 1) * 15.0;
      canvas.drawLine(
        Offset(x - size / 2 - offset - 10, y - 10),
        Offset(x - size / 2 - offset, y),
        linePaint,
      );
      canvas.drawLine(
        Offset(x - size / 2 - offset - 10, y + 10),
        Offset(x - size / 2 - offset, y),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FrictionPainter oldDelegate) {
    return oldDelegate.position != position ||
           oldDelegate.appliedForce != appliedForce ||
           oldDelegate.isMoving != isMoving;
  }
}
