import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class WaveSimulation extends StatefulWidget {
  const WaveSimulation({super.key});

  @override
  State<WaveSimulation> createState() => _WaveSimulationState();
}

class _WaveSimulationState extends State<WaveSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  double _frequency = 1.0;
  double _amplitude = 50.0;
  double _wavelength = 100.0;
  bool _isTransverse = true;
  bool _hasSpokenIntro = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Speak introduction after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Wave Simulation. You can see a transverse wave moving across the screen. '
          'Use the sliders to change the frequency, amplitude, and wavelength. '
          'Toggle between transverse and longitudinal waves using the buttons above.',
          force: true,
        );
      }
    });
  }

  void _onWaveTypeChanged(bool isTransverse) {
    setState(() => _isTransverse = isTransverse);
    if (isTransverse) {
      speakSimulation(
        'Transverse wave selected. In transverse waves, particles vibrate perpendicular to the direction '
        'of energy transfer. Examples include light waves and water ripples.',
        force: true,
      );
    } else {
      speakSimulation(
        'Longitudinal wave selected. In longitudinal waves, particles vibrate parallel to the direction '
        'of energy transfer. Sound waves are an example. Notice the compressions and rarefactions.',
        force: true,
      );
    }
  }

  void _onFrequencyChanged(double value) {
    setState(() => _frequency = value);
    if (value < 1.0) {
      speakSimulation('Low frequency. The wave oscillates slowly with fewer cycles per second.');
    } else if (value > 2.0) {
      speakSimulation('High frequency. The wave oscillates rapidly with more cycles per second.');
    } else {
      speakSimulation('Frequency set to ${value.toStringAsFixed(1)} Hertz.');
    }
  }

  void _onAmplitudeChanged(double value) {
    setState(() => _amplitude = value);
    if (value < 35) {
      speakSimulation('Small amplitude. The wave has low energy and particles move a short distance.');
    } else if (value > 65) {
      speakSimulation('Large amplitude. The wave has high energy and particles move a greater distance.');
    } else {
      speakSimulation('Amplitude set to ${value.toInt()} units.');
    }
  }

  void _onWavelengthChanged(double value) {
    setState(() => _wavelength = value);
    if (value < 80) {
      speakSimulation('Short wavelength. The distance between wave peaks is small.');
    } else if (value > 150) {
      speakSimulation('Long wavelength. The distance between wave peaks is large.');
    } else {
      speakSimulation('Wavelength set to ${value.toInt()} units.');
    }
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
        // TTS toggle and wave type toggle
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTTSToggle(),
              const SizedBox(width: 8),
              _buildToggleButton('Transverse', _isTransverse, () {
                _onWaveTypeChanged(true);
              }),
              const SizedBox(width: 16),
              _buildToggleButton('Longitudinal', !_isTransverse, () {
                _onWaveTypeChanged(false);
              }),
            ],
          ),
        ),
        // Wave display
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _isTransverse
                    ? TransverseWavePainter(
                        phase: _controller.value * 2 * math.pi,
                        frequency: _frequency,
                        amplitude: _amplitude,
                        wavelength: _wavelength,
                      )
                    : LongitudinalWavePainter(
                        phase: _controller.value * 2 * math.pi,
                        frequency: _frequency,
                        wavelength: _wavelength,
                      ),
                size: Size.infinite,
              );
            },
          ),
        ),
        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _buildSlider(
                'Frequency',
                _frequency,
                0.5,
                3.0,
                '${_frequency.toStringAsFixed(1)} Hz',
                _onFrequencyChanged,
                Colors.blue,
              ),
              _buildSlider(
                'Amplitude',
                _amplitude,
                20,
                80,
                '${_amplitude.toInt()} px',
                _onAmplitudeChanged,
                Colors.green,
              ),
              _buildSlider(
                'Wavelength',
                _wavelength,
                50,
                200,
                '${_wavelength.toInt()} px',
                _onWavelengthChanged,
                Colors.orange,
              ),
              const SizedBox(height: 8),
              // Info display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildInfoItem('Wave Speed', '${(_frequency * _wavelength).toInt()} px/s'),
                    _buildInfoItem('Period', '${(1 / _frequency).toStringAsFixed(2)} s'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
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
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500),
            ),
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
            width: 70,
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

class TransverseWavePainter extends CustomPainter {
  final double phase;
  final double frequency;
  final double amplitude;
  final double wavelength;

  TransverseWavePainter({
    required this.phase,
    required this.frequency,
    required this.amplitude,
    required this.wavelength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool first = true;

    // Draw wave
    for (double x = 0; x < size.width; x += 2) {
      final y = centerY + amplitude * math.sin((x / wavelength) * 2 * math.pi - phase * frequency);
      if (first) {
        path.moveTo(x, y);
        first = false;
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);

    // Draw center line
    final centerLinePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerLinePaint,
    );

    // Draw amplitude indicator
    final indicatorPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(50, centerY),
      Offset(50, centerY - amplitude),
      indicatorPaint,
    );
    canvas.drawLine(
      Offset(45, centerY - amplitude),
      Offset(55, centerY - amplitude),
      indicatorPaint,
    );

    // Draw wavelength indicator
    final wavelengthPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2;
    final waveY = centerY + 70;
    canvas.drawLine(
      Offset(100, waveY),
      Offset(100 + wavelength, waveY),
      wavelengthPaint,
    );
    canvas.drawLine(
      Offset(100, waveY - 5),
      Offset(100, waveY + 5),
      wavelengthPaint,
    );
    canvas.drawLine(
      Offset(100 + wavelength, waveY - 5),
      Offset(100 + wavelength, waveY + 5),
      wavelengthPaint,
    );

    // Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'A',
      style: TextStyle(color: Colors.green, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(55, centerY - amplitude / 2 - 6));

    textPainter.text = const TextSpan(
      text: 'λ',
      style: TextStyle(color: Colors.orange, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(100 + wavelength / 2 - 4, waveY + 5));
  }

  @override
  bool shouldRepaint(covariant TransverseWavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.frequency != frequency ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.wavelength != wavelength;
  }
}

class LongitudinalWavePainter extends CustomPainter {
  final double phase;
  final double frequency;
  final double wavelength;

  LongitudinalWavePainter({
    required this.phase,
    required this.frequency,
    required this.wavelength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final paint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2;

    // Draw particles
    for (double baseX = 20; baseX < size.width - 20; baseX += 15) {
      final displacement = 10 * math.sin((baseX / wavelength) * 2 * math.pi - phase * frequency);
      final x = baseX + displacement;

      // Density visualization
      final density = 1 + 0.5 * math.cos((baseX / wavelength) * 2 * math.pi - phase * frequency);
      final radius = 4 * density;

      canvas.drawCircle(
        Offset(x, centerY),
        radius,
        paint..color = Colors.cyan.withValues(alpha: density.clamp(0.3, 1.0)),
      );
    }

    // Draw compression/rarefaction labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    textPainter.text = const TextSpan(
      text: 'Compression',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 4 - 30, centerY + 40));

    textPainter.text = const TextSpan(
      text: 'Rarefaction',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 4 + wavelength / 2 - 25, centerY + 40));

    // Draw arrow showing direction
    final arrowPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width / 2 - 50, centerY - 60),
      Offset(size.width / 2 + 50, centerY - 60),
      arrowPaint,
    );
    // Arrow head
    canvas.drawLine(
      Offset(size.width / 2 + 50, centerY - 60),
      Offset(size.width / 2 + 40, centerY - 65),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2 + 50, centerY - 60),
      Offset(size.width / 2 + 40, centerY - 55),
      arrowPaint,
    );

    textPainter.text = const TextSpan(
      text: 'Direction of wave',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - 40, centerY - 80));
  }

  @override
  bool shouldRepaint(covariant LongitudinalWavePainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.frequency != frequency ||
        oldDelegate.wavelength != wavelength;
  }
}
