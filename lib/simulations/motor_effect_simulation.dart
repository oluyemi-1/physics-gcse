import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class MotorEffectSimulation extends StatefulWidget {
  const MotorEffectSimulation({super.key});

  @override
  State<MotorEffectSimulation> createState() => _MotorEffectSimulationState();
}

class _MotorEffectSimulationState extends State<MotorEffectSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _current = 5.0; // Amps
  double _magneticField = 0.5; // Tesla
  final double _wireLength = 0.1; // metres
  bool _currentOn = true;
  bool _hasSpokenIntro = false;
  double _wirePosition = 0.0;
  bool _isMoving = false;

  // Fleming's Left Hand Rule directions
  bool _fieldLeftToRight = true;
  bool _currentIntoPage = true;

  double get _force => _current * _magneticField * _wireLength;

  String get _forceDirection {
    // Fleming's left hand rule
    if (_fieldLeftToRight && _currentIntoPage) return 'UP';
    if (_fieldLeftToRight && !_currentIntoPage) return 'DOWN';
    if (!_fieldLeftToRight && _currentIntoPage) return 'DOWN';
    return 'UP';
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateMotion);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Motor Effect simulation! '
          'When a current-carrying wire is placed in a magnetic field, it experiences a force. '
          'This is the motor effect, and it\'s how electric motors work. '
          'Use Fleming\'s left-hand rule: thumb for thrust, first finger for field, second finger for current. '
          'The force equals B times I times L - magnetic field strength times current times wire length.',
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

  void _updateMotion() {
    if (!_currentOn || !_isMoving) return;

    setState(() {
      final direction = _forceDirection == 'UP' ? -1.0 : 1.0;
      _wirePosition += direction * _force * 0.5;
      _wirePosition = _wirePosition.clamp(-80.0, 80.0);

      if (_wirePosition.abs() >= 80) {
        _isMoving = false;
        _controller.stop();
      }
    });
  }

  void _toggleCurrent() {
    setState(() {
      _currentOn = !_currentOn;
      if (!_currentOn) {
        _isMoving = false;
        _controller.stop();
      }
    });
    speakSimulation(
      _currentOn ? 'Current turned on. The wire will experience a force.' : 'Current turned off. No force on the wire.',
      force: true,
    );
  }

  void _startMotion() {
    if (!_currentOn) return;
    setState(() {
      _isMoving = true;
    });
    _controller.repeat();
    speakSimulation(
      'The wire moves ${_forceDirection.toLowerCase()} due to the motor effect. '
      'Force is ${_force.toStringAsFixed(3)} Newtons.',
      force: true,
    );
  }

  void _reset() {
    setState(() {
      _wirePosition = 0.0;
      _isMoving = false;
    });
    _controller.stop();
  }

  void _toggleFieldDirection() {
    setState(() {
      _fieldLeftToRight = !_fieldLeftToRight;
      _wirePosition = 0.0;
      _isMoving = false;
    });
    _controller.stop();
    speakSimulation(
      'Magnetic field now points ${_fieldLeftToRight ? 'left to right' : 'right to left'}. '
      'Force direction changes to $_forceDirection.',
      force: true,
    );
  }

  void _toggleCurrentDirection() {
    setState(() {
      _currentIntoPage = !_currentIntoPage;
      _wirePosition = 0.0;
      _isMoving = false;
    });
    _controller.stop();
    speakSimulation(
      'Current now flows ${_currentIntoPage ? 'into the page' : 'out of the page'}. '
      'Force direction changes to $_forceDirection.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade300),
            ),
            child: CustomPaint(
              painter: _MotorEffectPainter(
                wirePosition: _wirePosition,
                fieldLeftToRight: _fieldLeftToRight,
                currentIntoPage: _currentIntoPage,
                currentOn: _currentOn,
                forceDirection: _forceDirection,
                force: _force,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Fleming's Left Hand Rule diagram
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text("Fleming's Left Hand Rule", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildRuleItem('Thumb', 'Thrust (F)', Colors.green),
                      const SizedBox(width: 8),
                      _buildRuleItem('First', 'Field (B)', Colors.red),
                      const SizedBox(width: 8),
                      _buildRuleItem('Second', 'Current (I)', Colors.blue),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('F = BIL', style: TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16)),
                    Text(
                      '${_force.toStringAsFixed(3)} = ${_magneticField.toStringAsFixed(2)} × ${_current.toStringAsFixed(1)} × ${_wireLength.toStringAsFixed(2)}',
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Current slider
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Current:', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _current,
                        min: 0.5,
                        max: 10,
                        onChanged: (v) => setState(() => _current = v),
                        activeColor: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 50, child: Text('${_current.toStringAsFixed(1)} A', style: const TextStyle(color: Colors.white))),
                  ],
                ),

                // Magnetic field slider
                Row(
                  children: [
                    const SizedBox(width: 80, child: Text('Field (B):', style: TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _magneticField,
                        min: 0.1,
                        max: 1.0,
                        onChanged: (v) => setState(() => _magneticField = v),
                        activeColor: Colors.red,
                      ),
                    ),
                    SizedBox(width: 50, child: Text('${_magneticField.toStringAsFixed(2)} T', style: const TextStyle(color: Colors.white))),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _toggleFieldDirection,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                      child: Text('Field: ${_fieldLeftToRight ? '→' : '←'}', style: const TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: _toggleCurrentDirection,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700]),
                      child: Text('Current: ${_currentIntoPage ? '⊗' : '⊙'}', style: const TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      onPressed: _toggleCurrent,
                      style: ElevatedButton.styleFrom(backgroundColor: _currentOn ? Colors.green : Colors.grey),
                      child: Text(_currentOn ? 'ON' : 'OFF', style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentOn && !_isMoving ? _startMotion : null,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Apply Force'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    buildTTSToggle(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleItem(String finger, String quantity, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(finger, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 10)),
          Text(quantity, style: const TextStyle(color: Colors.white70, fontSize: 9)),
        ],
      ),
    );
  }
}

class _MotorEffectPainter extends CustomPainter {
  final double wirePosition;
  final bool fieldLeftToRight;
  final bool currentIntoPage;
  final bool currentOn;
  final String forceDirection;
  final double force;

  _MotorEffectPainter({
    required this.wirePosition,
    required this.fieldLeftToRight,
    required this.currentIntoPage,
    required this.currentOn,
    required this.forceDirection,
    required this.force,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw magnet poles
    _drawMagnets(canvas, size);

    // Draw magnetic field lines
    _drawFieldLines(canvas, size);

    // Draw wire
    _drawWire(canvas, centerX, centerY + wirePosition);

    // Draw force arrow if current is on
    if (currentOn) {
      _drawForceArrow(canvas, centerX, centerY + wirePosition);
    }

    // Draw labels
    _drawLabels(canvas, size);
  }

  void _drawMagnets(Canvas canvas, Size size) {
    final leftMagnet = Rect.fromLTWH(20, size.height / 2 - 60, 40, 120);
    final rightMagnet = Rect.fromLTWH(size.width - 60, size.height / 2 - 60, 40, 120);

    // North pole (red)
    final northPaint = Paint()..color = Colors.red;
    // South pole (blue)
    final southPaint = Paint()..color = Colors.blue;

    if (fieldLeftToRight) {
      canvas.drawRect(leftMagnet, northPaint);
      canvas.drawRect(rightMagnet, southPaint);
    } else {
      canvas.drawRect(leftMagnet, southPaint);
      canvas.drawRect(rightMagnet, northPaint);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = TextSpan(
      text: fieldLeftToRight ? 'N' : 'S',
      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(32, size.height / 2 - 12));

    textPainter.text = TextSpan(
      text: fieldLeftToRight ? 'S' : 'N',
      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 52, size.height / 2 - 12));
  }

  void _drawFieldLines(Canvas canvas, Size size) {
    final fieldPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.4)
      ..strokeWidth = 1.5;

    final startX = 65.0;
    final endX = size.width - 65;
    final centerY = size.height / 2;

    for (int i = -2; i <= 2; i++) {
      final y = centerY + i * 20;
      canvas.drawLine(Offset(startX, y), Offset(endX, y), fieldPaint);

      // Arrow heads
      final arrowX = (startX + endX) / 2;
      final direction = fieldLeftToRight ? 1.0 : -1.0;
      _drawArrowHead(canvas, arrowX, y, direction, fieldPaint.color);
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'B field ${fieldLeftToRight ? '→' : '←'}',
        style: TextStyle(color: Colors.red.withValues(alpha: 0.7), fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - 25, size.height / 2 + 50));
  }

  void _drawWire(Canvas canvas, double x, double y) {
    // Wire cross-section (circle)
    final wirePaint = Paint()
      ..color = currentOn ? Colors.amber : Colors.grey
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 15, wirePaint);

    // Wire outline
    final outlinePaint = Paint()
      ..color = Colors.brown
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(x, y), 15, outlinePaint);

    // Current direction symbol
    if (currentOn) {
      final symbolPaint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 2;

      if (currentIntoPage) {
        // X symbol (into page)
        canvas.drawLine(Offset(x - 8, y - 8), Offset(x + 8, y + 8), symbolPaint);
        canvas.drawLine(Offset(x + 8, y - 8), Offset(x - 8, y + 8), symbolPaint);
      } else {
        // Dot symbol (out of page)
        canvas.drawCircle(Offset(x, y), 5, symbolPaint..style = PaintingStyle.fill);
      }
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Wire\n(I ${currentIntoPage ? '⊗' : '⊙'})',
        style: const TextStyle(color: Colors.brown, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 15, y + 20));
  }

  void _drawForceArrow(Canvas canvas, double x, double y) {
    final forcePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4;

    final arrowLength = force * 300; // Scale force for visibility
    final direction = forceDirection == 'UP' ? -1.0 : 1.0;
    final endY = y + direction * arrowLength;

    canvas.drawLine(Offset(x, y), Offset(x, endY), forcePaint);

    // Arrow head
    final path = Path();
    path.moveTo(x, endY);
    path.lineTo(x - 8, endY - direction * 12);
    path.lineTo(x + 8, endY - direction * 12);
    path.close();
    canvas.drawPath(path, forcePaint..style = PaintingStyle.fill);

    // Force label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'F = ${force.toStringAsFixed(3)} N\n($forceDirection)',
        style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 20, y - 20));
  }

  void _drawArrowHead(Canvas canvas, double x, double y, double direction, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(x + direction * 8, y);
    path.lineTo(x - direction * 4, y - 4);
    path.lineTo(x - direction * 4, y + 4);
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'Motor Effect: F = BIL',
      style: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 10));
  }

  @override
  bool shouldRepaint(covariant _MotorEffectPainter oldDelegate) {
    return wirePosition != oldDelegate.wirePosition ||
        fieldLeftToRight != oldDelegate.fieldLeftToRight ||
        currentIntoPage != oldDelegate.currentIntoPage ||
        currentOn != oldDelegate.currentOn;
  }
}
