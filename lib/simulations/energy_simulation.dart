import 'package:flutter/material.dart';
import 'simulation_tts_mixin.dart';

class EnergySimulation extends StatefulWidget {
  const EnergySimulation({super.key});

  @override
  State<EnergySimulation> createState() => _EnergySimulationState();
}

class _EnergySimulationState extends State<EnergySimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _height = 200;
  double _mass = 2.0;
  double _ballY = 50;
  double _velocity = 0;
  bool _isDropped = false;
  final double _gravity = 9.8;
  bool _hasSpokenIntro = false;
  bool _hasAnnouncedBounce = false;

  double get _maxHeight => 200;
  double get _potentialEnergy => _mass * _gravity * (_maxHeight - _ballY) / 10;
  double get _kineticEnergy => 0.5 * _mass * _velocity * _velocity / 100;
  double get _totalEnergy => _potentialEnergy + _kineticEnergy;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePhysics);

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Energy Conservation Simulation. This demonstrates how gravitational potential energy '
          'converts to kinetic energy as a ball falls. Adjust the drop height and mass using the sliders, '
          'then press Drop to release the ball. Watch the energy bars change as potential energy becomes kinetic energy.',
          force: true,
        );
      }
    });
  }

  void _updatePhysics() {
    if (!_isDropped) return;

    setState(() {
      _velocity += _gravity * 0.016 * 5;
      _ballY += _velocity * 0.016 * 5;

      // Bounce at bottom
      if (_ballY >= _maxHeight - 20) {
        _ballY = _maxHeight - 20;
        _velocity = -_velocity * 0.8; // Energy loss on bounce

        if (!_hasAnnouncedBounce) {
          _hasAnnouncedBounce = true;
          speakSimulation(
            'The ball has bounced! Some energy is lost to heat and sound on each bounce. '
            'Notice the total energy decreases slightly. This is why the ball doesn\'t bounce back to its original height.',
            force: true,
          );
        }

        if (_velocity.abs() < 2) {
          _isDropped = false;
          _controller.stop();
          _velocity = 0;
          speakSimulation(
            'The ball has come to rest. All kinetic energy has been converted to heat and sound through friction and air resistance.',
            force: true,
          );
        }
      }
    });
  }

  void _dropBall() {
    setState(() {
      _isDropped = true;
      _velocity = 0;
      _ballY = 50 + (_maxHeight - _height);
      _hasAnnouncedBounce = false;
    });
    _controller.repeat();
    speakSimulation(
      'Ball dropped! The ball starts with maximum gravitational potential energy and zero kinetic energy. '
      'As it falls, potential energy converts to kinetic energy. The formula is: potential energy equals mass times gravity times height.',
      force: true,
    );
  }

  void _resetBall() {
    _controller.stop();
    setState(() {
      _isDropped = false;
      _velocity = 0;
      _ballY = 50 + (_maxHeight - _height);
      _hasAnnouncedBounce = false;
    });
    speakSimulation('Ball reset to starting position. Adjust height or mass and drop again.', force: true);
  }

  void _onHeightChanged(double value) {
    setState(() {
      _height = value;
      if (!_isDropped) {
        _ballY = 50 + (_maxHeight - _height);
      }
    });
    speakSimulation(
      'Drop height set to ${value.toInt()} pixels. A higher drop means more gravitational potential energy at the start.',
    );
  }

  void _onMassChanged(double value) {
    setState(() => _mass = value);
    speakSimulation(
      'Mass set to ${value.toStringAsFixed(1)} kilograms. '
      'Greater mass means more potential and kinetic energy, but the ball still falls at the same rate due to gravity.',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Energy display
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildEnergyCard('PE', _potentialEnergy, Colors.blue),
              _buildEnergyCard('KE', _kineticEnergy, Colors.red),
              _buildEnergyCard('Total', _totalEnergy, Colors.green),
            ],
          ),
        ),
        // Simulation area
        Expanded(
          child: Row(
            children: [
              // Animation area
              Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: CustomPaint(
                    painter: EnergyPainter(
                      ballY: _ballY,
                      mass: _mass,
                      maxHeight: _maxHeight,
                      height: _height,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
              // Energy bar chart
              Container(
                width: 100,
                margin: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Energy',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildEnergyBar('PE', _potentialEnergy, _totalEnergy, Colors.blue),
                          _buildEnergyBar('KE', _kineticEnergy, _totalEnergy, Colors.red),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [buildTTSToggle()],
              ),
              _buildSlider(
                'Drop Height',
                _height,
                50,
                200,
                '${_height.toInt()} px',
                _onHeightChanged,
                Colors.orange,
              ),
              _buildSlider(
                'Mass',
                _mass,
                1,
                5,
                '${_mass.toStringAsFixed(1)} kg',
                _onMassChanged,
                Colors.purple,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isDropped ? null : _dropBall,
                    icon: const Icon(Icons.arrow_downward),
                    label: const Text('Drop'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _resetBall,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Energy Conservation',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'GPE = mgh    KE = ½mv²',
                      style: TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace'),
                    ),
                    Text(
                      'Total Energy ≈ ${_totalEnergy.toStringAsFixed(1)} J (with losses)',
                      style: const TextStyle(color: Colors.green, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnergyCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            '${value.toStringAsFixed(1)} J',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildEnergyBar(String label, double value, double maxValue, Color color) {
    final height = maxValue > 0 ? (value / maxValue * 150).clamp(0.0, 150.0) : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10)),
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
    return Row(
      children: [
        SizedBox(
          width: 90,
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
              onChanged: _isDropped ? null : onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 60,
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

class EnergyPainter extends CustomPainter {
  final double ballY;
  final double mass;
  final double maxHeight;
  final double height;

  EnergyPainter({
    required this.ballY,
    required this.mass,
    required this.maxHeight,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;

    // Draw ground
    final groundPaint = Paint()
      ..color = Colors.brown.withValues(alpha: 0.5)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(20, size.height - 30),
      Offset(size.width - 20, size.height - 30),
      groundPaint,
    );

    // Draw height ruler
    final rulerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(40, 50),
      Offset(40, size.height - 30),
      rulerPaint,
    );

    // Height markers
    for (int i = 0; i <= 4; i++) {
      final y = 50 + i * (size.height - 80) / 4;
      canvas.drawLine(Offset(35, y), Offset(45, y), rulerPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${((4 - i) * 50).toInt()}',
          style: const TextStyle(color: Colors.white38, fontSize: 9),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(15, y - 5));
    }

    // Draw initial height indicator
    final startY = 50 + (maxHeight - height);
    final indicatorPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dashPath = Path();
    for (double x = 40; x < size.width - 40; x += 10) {
      dashPath.moveTo(x, startY);
      dashPath.lineTo(x + 5, startY);
    }
    canvas.drawPath(dashPath, indicatorPaint);

    // Draw ball
    final ballRadius = 10 + mass * 3;
    final ballPaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.orange.shade300, Colors.orange.shade700],
      ).createShader(Rect.fromCircle(
        center: Offset(centerX, ballY + 20),
        radius: ballRadius,
      ));

    canvas.drawCircle(Offset(centerX, ballY + 20), ballRadius, ballPaint);

    // Ball highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3);
    canvas.drawCircle(
      Offset(centerX - ballRadius / 3, ballY + 20 - ballRadius / 3),
      ballRadius / 3,
      highlightPaint,
    );

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'h = ${((maxHeight - ballY) / 10).toStringAsFixed(1)} m',
      style: const TextStyle(color: Colors.cyan, fontSize: 11),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX + ballRadius + 10, ballY + 15));
  }

  @override
  bool shouldRepaint(covariant EnergyPainter oldDelegate) {
    return oldDelegate.ballY != ballY ||
        oldDelegate.mass != mass ||
        oldDelegate.height != height;
  }
}
