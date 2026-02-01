import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class WaveInterferenceSimulation extends StatefulWidget {
  const WaveInterferenceSimulation({super.key});

  @override
  State<WaveInterferenceSimulation> createState() =>
      _WaveInterferenceSimulationState();
}

class _WaveInterferenceSimulationState extends State<WaveInterferenceSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _phase = 0.0;
  double _frequency1 = 2.0;
  double _frequency2 = 2.0;
  final double _amplitude1 = 40.0;
  final double _amplitude2 = 40.0;
  double _phaseDiff = 0.0;
  bool _showResult = true;
  bool _hasSpokenIntro = false;

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
          'Welcome to the Wave Interference simulation! '
          'When two waves meet, they combine by superposition. '
          'Constructive interference occurs when peaks align, creating larger amplitude. '
          'Destructive interference occurs when a peak meets a trough, cancelling out.',
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
      _phase += 0.05;
      if (_phase > 2 * math.pi) {
        _phase -= 2 * math.pi;
      }
    });
  }

  void _onPhaseDiffChanged(double value) {
    setState(() {
      _phaseDiff = value;
    });

    if (value.abs() < 0.1) {
      speakSimulation(
        'Waves are in phase. This produces constructive interference with maximum amplitude.',
      );
    } else if ((value - math.pi).abs() < 0.1) {
      speakSimulation(
        'Waves are in antiphase, 180 degrees out of phase. This produces destructive interference.',
      );
    }
  }

  String _getInterferenceType() {
    final phaseDiffNormalized = _phaseDiff % (2 * math.pi);
    if (phaseDiffNormalized < math.pi / 4 || phaseDiffNormalized > 7 * math.pi / 4) {
      return 'Constructive';
    } else if (phaseDiffNormalized > 3 * math.pi / 4 && phaseDiffNormalized < 5 * math.pi / 4) {
      return 'Destructive';
    }
    return 'Partial';
  }

  @override
  Widget build(BuildContext context) {
    final interferenceType = _getInterferenceType();

    return Column(
      children: [
        // Wave visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade700),
            ),
            child: CustomPaint(
              painter: _InterferencePainter(
                phase: _phase,
                frequency1: _frequency1,
                frequency2: _frequency2,
                amplitude1: _amplitude1,
                amplitude2: _amplitude2,
                phaseDiff: _phaseDiff,
                showResult: _showResult,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                '$interferenceType Interference',
                style: TextStyle(
                  color: interferenceType == 'Constructive'
                      ? Colors.green
                      : interferenceType == 'Destructive'
                          ? Colors.red
                          : Colors.yellow,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Phase difference: ${(_phaseDiff * 180 / math.pi).toStringAsFixed(0)}°',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const Text(
                'Superposition: y = y₁ + y₂',
                style: TextStyle(
                    color: Colors.cyan, fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Phase difference slider
                  Row(
                    children: [
                      const SizedBox(
                          width: 90,
                          child: Text('Phase Diff:',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _phaseDiff,
                          min: 0,
                          max: 2 * math.pi,
                          onChanged: _onPhaseDiffChanged,
                          activeColor: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  // Frequency sliders
                  Row(
                    children: [
                      const SizedBox(
                          width: 90,
                          child: Text('Freq 1:',
                              style: TextStyle(color: Colors.blue, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _frequency1,
                          min: 1.0,
                          max: 4.0,
                          onChanged: (v) => setState(() => _frequency1 = v),
                          activeColor: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      const SizedBox(
                          width: 90,
                          child: Text('Freq 2:',
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 12))),
                      Expanded(
                        child: Slider(
                          value: _frequency2,
                          min: 1.0,
                          max: 4.0,
                          onChanged: (v) => setState(() => _frequency2 = v),
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
                            value: _showResult,
                            onChanged: (v) =>
                                setState(() => _showResult = v ?? true),
                            activeColor: Colors.green,
                          ),
                          const Text('Show Result',
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
        ),
      ],
    );
  }
}

class _InterferencePainter extends CustomPainter {
  final double phase;
  final double frequency1;
  final double frequency2;
  final double amplitude1;
  final double amplitude2;
  final double phaseDiff;
  final bool showResult;

  _InterferencePainter({
    required this.phase,
    required this.frequency1,
    required this.frequency2,
    required this.amplitude1,
    required this.amplitude2,
    required this.phaseDiff,
    required this.showResult,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final height = size.height;
    final sectionHeight = height / (showResult ? 3 : 2);

    // Draw Wave 1
    _drawWave(
      canvas,
      size,
      0,
      sectionHeight,
      frequency1,
      amplitude1 * 0.35,
      phase,
      Colors.blue,
      'Wave 1',
    );

    // Draw Wave 2
    _drawWave(
      canvas,
      size,
      sectionHeight,
      sectionHeight,
      frequency2,
      amplitude2 * 0.35,
      phase + phaseDiff,
      Colors.orange,
      'Wave 2',
    );

    // Draw resultant wave
    if (showResult) {
      _drawResultantWave(
        canvas,
        size,
        sectionHeight * 2,
        sectionHeight,
      );
    }

    // Draw section dividers
    final dividerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, sectionHeight),
      Offset(size.width, sectionHeight),
      dividerPaint,
    );
    if (showResult) {
      canvas.drawLine(
        Offset(0, sectionHeight * 2),
        Offset(size.width, sectionHeight * 2),
        dividerPaint,
      );
    }
  }

  void _drawWave(
    Canvas canvas,
    Size size,
    double top,
    double height,
    double frequency,
    double amplitude,
    double wavePhase,
    Color color,
    String label,
  ) {
    final centerY = top + height / 2;

    // Draw center line
    final centerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerPaint,
    );

    // Draw wave
    final wavePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int x = 0; x < size.width.toInt(); x++) {
      final waveX = x / size.width * frequency * 2 * math.pi;
      final y = centerY - amplitude * math.sin(waveX - wavePhase);

      if (x == 0) {
        path.moveTo(x.toDouble(), y);
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }
    canvas.drawPath(path, wavePaint);

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, top + 5));
  }

  void _drawResultantWave(
    Canvas canvas,
    Size size,
    double top,
    double height,
  ) {
    final centerY = top + height / 2;

    // Draw center line
    final centerPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      centerPaint,
    );

    // Draw resultant wave
    final wavePaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int x = 0; x < size.width.toInt(); x++) {
      final waveX1 = x / size.width * frequency1 * 2 * math.pi;
      final waveX2 = x / size.width * frequency2 * 2 * math.pi;

      final y1 = amplitude1 * 0.35 * math.sin(waveX1 - phase);
      final y2 = amplitude2 * 0.35 * math.sin(waveX2 - phase - phaseDiff);
      final y = centerY - (y1 + y2);

      if (x == 0) {
        path.moveTo(x.toDouble(), y);
      } else {
        path.lineTo(x.toDouble(), y);
      }
    }
    canvas.drawPath(path, wavePaint);

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Resultant (y₁ + y₂)',
        style: TextStyle(color: Colors.green, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, top + 5));

    // Show amplitude comparison
    final maxAmplitude = amplitude1 * 0.35 + amplitude2 * 0.35;
    final resultAmplitude = _calculateResultantAmplitude();

    final ampText = TextPainter(
      text: TextSpan(
        text: 'Max A: ${(resultAmplitude / maxAmplitude * 100).toStringAsFixed(0)}%',
        style: const TextStyle(color: Colors.white70, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    ampText.layout();
    ampText.paint(canvas, Offset(size.width - 80, top + 5));
  }

  double _calculateResultantAmplitude() {
    // For same frequency waves: A_result = sqrt(A1² + A2² + 2*A1*A2*cos(φ))
    if ((frequency1 - frequency2).abs() < 0.01) {
      final a1 = amplitude1 * 0.35;
      final a2 = amplitude2 * 0.35;
      return math.sqrt(a1 * a1 + a2 * a2 + 2 * a1 * a2 * math.cos(phaseDiff));
    }
    // For different frequencies, just return sum (approximate max)
    return amplitude1 * 0.35 + amplitude2 * 0.35;
  }

  @override
  bool shouldRepaint(covariant _InterferencePainter oldDelegate) {
    return phase != oldDelegate.phase ||
        phaseDiff != oldDelegate.phaseDiff ||
        frequency1 != oldDelegate.frequency1 ||
        frequency2 != oldDelegate.frequency2;
  }
}
