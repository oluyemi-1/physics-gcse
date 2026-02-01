import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class SoundWavesSimulation extends StatefulWidget {
  const SoundWavesSimulation({super.key});

  @override
  State<SoundWavesSimulation> createState() => _SoundWavesSimulationState();
}

class _SoundWavesSimulationState extends State<SoundWavesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _frequency = 2.0; // Hz (visual representation)
  double _amplitude = 50.0;
  double _phase = 0.0;
  bool _showCompression = true;
  bool _showWaveform = true;
  bool _hasSpokenIntro = false;

  String _selectedMedium = 'Air';
  final Map<String, double> _mediumSpeeds = {
    'Air': 343.0,
    'Water': 1480.0,
    'Steel': 5960.0,
    'Vacuum': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePhase);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Sound Waves simulation! '
          'Sound is a longitudinal wave that travels through a medium by compression and rarefaction. '
          'Particles vibrate back and forth in the same direction as the wave travels. '
          'Notice how the compressions and rarefactions create the wave pattern.',
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

  void _updatePhase() {
    setState(() {
      _phase += 0.05 * _frequency;
      if (_phase > 2 * math.pi) {
        _phase -= 2 * math.pi;
      }
    });
  }

  void _onFrequencyChanged(double value) {
    setState(() {
      _frequency = value;
    });

    if (value > 3.5) {
      speakSimulation(
        'Higher frequency means more compressions per second. '
        'This corresponds to a higher pitched sound.',
      );
    } else if (value < 1.0) {
      speakSimulation(
        'Lower frequency means fewer compressions per second. '
        'This corresponds to a lower pitched sound.',
      );
    }
  }

  void _onAmplitudeChanged(double value) {
    setState(() {
      _amplitude = value;
    });

    if (value > 70) {
      speakSimulation(
        'Higher amplitude means particles move further from their rest position. '
        'This corresponds to a louder sound.',
      );
    }
  }

  void _onMediumChanged(String? medium) {
    if (medium == null) return;
    setState(() {
      _selectedMedium = medium;
    });

    final speed = _mediumSpeeds[medium]!;
    if (speed == 0) {
      speakSimulation(
        'Sound cannot travel through a vacuum because there are no particles to vibrate.',
        force: true,
      );
    } else {
      speakSimulation(
        'In $medium, sound travels at $speed metres per second. '
        'Sound travels faster in denser materials because particles are closer together.',
        force: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final speed = _mediumSpeeds[_selectedMedium]!;
    final wavelength = speed > 0 ? speed / (_frequency * 100) : 0.0;

    return Column(
      children: [
        // Compression visualization
        if (_showCompression)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade700),
              ),
              child: speed > 0
                  ? CustomPaint(
                      painter: _CompressionPainter(
                        phase: _phase,
                        frequency: _frequency,
                        amplitude: _amplitude,
                      ),
                      size: Size.infinite,
                    )
                  : const Center(
                      child: Text(
                        'No sound propagation in vacuum',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
            ),
          ),

        // Waveform visualization
        if (_showWaveform)
          Expanded(
            flex: 1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade900),
              ),
              child: speed > 0
                  ? CustomPaint(
                      painter: _WaveformPainter(
                        phase: _phase,
                        frequency: _frequency,
                        amplitude: _amplitude,
                      ),
                      size: Size.infinite,
                    )
                  : const SizedBox(),
            ),
          ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                'Sound Wave in $_selectedMedium',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    'Speed: ${speed.toStringAsFixed(0)} m/s',
                    style:
                        const TextStyle(color: Colors.cyan, fontSize: 12),
                  ),
                  Text(
                    'λ: ${wavelength.toStringAsFixed(2)} m',
                    style:
                        const TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ],
              ),
              const Text(
                'v = f × λ',
                style: TextStyle(
                    color: Colors.white70, fontFamily: 'monospace', fontSize: 12),
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
                // Medium selector
                Row(
                  children: [
                    const Text('Medium: ',
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedMedium,
                        dropdownColor: Colors.grey[800],
                        isExpanded: true,
                        items: _mediumSpeeds.keys.map((medium) {
                          return DropdownMenuItem(
                            value: medium,
                            child: Text(medium,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: _onMediumChanged,
                      ),
                    ),
                  ],
                ),

                // Frequency slider
                Row(
                  children: [
                    const SizedBox(
                        width: 90,
                        child: Text('Frequency:',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _frequency,
                        min: 0.5,
                        max: 5.0,
                        onChanged: _onFrequencyChanged,
                        activeColor: Colors.green,
                      ),
                    ),
                  ],
                ),

                // Amplitude slider
                Row(
                  children: [
                    const SizedBox(
                        width: 90,
                        child: Text('Amplitude:',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12))),
                    Expanded(
                      child: Slider(
                        value: _amplitude,
                        min: 20,
                        max: 80,
                        onChanged: _onAmplitudeChanged,
                        activeColor: Colors.orange,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Checkbox(
                          value: _showCompression,
                          onChanged: (v) =>
                              setState(() => _showCompression = v ?? true),
                          activeColor: Colors.green,
                        ),
                        const Text('Particles',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(width: 8),
                        Checkbox(
                          value: _showWaveform,
                          onChanged: (v) =>
                              setState(() => _showWaveform = v ?? true),
                          activeColor: Colors.cyan,
                        ),
                        const Text('Waveform',
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                      ],
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
}

class _CompressionPainter extends CustomPainter {
  final double phase;
  final double frequency;
  final double amplitude;

  _CompressionPainter({
    required this.phase,
    required this.frequency,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    const particleRadius = 8.0;
    const rows = 3;
    const cols = 25;

    final particlePaint = Paint()..color = Colors.green;

    // Draw speaker
    final speakerPaint = Paint()
      ..color = Colors.grey[700]!
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, centerY - 40, 20, 80),
      speakerPaint,
    );

    // Speaker cone movement
    final coneOffset = math.sin(phase) * 5;
    canvas.drawRect(
      Rect.fromLTWH(15 + coneOffset, centerY - 30, 10, 60),
      Paint()..color = Colors.grey[500]!,
    );

    // Draw particles
    for (int row = 0; row < rows; row++) {
      final rowY = centerY - 30 + row * 30;

      for (int col = 0; col < cols; col++) {
        // Base x position
        final baseX = 50.0 + col * ((size.width - 60) / cols);

        // Calculate displacement based on wave
        final distanceFromSource = col / cols;
        final wavePhase = phase - distanceFromSource * frequency * 2 * math.pi;
        final displacement = math.sin(wavePhase) * (amplitude / 5);

        final x = baseX + displacement;

        // Color based on compression/rarefaction
        final compressionFactor = math.sin(wavePhase);
        Color color;
        if (compressionFactor > 0.3) {
          color = Colors.green.shade300; // Compression
        } else if (compressionFactor < -0.3) {
          color = Colors.green.shade800; // Rarefaction
        } else {
          color = Colors.green;
        }

        particlePaint.color = color;
        canvas.drawCircle(Offset(x, rowY), particleRadius, particlePaint);
      }
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Find compression and rarefaction points
    for (int i = 0; i < 3; i++) {
      final labelX = 80.0 + i * (size.width - 100) / 3;
      final wavePhase = phase - (labelX - 50) / (size.width - 60) * frequency * 2 * math.pi;
      final compressionFactor = math.sin(wavePhase);

      if (compressionFactor > 0.7) {
        textPainter.text = const TextSpan(
          text: 'Compression',
          style: TextStyle(color: Colors.white70, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(labelX - 30, size.height - 25));
      } else if (compressionFactor < -0.7) {
        textPainter.text = const TextSpan(
          text: 'Rarefaction',
          style: TextStyle(color: Colors.white70, fontSize: 10),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(labelX - 28, size.height - 25));
      }
    }

    // Direction arrow
    final arrowPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width - 60, 15),
      Offset(size.width - 20, 15),
      arrowPaint,
    );
    final arrowHead = Path()
      ..moveTo(size.width - 20, 15)
      ..lineTo(size.width - 30, 10)
      ..lineTo(size.width - 30, 20)
      ..close();
    canvas.drawPath(arrowHead, arrowPaint..style = PaintingStyle.fill);

    textPainter.text = const TextSpan(
      text: 'Wave direction',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 100, 5));
  }

  @override
  bool shouldRepaint(covariant _CompressionPainter oldDelegate) {
    return phase != oldDelegate.phase;
  }
}

class _WaveformPainter extends CustomPainter {
  final double phase;
  final double frequency;
  final double amplitude;

  _WaveformPainter({
    required this.phase,
    required this.frequency,
    required this.amplitude,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;

    // Draw axis
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      axisPaint,
    );

    // Draw waveform
    final wavePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int x = 0; x < size.width.toInt(); x++) {
      final waveX = x / size.width;
      final wavePhase = phase - waveX * frequency * 2 * math.pi;
      final y = centerY - math.sin(wavePhase) * (amplitude * 0.4);

      if (x == 0) {
        path.moveTo(x.toDouble(), y);
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }
    canvas.drawPath(path, wavePaint);

    // Draw wavelength marker
    final wavelength = size.width / frequency;
    if (wavelength < size.width - 20) {
      final markerPaint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 2;

      final startX = 20.0;
      final markerY = size.height - 15;

      canvas.drawLine(
        Offset(startX, markerY),
        Offset(startX + wavelength, markerY),
        markerPaint,
      );

      // End caps
      canvas.drawLine(
        Offset(startX, markerY - 5),
        Offset(startX, markerY + 5),
        markerPaint,
      );
      canvas.drawLine(
        Offset(startX + wavelength, markerY - 5),
        Offset(startX + wavelength, markerY + 5),
        markerPaint,
      );

      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'λ (wavelength)',
          style: TextStyle(color: Colors.orange, fontSize: 10),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + wavelength / 2 - 30, markerY - 15));
    }

    // Amplitude marker
    final ampPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(10, centerY),
      Offset(10, centerY - amplitude * 0.4),
      ampPaint,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'A',
        style: TextStyle(color: Colors.cyan, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(2, centerY - amplitude * 0.2 - 5));
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return phase != oldDelegate.phase;
  }
}
