import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class NuclearFusionSimulation extends StatefulWidget {
  const NuclearFusionSimulation({super.key});

  @override
  State<NuclearFusionSimulation> createState() => _NuclearFusionSimulationState();
}

class _NuclearFusionSimulationState extends State<NuclearFusionSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _phase = 0.0;
  bool _isFusing = false;
  double _fusionProgress = 0.0;
  bool _hasSpokenIntro = false;
  bool _showEnergy = false;

  String _selectedReaction = 'D-T';

  final Map<String, Map<String, dynamic>> _reactions = {
    'D-T': {
      'reactant1': 'Deuterium (²H)',
      'reactant2': 'Tritium (³H)',
      'product': 'Helium-4 + neutron',
      'energy': '17.6 MeV',
      'temp': '100 million °C',
    },
    'D-D': {
      'reactant1': 'Deuterium (²H)',
      'reactant2': 'Deuterium (²H)',
      'product': 'Helium-3 + neutron',
      'energy': '3.3 MeV',
      'temp': '400 million °C',
    },
    'p-p': {
      'reactant1': 'Proton (¹H)',
      'reactant2': 'Proton (¹H)',
      'product': 'Deuterium + positron',
      'energy': '1.4 MeV',
      'temp': '15 million °C (Sun)',
    },
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateAnimation);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Nuclear Fusion simulation! '
          'Fusion combines light nuclei to form heavier ones, releasing enormous energy. '
          'This is the process that powers the Sun and stars. '
          'Fusion requires extreme temperatures to overcome electrostatic repulsion between nuclei.',
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

  void _updateAnimation() {
    setState(() {
      _phase += 0.02;
      if (_phase > 2 * math.pi) {
        _phase -= 2 * math.pi;
      }

      if (_isFusing) {
        _fusionProgress += 0.015;
        if (_fusionProgress >= 1.0) {
          _fusionProgress = 1.0;
          _isFusing = false;
          _showEnergy = true;
          speakSimulation(
            'Fusion complete! ${_reactions[_selectedReaction]!['energy']} of energy released. '
            'Notice how the mass of products is less than reactants. The missing mass becomes energy via E equals mc squared.',
          );
        }
      }
    });
  }

  void _startFusion() {
    setState(() {
      _isFusing = true;
      _fusionProgress = 0.0;
      _showEnergy = false;
    });
    speakSimulation(
      'Starting fusion. Nuclei must overcome electrostatic repulsion to get close enough for the strong force to bind them.',
      force: true,
    );
  }

  void _resetSimulation() {
    setState(() {
      _isFusing = false;
      _fusionProgress = 0.0;
      _showEnergy = false;
    });
  }

  void _onReactionChanged(String? reaction) {
    if (reaction == null) return;
    _resetSimulation();
    setState(() {
      _selectedReaction = reaction;
    });

    final data = _reactions[reaction]!;
    speakSimulation(
      '$reaction fusion selected. ${data['reactant1']} plus ${data['reactant2']} produces ${data['product']}. '
      'This reaction releases ${data['energy']} and requires temperatures of ${data['temp']}.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reaction = _reactions[_selectedReaction]!;

    return Column(
      children: [
        // Fusion visualization
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade700),
            ),
            child: CustomPaint(
              painter: _FusionPainter(
                phase: _phase,
                fusionProgress: _fusionProgress,
                showEnergy: _showEnergy,
                reactionType: _selectedReaction,
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
            color: Colors.orange.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Text(
                '$_selectedReaction Fusion Reaction',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Reactants',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        reaction['reactant1'] as String,
                        style: const TextStyle(color: Colors.cyan, fontSize: 11),
                      ),
                      Text(
                        reaction['reactant2'] as String,
                        style: const TextStyle(color: Colors.cyan, fontSize: 11),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: Colors.yellow),
                  Column(
                    children: [
                      const Text('Products',
                          style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        reaction['product'] as String,
                        style: const TextStyle(color: Colors.green, fontSize: 11),
                      ),
                      Text(
                        '+ ${reaction['energy']}',
                        style: const TextStyle(color: Colors.orange, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Required temperature: ${reaction['temp']}',
                style: const TextStyle(color: Colors.red, fontSize: 11),
              ),
              const Text(
                'E = mc²',
                style: TextStyle(
                    color: Colors.yellow, fontFamily: 'monospace', fontSize: 14),
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
                // Reaction selector
                Row(
                  children: [
                    const Text('Reaction: ', style: TextStyle(color: Colors.white)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedReaction,
                        dropdownColor: Colors.grey[800],
                        isExpanded: true,
                        items: _reactions.keys.map((reaction) {
                          return DropdownMenuItem(
                            value: reaction,
                            child: Text(reaction,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: _onReactionChanged,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isFusing ? null : _startFusion,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Fuse'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _resetSimulation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                          ),
                        ),
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

class _FusionPainter extends CustomPainter {
  final double phase;
  final double fusionProgress;
  final bool showEnergy;
  final String reactionType;

  _FusionPainter({
    required this.phase,
    required this.fusionProgress,
    required this.showEnergy,
    required this.reactionType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw plasma background
    _drawPlasmaBackground(canvas, size);

    if (fusionProgress < 0.5) {
      // Draw approaching nuclei
      final separation = 120.0 * (1 - fusionProgress * 2);

      // Left nucleus
      _drawNucleus(
        canvas,
        Offset(centerX - separation + math.sin(phase) * 5, centerY),
        30,
        Colors.blue,
        reactionType == 'p-p' ? 1 : 2,
      );

      // Right nucleus
      _drawNucleus(
        canvas,
        Offset(centerX + separation + math.cos(phase) * 5, centerY),
        30,
        Colors.red,
        reactionType == 'D-T' ? 3 : (reactionType == 'p-p' ? 1 : 2),
      );

      // Draw repulsion field
      if (separation < 80) {
        final fieldPaint = Paint()
          ..color = Colors.yellow.withValues(alpha: (80 - separation) / 80 * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        for (int i = 1; i <= 3; i++) {
          canvas.drawCircle(
            Offset(centerX - separation, centerY),
            30 + i * 10,
            fieldPaint,
          );
          canvas.drawCircle(
            Offset(centerX + separation, centerY),
            30 + i * 10,
            fieldPaint,
          );
        }
      }
    } else if (fusionProgress < 1.0) {
      // Fusion in progress - draw combined unstable nucleus
      final wobble = math.sin(phase * 4) * 10;
      final glowIntensity = (fusionProgress - 0.5) * 2;

      // Glow effect
      final glowPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: glowIntensity * 0.5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 30 + wobble);
      canvas.drawCircle(Offset(centerX, centerY), 50, glowPaint);

      // Combined nucleus
      _drawNucleus(
        canvas,
        Offset(centerX + wobble * 0.3, centerY + math.cos(phase * 4) * 5),
        40 + wobble * 0.5,
        Colors.purple,
        reactionType == 'D-T' ? 5 : (reactionType == 'p-p' ? 2 : 4),
      );
    } else {
      // Fusion complete - show products
      _drawFusionProducts(canvas, centerX, centerY);
    }

    // Draw energy release
    if (showEnergy) {
      _drawEnergyRelease(canvas, size);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    if (fusionProgress < 0.5) {
      textPainter.text = TextSpan(
        text: reactionType == 'p-p' ? '¹H' : '²H',
        style: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX - 120 * (1 - fusionProgress * 2) - 10, centerY + 40));

      textPainter.text = TextSpan(
        text: reactionType == 'D-T' ? '³H' : (reactionType == 'p-p' ? '¹H' : '²H'),
        style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(centerX + 120 * (1 - fusionProgress * 2) - 10, centerY + 40));
    }
  }

  void _drawPlasmaBackground(Canvas canvas, Size size) {
    final random = math.Random(42);
    final particlePaint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final offset = math.sin(phase + i) * 3;

      particlePaint.color = Colors.orange.withValues(alpha: 0.2);
      canvas.drawCircle(Offset(x + offset, y), 2, particlePaint);
    }
  }

  void _drawNucleus(Canvas canvas, Offset center, double radius, Color color, int nucleons) {
    // Glow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius + 5, glowPaint);

    // Main nucleus
    final nucleusPaint = Paint()..color = color;
    canvas.drawCircle(center, radius, nucleusPaint);

    // Draw nucleons inside
    final random = math.Random(nucleons);
    final protonPaint = Paint()..color = Colors.red.shade300;
    final neutronPaint = Paint()..color = Colors.grey.shade400;

    for (int i = 0; i < nucleons; i++) {
      final angle = random.nextDouble() * 2 * math.pi;
      final dist = random.nextDouble() * (radius - 8);
      final x = center.dx + dist * math.cos(angle + phase * 0.5);
      final y = center.dy + dist * math.sin(angle + phase * 0.5);

      canvas.drawCircle(
        Offset(x, y),
        6,
        i.isEven ? protonPaint : neutronPaint,
      );
    }
  }

  void _drawFusionProducts(Canvas canvas, double centerX, double centerY) {
    // Helium nucleus (product)
    _drawNucleus(
      canvas,
      Offset(centerX, centerY),
      35,
      Colors.green,
      4,
    );

    // Ejected particle (neutron or other)
    final neutronAngle = phase * 2;
    final neutronDist = 80.0;
    final neutronPaint = Paint()..color = Colors.grey;
    canvas.drawCircle(
      Offset(
        centerX + neutronDist * math.cos(neutronAngle),
        centerY + neutronDist * math.sin(neutronAngle),
      ),
      8,
      neutronPaint,
    );

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    textPainter.text = const TextSpan(
      text: '⁴He',
      style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 10, centerY + 45));

    textPainter.text = const TextSpan(
      text: 'n',
      style: TextStyle(color: Colors.grey, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerX + neutronDist * math.cos(neutronAngle) - 5,
        centerY + neutronDist * math.sin(neutronAngle) + 12,
      ),
    );
  }

  void _drawEnergyRelease(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Radiating energy waves
    final wavePaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 5; i++) {
      final radius = 60.0 + i * 25 + (phase * 20) % 25;
      wavePaint.color = Colors.yellow.withValues(alpha: 0.4 - i * 0.08);
      canvas.drawCircle(Offset(centerX, centerY), radius, wavePaint);
    }

    // Energy label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ENERGY RELEASED',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 55, 20));
  }

  @override
  bool shouldRepaint(covariant _FusionPainter oldDelegate) {
    return phase != oldDelegate.phase ||
        fusionProgress != oldDelegate.fusionProgress ||
        showEnergy != oldDelegate.showEnergy;
  }
}
