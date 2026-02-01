import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class SpringSimulation extends StatefulWidget {
  const SpringSimulation({super.key});

  @override
  State<SpringSimulation> createState() => _SpringSimulationState();
}

class _SpringSimulationState extends State<SpringSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _springConstant = 50.0; // N/m
  double _mass = 1.0; // kg
  double _appliedForce = 0.0; // N
  double _extension = 0.0; // m
  final double _originalLength = 100.0; // pixels (visual)
  bool _showElasticLimit = false;
  final double _elasticLimit = 150.0; // N
  bool _hasSpokenIntro = false;
  bool _hasSpokenElasticWarning = false;

  // For oscillation mode
  bool _isOscillating = false;
  double _displacement = 0.0;
  double _velocity = 0.0;
  double _time = 0.0;
  final List<DataPoint> _forceExtensionData = [];
  double _previousDisplacement = 0.0; // For sound trigger

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
          'Welcome to the Spring Simulation demonstrating Hooke\'s Law. '
          'This law states that force equals spring constant times extension: F equals k times e. '
          'Use the sliders to apply force to the spring and observe how it extends. '
          'You can also start oscillation mode to see simple harmonic motion.',
          force: true,
        );
      }
    });
  }

  void _updateSimulation() {
    if (!_isOscillating) return;

    setState(() {
      _time += 0.016;

      // Store previous displacement for sound
      final oldDisplacement = _displacement;

      // Simple harmonic motion: a = -k/m * x
      final acceleration = -(_springConstant / _mass) * _displacement;

      _velocity += acceleration * 0.016;
      _displacement += _velocity * 0.016;

      // Damping
      _velocity *= 0.995;

      // Update extension for display
      _extension = _displacement.abs() * 100; // Scale for display

      _previousDisplacement = oldDisplacement;

      // Play spring sound when crossing equilibrium
      if (oldDisplacement * _displacement < 0 && _velocity.abs() > 0.1) {
        context.read<SoundProvider>().playSpring(stretch: _velocity.abs().clamp(0.0, 1.0));
      }
    });
  }

  void _applyForce(double force) {
    setState(() {
      _appliedForce = force;

      if (!_showElasticLimit || force <= _elasticLimit) {
        // Hooke's Law: F = kx, so x = F/k
        _extension = (force / _springConstant) * 100; // Scale for display

        // Add data point
        if (_forceExtensionData.length < 50) {
          _forceExtensionData.add(DataPoint(force, _extension / 100));
        }
        _hasSpokenElasticWarning = false;
      } else {
        // Beyond elastic limit - permanent deformation
        _extension = (_elasticLimit / _springConstant) * 100 +
            (force - _elasticLimit) * 2; // Non-linear extension

        if (!_hasSpokenElasticWarning) {
          _hasSpokenElasticWarning = true;
          speakSimulation(
            'Warning! The force has exceeded the elastic limit. The spring is now permanently deformed '
            'and will not return to its original shape. This is called plastic deformation.',
            force: true,
          );
        }
      }
    });

    if (force > 0 && (!_showElasticLimit || force <= _elasticLimit)) {
      final extensionMeters = (_extension / 100).toStringAsFixed(3);
      speakSimulation(
        'Applied force: ${force.toStringAsFixed(0)} Newtons. Extension: $extensionMeters meters. '
        'Using Hooke\'s Law, F equals k times e.',
      );
    }
  }

  void _startOscillation() {
    setState(() {
      _isOscillating = true;
      _displacement = 0.5; // Initial displacement in meters
      _velocity = 0;
      _time = 0;
      _appliedForce = 0;
    });
    _controller.repeat();

    final period = (2 * math.pi * math.sqrt(_mass / _springConstant)).toStringAsFixed(2);
    speakSimulation(
      'Oscillation started! This demonstrates simple harmonic motion. '
      'The period of oscillation is $period seconds. '
      'A heavier mass oscillates slower, and a stiffer spring oscillates faster.',
      force: true,
    );
  }

  void _stopOscillation() {
    setState(() {
      _isOscillating = false;
      _displacement = 0;
      _extension = 0;
    });
    _controller.stop();
    speakSimulation('Oscillation stopped.', force: true);
  }

  void _resetSimulation() {
    _stopOscillation();
    setState(() {
      _appliedForce = 0;
      _extension = 0;
      _forceExtensionData.clear();
      _hasSpokenElasticWarning = false;
    });
    speakSimulation('Simulation reset. The spring returns to its natural length.', force: true);
  }

  void _onSpringConstantChanged(double value) {
    setState(() {
      _springConstant = value;
      _forceExtensionData.clear();
      _applyForce(_appliedForce);
    });
    speakSimulation(
      'Spring constant set to ${value.toStringAsFixed(0)} Newtons per meter. '
      'A higher spring constant means a stiffer spring that extends less for the same force.',
    );
  }

  void _onMassChanged(double value) {
    setState(() => _mass = value);
    final period = (2 * math.pi * math.sqrt(value / _springConstant)).toStringAsFixed(2);
    speakSimulation(
      'Mass set to ${value.toStringAsFixed(1)} kilograms. '
      'The period of oscillation would now be $period seconds.',
    );
  }

  void _onElasticLimitToggled(bool value) {
    setState(() {
      _showElasticLimit = value;
      _forceExtensionData.clear();
      _hasSpokenElasticWarning = false;
    });
    if (value) {
      speakSimulation(
        'Elastic limit is now shown. Beyond this limit at ${_elasticLimit.toStringAsFixed(0)} Newtons, '
        'the spring will be permanently deformed and Hooke\'s Law no longer applies.',
        force: true,
      );
    } else {
      speakSimulation('Elastic limit display disabled.', force: true);
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
          // Spring visualization
          Container(
            height: 280,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              painter: SpringPainter(
                originalLength: _originalLength,
                extension: _extension,
                appliedForce: _appliedForce,
                mass: _mass,
                isOscillating: _isOscillating,
                showElasticLimit: _showElasticLimit,
                elasticLimit: _elasticLimit,
                springConstant: _springConstant,
              ),
              size: Size.infinite,
            ),
          ),
          // Force-Extension Graph
          Container(
            height: 150,
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
                  'Force-Extension Graph (Hooke\'s Law)',
                  style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: ForceExtensionGraphPainter(
                      dataPoints: _forceExtensionData,
                      springConstant: _springConstant,
                      showElasticLimit: _showElasticLimit,
                      elasticLimit: _elasticLimit,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Data display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDataCard('Force', '${_appliedForce.toStringAsFixed(1)} N', Colors.orange),
                _buildDataCard('Extension', '${(_extension / 100).toStringAsFixed(3)} m', Colors.cyan),
                _buildDataCard('Spring Constant', '${_springConstant.toStringAsFixed(0)} N/m', Colors.green),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [buildTTSToggle()],
                ),
                // Force slider
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('Applied Force', style: TextStyle(color: Colors.orange, fontSize: 12)),
                    ),
                    Expanded(
                      child: Slider(
                        value: _appliedForce,
                        min: 0,
                        max: 200,
                        onChanged: _isOscillating ? null : _applyForce,
                        activeColor: Colors.orange,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${_appliedForce.toStringAsFixed(0)} N',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
                // Spring constant slider
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('Spring Constant', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ),
                    Expanded(
                      child: Slider(
                        value: _springConstant,
                        min: 10,
                        max: 200,
                        onChanged: _isOscillating ? null : _onSpringConstantChanged,
                        activeColor: Colors.green,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${_springConstant.toStringAsFixed(0)} N/m',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
                // Mass slider (for oscillation)
                Row(
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text('Mass', style: TextStyle(color: Colors.purple, fontSize: 12)),
                    ),
                    Expanded(
                      child: Slider(
                        value: _mass,
                        min: 0.5,
                        max: 5,
                        onChanged: _isOscillating ? null : _onMassChanged,
                        activeColor: Colors.purple,
                      ),
                    ),
                    SizedBox(
                      width: 60,
                      child: Text('${_mass.toStringAsFixed(1)} kg',
                          style: const TextStyle(color: Colors.white70, fontSize: 11)),
                    ),
                  ],
                ),
                // Elastic limit toggle
                Row(
                  children: [
                    const Text('Show Elastic Limit', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Switch(
                      value: _showElasticLimit,
                      onChanged: _onElasticLimitToggled,
                      activeColor: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _isOscillating ? _stopOscillation : _startOscillation,
                  icon: Icon(_isOscillating ? Icons.stop : Icons.waves),
                  label: Text(_isOscillating ? 'Stop' : 'Oscillate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isOscillating ? Colors.red : Colors.purple,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: _resetSimulation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ],
            ),
          ),
          // Info panel
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Hooke\'s Law: F = k × e',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'F = Force (N), k = Spring constant (N/m), e = Extension (m)\n'
                  'Period of oscillation: T = 2π√(m/k) = ${(2 * math.pi * math.sqrt(_mass / _springConstant)).toStringAsFixed(2)}s',
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        ],
      ),
    );
  }
}

class DataPoint {
  final double force;
  final double extension;
  DataPoint(this.force, this.extension);
}

class SpringPainter extends CustomPainter {
  final double originalLength;
  final double extension;
  final double appliedForce;
  final double mass;
  final bool isOscillating;
  final bool showElasticLimit;
  final double elasticLimit;
  final double springConstant;

  SpringPainter({
    required this.originalLength,
    required this.extension,
    required this.appliedForce,
    required this.mass,
    required this.isOscillating,
    required this.showElasticLimit,
    required this.elasticLimit,
    required this.springConstant,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final topY = 30.0;
    final springLength = originalLength + extension;

    // Draw fixed support
    final supportPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3;
    canvas.drawLine(Offset(centerX - 40, topY), Offset(centerX + 40, topY), supportPaint);

    // Draw hatching for fixed support
    for (int i = -4; i <= 4; i++) {
      canvas.drawLine(
        Offset(centerX + i * 10, topY),
        Offset(centerX + i * 10 - 8, topY - 10),
        supportPaint..strokeWidth = 1,
      );
    }

    // Draw spring
    _drawSpring(canvas, centerX, topY, springLength);

    // Draw mass
    final massY = topY + springLength;
    final massSize = 30 + mass * 5;
    final massPaint = Paint()..color = Colors.purple;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(centerX, massY + massSize / 2), width: massSize, height: massSize),
        const Radius.circular(4),
      ),
      massPaint,
    );

    // Mass label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${mass.toStringAsFixed(1)}kg',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, massY + massSize / 2 - 5));

    // Draw force arrow if force applied
    if (appliedForce > 0 && !isOscillating) {
      final arrowLength = appliedForce / 2;
      final arrowPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 3;

      canvas.drawLine(
        Offset(centerX, massY + massSize),
        Offset(centerX, massY + massSize + arrowLength),
        arrowPaint,
      );

      // Arrow head
      canvas.drawLine(
        Offset(centerX, massY + massSize + arrowLength),
        Offset(centerX - 8, massY + massSize + arrowLength - 10),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(centerX, massY + massSize + arrowLength),
        Offset(centerX + 8, massY + massSize + arrowLength - 10),
        arrowPaint,
      );

      // Force label
      final forcePainter = TextPainter(
        text: TextSpan(
          text: 'F = ${appliedForce.toStringAsFixed(0)}N',
          style: const TextStyle(color: Colors.orange, fontSize: 11),
        ),
        textDirection: TextDirection.ltr,
      );
      forcePainter.layout();
      forcePainter.paint(canvas, Offset(centerX + 15, massY + massSize + arrowLength / 2 - 6));
    }

    // Draw extension markers
    if (extension > 0) {
      final markerPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 1;

      // Original length marker
      canvas.drawLine(
        Offset(centerX + 50, topY),
        Offset(centerX + 50, topY + originalLength),
        markerPaint..strokeWidth = 0.5,
      );

      // Extension marker
      final extPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 2;
      canvas.drawLine(
        Offset(centerX + 50, topY + originalLength),
        Offset(centerX + 50, topY + springLength),
        extPaint,
      );

      // Extension label
      final extPainter = TextPainter(
        text: TextSpan(
          text: 'e = ${(extension / 100).toStringAsFixed(3)}m',
          style: const TextStyle(color: Colors.cyan, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      extPainter.layout();
      extPainter.paint(canvas, Offset(centerX + 55, topY + originalLength + extension / 2 - 6));
    }

    // Warning if beyond elastic limit
    if (showElasticLimit && appliedForce > elasticLimit) {
      final warningPainter = TextPainter(
        text: const TextSpan(
          text: '⚠ Beyond Elastic Limit!',
          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      warningPainter.layout();
      warningPainter.paint(canvas, Offset(centerX - warningPainter.width / 2, size.height - 25));
    }
  }

  void _drawSpring(Canvas canvas, double centerX, double topY, double length) {
    final springPaint = Paint()
      ..color = showElasticLimit && appliedForce > elasticLimit ? Colors.red : Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final coils = 15;
    final coilWidth = 20.0;
    final coilHeight = length / coils;

    path.moveTo(centerX, topY);

    for (int i = 0; i < coils; i++) {
      final y1 = topY + i * coilHeight + coilHeight / 4;
      final y2 = topY + i * coilHeight + coilHeight * 3 / 4;

      path.lineTo(centerX + coilWidth, y1);
      path.lineTo(centerX - coilWidth, y2);
    }

    path.lineTo(centerX, topY + length);
    canvas.drawPath(path, springPaint);
  }

  @override
  bool shouldRepaint(covariant SpringPainter oldDelegate) =>
      oldDelegate.extension != extension ||
      oldDelegate.appliedForce != appliedForce ||
      oldDelegate.mass != mass;
}

class ForceExtensionGraphPainter extends CustomPainter {
  final List<DataPoint> dataPoints;
  final double springConstant;
  final bool showElasticLimit;
  final double elasticLimit;

  ForceExtensionGraphPainter({
    required this.dataPoints,
    required this.springConstant,
    required this.showElasticLimit,
    required this.elasticLimit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    // Draw axes
    canvas.drawLine(Offset(35, 0), Offset(35, size.height - 15), axisPaint);
    canvas.drawLine(Offset(35, size.height - 15), Offset(size.width - 10, size.height - 15), axisPaint);

    // Axis labels
    final xLabel = TextPainter(
      text: const TextSpan(text: 'Extension (m)', style: TextStyle(color: Colors.white54, fontSize: 8)),
      textDirection: TextDirection.ltr,
    );
    xLabel.layout();
    xLabel.paint(canvas, Offset(size.width / 2 - 25, size.height - 12));

    final yLabel = TextPainter(
      text: const TextSpan(text: 'F(N)', style: TextStyle(color: Colors.white54, fontSize: 8)),
      textDirection: TextDirection.ltr,
    );
    yLabel.layout();
    yLabel.paint(canvas, Offset(5, 5));

    // Draw theoretical line (Hooke's Law)
    final theoreticalPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    final maxExtension = 2.0; // 2 meters
    final maxForce = 200.0;

    canvas.drawLine(
      Offset(35, size.height - 15),
      Offset(35 + (springConstant * maxExtension / maxForce) * (size.width - 45),
          size.height - 15 - (springConstant * maxExtension / maxForce) * (size.height - 20)),
      theoreticalPaint,
    );

    // Draw elastic limit line if enabled
    if (showElasticLimit) {
      final limitPaint = Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 1;

      final limitY = size.height - 15 - (elasticLimit / maxForce) * (size.height - 20);
      canvas.drawLine(Offset(35, limitY), Offset(size.width - 10, limitY), limitPaint);

      final limitLabel = TextPainter(
        text: const TextSpan(text: 'Elastic limit', style: TextStyle(color: Colors.red, fontSize: 8)),
        textDirection: TextDirection.ltr,
      );
      limitLabel.layout();
      limitLabel.paint(canvas, Offset(size.width - 60, limitY - 10));
    }

    // Draw data points
    if (dataPoints.isEmpty) return;

    final pointPaint = Paint()..color = Colors.cyan;

    for (final point in dataPoints) {
      final x = 35 + (point.extension / maxExtension) * (size.width - 45);
      final y = size.height - 15 - (point.force / maxForce) * (size.height - 20);
      canvas.drawCircle(Offset(x.clamp(35, size.width - 10), y.clamp(5, size.height - 15)), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ForceExtensionGraphPainter oldDelegate) =>
      oldDelegate.dataPoints.length != dataPoints.length ||
      oldDelegate.springConstant != springConstant;
}
