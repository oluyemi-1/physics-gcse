import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

/// Standing Waves Simulation demonstrating stationary wave patterns
/// Shows nodes, antinodes, and harmonics on strings and in pipes
class StandingWavesSimulation extends StatefulWidget {
  const StandingWavesSimulation({super.key});

  @override
  State<StandingWavesSimulation> createState() => _StandingWavesSimulationState();
}

class _StandingWavesSimulationState extends State<StandingWavesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  int _harmonic = 1; // 1st, 2nd, 3rd harmonic etc.
  double _amplitude = 30.0;
  double _time = 0.0;
  String _systemType = 'String (fixed ends)';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _time += 0.03;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Standing Waves Simulation. Standing waves form when two identical waves '
        'travel in opposite directions and interfere. Points that don\'t move are called nodes, '
        'and points of maximum displacement are antinodes. '
        'The first harmonic is the fundamental frequency.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _numNodes {
    if (_systemType == 'String (fixed ends)') {
      return _harmonic + 1;
    } else if (_systemType == 'Open Pipe') {
      return _harmonic - 1;
    } else {
      // Closed pipe (one end closed)
      return (_harmonic + 1) ~/ 2;
    }
  }

  int get _numAntinodes {
    if (_systemType == 'String (fixed ends)') {
      return _harmonic;
    } else if (_systemType == 'Open Pipe') {
      return _harmonic;
    } else {
      return (_harmonic + 1) ~/ 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standing Waves'),
        backgroundColor: Colors.cyan.shade800,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.cyan.shade900, Colors.black],
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
        border: Border.all(color: Colors.cyan.shade300),
      ),
      child: Column(
        children: [
          Text(
            '$_systemType - ${_getHarmonicName()} Harmonic',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Harmonic', '$_harmonic${_getOrdinalSuffix(_harmonic)}'),
              _buildInfoItem('Nodes', '$_numNodes', Colors.red),
              _buildInfoItem('Antinodes', '$_numAntinodes', Colors.green),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getFrequencyInfo(),
              style: const TextStyle(color: Colors.amber, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getHarmonicName() {
    switch (_harmonic) {
      case 1:
        return '1st (Fundamental)';
      case 2:
        return '2nd';
      case 3:
        return '3rd';
      default:
        return '${_harmonic}th';
    }
  }

  String _getOrdinalSuffix(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _getFrequencyInfo() {
    if (_systemType == 'String (fixed ends)') {
      return 'fₙ = n × f₁  |  λₙ = 2L/n  |  Frequency = $_harmonic × fundamental';
    } else if (_systemType == 'Open Pipe') {
      return 'fₙ = n × f₁  |  All harmonics present';
    } else {
      return 'fₙ = n × f₁ (odd n only)  |  Only odd harmonics';
    }
  }

  Widget _buildInfoItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
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
          painter: _StandingWavesPainter(
            harmonic: _harmonic,
            amplitude: _amplitude,
            time: _time,
            systemType: _systemType,
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
          // System type selector
          Wrap(
            spacing: 8,
            children: ['String (fixed ends)', 'Open Pipe', 'Closed Pipe'].map((type) {
              return ChoiceChip(
                label: Text(type, style: const TextStyle(fontSize: 10)),
                selected: _systemType == type,
                selectedColor: Colors.cyan.shade400,
                onSelected: (selected) {
                  if (selected) {
                    context.read<SoundProvider>().playClick();
                    setState(() {
                      _systemType = type;
                      // Closed pipe only supports odd harmonics
                      if (type == 'Closed Pipe' && _harmonic % 2 == 0) {
                        _harmonic = 1;
                      }
                    });
                    speakSimulation(
                      '$type selected. ${type == "String (fixed ends)" ? "Both ends are nodes, fixed in place." : type == "Open Pipe" ? "Both ends are antinodes, open to air." : "One end is a node (closed), one is an antinode (open). Only odd harmonics are possible."}',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Harmonic selector
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Harmonic:', style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(width: 8),
              ...List.generate(6, (index) {
                final n = index + 1;
                // For closed pipe, only odd harmonics
                if (_systemType == 'Closed Pipe' && n % 2 == 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$n', style: const TextStyle(fontSize: 12)),
                    selected: _harmonic == n,
                    selectedColor: Colors.cyan,
                    onSelected: (selected) {
                      if (selected) {
                        context.read<SoundProvider>().playWave();
                        setState(() => _harmonic = n);
                        speakSimulation(
                          '${_getHarmonicName()} harmonic. This has $_numNodes nodes and $_numAntinodes antinodes.',
                        );
                      }
                    },
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 8),

          // Amplitude slider
          Row(
            children: [
              const Icon(Icons.height, color: Colors.white70, size: 18),
              const SizedBox(width: 8),
              const Text('Amplitude:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _amplitude,
                  min: 10,
                  max: 60,
                  activeColor: Colors.cyan,
                  onChanged: (value) => setState(() => _amplitude = value),
                ),
              ),
            ],
          ),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('Node', style: TextStyle(color: Colors.white70, fontSize: 11)),
              const SizedBox(width: 16),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              ),
              const SizedBox(width: 4),
              const Text('Antinode', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),

          const SizedBox(height: 8),

          // Key concept
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.cyan.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Standing wave = superposition of two waves traveling in opposite directions',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingWavesPainter extends CustomPainter {
  final int harmonic;
  final double amplitude;
  final double time;
  final String systemType;

  _StandingWavesPainter({
    required this.harmonic,
    required this.amplitude,
    required this.time,
    required this.systemType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final startX = 50.0;
    final endX = size.width - 50;
    final length = endX - startX;

    // Draw boundary conditions
    _drawBoundaries(canvas, size, startX, endX, centerY);

    // Draw envelope
    _drawEnvelope(canvas, startX, endX, centerY, length);

    // Draw standing wave
    _drawStandingWave(canvas, startX, endX, centerY, length);

    // Draw nodes and antinodes
    _drawNodesAndAntinodes(canvas, startX, endX, centerY, length);

    // Draw wavelength indicator
    _drawWavelengthIndicator(canvas, startX, centerY, length);
  }

  void _drawBoundaries(Canvas canvas, Size size, double startX, double endX, double centerY) {
    final boundaryPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 4;

    if (systemType == 'String (fixed ends)') {
      // Fixed ends - draw supports
      canvas.drawLine(Offset(startX, centerY - 40), Offset(startX, centerY + 40), boundaryPaint);
      canvas.drawLine(Offset(endX, centerY - 40), Offset(endX, centerY + 40), boundaryPaint);
    } else if (systemType == 'Open Pipe') {
      // Open pipe - draw pipe outline
      final pipePaint = Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(
        Rect.fromLTRB(startX - 10, centerY - 50, endX + 10, centerY + 50),
        pipePaint,
      );
    } else {
      // Closed pipe - one end closed
      canvas.drawLine(Offset(startX, centerY - 50), Offset(startX, centerY + 50), boundaryPaint);
      final pipePaint = Paint()
        ..color = Colors.grey.shade700
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawLine(Offset(startX, centerY - 50), Offset(endX, centerY - 50), pipePaint);
      canvas.drawLine(Offset(startX, centerY + 50), Offset(endX, centerY + 50), pipePaint);
    }
  }

  void _drawEnvelope(Canvas canvas, double startX, double endX, double centerY, double length) {
    final envelopePaint = Paint()
      ..color = Colors.cyan.withAlpha(50)
      ..style = PaintingStyle.fill;

    final topPath = Path();
    final bottomPath = Path();

    topPath.moveTo(startX, centerY);
    bottomPath.moveTo(startX, centerY);

    for (var x = startX; x <= endX; x += 2) {
      final normalizedX = (x - startX) / length;
      double envelopeValue;

      if (systemType == 'String (fixed ends)') {
        envelopeValue = math.sin(normalizedX * harmonic * math.pi).abs();
      } else if (systemType == 'Open Pipe') {
        envelopeValue = math.cos(normalizedX * harmonic * math.pi).abs();
      } else {
        // Closed pipe - node at closed end, antinode at open
        envelopeValue = math.sin(normalizedX * (harmonic * 0.5) * math.pi).abs();
      }

      topPath.lineTo(x, centerY - envelopeValue * amplitude);
      bottomPath.lineTo(x, centerY + envelopeValue * amplitude);
    }

    topPath.lineTo(endX, centerY);
    bottomPath.lineTo(endX, centerY);

    canvas.drawPath(topPath, envelopePaint);
    canvas.drawPath(bottomPath, envelopePaint);
  }

  void _drawStandingWave(Canvas canvas, double startX, double endX, double centerY, double length) {
    final wavePaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    path.moveTo(startX, centerY);

    for (var x = startX; x <= endX; x += 2) {
      final normalizedX = (x - startX) / length;
      double spatialPart;

      if (systemType == 'String (fixed ends)') {
        spatialPart = math.sin(normalizedX * harmonic * math.pi);
      } else if (systemType == 'Open Pipe') {
        spatialPart = math.cos(normalizedX * harmonic * math.pi);
      } else {
        spatialPart = math.sin(normalizedX * (harmonic * 0.5) * math.pi);
      }

      final temporalPart = math.cos(time * 5);
      final y = centerY - spatialPart * temporalPart * amplitude;

      path.lineTo(x, y);
    }

    canvas.drawPath(path, wavePaint);
  }

  void _drawNodesAndAntinodes(Canvas canvas, double startX, double endX, double centerY, double length) {
    final nodePaint = Paint()..color = Colors.red;
    final antinodePaint = Paint()..color = Colors.green;

    if (systemType == 'String (fixed ends)') {
      // Nodes at x = 0, L/n, 2L/n, ..., L
      for (var i = 0; i <= harmonic; i++) {
        final x = startX + (i / harmonic) * length;
        canvas.drawCircle(Offset(x, centerY), 8, nodePaint);
      }

      // Antinodes at x = L/(2n), 3L/(2n), ...
      for (var i = 0; i < harmonic; i++) {
        final x = startX + ((2 * i + 1) / (2 * harmonic)) * length;
        canvas.drawCircle(Offset(x, centerY), 8, antinodePaint);
      }
    } else if (systemType == 'Open Pipe') {
      // Antinodes at ends
      for (var i = 0; i <= harmonic; i++) {
        final x = startX + (i / harmonic) * length;
        if (i % 2 == 0) {
          canvas.drawCircle(Offset(x, centerY), 8, antinodePaint);
        } else {
          canvas.drawCircle(Offset(x, centerY), 8, nodePaint);
        }
      }
    } else {
      // Closed pipe - node at closed end
      canvas.drawCircle(Offset(startX, centerY), 8, nodePaint);
      canvas.drawCircle(Offset(endX, centerY), 8, antinodePaint);

      // Additional nodes/antinodes for higher harmonics
      final numHalfWaves = harmonic;
      for (var i = 1; i < numHalfWaves; i++) {
        final x = startX + (i / numHalfWaves) * length;
        if (i % 2 == 1) {
          canvas.drawCircle(Offset(x, centerY), 8, antinodePaint);
        } else {
          canvas.drawCircle(Offset(x, centerY), 8, nodePaint);
        }
      }
    }
  }

  void _drawWavelengthIndicator(Canvas canvas, double startX, double centerY, double length) {
    final wavelength = length / (harmonic / 2);

    if (wavelength > 30) {
      final indicatorY = centerY + amplitude + 40;
      final arrowPaint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 2;

      // Draw wavelength arrow
      canvas.drawLine(
        Offset(startX, indicatorY),
        Offset(startX + wavelength, indicatorY),
        arrowPaint,
      );

      // Arrow heads
      canvas.drawLine(Offset(startX, indicatorY), Offset(startX + 10, indicatorY - 5), arrowPaint);
      canvas.drawLine(Offset(startX, indicatorY), Offset(startX + 10, indicatorY + 5), arrowPaint);
      canvas.drawLine(Offset(startX + wavelength, indicatorY), Offset(startX + wavelength - 10, indicatorY - 5), arrowPaint);
      canvas.drawLine(Offset(startX + wavelength, indicatorY), Offset(startX + wavelength - 10, indicatorY + 5), arrowPaint);

      // Label
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'λ',
          style: TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(startX + wavelength / 2 - 5, indicatorY - 25));
    }
  }

  @override
  bool shouldRepaint(covariant _StandingWavesPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.harmonic != harmonic ||
           oldDelegate.amplitude != amplitude ||
           oldDelegate.systemType != systemType;
  }
}
