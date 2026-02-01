import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class MomentsSimulation extends StatefulWidget {
  const MomentsSimulation({super.key});

  @override
  State<MomentsSimulation> createState() => _MomentsSimulationState();
}

class _MomentsSimulationState extends State<MomentsSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  // Lever properties
  final double _pivotPosition = 0.5; // 0 to 1 (position along beam)
  double _leftForce = 50.0; // N
  double _rightForce = 50.0; // N
  double _leftDistance = 0.3; // m from pivot
  double _rightDistance = 0.3; // m from pivot
  bool _hasSpokenIntro = false;
  bool _lastBalanceState = true;

  // Animation
  double _angle = 0.0;
  double _angularVelocity = 0.0;
  bool _isBalanced = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateSimulation);
    _controller.repeat();
    _calculateBalance();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Moments Simulation. A moment is the turning effect of a force. '
          'Moment equals Force times Distance from the pivot. '
          'For the lever to balance, the anticlockwise moment on the left must equal the clockwise moment on the right. '
          'Adjust the forces and distances to see how the lever tips.',
          force: true,
        );
      }
    });
  }

  void _calculateBalance() {
    final leftMoment = _leftForce * _leftDistance;
    final rightMoment = _rightForce * _rightDistance;
    final netMoment = rightMoment - leftMoment;

    setState(() {
      _isBalanced = netMoment.abs() < 0.5;
    });

    // Announce balance state changes
    if (_isBalanced != _lastBalanceState) {
      _lastBalanceState = _isBalanced;
      if (_isBalanced) {
        speakSimulation(
          'The lever is now balanced! The anticlockwise moment of ${leftMoment.toStringAsFixed(1)} Newton meters '
          'equals the clockwise moment of ${rightMoment.toStringAsFixed(1)} Newton meters.',
          force: true,
        );
      } else {
        final direction = leftMoment > rightMoment ? 'left, anticlockwise' : 'right, clockwise';
        speakSimulation(
          'The lever is unbalanced and tips to the $direction. '
          'Left moment: ${leftMoment.toStringAsFixed(1)} Newton meters. Right moment: ${rightMoment.toStringAsFixed(1)} Newton meters.',
        );
      }
    }
  }

  void _updateSimulation() {
    final leftMoment = _leftForce * _leftDistance;
    final rightMoment = _rightForce * _rightDistance;
    final netMoment = rightMoment - leftMoment;

    setState(() {
      // Apply torque (simplified physics)
      _angularVelocity += netMoment * 0.0001;
      _angularVelocity *= 0.98; // Damping
      _angle += _angularVelocity;

      // Limit angle
      _angle = _angle.clamp(-0.5, 0.5);

      // Stop at limits
      if (_angle.abs() >= 0.5) {
        _angularVelocity = 0;
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      _angle = 0;
      _angularVelocity = 0;
      _leftForce = 50;
      _rightForce = 50;
      _leftDistance = 0.3;
      _rightDistance = 0.3;
      _lastBalanceState = true;
    });
    _calculateBalance();
    speakSimulation('Simulation reset. Forces and distances are now equal, so the lever is balanced.', force: true);
  }

  void _onLeftForceChanged(double value) {
    setState(() => _leftForce = value);
    _calculateBalance();
    final moment = (value * _leftDistance).toStringAsFixed(1);
    speakSimulation('Left force set to ${value.toStringAsFixed(0)} Newtons. Left moment is now $moment Newton meters.');
  }

  void _onLeftDistanceChanged(double value) {
    setState(() => _leftDistance = value);
    _calculateBalance();
    final moment = (_leftForce * value).toStringAsFixed(1);
    speakSimulation('Left distance set to ${value.toStringAsFixed(2)} meters. Left moment is now $moment Newton meters.');
  }

  void _onRightForceChanged(double value) {
    setState(() => _rightForce = value);
    _calculateBalance();
    final moment = (value * _rightDistance).toStringAsFixed(1);
    speakSimulation('Right force set to ${value.toStringAsFixed(0)} Newtons. Right moment is now $moment Newton meters.');
  }

  void _onRightDistanceChanged(double value) {
    setState(() => _rightDistance = value);
    _calculateBalance();
    final moment = (_rightForce * value).toStringAsFixed(1);
    speakSimulation('Right distance set to ${value.toStringAsFixed(2)} meters. Right moment is now $moment Newton meters.');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leftMoment = _leftForce * _leftDistance;
    final rightMoment = _rightForce * _rightDistance;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Lever visualization
          Container(
            height: 250,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              painter: LeverPainter(
                angle: _angle,
                pivotPosition: _pivotPosition,
                leftForce: _leftForce,
                rightForce: _rightForce,
                leftDistance: _leftDistance,
                rightDistance: _rightDistance,
              ),
              size: Size.infinite,
            ),
          ),
          // Moment calculations
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMomentCard(
                      'Left Moment',
                      '${leftMoment.toStringAsFixed(1)} Nm',
                      Colors.blue,
                      'Anticlockwise',
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isBalanced ? Colors.green.withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _isBalanced ? Colors.green : Colors.orange,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isBalanced ? Icons.balance : Icons.warning,
                        color: _isBalanced ? Colors.green : Colors.orange,
                        size: 30,
                      ),
                    ),
                    _buildMomentCard(
                      'Right Moment',
                      '${rightMoment.toStringAsFixed(1)} Nm',
                      Colors.red,
                      'Clockwise',
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _isBalanced
                      ? 'BALANCED - Moments are equal'
                      : leftMoment > rightMoment
                          ? 'UNBALANCED - Tips left (anticlockwise)'
                          : 'UNBALANCED - Tips right (clockwise)',
                  style: TextStyle(
                    color: _isBalanced ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                // Left force slider
                _buildSlider(
                  'Left Force',
                  _leftForce,
                  0,
                  100,
                  '${_leftForce.toStringAsFixed(0)} N',
                  _onLeftForceChanged,
                  Colors.blue,
                ),
                // Left distance slider
                _buildSlider(
                  'Left Distance',
                  _leftDistance,
                  0.1,
                  0.5,
                  '${_leftDistance.toStringAsFixed(2)} m',
                  _onLeftDistanceChanged,
                  Colors.blue.shade300,
                ),
                const Divider(color: Colors.white24),
                // Right force slider
                _buildSlider(
                  'Right Force',
                  _rightForce,
                  0,
                  100,
                  '${_rightForce.toStringAsFixed(0)} N',
                  _onRightForceChanged,
                  Colors.red,
                ),
                // Right distance slider
                _buildSlider(
                  'Right Distance',
                  _rightDistance,
                  0.1,
                  0.5,
                  '${_rightDistance.toStringAsFixed(2)} m',
                  _onRightDistanceChanged,
                  Colors.red.shade300,
                ),
              ],
            ),
          ),
          // Reset button
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _resetSimulation,
              icon: const Icon(Icons.refresh),
              label: const Text('Reset'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ),
          // Formula info
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'Moment = Force × Distance',
                  style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  'M = F × d',
                  style: TextStyle(color: Colors.white70, fontFamily: 'monospace', fontSize: 14),
                ),
                const SizedBox(height: 8),
                const Text(
                  'For balance: Anticlockwise moment = Clockwise moment',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'F₁ × d₁ = F₂ × d₂',
                  style: TextStyle(color: Colors.purple.shade200, fontFamily: 'monospace', fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMomentCard(String label, String value, Color color, String direction) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: color, fontSize: 11)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
        Text(direction, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: TextStyle(color: color, fontSize: 12)),
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
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(displayValue, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}

class LeverPainter extends CustomPainter {
  final double angle;
  final double pivotPosition;
  final double leftForce;
  final double rightForce;
  final double leftDistance;
  final double rightDistance;

  LeverPainter({
    required this.angle,
    required this.pivotPosition,
    required this.leftForce,
    required this.rightForce,
    required this.leftDistance,
    required this.rightDistance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final pivotY = size.height * 0.7;
    final beamLength = size.width * 0.8;

    // Save canvas state
    canvas.save();

    // Translate to pivot point and rotate
    canvas.translate(centerX, pivotY);
    canvas.rotate(angle);

    // Draw beam
    final beamPaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-beamLength / 2, 0),
      Offset(beamLength / 2, 0),
      beamPaint,
    );

    // Draw distance markers
    final markerPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 1;

    for (double d = 0.1; d <= 0.5; d += 0.1) {
      final leftX = -d * beamLength;
      final rightX = d * beamLength;
      canvas.drawLine(Offset(leftX, -8), Offset(leftX, 8), markerPaint);
      canvas.drawLine(Offset(rightX, -8), Offset(rightX, 8), markerPaint);
    }

    // Draw left weight
    final leftX = -leftDistance * beamLength;
    _drawWeight(canvas, Offset(leftX, 0), leftForce, Colors.blue);

    // Draw right weight
    final rightX = rightDistance * beamLength;
    _drawWeight(canvas, Offset(rightX, 0), rightForce, Colors.red);

    // Draw distance labels
    _drawDistanceLabel(canvas, Offset(leftX / 2, 25), '${leftDistance.toStringAsFixed(2)}m', Colors.blue);
    _drawDistanceLabel(canvas, Offset(rightX / 2, 25), '${rightDistance.toStringAsFixed(2)}m', Colors.red);

    // Draw distance arrows
    final arrowPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;
    canvas.drawLine(const Offset(0, 20), Offset(leftX, 20), arrowPaint);
    canvas.drawLine(const Offset(0, 20), Offset(rightX, 20), arrowPaint);

    canvas.restore();

    // Draw pivot (triangle)
    final pivotPath = Path();
    pivotPath.moveTo(centerX, pivotY);
    pivotPath.lineTo(centerX - 20, pivotY + 40);
    pivotPath.lineTo(centerX + 20, pivotY + 40);
    pivotPath.close();

    canvas.drawPath(pivotPath, Paint()..color = Colors.grey);
    canvas.drawPath(
      pivotPath,
      Paint()
        ..color = Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Draw ground
    canvas.drawLine(
      Offset(centerX - 60, pivotY + 40),
      Offset(centerX + 60, pivotY + 40),
      Paint()
        ..color = Colors.grey
        ..strokeWidth = 3,
    );

    // Pivot label
    final pivotLabel = TextPainter(
      text: const TextSpan(
        text: 'Pivot',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    pivotLabel.layout();
    pivotLabel.paint(canvas, Offset(centerX - 15, pivotY + 45));

    // Rotation direction indicators
    if (angle.abs() > 0.01) {
      final rotationPaint = Paint()
        ..color = angle > 0 ? Colors.red.withValues(alpha: 0.5) : Colors.blue.withValues(alpha: 0.5)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final rotationPath = Path();
      rotationPath.addArc(
        Rect.fromCenter(center: Offset(centerX, pivotY - 60), width: 40, height: 40),
        angle > 0 ? -0.5 : math.pi - 0.5,
        angle > 0 ? 1 : 1,
      );
      canvas.drawPath(rotationPath, rotationPaint);
    }
  }

  void _drawWeight(Canvas canvas, Offset position, double force, Color color) {
    final weightSize = 20 + force / 5;
    final weightPaint = Paint()..color = color;

    // Draw weight box
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(position.dx, position.dy + weightSize / 2 + 15),
          width: weightSize,
          height: weightSize,
        ),
        const Radius.circular(4),
      ),
      weightPaint,
    );

    // Draw connecting line
    canvas.drawLine(
      position,
      Offset(position.dx, position.dy + 15),
      Paint()
        ..color = Colors.white54
        ..strokeWidth = 2,
    );

    // Draw force arrow
    final arrowLength = force / 2;
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 3;

    final arrowStart = Offset(position.dx, position.dy + weightSize + 20);
    final arrowEnd = Offset(position.dx, arrowStart.dy + arrowLength);

    canvas.drawLine(arrowStart, arrowEnd, arrowPaint);

    // Arrow head
    canvas.drawLine(arrowEnd, Offset(arrowEnd.dx - 6, arrowEnd.dy - 8), arrowPaint);
    canvas.drawLine(arrowEnd, Offset(arrowEnd.dx + 6, arrowEnd.dy - 8), arrowPaint);

    // Force label
    final forcePainter = TextPainter(
      text: TextSpan(
        text: '${force.toStringAsFixed(0)}N',
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    forcePainter.layout();
    forcePainter.paint(canvas, Offset(position.dx + 15, arrowStart.dy + arrowLength / 2 - 5));
  }

  void _drawDistanceLabel(Canvas canvas, Offset position, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy));
  }

  @override
  bool shouldRepaint(covariant LeverPainter oldDelegate) =>
      oldDelegate.angle != angle ||
      oldDelegate.leftForce != leftForce ||
      oldDelegate.rightForce != rightForce ||
      oldDelegate.leftDistance != leftDistance ||
      oldDelegate.rightDistance != rightDistance;
}
