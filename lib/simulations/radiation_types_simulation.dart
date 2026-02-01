import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Radiation Types Simulation demonstrating alpha, beta, and gamma radiation
/// Shows penetrating power, ionizing ability, and behavior in fields
class RadiationTypesSimulation extends StatefulWidget {
  const RadiationTypesSimulation({super.key});

  @override
  State<RadiationTypesSimulation> createState() => _RadiationTypesSimulationState();
}

class _RadiationTypesSimulationState extends State<RadiationTypesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  String _selectedRadiation = 'alpha';
  String _testMode = 'penetration';
  double _time = 0.0;
  bool _isRunning = true;

  final Map<String, Map<String, dynamic>> _radiationProperties = {
    'alpha': {
      'symbol': 'α',
      'particle': '²He⁴ (2 protons, 2 neutrons)',
      'charge': '+2',
      'mass': 'Heavy (4 u)',
      'speed': 'Slow (5-7% of c)',
      'penetration': 'Paper stops it',
      'ionizing': 'Highly ionizing',
      'range': 'Few cm in air',
      'color': Colors.red,
      'deflection': 'Curves towards negative plate',
    },
    'beta': {
      'symbol': 'β',
      'particle': 'Electron (e⁻) or Positron (e⁺)',
      'charge': '-1 or +1',
      'mass': 'Very light (1/1836 u)',
      'speed': 'Fast (up to 99% of c)',
      'penetration': 'Aluminium stops it',
      'ionizing': 'Moderately ionizing',
      'range': 'Few meters in air',
      'color': Colors.blue,
      'deflection': 'Curves towards positive plate (β⁻)',
    },
    'gamma': {
      'symbol': 'γ',
      'particle': 'High-energy photon (EM wave)',
      'charge': '0',
      'mass': 'No mass',
      'speed': 'Speed of light (c)',
      'penetration': 'Lead/concrete reduces it',
      'ionizing': 'Weakly ionizing',
      'range': 'Very long range',
      'color': Colors.green,
      'deflection': 'No deflection (no charge)',
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      if (_isRunning) {
        setState(() {
          _time += 0.02;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Radiation Types Simulation. Explore the three main types of nuclear radiation: '
        'Alpha particles are helium nuclei, stopped by paper. '
        'Beta particles are fast electrons, stopped by aluminium. '
        'Gamma rays are electromagnetic waves, reduced by thick lead or concrete.',
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
        title: const Text('Radiation Types'),
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
    final props = _radiationProperties[_selectedRadiation]!;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: (props['color'] as Color).withAlpha(150)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                props['symbol'] as String,
                style: TextStyle(
                  color: props['color'] as Color,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                _selectedRadiation.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildPropertyChip('Particle', props['particle'] as String),
              _buildPropertyChip('Charge', props['charge'] as String),
              _buildPropertyChip('Mass', props['mass'] as String),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildPropertyChip('Penetration', props['penetration'] as String),
              _buildPropertyChip('Ionizing', props['ionizing'] as String),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSimulationArea() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _RadiationPainter(
            selectedRadiation: _selectedRadiation,
            testMode: _testMode,
            time: _time,
            properties: _radiationProperties,
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
          // Radiation type selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['alpha', 'beta', 'gamma'].map((type) {
              final props = _radiationProperties[type]!;
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      props['symbol'] as String,
                      style: TextStyle(
                        color: _selectedRadiation == type ? Colors.white : props['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(type.toUpperCase(), style: const TextStyle(fontSize: 11)),
                  ],
                ),
                selected: _selectedRadiation == type,
                selectedColor: (props['color'] as Color).withAlpha(200),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedRadiation = type);
                    speakSimulation(
                      '${type.toUpperCase()} radiation selected. '
                      '${props['particle']}. ${props['penetration']}. ${props['ionizing']}.',
                    );
                  }
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // Test mode selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildModeButton('penetration', 'Penetration Test', Icons.layers),
              _buildModeButton('field', 'Electric Field', Icons.electric_bolt),
              _buildModeButton('ionization', 'Ionization', Icons.scatter_plot),
            ],
          ),

          const SizedBox(height: 8),

          // Play/pause button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => setState(() => _isRunning = !_isRunning),
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
              ),
              IconButton(
                onPressed: () => setState(() => _time = 0),
                icon: const Icon(Icons.refresh),
                color: Colors.white,
              ),
            ],
          ),

          // Key facts
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'α: Stopped by paper | β: Stopped by aluminium | γ: Reduced by lead/concrete',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, String label, IconData icon) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10)),
        ],
      ),
      selected: _testMode == mode,
      selectedColor: Colors.deepPurple.shade400,
      onSelected: (selected) {
        if (selected) {
          setState(() => _testMode = mode);
        }
      },
    );
  }
}

class _RadiationPainter extends CustomPainter {
  final String selectedRadiation;
  final String testMode;
  final double time;
  final Map<String, Map<String, dynamic>> properties;

  _RadiationPainter({
    required this.selectedRadiation,
    required this.testMode,
    required this.time,
    required this.properties,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (testMode) {
      case 'penetration':
        _drawPenetrationTest(canvas, size);
        break;
      case 'field':
        _drawElectricField(canvas, size);
        break;
      case 'ionization':
        _drawIonization(canvas, size);
        break;
    }
  }

  void _drawPenetrationTest(Canvas canvas, Size size) {
    final sourceX = 50.0;
    final centerY = size.height / 2;

    // Draw radioactive source
    _drawSource(canvas, Offset(sourceX, centerY));

    // Draw barriers
    final paperX = size.width * 0.3;
    final aluminiumX = size.width * 0.5;
    final leadX = size.width * 0.7;

    // Paper
    _drawBarrier(canvas, paperX, centerY, 'Paper', Colors.brown.shade200, 5);

    // Aluminium
    _drawBarrier(canvas, aluminiumX, centerY, 'Aluminium', Colors.grey.shade400, 10);

    // Lead
    _drawBarrier(canvas, leadX, centerY, 'Lead', Colors.grey.shade700, 20);

    // Draw radiation particles
    final props = properties[selectedRadiation]!;
    final color = props['color'] as Color;

    // Determine how far particles travel
    double maxX;
    if (selectedRadiation == 'alpha') {
      maxX = paperX - 10; // Stopped by paper
    } else if (selectedRadiation == 'beta') {
      maxX = aluminiumX - 10; // Stopped by aluminium
    } else {
      maxX = size.width - 20; // Gamma passes through (but reduced)
    }

    // Draw particles
    for (var i = 0; i < 5; i++) {
      final startX = sourceX + 30;
      final progress = (time * 0.5 + i * 0.2) % 1.0;
      final x = startX + progress * (maxX - startX);
      final y = centerY + math.sin(progress * math.pi * 4 + i) * 20;

      // Fade out near barriers for absorbed particles
      var alpha = 255;
      if (selectedRadiation == 'alpha' && x > paperX - 30) {
        alpha = ((paperX - x) / 30 * 255).toInt().clamp(0, 255);
      } else if (selectedRadiation == 'beta' && x > aluminiumX - 30) {
        alpha = ((aluminiumX - x) / 30 * 255).toInt().clamp(0, 255);
      } else if (selectedRadiation == 'gamma' && x > leadX) {
        alpha = (255 * 0.3).toInt(); // Reduced but not stopped
      }

      _drawParticle(canvas, Offset(x, y), color.withAlpha(alpha), selectedRadiation);
    }

    // Labels
    _drawLabel(canvas, 'Radioactive\nSource', Offset(sourceX - 20, centerY + 60));
    _drawStoppedLabel(canvas, size, centerY);
  }

  void _drawElectricField(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final sourceX = 50.0;
    final fieldStart = size.width * 0.25;
    final fieldEnd = size.width * 0.75;

    // Draw source
    _drawSource(canvas, Offset(sourceX, centerY));

    // Draw electric field plates
    final platePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 8;

    // Positive plate (top)
    canvas.drawLine(
      Offset(fieldStart, centerY - 80),
      Offset(fieldEnd, centerY - 80),
      platePaint,
    );
    _drawLabel(canvas, '+', Offset((fieldStart + fieldEnd) / 2, centerY - 100), Colors.red);

    // Negative plate (bottom)
    canvas.drawLine(
      Offset(fieldStart, centerY + 80),
      Offset(fieldEnd, centerY + 80),
      platePaint,
    );
    _drawLabel(canvas, '−', Offset((fieldStart + fieldEnd) / 2, centerY + 85), Colors.blue);

    // Draw field lines
    final fieldPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    for (var x = fieldStart + 20; x < fieldEnd; x += 30) {
      canvas.drawLine(
        Offset(x, centerY - 75),
        Offset(x, centerY + 75),
        fieldPaint,
      );
      // Arrow heads pointing down
      canvas.drawLine(Offset(x, centerY), Offset(x - 5, centerY - 10), fieldPaint);
      canvas.drawLine(Offset(x, centerY), Offset(x + 5, centerY - 10), fieldPaint);
    }

    // Draw radiation paths
    final props = properties[selectedRadiation]!;
    final color = props['color'] as Color;

    for (var i = 0; i < 3; i++) {
      final startX = sourceX + 30;
      final progress = (time * 0.3 + i * 0.3) % 1.0;
      final x = startX + progress * (size.width - startX - 30);

      double y = centerY;
      if (x > fieldStart && x < fieldEnd) {
        final fieldProgress = (x - fieldStart) / (fieldEnd - fieldStart);
        if (selectedRadiation == 'alpha') {
          // Alpha: +2 charge, curves toward negative (down, but less than beta due to mass)
          y = centerY + fieldProgress * fieldProgress * 30;
        } else if (selectedRadiation == 'beta') {
          // Beta-: -1 charge, curves toward positive (up)
          y = centerY - fieldProgress * fieldProgress * 50;
        }
        // Gamma: no deflection
      }

      _drawParticle(canvas, Offset(x, y), color, selectedRadiation);
    }

    // Draw path labels
    final pathEndY = selectedRadiation == 'alpha' ? centerY + 30 :
                      selectedRadiation == 'beta' ? centerY - 50 : centerY;

    _drawLabel(
      canvas,
      props['deflection'] as String,
      Offset(fieldEnd + 10, pathEndY),
      color,
    );
  }

  void _drawIonization(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final sourceX = 50.0;

    // Draw source
    _drawSource(canvas, Offset(sourceX, centerY));

    // Draw air molecules
    final moleculePaint = Paint()..color = Colors.white24;
    final random = math.Random(42);
    final molecules = <Offset>[];

    for (var i = 0; i < 50; i++) {
      final x = 100 + random.nextDouble() * (size.width - 150);
      final y = centerY - 100 + random.nextDouble() * 200;
      molecules.add(Offset(x, y));
      canvas.drawCircle(Offset(x, y), 4, moleculePaint);
    }

    // Draw radiation and ionization events
    final props = properties[selectedRadiation]!;
    final color = props['color'] as Color;

    // Number of ionization events (alpha > beta > gamma)
    final ionizationRate = selectedRadiation == 'alpha' ? 0.8 :
                           selectedRadiation == 'beta' ? 0.4 : 0.1;

    // Draw radiation path
    final progress = (time * 0.3) % 1.0;
    final maxRange = selectedRadiation == 'alpha' ? size.width * 0.3 :
                     selectedRadiation == 'beta' ? size.width * 0.6 : size.width - 50;
    final x = sourceX + 30 + progress * (maxRange - sourceX - 30);

    _drawParticle(canvas, Offset(x, centerY), color, selectedRadiation);

    // Show ionization events along path
    for (final mol in molecules) {
      if (mol.dx < x && random.nextDouble() < ionizationRate) {
        // Draw ionized molecule
        final ionPaint = Paint()..color = Colors.yellow.withAlpha(150);
        canvas.drawCircle(mol, 6, ionPaint);

        // Draw ejected electron
        final electronPaint = Paint()..color = Colors.cyan;
        final electronOffset = Offset(
          mol.dx + 10 + random.nextDouble() * 20,
          mol.dy + (random.nextDouble() - 0.5) * 30,
        );
        canvas.drawCircle(electronOffset, 2, electronPaint);

        // Line showing ejection
        canvas.drawLine(mol, electronOffset, Paint()..color = Colors.cyan.withAlpha(100)..strokeWidth = 1);
      }
    }

    // Ionization density indicator
    _drawLabel(canvas, 'Ionization density: ${(ionizationRate * 100).toStringAsFixed(0)}%',
               Offset(size.width / 2, size.height - 30), color);
  }

  void _drawSource(Canvas canvas, Offset position) {
    // Radioactive source symbol
    final sourcePaint = Paint()..color = Colors.yellow.shade700;
    canvas.drawCircle(position, 25, sourcePaint);

    // Trefoil symbol
    final trefoilPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 3; i++) {
      final angle = i * 2 * math.pi / 3 - math.pi / 2;
      final path = Path();
      path.moveTo(position.dx, position.dy);
      path.arcTo(
        Rect.fromCircle(center: position, radius: 15),
        angle - 0.5,
        1.0,
        false,
      );
      path.close();
      canvas.drawPath(path, trefoilPaint);
    }

    // Center circle
    canvas.drawCircle(position, 5, trefoilPaint);
  }

  void _drawBarrier(Canvas canvas, double x, double y, String label, Color color, double thickness) {
    final barrierPaint = Paint()
      ..color = color
      ..strokeWidth = thickness;

    canvas.drawLine(
      Offset(x, y - 100),
      Offset(x, y + 100),
      barrierPaint,
    );

    _drawLabel(canvas, label, Offset(x - 20, y + 110));
  }

  void _drawParticle(Canvas canvas, Offset position, Color color, String type) {
    final particlePaint = Paint()..color = color;

    if (type == 'alpha') {
      // Alpha: large circle
      canvas.drawCircle(position, 8, particlePaint);
    } else if (type == 'beta') {
      // Beta: small circle with trail
      canvas.drawCircle(position, 4, particlePaint);
      // Trail
      for (var i = 1; i < 5; i++) {
        canvas.drawCircle(
          Offset(position.dx - i * 3, position.dy),
          2,
          Paint()..color = color.withAlpha(255 - i * 50),
        );
      }
    } else {
      // Gamma: wavy line
      final path = Path();
      path.moveTo(position.dx - 20, position.dy);
      for (var i = 0; i < 4; i++) {
        path.quadraticBezierTo(
          position.dx - 15 + i * 10, position.dy - 5,
          position.dx - 10 + i * 10, position.dy,
        );
        path.quadraticBezierTo(
          position.dx - 5 + i * 10, position.dy + 5,
          position.dx + i * 10, position.dy,
        );
      }
      canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    }
  }

  void _drawLabel(Canvas canvas, String text, Offset position, [Color? color]) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color ?? Colors.white70, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  void _drawStoppedLabel(Canvas canvas, Size size, double centerY) {
    String stoppedBy;
    if (selectedRadiation == 'alpha') {
      stoppedBy = 'α STOPPED BY PAPER';
    } else if (selectedRadiation == 'beta') {
      stoppedBy = 'β STOPPED BY ALUMINIUM';
    } else {
      stoppedBy = 'γ REDUCED BY LEAD (not fully stopped)';
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: stoppedBy,
        style: TextStyle(
          color: (properties[selectedRadiation]!['color'] as Color),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 20));
  }

  @override
  bool shouldRepaint(covariant _RadiationPainter oldDelegate) {
    return oldDelegate.time != time ||
           oldDelegate.selectedRadiation != selectedRadiation ||
           oldDelegate.testMode != testMode;
  }
}
