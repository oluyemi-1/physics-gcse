import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Electromagnet Simulation demonstrating factors affecting electromagnet strength
/// Shows effect of current, coils, and core material
class ElectromagnetSimulation extends StatefulWidget {
  const ElectromagnetSimulation({super.key});

  @override
  State<ElectromagnetSimulation> createState() => _ElectromagnetSimulationState();
}

class _ElectromagnetSimulationState extends State<ElectromagnetSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _current = 2.0; // Amps
  int _numCoils = 10;
  String _coreMaterial = 'Iron';
  bool _isOn = true;
  double _time = 0.0;

  final Map<String, double> _coreMultipliers = {
    'Air': 1.0,
    'Aluminium': 1.0,
    'Iron': 200.0,
    'Steel': 100.0,
    'Soft Iron': 250.0,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _time += 0.02;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Electromagnet Simulation. An electromagnet is a temporary magnet made by passing current through a coil. '
        'Its strength increases with more current, more coils, and using an iron core. '
        'Unlike permanent magnets, electromagnets can be switched on and off.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _fieldStrength {
    if (!_isOn) return 0;
    return _current * _numCoils * _coreMultipliers[_coreMaterial]! / 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electromagnets'),
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
        border: Border.all(color: _isOn ? Colors.indigo.shade300 : Colors.grey),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isOn ? Icons.flash_on : Icons.flash_off,
                color: _isOn ? Colors.yellow : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                _isOn ? 'ELECTROMAGNET ON' : 'ELECTROMAGNET OFF',
                style: TextStyle(
                  color: _isOn ? Colors.white : Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Current', '${_current.toStringAsFixed(1)} A'),
              _buildInfoItem('Coils', '$_numCoils turns'),
              _buildInfoItem('Core', _coreMaterial),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Field Strength: ',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  _isOn ? '${_fieldStrength.toStringAsFixed(1)} (relative)' : 'OFF',
                  style: TextStyle(
                    color: _isOn ? Colors.amber : Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ElectromagnetPainter(
            current: _current,
            numCoils: _numCoils,
            coreMaterial: _coreMaterial,
            isOn: _isOn,
            fieldStrength: _fieldStrength,
            time: _time,
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
          // On/Off switch
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Power: ', style: TextStyle(color: Colors.white)),
              Switch(
                value: _isOn,
                onChanged: (value) {
                  setState(() => _isOn = value);
                  speakSimulation(
                    value ? 'Electromagnet switched on. Current flowing through coil creates magnetic field.'
                          : 'Electromagnet switched off. No current, no magnetic field.',
                  );
                },
                activeColor: Colors.yellow,
              ),
            ],
          ),

          // Current slider
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.yellow, size: 18),
              const SizedBox(width: 8),
              const Text('Current:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _current,
                  min: 0.5,
                  max: 10,
                  activeColor: Colors.yellow,
                  onChanged: (value) => setState(() => _current = value),
                ),
              ),
              Text('${_current.toStringAsFixed(1)} A', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Number of coils slider
          Row(
            children: [
              const Icon(Icons.loop, color: Colors.orange, size: 18),
              const SizedBox(width: 8),
              const Text('Coils:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _numCoils.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => _numCoils = value.round()),
                ),
              ),
              Text('$_numCoils', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Core material selector
          Wrap(
            spacing: 8,
            children: _coreMultipliers.keys.map((material) {
              return ChoiceChip(
                label: Text(material, style: const TextStyle(fontSize: 11)),
                selected: _coreMaterial == material,
                selectedColor: Colors.indigo.shade400,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _coreMaterial = material);
                    final multiplier = _coreMultipliers[material]!;
                    speakSimulation(
                      '$material core selected. ${multiplier > 1 ? "This magnetic material greatly increases field strength." : "Non-magnetic material, weak field."}',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Factors affecting strength
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Stronger electromagnet: ↑ Current | ↑ Coils | Iron core',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _ElectromagnetPainter extends CustomPainter {
  final double current;
  final int numCoils;
  final String coreMaterial;
  final bool isOn;
  final double fieldStrength;
  final double time;

  _ElectromagnetPainter({
    required this.current,
    required this.numCoils,
    required this.coreMaterial,
    required this.isOn,
    required this.fieldStrength,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw battery/power source
    _drawPowerSource(canvas, Offset(50, centerY));

    // Draw wire connections
    _drawWires(canvas, size, centerX, centerY);

    // Draw core
    _drawCore(canvas, centerX, centerY);

    // Draw coils
    _drawCoils(canvas, centerX, centerY);

    // Draw magnetic field lines (if on)
    if (isOn) {
      _drawFieldLines(canvas, centerX, centerY);
    }

    // Draw attracted objects (paperclips)
    _drawAttractedObjects(canvas, centerX, centerY);

    // Draw current flow arrows (if on)
    if (isOn) {
      _drawCurrentFlow(canvas, size, centerX, centerY);
    }

    // Draw poles
    if (isOn) {
      _drawPoles(canvas, centerX, centerY);
    }
  }

  void _drawPowerSource(Canvas canvas, Offset position) {
    // Battery symbol
    final batteryPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromCenter(center: position, width: 30, height: 50),
      batteryPaint,
    );

    // Positive terminal
    canvas.drawLine(
      Offset(position.dx - 10, position.dy - 30),
      Offset(position.dx + 10, position.dy - 30),
      Paint()..color = Colors.red..strokeWidth = 4,
    );
    canvas.drawLine(
      Offset(position.dx, position.dy - 35),
      Offset(position.dx, position.dy - 25),
      Paint()..color = Colors.red..strokeWidth = 4,
    );

    // Negative terminal
    canvas.drawLine(
      Offset(position.dx - 10, position.dy + 30),
      Offset(position.dx + 10, position.dy + 30),
      Paint()..color = Colors.blue..strokeWidth = 4,
    );

    // Labels
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${current.toStringAsFixed(1)}A',
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(position.dx - textPainter.width / 2, position.dy - 5));
  }

  void _drawWires(Canvas canvas, Size size, double centerX, double centerY) {
    final wirePaint = Paint()
      ..color = isOn ? Colors.red.shade400 : Colors.grey
      ..strokeWidth = 3;

    // Top wire
    canvas.drawLine(Offset(50, centerY - 30), Offset(50, centerY - 80), wirePaint);
    canvas.drawLine(Offset(50, centerY - 80), Offset(centerX - 80, centerY - 80), wirePaint);
    canvas.drawLine(Offset(centerX - 80, centerY - 80), Offset(centerX - 80, centerY - 30), wirePaint);

    // Bottom wire
    final wireBlue = Paint()
      ..color = isOn ? Colors.blue.shade400 : Colors.grey
      ..strokeWidth = 3;
    canvas.drawLine(Offset(50, centerY + 30), Offset(50, centerY + 80), wireBlue);
    canvas.drawLine(Offset(50, centerY + 80), Offset(centerX + 80, centerY + 80), wireBlue);
    canvas.drawLine(Offset(centerX + 80, centerY + 80), Offset(centerX + 80, centerY + 30), wireBlue);
  }

  void _drawCore(Canvas canvas, double centerX, double centerY) {
    Color coreColor;
    switch (coreMaterial) {
      case 'Iron':
      case 'Soft Iron':
        coreColor = Colors.grey.shade600;
        break;
      case 'Steel':
        coreColor = Colors.blueGrey.shade500;
        break;
      case 'Aluminium':
        coreColor = Colors.grey.shade400;
        break;
      default:
        coreColor = Colors.transparent;
    }

    if (coreMaterial != 'Air') {
      final corePaint = Paint()..color = coreColor;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(centerX, centerY), width: 120, height: 40),
          const Radius.circular(5),
        ),
        corePaint,
      );

      // Core label
      final textPainter = TextPainter(
        text: TextSpan(
          text: coreMaterial,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, centerY - 5));
    }
  }

  void _drawCoils(Canvas canvas, double centerX, double centerY) {
    final coilPaint = Paint()
      ..color = isOn ? Colors.orange : Colors.orange.shade800
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final coilSpacing = 140.0 / numCoils;
    final startX = centerX - 70;

    for (var i = 0; i < numCoils; i++) {
      final x = startX + i * coilSpacing;

      // Draw coil loop
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, centerY), width: coilSpacing * 0.8, height: 60),
        coilPaint,
      );
    }

    // Coil count label
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$numCoils turns',
        style: const TextStyle(color: Colors.orange, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, centerY + 40));
  }

  void _drawFieldLines(Canvas canvas, double centerX, double centerY) {
    final fieldPaint = Paint()
      ..color = Colors.cyan.withAlpha((100 * math.min(fieldStrength / 50, 1)).toInt() + 50)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final numLines = (fieldStrength / 10).clamp(2, 8).toInt();

    for (var i = 0; i < numLines; i++) {
      final yOffset = (i - numLines / 2) * 15;

      // Field line path (exiting from N pole, entering S pole)
      final path = Path();
      path.moveTo(centerX + 80, centerY + yOffset);

      // Curve around the outside
      path.quadraticBezierTo(
        centerX + 150, centerY + yOffset,
        centerX + 150, centerY + yOffset + 50,
      );
      path.quadraticBezierTo(
        centerX + 150, centerY + yOffset + 100,
        centerX, centerY + yOffset + 100,
      );
      path.quadraticBezierTo(
        centerX - 150, centerY + yOffset + 100,
        centerX - 150, centerY + yOffset + 50,
      );
      path.quadraticBezierTo(
        centerX - 150, centerY + yOffset,
        centerX - 80, centerY + yOffset,
      );

      canvas.drawPath(path, fieldPaint);

      // Arrow indicating direction
      final arrowX = centerX + 150;
      final arrowY = centerY + yOffset + 50;
      _drawSmallArrow(canvas, Offset(arrowX, arrowY), true, Colors.cyan.withAlpha(150));
    }
  }

  void _drawSmallArrow(Canvas canvas, Offset position, bool down, Color color) {
    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 2;

    final direction = down ? 1.0 : -1.0;
    canvas.drawLine(position, Offset(position.dx - 5, position.dy - direction * 8), arrowPaint);
    canvas.drawLine(position, Offset(position.dx + 5, position.dy - direction * 8), arrowPaint);
  }

  void _drawAttractedObjects(Canvas canvas, double centerX, double centerY) {
    if (!isOn || fieldStrength < 5) return;

    // Draw paperclips being attracted
    final clipPaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final numClips = (fieldStrength / 15).clamp(1, 5).toInt();

    for (var i = 0; i < numClips; i++) {
      final attractProgress = math.sin(time * 2 + i) * 0.3 + 0.7;
      final clipX = centerX - 120 - i * 15 + (30 * attractProgress);
      final clipY = centerY + 60 + i * 10;

      // Simple paperclip shape
      final clipPath = Path();
      clipPath.moveTo(clipX, clipY);
      clipPath.lineTo(clipX + 15, clipY);
      clipPath.quadraticBezierTo(clipX + 20, clipY, clipX + 20, clipY + 5);
      clipPath.lineTo(clipX + 20, clipY + 15);
      clipPath.quadraticBezierTo(clipX + 20, clipY + 20, clipX + 15, clipY + 20);
      clipPath.lineTo(clipX + 5, clipY + 20);
      clipPath.quadraticBezierTo(clipX, clipY + 20, clipX, clipY + 15);
      clipPath.lineTo(clipX, clipY + 10);

      canvas.drawPath(clipPath, clipPaint);
    }

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Attracted\nobjects',
        style: TextStyle(color: Colors.white54, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 150, centerY + 90));
  }

  void _drawCurrentFlow(Canvas canvas, Size size, double centerX, double centerY) {
    // Animate current flow with moving dots
    final dotPaint = Paint()..color = Colors.yellow;

    for (var i = 0; i < 5; i++) {
      final progress = (time * 0.5 + i * 0.2) % 1.0;

      // Dots along top wire
      final topX = 50 + progress * (centerX - 80 - 50);
      canvas.drawCircle(Offset(topX, centerY - 80), 4, dotPaint);

      // Dots along bottom wire
      final bottomX = centerX + 80 - progress * (centerX + 80 - 50);
      canvas.drawCircle(Offset(bottomX, centerY + 80), 4, dotPaint);
    }
  }

  void _drawPoles(Canvas canvas, double centerX, double centerY) {
    // North pole (left side with standard current direction)
    final nPainter = TextPainter(
      text: const TextSpan(
        text: 'N',
        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    nPainter.layout();
    nPainter.paint(canvas, Offset(centerX - 90, centerY - 8));

    // South pole
    final sPainter = TextPainter(
      text: const TextSpan(
        text: 'S',
        style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    sPainter.layout();
    sPainter.paint(canvas, Offset(centerX + 80, centerY - 8));
  }

  @override
  bool shouldRepaint(covariant _ElectromagnetPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.isOn != isOn ||
           oldDelegate.current != current ||
           oldDelegate.numCoils != numCoils ||
           oldDelegate.coreMaterial != coreMaterial;
  }
}
