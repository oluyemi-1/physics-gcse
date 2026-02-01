import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Energy Efficiency Simulation demonstrating useful vs wasted energy
/// Shows Sankey diagrams and efficiency calculations for various devices
class EnergyEfficiencySimulation extends StatefulWidget {
  const EnergyEfficiencySimulation({super.key});

  @override
  State<EnergyEfficiencySimulation> createState() => _EnergyEfficiencySimulationState();
}

class _EnergyEfficiencySimulationState extends State<EnergyEfficiencySimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  String _selectedDevice = 'Incandescent Bulb';
  double _inputEnergy = 100.0; // Joules (or Watts for power)

  final Map<String, Map<String, dynamic>> _devices = {
    'Incandescent Bulb': {
      'efficiency': 5.0,
      'usefulOutput': 'Light',
      'wastedOutput': 'Heat',
      'inputType': 'Electrical',
      'icon': Icons.lightbulb_outline,
      'color': Colors.yellow,
    },
    'LED Bulb': {
      'efficiency': 40.0,
      'usefulOutput': 'Light',
      'wastedOutput': 'Heat',
      'inputType': 'Electrical',
      'icon': Icons.lightbulb,
      'color': Colors.white,
    },
    'Electric Motor': {
      'efficiency': 85.0,
      'usefulOutput': 'Kinetic',
      'wastedOutput': 'Heat + Sound',
      'inputType': 'Electrical',
      'icon': Icons.settings,
      'color': Colors.blue,
    },
    'Car Engine': {
      'efficiency': 25.0,
      'usefulOutput': 'Kinetic',
      'wastedOutput': 'Heat + Sound',
      'inputType': 'Chemical',
      'icon': Icons.directions_car,
      'color': Colors.red,
    },
    'Electric Heater': {
      'efficiency': 100.0,
      'usefulOutput': 'Heat',
      'wastedOutput': 'None',
      'inputType': 'Electrical',
      'icon': Icons.whatshot,
      'color': Colors.orange,
    },
    'Solar Panel': {
      'efficiency': 20.0,
      'usefulOutput': 'Electrical',
      'wastedOutput': 'Heat + Reflection',
      'inputType': 'Light (Solar)',
      'icon': Icons.solar_power,
      'color': Colors.amber,
    },
    'Coal Power Station': {
      'efficiency': 35.0,
      'usefulOutput': 'Electrical',
      'wastedOutput': 'Heat',
      'inputType': 'Chemical',
      'icon': Icons.factory,
      'color': Colors.grey,
    },
    'Human Body': {
      'efficiency': 25.0,
      'usefulOutput': 'Kinetic + Thinking',
      'wastedOutput': 'Heat',
      'inputType': 'Chemical (Food)',
      'icon': Icons.person,
      'color': Colors.pink,
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Energy Efficiency Simulation. Efficiency measures how much input energy becomes useful output. '
        'No device is 100% efficient except heaters, where heat IS the useful output. '
        'Efficiency equals useful energy output divided by total energy input, times 100 percent.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Efficiency'),
        backgroundColor: Colors.green.shade800,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade900, Colors.grey.shade900],
          ),
        ),
        child: Column(
          children: [
            _buildInfoPanel(),
            Expanded(child: _buildSankeyDiagram()),
            _buildControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    final device = _devices[_selectedDevice]!;
    final efficiency = device['efficiency'] as double;
    final usefulEnergy = _inputEnergy * efficiency / 100;
    final wastedEnergy = _inputEnergy - usefulEnergy;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (device['color'] as Color).withAlpha(150)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(device['icon'] as IconData, color: device['color'] as Color, size: 28),
              const SizedBox(width: 8),
              Text(
                _selectedDevice,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Input Energy', '${_inputEnergy.toStringAsFixed(0)} J', Colors.blue),
              _buildInfoItem('Useful Output', '${usefulEnergy.toStringAsFixed(1)} J', Colors.green),
              _buildInfoItem('Wasted', '${wastedEnergy.toStringAsFixed(1)} J', Colors.red),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Efficiency = ',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                Text(
                  '${efficiency.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${device['inputType']} → ${device['usefulOutput']} (useful) + ${device['wastedOutput']} (wasted)',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSankeyDiagram() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final device = _devices[_selectedDevice]!;

        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              size: Size(constraints.maxWidth, constraints.maxHeight),
              painter: _SankeyPainter(
                inputEnergy: _inputEnergy,
                efficiency: device['efficiency'] as double,
                usefulOutput: device['usefulOutput'] as String,
                wastedOutput: device['wastedOutput'] as String,
                inputType: device['inputType'] as String,
                deviceColor: device['color'] as Color,
                animationValue: _controller.value,
              ),
            );
          },
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
          // Device selector
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _devices.keys.map((deviceName) {
                final device = _devices[deviceName]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    avatar: Icon(device['icon'] as IconData, size: 16),
                    label: Text(deviceName, style: const TextStyle(fontSize: 10)),
                    selected: _selectedDevice == deviceName,
                    selectedColor: (device['color'] as Color).withAlpha(150),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedDevice = deviceName);
                        final eff = device['efficiency'] as double;
                        speakSimulation(
                          '$deviceName selected. Efficiency is ${eff.toStringAsFixed(0)} percent. '
                          'Input: ${device['inputType']}. Useful output: ${device['usefulOutput']}. '
                          'Wasted as: ${device['wastedOutput']}.',
                        );
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // Input energy slider
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.blue, size: 18),
              const SizedBox(width: 8),
              const Text('Input Energy:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _inputEnergy,
                  min: 10,
                  max: 1000,
                  activeColor: Colors.blue,
                  onChanged: (value) => setState(() => _inputEnergy = value),
                ),
              ),
              Text(
                '${_inputEnergy.toStringAsFixed(0)} J',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),

          // Efficiency comparison
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildComparisonItem('LED', 40, Colors.white),
                _buildComparisonItem('Motor', 85, Colors.blue),
                _buildComparisonItem('Car', 25, Colors.red),
                _buildComparisonItem('Solar', 20, Colors.amber),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Key equation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Efficiency = (Useful Energy Output / Total Energy Input) × 100%',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String name, int efficiency, Color color) {
    return Column(
      children: [
        Text(name, style: const TextStyle(color: Colors.white54, fontSize: 10)),
        Text(
          '$efficiency%',
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _SankeyPainter extends CustomPainter {
  final double inputEnergy;
  final double efficiency;
  final String usefulOutput;
  final String wastedOutput;
  final String inputType;
  final Color deviceColor;
  final double animationValue;

  _SankeyPainter({
    required this.inputEnergy,
    required this.efficiency,
    required this.usefulOutput,
    required this.wastedOutput,
    required this.inputType,
    required this.deviceColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final usefulEnergy = inputEnergy * efficiency / 100;
    final wastedEnergy = inputEnergy - usefulEnergy;

    // Scale factor for arrow widths
    final maxWidth = size.height * 0.3;
    final inputWidth = maxWidth;
    final usefulWidth = maxWidth * (efficiency / 100);
    final wastedWidth = maxWidth * ((100 - efficiency) / 100);

    // Draw device box
    _drawDeviceBox(canvas, centerX, centerY);

    // Draw input arrow
    _drawInputArrow(canvas, centerX, centerY, inputWidth);

    // Draw useful output arrow
    _drawUsefulArrow(canvas, centerX, centerY, usefulWidth, usefulEnergy);

    // Draw wasted output arrow
    if (wastedEnergy > 0) {
      _drawWastedArrow(canvas, centerX, centerY, wastedWidth, wastedEnergy);
    }

    // Draw energy flow particles
    _drawEnergyParticles(canvas, size, centerX, centerY, usefulWidth, wastedWidth);

    // Draw labels
    _drawLabels(canvas, size, centerX, centerY, usefulEnergy, wastedEnergy);
  }

  void _drawDeviceBox(Canvas canvas, double centerX, double centerY) {
    final boxPaint = Paint()
      ..color = deviceColor.withAlpha(150)
      ..style = PaintingStyle.fill;

    final boxRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(centerX, centerY), width: 100, height: 80),
      const Radius.circular(10),
    );
    canvas.drawRRect(boxRect, boxPaint);

    final borderPaint = Paint()
      ..color = deviceColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(boxRect, borderPaint);

    // Device label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'DEVICE',
        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2));
  }

  void _drawInputArrow(Canvas canvas, double centerX, double centerY, double width) {
    final arrowPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final startX = 20.0;
    final endX = centerX - 50;

    final path = Path();
    path.moveTo(startX, centerY - width / 2);
    path.lineTo(endX - 20, centerY - width / 2);
    path.lineTo(endX - 20, centerY - width / 2 - 10);
    path.lineTo(endX, centerY);
    path.lineTo(endX - 20, centerY + width / 2 + 10);
    path.lineTo(endX - 20, centerY + width / 2);
    path.lineTo(startX, centerY + width / 2);
    path.close();

    canvas.drawPath(path, arrowPaint);

    // Input label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'INPUT\n${inputEnergy.toStringAsFixed(0)} J\n($inputType)',
        style: const TextStyle(color: Colors.blue, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(startX, centerY - width / 2 - 40));
  }

  void _drawUsefulArrow(Canvas canvas, double centerX, double centerY, double width, double energy) {
    final arrowPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final startX = centerX + 50;
    final endX = centerX + 150;
    final arrowY = centerY - 20;

    final path = Path();
    path.moveTo(startX, arrowY - width / 2);
    path.lineTo(endX - 20, arrowY - width / 2);
    path.lineTo(endX - 20, arrowY - width / 2 - 10);
    path.lineTo(endX, arrowY);
    path.lineTo(endX - 20, arrowY + width / 2 + 10);
    path.lineTo(endX - 20, arrowY + width / 2);
    path.lineTo(startX, arrowY + width / 2);
    path.close();

    canvas.drawPath(path, arrowPaint);

    // Useful output label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'USEFUL\n${energy.toStringAsFixed(1)} J\n($usefulOutput)',
        style: const TextStyle(color: Colors.green, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(endX + 10, arrowY - 25));
  }

  void _drawWastedArrow(Canvas canvas, double centerX, double centerY, double width, double energy) {
    final arrowPaint = Paint()
      ..color = Colors.red.withAlpha(200)
      ..style = PaintingStyle.fill;

    final startX = centerX + 50;
    final endX = centerX + 120;
    final arrowY = centerY + 50;

    // Curved downward arrow
    final path = Path();
    path.moveTo(startX, centerY + 10);
    path.quadraticBezierTo(startX + 30, centerY + 40, endX - 20, arrowY);
    path.lineTo(endX - 20, arrowY - 10);
    path.lineTo(endX, arrowY + width / 4);
    path.lineTo(endX - 20, arrowY + width / 2 + 10);
    path.lineTo(endX - 20, arrowY + width / 2);
    path.quadraticBezierTo(startX + 30, centerY + 40 + width / 2, startX, centerY + 10 + width / 2);
    path.close();

    canvas.drawPath(path, arrowPaint);

    // Wasted output label
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'WASTED\n${energy.toStringAsFixed(1)} J\n($wastedOutput)',
        style: const TextStyle(color: Colors.red, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(endX + 10, arrowY));
  }

  void _drawEnergyParticles(Canvas canvas, Size size, double centerX, double centerY,
      double usefulWidth, double wastedWidth) {
    final particlePaint = Paint();
    final random = math.Random(42);

    // Input particles
    for (var i = 0; i < 5; i++) {
      final progress = (animationValue + i * 0.2) % 1.0;
      final x = 20 + progress * (centerX - 70);
      final y = centerY + (random.nextDouble() - 0.5) * 40;

      particlePaint.color = Colors.blue.withAlpha((255 * (1 - progress * 0.5)).toInt());
      canvas.drawCircle(Offset(x, y), 4, particlePaint);
    }

    // Useful output particles
    for (var i = 0; i < (efficiency / 20).ceil(); i++) {
      final progress = (animationValue + i * 0.25) % 1.0;
      final x = centerX + 50 + progress * 100;
      final y = centerY - 20 + (random.nextDouble() - 0.5) * usefulWidth;

      particlePaint.color = Colors.green.withAlpha((255 * (1 - progress * 0.5)).toInt());
      canvas.drawCircle(Offset(x, y), 4, particlePaint);
    }

    // Wasted output particles
    if (wastedWidth > 5) {
      for (var i = 0; i < ((100 - efficiency) / 25).ceil(); i++) {
        final progress = (animationValue + i * 0.3) % 1.0;
        final x = centerX + 50 + progress * 70;
        final y = centerY + 30 + progress * 40 + (random.nextDouble() - 0.5) * wastedWidth;

        particlePaint.color = Colors.red.withAlpha((255 * (1 - progress * 0.5)).toInt());
        canvas.drawCircle(Offset(x, y), 3, particlePaint);
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size, double centerX, double centerY,
      double usefulEnergy, double wastedEnergy) {
    // Title
    final titlePainter = TextPainter(
      text: const TextSpan(
        text: 'Sankey Diagram',
        style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(canvas, Offset(size.width / 2 - titlePainter.width / 2, 10));

    // Efficiency display
    final effPainter = TextPainter(
      text: TextSpan(
        text: 'Efficiency: ${efficiency.toStringAsFixed(0)}%',
        style: const TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    effPainter.layout();
    effPainter.paint(canvas, Offset(size.width / 2 - effPainter.width / 2, size.height - 30));
  }

  @override
  bool shouldRepaint(covariant _SankeyPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.efficiency != efficiency ||
           oldDelegate.inputEnergy != inputEnergy;
  }
}
