import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Diffraction Simulation demonstrating wave bending around obstacles
/// Shows single slit, double slit, and diffraction gratings
class DiffractionSimulation extends StatefulWidget {
  const DiffractionSimulation({super.key});

  @override
  State<DiffractionSimulation> createState() => _DiffractionSimulationState();
}

class _DiffractionSimulationState extends State<DiffractionSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _wavelength = 500.0; // nm (visible light)
  double _slitWidth = 100.0; // relative units
  double _slitSeparation = 200.0; // for double slit
  int _numSlits = 1;
  double _time = 0.0;

  String _diffractionType = 'Single Slit';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      setState(() {
        _time += 0.05;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Diffraction Simulation. Watch how waves bend around obstacles and through gaps. '
        'When waves pass through a slit, they spread out. The amount of spreading depends on '
        'the wavelength compared to the slit width. Smaller gaps cause more diffraction.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _waveColor {
    // Convert wavelength to approximate color
    if (_wavelength < 450) return Colors.purple;
    if (_wavelength < 495) return Colors.blue;
    if (_wavelength < 570) return Colors.green;
    if (_wavelength < 590) return Colors.yellow;
    if (_wavelength < 620) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diffraction'),
        backgroundColor: Colors.deepPurple,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade900, Colors.black],
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
        border: Border.all(color: Colors.deepPurple.shade300),
      ),
      child: Column(
        children: [
          Text(
            _diffractionType,
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
              _buildInfoItem('Wavelength', '${_wavelength.toStringAsFixed(0)} nm', _waveColor),
              _buildInfoItem('Slit Width', '${_slitWidth.toStringAsFixed(0)} units'),
              if (_numSlits > 1)
                _buildInfoItem('Separation', '${_slitSeparation.toStringAsFixed(0)} units'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getDiffractionInfo(),
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  String _getDiffractionInfo() {
    switch (_diffractionType) {
      case 'Single Slit':
        return 'Single slit: θ = λ/a for first minimum\nSmaller slit → more spreading';
      case 'Double Slit':
        return 'Double slit: d sin θ = nλ for bright fringes\nInterference + diffraction pattern';
      case 'Diffraction Grating':
        return 'd sin θ = nλ for maxima\nMany slits → sharp, bright maxima';
      default:
        return '';
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
          painter: _DiffractionPainter(
            wavelength: _wavelength,
            slitWidth: _slitWidth,
            slitSeparation: _slitSeparation,
            numSlits: _numSlits,
            time: _time,
            waveColor: _waveColor,
            diffractionType: _diffractionType,
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
          // Diffraction type selector
          Wrap(
            spacing: 8,
            children: ['Single Slit', 'Double Slit', 'Diffraction Grating'].map((type) {
              return ChoiceChip(
                label: Text(type, style: const TextStyle(fontSize: 11)),
                selected: _diffractionType == type,
                selectedColor: Colors.deepPurple.shade400,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _diffractionType = type;
                      _numSlits = type == 'Single Slit' ? 1 : (type == 'Double Slit' ? 2 : 6);
                    });
                    speakSimulation(
                      '$type selected. ${type == "Single Slit" ? "Waves spread out after passing through a single gap." : type == "Double Slit" ? "Two slits create an interference pattern superimposed on the diffraction pattern." : "Multiple slits create sharp, bright maxima at specific angles."}',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 8),

          // Wavelength slider
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _waveColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text('λ:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _wavelength,
                  min: 380,
                  max: 700,
                  activeColor: _waveColor,
                  onChanged: (value) => setState(() => _wavelength = value),
                ),
              ),
              Text('${_wavelength.toStringAsFixed(0)} nm', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Slit width slider
          Row(
            children: [
              const Icon(Icons.swap_horiz, color: Colors.white70, size: 16),
              const SizedBox(width: 8),
              const Text('Slit:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _slitWidth,
                  min: 20,
                  max: 200,
                  activeColor: Colors.orange,
                  onChanged: (value) => setState(() => _slitWidth = value),
                ),
              ),
              Text(_slitWidth.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 12)),
            ],
          ),

          // Slit separation slider (for double slit and grating)
          if (_numSlits > 1)
            Row(
              children: [
                const Icon(Icons.compare_arrows, color: Colors.white70, size: 16),
                const SizedBox(width: 8),
                const Text('d:', style: TextStyle(color: Colors.white, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _slitSeparation,
                    min: 50,
                    max: 400,
                    activeColor: Colors.green,
                    onChanged: (value) => setState(() => _slitSeparation = value),
                  ),
                ),
                Text(_slitSeparation.toStringAsFixed(0), style: const TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),

          const SizedBox(height: 8),

          // Key equation
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Diffraction: waves spread when passing through gaps ≈ wavelength',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffractionPainter extends CustomPainter {
  final double wavelength;
  final double slitWidth;
  final double slitSeparation;
  final int numSlits;
  final double time;
  final Color waveColor;
  final String diffractionType;

  _DiffractionPainter({
    required this.wavelength,
    required this.slitWidth,
    required this.slitSeparation,
    required this.numSlits,
    required this.time,
    required this.waveColor,
    required this.diffractionType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barrierX = size.width * 0.3;
    final centerY = size.height / 2;

    // Draw barrier
    _drawBarrier(canvas, size, barrierX, centerY);

    // Draw incoming waves
    _drawIncomingWaves(canvas, size, barrierX);

    // Draw diffracted waves
    _drawDiffractedWaves(canvas, size, barrierX, centerY);

    // Draw intensity pattern on screen
    _drawIntensityPattern(canvas, size);

    // Draw labels
    _drawLabels(canvas, size, barrierX);
  }

  void _drawBarrier(Canvas canvas, Size size, double barrierX, double centerY) {
    final barrierPaint = Paint()
      ..color = Colors.grey.shade700
      ..strokeWidth = 8;

    final slitPositions = _getSlitPositions(centerY);

    // Draw barrier with slits
    var lastY = 0.0;
    for (final slitY in slitPositions) {
      // Draw barrier above slit
      canvas.drawLine(
        Offset(barrierX, lastY),
        Offset(barrierX, slitY - slitWidth / 2),
        barrierPaint,
      );
      lastY = slitY + slitWidth / 2;
    }
    // Draw barrier below last slit
    canvas.drawLine(
      Offset(barrierX, lastY),
      Offset(barrierX, size.height),
      barrierPaint,
    );
  }

  List<double> _getSlitPositions(double centerY) {
    if (numSlits == 1) {
      return [centerY];
    } else if (numSlits == 2) {
      return [centerY - slitSeparation / 2, centerY + slitSeparation / 2];
    } else {
      // Diffraction grating
      final positions = <double>[];
      final totalWidth = (numSlits - 1) * slitSeparation;
      final startY = centerY - totalWidth / 2;
      for (var i = 0; i < numSlits; i++) {
        positions.add(startY + i * slitSeparation);
      }
      return positions;
    }
  }

  void _drawIncomingWaves(Canvas canvas, Size size, double barrierX) {
    final wavePaint = Paint()
      ..color = waveColor.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final waveSpacing = wavelength / 10;
    for (var x = 0.0; x < barrierX; x += waveSpacing) {
      final phase = (x / waveSpacing - time * 5) % 1;
      final alpha = (math.sin(phase * math.pi * 2) * 0.5 + 0.5) * 150;
      wavePaint.color = waveColor.withAlpha(alpha.toInt());

      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        wavePaint,
      );
    }
  }

  void _drawDiffractedWaves(Canvas canvas, Size size, double barrierX, double centerY) {
    final slitPositions = _getSlitPositions(centerY);

    for (final slitY in slitPositions) {
      // Draw circular waves emanating from each slit
      final maxRadius = size.width - barrierX;
      final waveSpacing = wavelength / 10;

      for (var r = waveSpacing; r < maxRadius; r += waveSpacing) {
        final phase = (r / waveSpacing - time * 5) % 1;
        final alpha = (math.sin(phase * math.pi * 2) * 0.3 + 0.3) * 255;
        final fadeAlpha = (alpha * (1 - r / maxRadius)).toInt().clamp(0, 255);

        final wavePaint = Paint()
          ..color = waveColor.withAlpha(fadeAlpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

        // Draw semicircle on right side of barrier
        final arcRect = Rect.fromCircle(
          center: Offset(barrierX, slitY),
          radius: r,
        );
        canvas.drawArc(arcRect, -math.pi / 2, math.pi, false, wavePaint);
      }
    }
  }

  void _drawIntensityPattern(Canvas canvas, Size size) {
    final screenX = size.width - 30;
    final centerY = size.height / 2;

    // Draw screen
    final screenPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 4;
    canvas.drawLine(
      Offset(screenX, 20),
      Offset(screenX, size.height - 20),
      screenPaint,
    );

    // Calculate and draw intensity pattern
    final intensities = <double>[];
    for (var y = 0.0; y < size.height; y += 2) {
      final intensity = _calculateIntensity(y - centerY);
      intensities.add(intensity);

      final dotPaint = Paint()
        ..color = waveColor.withAlpha((intensity * 255).toInt().clamp(0, 255));
      canvas.drawCircle(Offset(screenX, y), 3, dotPaint);
    }
  }

  double _calculateIntensity(double y) {
    // Simplified intensity calculation
    final theta = math.atan2(y, 200);
    final k = 2 * math.pi / (wavelength / 50);

    if (numSlits == 1) {
      // Single slit diffraction
      final beta = k * slitWidth * math.sin(theta) / 2;
      if (beta.abs() < 0.001) return 1.0;
      final sinc = math.sin(beta) / beta;
      return sinc * sinc;
    } else {
      // Multiple slit interference + diffraction
      final beta = k * slitWidth * math.sin(theta) / 2;
      final delta = k * slitSeparation * math.sin(theta);

      double singleSlitFactor;
      if (beta.abs() < 0.001) {
        singleSlitFactor = 1.0;
      } else {
        final sinc = math.sin(beta) / beta;
        singleSlitFactor = sinc * sinc;
      }

      // Multi-slit interference
      double interferenceFactor;
      if ((delta / 2).abs() < 0.001) {
        interferenceFactor = numSlits * numSlits.toDouble();
      } else {
        final numerator = math.sin(numSlits * delta / 2);
        final denominator = math.sin(delta / 2);
        interferenceFactor = (numerator / denominator) * (numerator / denominator);
      }

      return singleSlitFactor * interferenceFactor / (numSlits * numSlits);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double barrierX) {
    // Incoming wave label
    final incomingText = TextPainter(
      text: const TextSpan(
        text: 'Plane waves →',
        style: TextStyle(color: Colors.white70, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    incomingText.layout();
    incomingText.paint(canvas, Offset(10, size.height / 2 - 50));

    // Barrier label
    final barrierText = TextPainter(
      text: TextSpan(
        text: numSlits == 1 ? 'Slit' : '$numSlits Slits',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    barrierText.layout();
    barrierText.paint(canvas, Offset(barrierX - barrierText.width / 2, 5));

    // Screen label
    final screenText = TextPainter(
      text: const TextSpan(
        text: 'Screen',
        style: TextStyle(color: Colors.white70, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    screenText.layout();
    screenText.paint(canvas, Offset(size.width - 40, 5));

    // Central maximum label
    final centralText = TextPainter(
      text: const TextSpan(
        text: 'Central\nmaximum',
        style: TextStyle(color: Colors.white54, fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    centralText.layout();
    centralText.paint(canvas, Offset(size.width - 80, size.height / 2 - 20));
  }

  @override
  bool shouldRepaint(covariant _DiffractionPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.wavelength != wavelength ||
           oldDelegate.slitWidth != slitWidth ||
           oldDelegate.numSlits != numSlits;
  }
}
