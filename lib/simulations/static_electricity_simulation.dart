import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class StaticElectricitySimulation extends StatefulWidget {
  const StaticElectricitySimulation({super.key});

  @override
  State<StaticElectricitySimulation> createState() => _StaticElectricitySimulationState();
}

class _StaticElectricitySimulationState extends State<StaticElectricitySimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  // Object charges
  double _object1Charge = 0; // -1 to 1 (negative to positive)
  double _object2Charge = 0;
  String _material1 = 'rod';
  String _material2 = 'cloth';
  bool _hasSpokenIntro = false;

  // Animation
  Offset _object1Position = const Offset(100, 150);
  Offset _object2Position = const Offset(250, 150);
  final List<ChargeParticle> _particles = [];
  final math.Random _random = math.Random();

  bool _showFieldLines = true;
  bool _isRubbing = false;
  double _rubProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateParticles);
    _controller.repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Static Electricity Simulation. This demonstrates how objects become charged through friction. '
          'Select materials and press Rub Together to transfer electrons between objects. '
          'Like charges repel each other, while opposite charges attract. You can drag objects to move them.',
          force: true,
        );
      }
    });
  }

  void _updateParticles() {
    setState(() {
      // Update particle positions
      for (var particle in _particles) {
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.life -= 0.02;

        // Apply force towards/away from charged objects
        if (_object1Charge != 0) {
          final dx = particle.x - _object1Position.dx;
          final dy = particle.y - _object1Position.dy;
          final dist = math.sqrt(dx * dx + dy * dy);
          if (dist > 10) {
            final force = _object1Charge * particle.charge * 0.5 / (dist * dist) * 1000;
            particle.vx += force * dx / dist;
            particle.vy += force * dy / dist;
          }
        }

        // Damping
        particle.vx *= 0.98;
        particle.vy *= 0.98;
      }

      _particles.removeWhere((p) => p.life <= 0);

      // Add new particles around charged objects
      if (_object1Charge != 0 && _random.nextDouble() < 0.1) {
        _addParticlesAroundObject(_object1Position, _object1Charge);
      }
      if (_object2Charge != 0 && _random.nextDouble() < 0.1) {
        _addParticlesAroundObject(_object2Position, _object2Charge);
      }
    });
  }

  void _addParticlesAroundObject(Offset position, double charge) {
    final angle = _random.nextDouble() * 2 * math.pi;
    final radius = 30 + _random.nextDouble() * 20;
    _particles.add(ChargeParticle(
      x: position.dx + math.cos(angle) * radius,
      y: position.dy + math.sin(angle) * radius,
      vx: 0,
      vy: 0,
      charge: charge > 0 ? 1 : -1,
      life: 1.0,
    ));
  }

  void _rubObjects() async {
    setState(() {
      _isRubbing = true;
      _rubProgress = 0;
    });

    speakSimulation(
      'Rubbing the objects together. Electrons are being transferred by friction.',
      force: true,
    );

    // Animate rubbing
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;
      setState(() {
        _rubProgress = (i + 1) / 20;
      });
    }

    // Transfer charge based on materials
    setState(() {
      _isRubbing = false;
      // Electron transfer simulation
      if (_material1 == 'rod' && _material2 == 'cloth') {
        _object1Charge = -0.8; // Rod gains electrons (becomes negative)
        _object2Charge = 0.8;  // Cloth loses electrons (becomes positive)
      } else if (_material1 == 'balloon' && _material2 == 'hair') {
        _object1Charge = -0.9;
        _object2Charge = 0.9;
      } else if (_material1 == 'glass' && _material2 == 'silk') {
        _object1Charge = 0.7; // Glass loses electrons (becomes positive)
        _object2Charge = -0.7;
      } else {
        _object1Charge = -0.5;
        _object2Charge = 0.5;
      }
    });

    _speakChargeResult();
  }

  void _speakChargeResult() {
    final obj1ChargeType = _object1Charge < 0 ? 'negative' : 'positive';
    final obj2ChargeType = _object2Charge < 0 ? 'negative' : 'positive';
    final mat1Name = _getMaterialName(_material1);
    final mat2Name = _getMaterialName(_material2);

    String explanation;
    if (_object1Charge < 0) {
      explanation = 'The $mat1Name gained electrons and became $obj1ChargeType. '
          'The $mat2Name lost electrons and became $obj2ChargeType.';
    } else {
      explanation = 'The $mat1Name lost electrons and became $obj1ChargeType. '
          'The $mat2Name gained electrons and became $obj2ChargeType.';
    }

    final forceType = _object1Charge * _object2Charge < 0 ? 'attract' : 'repel';
    speakSimulation(
      '$explanation Since one is positive and one is negative, these charges will $forceType each other.',
      force: true,
    );
  }

  void _discharge() {
    setState(() {
      _object1Charge = 0;
      _object2Charge = 0;
      _particles.clear();
    });
    speakSimulation(
      'Both objects have been discharged. They are now electrically neutral with no net charge.',
      force: true,
    );
  }

  void _earthObject(int objectNum) {
    final materialName = objectNum == 1 ? _getMaterialName(_material1) : _getMaterialName(_material2);
    setState(() {
      if (objectNum == 1) {
        _object1Charge = 0;
      } else {
        _object2Charge = 0;
      }
    });
    speakSimulation(
      'Object $objectNum, the $materialName, has been earthed. '
      'Earthing allows excess charge to flow to or from the ground, making the object neutral.',
      force: true,
    );
  }

  void _onMaterial1Changed(String value) {
    setState(() => _material1 = value);
    speakSimulation('Object 1 material changed to ${_getMaterialName(value)}.');
  }

  void _onMaterial2Changed(String value) {
    setState(() => _material2 = value);
    speakSimulation('Object 2 material changed to ${_getMaterialName(value)}.');
  }

  void _onFieldLinesToggled(bool value) {
    setState(() => _showFieldLines = value);
    if (value) {
      speakSimulation(
        'Electric field lines are now visible. These show the direction a positive charge would move in the field.',
        force: true,
      );
    } else {
      speakSimulation('Electric field lines hidden.', force: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Material selectors
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildTTSToggle(),
                _buildMaterialSelector('Object 1', _material1, _onMaterial1Changed),
                _buildMaterialSelector('Object 2', _material2, _onMaterial2Changed),
              ],
            ),
          ),
          // Simulation area
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: GestureDetector(
              onPanUpdate: (details) {
                _handleDrag(details.localPosition);
              },
              child: CustomPaint(
                painter: StaticElectricityPainter(
                  object1Position: _object1Position,
                  object2Position: _object2Position,
                  object1Charge: _object1Charge,
                  object2Charge: _object2Charge,
                  material1: _material1,
                  material2: _material2,
                  particles: _particles,
                  showFieldLines: _showFieldLines,
                  isRubbing: _isRubbing,
                  rubProgress: _rubProgress,
                ),
                size: Size.infinite,
              ),
            ),
          ),
          // Charge indicators
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChargeIndicator('Object 1', _object1Charge, _material1),
                _buildChargeIndicator('Object 2', _object2Charge, _material2),
              ],
            ),
          ),
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRubbing ? null : _rubObjects,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Rub Together'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _discharge,
                      icon: const Icon(Icons.flash_off),
                      label: const Text('Discharge'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: () => _earthObject(1),
                      icon: const Icon(Icons.electric_bolt, size: 16),
                      label: const Text('Earth 1', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton.icon(
                      onPressed: () => _earthObject(2),
                      icon: const Icon(Icons.electric_bolt, size: 16),
                      label: const Text('Earth 2', style: TextStyle(fontSize: 12)),
                    ),
                    Row(
                      children: [
                        const Text('Field Lines', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        Switch(
                          value: _showFieldLines,
                          onChanged: _onFieldLinesToggled,
                          activeColor: Colors.cyan,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Force indicator
          if (_object1Charge != 0 && _object2Charge != 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getForceColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getForceColor()),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _object1Charge * _object2Charge < 0 ? Icons.compress : Icons.expand,
                    color: _getForceColor(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _object1Charge * _object2Charge < 0
                        ? 'ATTRACTION - Opposite charges attract'
                        : 'REPULSION - Like charges repel',
                    style: TextStyle(
                      color: _getForceColor(),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // Info panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Static Electricity',
                  style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  '• Rubbing transfers electrons between materials\n'
                  '• Objects become charged (+ or -)\n'
                  '• Like charges repel, opposite charges attract\n'
                  '• Earthing removes excess charge',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDrag(Offset position) {
    final dist1 = (position - _object1Position).distance;
    final dist2 = (position - _object2Position).distance;

    setState(() {
      if (dist1 < dist2 && dist1 < 50) {
        _object1Position = Offset(
          position.dx.clamp(50, 300),
          position.dy.clamp(50, 250),
        );
      } else if (dist2 < 50) {
        _object2Position = Offset(
          position.dx.clamp(50, 300),
          position.dy.clamp(50, 250),
        );
      }
    });
  }

  Color _getForceColor() {
    return _object1Charge * _object2Charge < 0 ? Colors.green : Colors.red;
  }

  Widget _buildMaterialSelector(String label, String value, ValueChanged<String> onChanged) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white, fontSize: 12),
            underline: const SizedBox(),
            items: const [
              DropdownMenuItem(value: 'rod', child: Text('Polythene Rod')),
              DropdownMenuItem(value: 'cloth', child: Text('Cloth')),
              DropdownMenuItem(value: 'balloon', child: Text('Balloon')),
              DropdownMenuItem(value: 'hair', child: Text('Hair')),
              DropdownMenuItem(value: 'glass', child: Text('Glass Rod')),
              DropdownMenuItem(value: 'silk', child: Text('Silk')),
            ],
            onChanged: (v) => onChanged(v!),
          ),
        ),
      ],
    );
  }

  Widget _buildChargeIndicator(String label, double charge, String material) {
    Color chargeColor;
    String chargeText;
    IconData chargeIcon;

    if (charge < -0.1) {
      chargeColor = Colors.blue;
      chargeText = 'Negative (-)';
      chargeIcon = Icons.remove_circle;
    } else if (charge > 0.1) {
      chargeColor = Colors.red;
      chargeText = 'Positive (+)';
      chargeIcon = Icons.add_circle;
    } else {
      chargeColor = Colors.grey;
      chargeText = 'Neutral';
      chargeIcon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: chargeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chargeColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          Icon(chargeIcon, color: chargeColor, size: 28),
          Text(chargeText, style: TextStyle(color: chargeColor, fontWeight: FontWeight.bold, fontSize: 12)),
          Text(_getMaterialName(material), style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }

  String _getMaterialName(String material) {
    switch (material) {
      case 'rod': return 'Polythene Rod';
      case 'cloth': return 'Cloth';
      case 'balloon': return 'Balloon';
      case 'hair': return 'Hair';
      case 'glass': return 'Glass Rod';
      case 'silk': return 'Silk';
      default: return material;
    }
  }
}

class ChargeParticle {
  double x, y, vx, vy;
  int charge; // -1 or 1
  double life;

  ChargeParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.charge,
    required this.life,
  });
}

class StaticElectricityPainter extends CustomPainter {
  final Offset object1Position;
  final Offset object2Position;
  final double object1Charge;
  final double object2Charge;
  final String material1;
  final String material2;
  final List<ChargeParticle> particles;
  final bool showFieldLines;
  final bool isRubbing;
  final double rubProgress;

  StaticElectricityPainter({
    required this.object1Position,
    required this.object2Position,
    required this.object1Charge,
    required this.object2Charge,
    required this.material1,
    required this.material2,
    required this.particles,
    required this.showFieldLines,
    required this.isRubbing,
    required this.rubProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw field lines if enabled
    if (showFieldLines && (object1Charge != 0 || object2Charge != 0)) {
      _drawFieldLines(canvas, size);
    }

    // Draw objects
    _drawObject(canvas, object1Position, object1Charge, material1, isRubbing ? rubProgress : 0);
    _drawObject(canvas, object2Position, object2Charge, material2, isRubbing ? rubProgress : 0);

    // Draw rubbing animation
    if (isRubbing) {
      _drawRubbingEffect(canvas);
    }

    // Draw particles
    for (var particle in particles) {
      final color = particle.charge > 0 ? Colors.red : Colors.blue;
      final paint = Paint()..color = color.withValues(alpha: particle.life);
      canvas.drawCircle(Offset(particle.x, particle.y), 3, paint);
    }

    // Draw force arrows between charged objects
    if (object1Charge != 0 && object2Charge != 0) {
      _drawForceArrows(canvas);
    }
  }

  void _drawObject(Canvas canvas, Offset position, double charge, String material, double shake) {
    final shakeOffset = isRubbing ? Offset(math.sin(shake * 20) * 5, 0) : Offset.zero;
    final pos = position + shakeOffset;

    Color objectColor;
    if (charge < -0.1) {
      objectColor = Colors.blue;
    } else if (charge > 0.1) {
      objectColor = Colors.red;
    } else {
      objectColor = Colors.grey;
    }

    final paint = Paint()..color = objectColor;

    // Draw based on material type
    if (material == 'rod' || material == 'glass') {
      // Draw rod shape
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: 60, height: 20),
          const Radius.circular(10),
        ),
        paint,
      );
    } else if (material == 'balloon') {
      // Draw balloon shape
      canvas.drawOval(
        Rect.fromCenter(center: pos, width: 50, height: 60),
        paint,
      );
      // String
      canvas.drawLine(
        Offset(pos.dx, pos.dy + 30),
        Offset(pos.dx, pos.dy + 50),
        Paint()..color = Colors.white54..strokeWidth = 1,
      );
    } else if (material == 'hair') {
      // Draw hair strands
      for (int i = -3; i <= 3; i++) {
        final path = Path();
        path.moveTo(pos.dx + i * 8, pos.dy - 20);
        path.quadraticBezierTo(
          pos.dx + i * 8 + (charge * 10),
          pos.dy,
          pos.dx + i * 8 + (charge * 15),
          pos.dy + 20,
        );
        canvas.drawPath(
          path,
          Paint()..color = objectColor..strokeWidth = 2..style = PaintingStyle.stroke,
        );
      }
    } else {
      // Draw cloth/silk as wavy rectangle
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: pos, width: 50, height: 40),
          const Radius.circular(5),
        ),
        paint,
      );
    }

    // Draw charge symbols on object
    if (charge.abs() > 0.1) {
      final symbol = charge > 0 ? '+' : '-';
      final textPainter = TextPainter(
        text: TextSpan(
          text: symbol,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(pos.dx - 5, pos.dy - 8));
    }
  }

  void _drawFieldLines(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw field lines from positive to negative charges
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;

      if (object1Charge.abs() > 0.1) {
        final startRadius = 35.0;
        final start = Offset(
          object1Position.dx + math.cos(angle) * startRadius,
          object1Position.dy + math.sin(angle) * startRadius,
        );

        final path = Path();
        path.moveTo(start.dx, start.dy);

        // Curve outward
        final control = Offset(
          start.dx + math.cos(angle) * 50,
          start.dy + math.sin(angle) * 50,
        );

        Offset end;
        if (object2Charge != 0 && object1Charge * object2Charge < 0) {
          // Attract - lines go to other object
          end = Offset(
            object2Position.dx - math.cos(angle) * 35,
            object2Position.dy - math.sin(angle) * 35,
          );
        } else {
          // Repel or single - lines go outward
          end = Offset(
            start.dx + math.cos(angle) * 80,
            start.dy + math.sin(angle) * 80,
          );
        }

        path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
        canvas.drawPath(path, linePaint);
      }
    }
  }

  void _drawForceArrows(Canvas canvas) {
    final isAttracting = object1Charge * object2Charge < 0;
    final arrowColor = isAttracting ? Colors.green : Colors.red;
    final arrowPaint = Paint()
      ..color = arrowColor
      ..strokeWidth = 2;

    final direction = (object2Position - object1Position);
    final distance = direction.distance;
    final normalized = Offset(direction.dx / distance, direction.dy / distance);

    if (isAttracting) {
      // Arrows pointing towards each other
      _drawArrow(canvas, object1Position + normalized * 40, object1Position + normalized * 70, arrowPaint);
      _drawArrow(canvas, object2Position - normalized * 40, object2Position - normalized * 70, arrowPaint);
    } else {
      // Arrows pointing away
      _drawArrow(canvas, object1Position - normalized * 70, object1Position - normalized * 40, arrowPaint);
      _drawArrow(canvas, object2Position + normalized * 70, object2Position + normalized * 40, arrowPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    canvas.drawLine(from, to, paint);

    final direction = (to - from);
    final angle = math.atan2(direction.dy, direction.dx);

    canvas.drawLine(
      to,
      Offset(to.dx - 8 * math.cos(angle - 0.5), to.dy - 8 * math.sin(angle - 0.5)),
      paint,
    );
    canvas.drawLine(
      to,
      Offset(to.dx - 8 * math.cos(angle + 0.5), to.dy - 8 * math.sin(angle + 0.5)),
      paint,
    );
  }

  void _drawRubbingEffect(Canvas canvas) {
    // Draw sparks/electrons transferring
    final midPoint = Offset(
      (object1Position.dx + object2Position.dx) / 2,
      (object1Position.dy + object2Position.dy) / 2,
    );

    final sparkPaint = Paint()..color = Colors.yellow.withValues(alpha: rubProgress);

    for (int i = 0; i < 5; i++) {
      final offset = Offset(
        math.sin(rubProgress * 10 + i) * 20,
        math.cos(rubProgress * 10 + i) * 10,
      );
      canvas.drawCircle(midPoint + offset, 3, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant StaticElectricityPainter oldDelegate) => true;
}
