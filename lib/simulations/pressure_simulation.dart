import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class PressureSimulation extends StatefulWidget {
  const PressureSimulation({super.key});

  @override
  State<PressureSimulation> createState() => _PressureSimulationState();
}

class _PressureSimulationState extends State<PressureSimulation>
    with SimulationTTSMixin {
  double _force = 100;
  double _area = 0.1;
  String _mode = 'basic'; // 'basic', 'liquid', 'examples'

  double get _pressure => _force / _area;

  // Liquid pressure
  double _depth = 5;
  double _density = 1000; // water
  final double _gravity = 10;

  double get _liquidPressure => _density * _gravity * _depth;

  bool _hasSpokenIntro = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Pressure Simulation. Pressure equals force divided by area. '
          'Explore three modes: basic pressure calculation, liquid pressure which increases with depth, '
          'and real-world examples showing how area affects pressure.',
          force: true,
        );
      }
    });
  }

  void _onModeChanged(String mode) {
    setState(() => _mode = mode);
    switch (mode) {
      case 'basic':
        speakSimulation(
          'Basic pressure mode. Pressure equals force divided by area. '
          'Increase the force to increase pressure. Increase the area to decrease pressure.',
          force: true,
        );
        break;
      case 'liquid':
        speakSimulation(
          'Liquid pressure mode. In liquids, pressure increases with depth. '
          'The formula is: pressure equals density times gravity times depth. '
          'Try different liquids to see how density affects pressure.',
          force: true,
        );
        break;
      case 'examples':
        speakSimulation(
          'Real world examples. See how different objects use area to control pressure. '
          'Sharp knives have small areas for high pressure. Snowshoes have large areas for low pressure.',
          force: true,
        );
        break;
    }
  }

  void _onForceChanged(double value) {
    setState(() => _force = value);
    speakSimulation(
      'Force set to ${value.toInt()} Newtons. Pressure is now ${_pressure.toStringAsFixed(0)} Pascals.',
    );
  }

  void _onAreaChanged(double value) {
    setState(() => _area = value);
    speakSimulation(
      'Area set to ${value.toStringAsFixed(2)} square meters. '
      '${value < 0.1 ? "Small area means high pressure." : value > 0.5 ? "Large area means low pressure." : ""} '
      'Pressure is now ${_pressure.toStringAsFixed(0)} Pascals.',
    );
  }

  void _onDepthChanged(double value) {
    setState(() => _depth = value);
    speakSimulation(
      'Depth set to ${value.toStringAsFixed(1)} meters. '
      'Pressure at this depth is ${_liquidPressure.toStringAsFixed(0)} Pascals or ${(_liquidPressure / 1000).toStringAsFixed(1)} kilopascals.',
    );
  }

  void _onLiquidChanged(double density, String name) {
    setState(() => _density = density);
    speakSimulation(
      '$name selected with density ${density.toInt()} kilograms per cubic meter. '
      '${name == "Mercury" ? "Mercury is very dense, so pressure increases rapidly with depth." : ""}'
      'Pressure at current depth is ${_liquidPressure.toStringAsFixed(0)} Pascals.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode selector
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTTSToggle(),
              const SizedBox(width: 8),
              _buildModeButton('Basic P=F/A', 'basic'),
              const SizedBox(width: 12),
              _buildModeButton('Liquid Pressure', 'liquid'),
              const SizedBox(width: 12),
              _buildModeButton('Examples', 'examples'),
            ],
          ),
        ),
        // Simulation area
        Expanded(
          child: _mode == 'basic'
              ? _buildBasicPressure()
              : _mode == 'liquid'
                  ? _buildLiquidPressure()
                  : _buildExamples(),
        ),
      ],
    );
  }

  Widget _buildModeButton(String label, String mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () => _onModeChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBasicPressure() {
    return Column(
      children: [
        // Visualization
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: BasicPressurePainter(
                force: _force,
                area: _area,
                pressure: _pressure,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        // Pressure result
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.teal.withValues(alpha: 0.3),
                Colors.blue.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Pressure = Force ÷ Area',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'P = ${_force.toInt()} N ÷ ${_area.toStringAsFixed(2)} m²',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '= ${_pressure.toStringAsFixed(0)} Pa',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(${(_pressure / 1000).toStringAsFixed(2)} kPa)',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSlider(
                'Force',
                _force,
                10,
                500,
                '${_force.toInt()} N',
                _onForceChanged,
                Colors.orange,
              ),
              _buildSlider(
                'Area',
                _area,
                0.01,
                1.0,
                '${_area.toStringAsFixed(2)} m²',
                _onAreaChanged,
                Colors.green,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidPressure() {
    return Column(
      children: [
        // Visualization
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              painter: LiquidPressurePainter(
                depth: _depth,
                density: _density,
                pressure: _liquidPressure,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        // Pressure result
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue.withValues(alpha: 0.3),
                Colors.indigo.withValues(alpha: 0.3),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Liquid Pressure = ρ × g × h',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'P = ${_density.toInt()} × $_gravity × ${_depth.toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                '= ${_liquidPressure.toStringAsFixed(0)} Pa',
                style: const TextStyle(
                  color: Colors.cyan,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '(${(_liquidPressure / 1000).toStringAsFixed(1)} kPa)',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSlider(
                'Depth',
                _depth,
                0.5,
                20,
                '${_depth.toStringAsFixed(1)} m',
                _onDepthChanged,
                Colors.cyan,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLiquidButton('Water', 1000, Colors.blue),
                  const SizedBox(width: 12),
                  _buildLiquidButton('Oil', 800, Colors.amber),
                  const SizedBox(width: 12),
                  _buildLiquidButton('Mercury', 13600, Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLiquidButton(String label, double density, Color color) {
    final isSelected = _density == density;
    return GestureDetector(
      onTap: () => _onLiquidChanged(density, label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              '${density.toInt()} kg/m³',
              style: TextStyle(
                color: isSelected ? Colors.white70 : color.withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamples() {
    final examples = [
      PressureExample(
        'Sharp Knife',
        'Small area = High pressure = Cuts easily',
        50,
        0.0001,
        Icons.content_cut,
        Colors.red,
      ),
      PressureExample(
        'Snowshoes',
        'Large area = Low pressure = Don\'t sink',
        700,
        0.3,
        Icons.downhill_skiing,
        Colors.cyan,
      ),
      PressureExample(
        'High Heels',
        'Tiny area = Very high pressure',
        500,
        0.0002,
        Icons.accessibility,
        Colors.pink,
      ),
      PressureExample(
        'Flat Shoes',
        'Larger area = Lower pressure',
        500,
        0.02,
        Icons.directions_walk,
        Colors.green,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: examples.length,
      itemBuilder: (context, index) {
        final example = examples[index];
        final pressure = example.force / example.area;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: example.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: example.color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: example.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(example.icon, color: example.color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      example.name,
                      style: TextStyle(
                        color: example.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      example.description,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'F=${example.force}N, A=${example.area}m²',
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    (pressure / 1000).toStringAsFixed(0),
                    style: TextStyle(
                      color: example.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const Text(
                    'kPa',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
          width: 60,
          child: Text(label, style: TextStyle(color: color, fontSize: 13)),
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

class PressureExample {
  final String name;
  final String description;
  final double force;
  final double area;
  final IconData icon;
  final Color color;

  PressureExample(
    this.name,
    this.description,
    this.force,
    this.area,
    this.icon,
    this.color,
  );
}

class BasicPressurePainter extends CustomPainter {
  final double force;
  final double area;
  final double pressure;

  BasicPressurePainter({
    required this.force,
    required this.area,
    required this.pressure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw surface
    final surfaceWidth = 50 + area * 150;
    final surfacePaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.7);

    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 50),
        width: surfaceWidth,
        height: 30,
      ),
      surfacePaint,
    );

    // Draw force arrow
    final arrowLength = 30 + force / 10;
    final arrowPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(centerX, centerY - 80),
      Offset(centerX, centerY + 30),
      arrowPaint,
    );

    // Arrow head
    canvas.drawLine(
      Offset(centerX, centerY + 30),
      Offset(centerX - 10, centerY + 15),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerY + 30),
      Offset(centerX + 10, centerY + 15),
      arrowPaint,
    );

    // Pressure indicators (arrows going into surface)
    final numArrows = (pressure / 500).clamp(3, 15).toInt();
    final pressurePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2;

    for (int i = 0; i < numArrows; i++) {
      final x = centerX - surfaceWidth / 2 + 10 + i * (surfaceWidth - 20) / (numArrows - 1);
      canvas.drawLine(
        Offset(x, centerY + 70),
        Offset(x, centerY + 90),
        pressurePaint,
      );
      canvas.drawLine(
        Offset(x, centerY + 70),
        Offset(x - 4, centerY + 78),
        pressurePaint,
      );
      canvas.drawLine(
        Offset(x, centerY + 70),
        Offset(x + 4, centerY + 78),
        pressurePaint,
      );
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'Force = ${force.toInt()} N',
      style: const TextStyle(color: Colors.orange, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 15, centerY - 50));

    textPainter.text = TextSpan(
      text: 'Area = ${area.toStringAsFixed(2)} m²',
      style: const TextStyle(color: Colors.green, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - surfaceWidth / 2, centerY + 85));

    // Draw area indicator
    final areaPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(centerX, centerY + 50),
        width: surfaceWidth,
        height: 30,
      ),
      areaPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BasicPressurePainter oldDelegate) {
    return oldDelegate.force != force ||
        oldDelegate.area != area ||
        oldDelegate.pressure != pressure;
  }
}

class LiquidPressurePainter extends CustomPainter {
  final double depth;
  final double density;
  final double pressure;

  LiquidPressurePainter({
    required this.depth,
    required this.density,
    required this.pressure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Draw container
    final containerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(centerX - 60, 30, 120, size.height - 60),
      containerPaint,
    );

    // Draw water
    final waterHeight = (depth / 20) * (size.height - 90);
    final waterGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.blue.withValues(alpha: 0.3),
        Colors.blue.withValues(alpha: 0.8),
      ],
    );

    final waterPaint = Paint()
      ..shader = waterGradient.createShader(
        Rect.fromLTWH(centerX - 58, size.height - 32 - waterHeight, 116, waterHeight),
      );

    canvas.drawRect(
      Rect.fromLTWH(centerX - 58, size.height - 32 - waterHeight, 116, waterHeight),
      waterPaint,
    );

    // Draw depth marker
    final markerPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(centerX - 80, size.height - 30),
      Offset(centerX - 80, size.height - 30 - waterHeight),
      markerPaint,
    );
    canvas.drawLine(
      Offset(centerX - 85, size.height - 30),
      Offset(centerX - 75, size.height - 30),
      markerPaint,
    );
    canvas.drawLine(
      Offset(centerX - 85, size.height - 30 - waterHeight),
      Offset(centerX - 75, size.height - 30 - waterHeight),
      markerPaint,
    );

    // Draw pressure arrows at bottom
    final arrowPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final x = centerX - 40 + i * 20.0;
      final arrowSize = (pressure / 50000 * 20).clamp(5, 25);

      canvas.drawLine(
        Offset(x, size.height - 35),
        Offset(x, size.height - 35 + arrowSize),
        arrowPaint,
      );
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'h = ${depth.toStringAsFixed(1)} m',
      style: const TextStyle(color: Colors.cyan, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 110, size.height - 30 - waterHeight / 2 - 6));

    textPainter.text = const TextSpan(
      text: 'Pressure increases\nwith depth',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + 70, size.height / 2));
  }

  @override
  bool shouldRepaint(covariant LiquidPressurePainter oldDelegate) {
    return oldDelegate.depth != depth ||
        oldDelegate.density != density ||
        oldDelegate.pressure != pressure;
  }
}
