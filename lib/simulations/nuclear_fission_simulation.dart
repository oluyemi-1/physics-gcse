import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class NuclearFissionSimulation extends StatefulWidget {
  const NuclearFissionSimulation({super.key});

  @override
  State<NuclearFissionSimulation> createState() => _NuclearFissionSimulationState();
}

class _NuclearFissionSimulationState extends State<NuclearFissionSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  bool _hasSpokenIntro = false;
  bool _chainReaction = false;

  List<_Neutron> _neutrons = [];
  List<_Nucleus> _nuclei = [];
  List<_FissionProduct> _products = [];
  int _fissionCount = 0;
  double _energyReleased = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);

    _resetSimulation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Nuclear Fission simulation! '
          'Fission occurs when a heavy nucleus like uranium-235 absorbs a neutron and splits into two smaller nuclei. '
          'This releases energy and more neutrons, which can cause a chain reaction. '
          'Press Fire Neutron to start, or enable Chain Reaction mode.',
          force: true,
        );
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      _neutrons = [];
      _products = [];
      _fissionCount = 0;
      _energyReleased = 0.0;

      // Create uranium nuclei
      _nuclei = [];
      if (_chainReaction) {
        // Multiple nuclei for chain reaction
        for (int i = 0; i < 12; i++) {
          _nuclei.add(_Nucleus(
            x: 100 + (i % 4) * 100.0,
            y: 100 + (i ~/ 4) * 80.0,
            isFissioned: false,
          ));
        }
      } else {
        // Single nucleus
        _nuclei.add(_Nucleus(x: 200, y: 150, isFissioned: false));
      }
    });
  }

  void _fireNeutron() {
    if (_nuclei.where((n) => !n.isFissioned).isEmpty) {
      _resetSimulation();
      return;
    }

    setState(() {
      _neutrons.add(_Neutron(
        x: 0,
        y: _chainReaction ? 100 + _random.nextDouble() * 150 : 150,
        vx: 3.0,
        vy: _random.nextDouble() * 0.5 - 0.25,
      ));
    });

    _controller.repeat();

    speakSimulation(
      'Neutron fired! Watch as it approaches the uranium-235 nucleus.',
      force: true,
    );
  }

  void _update() {
    setState(() {
      // Update neutrons
      for (var neutron in _neutrons) {
        neutron.x += neutron.vx;
        neutron.y += neutron.vy;

        // Check collision with nuclei
        for (var nucleus in _nuclei) {
          if (!nucleus.isFissioned) {
            final dx = neutron.x - nucleus.x;
            final dy = neutron.y - nucleus.y;
            final dist = math.sqrt(dx * dx + dy * dy);

            if (dist < 25) {
              // Fission occurs!
              nucleus.isFissioned = true;
              nucleus.fissionTime = 0;
              neutron.absorbed = true;
              _fissionCount++;
              _energyReleased += 200; // ~200 MeV per fission

              // Play explosion sound
              context.read<SoundProvider>().playExplosion();

              // Create fission products
              _products.add(_FissionProduct(
                x: nucleus.x,
                y: nucleus.y,
                vx: -2 - _random.nextDouble(),
                vy: -1 - _random.nextDouble(),
                type: 'Kr-92',
                color: Colors.green,
              ));
              _products.add(_FissionProduct(
                x: nucleus.x,
                y: nucleus.y,
                vx: 2 + _random.nextDouble(),
                vy: 1 + _random.nextDouble(),
                type: 'Ba-141',
                color: Colors.purple,
              ));

              // Release 2-3 neutrons
              final newNeutronCount = 2 + _random.nextInt(2);
              for (int i = 0; i < newNeutronCount; i++) {
                final angle = _random.nextDouble() * 2 * math.pi;
                _neutrons.add(_Neutron(
                  x: nucleus.x,
                  y: nucleus.y,
                  vx: math.cos(angle) * (2 + _random.nextDouble()),
                  vy: math.sin(angle) * (2 + _random.nextDouble()),
                ));
              }

              speakSimulation(
                'Fission! The uranium nucleus split into krypton-92 and barium-141, releasing $newNeutronCount neutrons and about 200 mega electron volts of energy.',
                force: true,
              );
            }
          }
        }
      }

      // Update fission products
      for (var product in _products) {
        product.x += product.vx;
        product.y += product.vy;
        product.vx *= 0.98; // Slow down
        product.vy *= 0.98;
      }

      // Update fissioned nuclei animation
      for (var nucleus in _nuclei) {
        if (nucleus.isFissioned) {
          nucleus.fissionTime += 0.02;
        }
      }

      // Remove absorbed neutrons and off-screen ones
      _neutrons.removeWhere((n) => n.absorbed || n.x > 500 || n.x < -50 || n.y > 400 || n.y < -50);

      // Stop if no active neutrons and no pending fissions
      if (_neutrons.isEmpty && _products.every((p) => p.vx.abs() < 0.1)) {
        _controller.stop();
      }
    });
  }

  void _toggleChainReaction() {
    setState(() {
      _chainReaction = !_chainReaction;
    });
    _resetSimulation();

    if (_chainReaction) {
      speakSimulation(
        'Chain reaction mode enabled! Multiple uranium nuclei are present. '
        'When one fissions, the released neutrons can trigger more fissions, '
        'creating a chain reaction. This is how nuclear reactors and bombs work.',
        force: true,
      );
    } else {
      speakSimulation(
        'Single nucleus mode. Watch a single fission event in detail.',
        force: true,
      );
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
        // Simulation area
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade700),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _FissionPainter(
                  neutrons: _neutrons,
                  nuclei: _nuclei,
                  products: _products,
                ),
                size: Size.infinite,
              ),
            ),
          ),
        ),

        // Data display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDataCard('Fission Events', '$_fissionCount'),
              _buildDataCard('Energy Released', '${_energyReleased.toStringAsFixed(0)} MeV'),
              _buildDataCard('Active Neutrons', '${_neutrons.length}'),
              _buildDataCard('Remaining Nuclei', '${_nuclei.where((n) => !n.isFissioned).length}'),
            ],
          ),
        ),

        // Reaction equation
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '²³⁵U + ¹n → ⁹²Kr + ¹⁴¹Ba + 3¹n + Energy (≈200 MeV)',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // Controls
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Mode: ', style: TextStyle(color: Colors.white)),
                    ChoiceChip(
                      label: const Text('Single Fission'),
                      selected: !_chainReaction,
                      onSelected: (_) => _toggleChainReaction(),
                      selectedColor: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('Chain Reaction'),
                      selected: _chainReaction,
                      onSelected: (_) => _toggleChainReaction(),
                      selectedColor: Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _fireNeutron,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Fire Neutron'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _resetSimulation,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    buildTTSToggle(),
                  ],
                ),

                const SizedBox(height: 8),

                // Legend
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: Colors.amber, label: 'U-235'),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.white, label: 'Neutron'),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.green, label: 'Kr-92'),
                    SizedBox(width: 16),
                    _LegendItem(color: Colors.purple, label: 'Ba-141'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          Text(value, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }
}

class _Neutron {
  double x, y, vx, vy;
  bool absorbed = false;

  _Neutron({required this.x, required this.y, required this.vx, required this.vy});
}

class _Nucleus {
  double x, y;
  bool isFissioned;
  double fissionTime = 0;

  _Nucleus({required this.x, required this.y, required this.isFissioned});
}

class _FissionProduct {
  double x, y, vx, vy;
  String type;
  Color color;

  _FissionProduct({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.type,
    required this.color,
  });
}

class _FissionPainter extends CustomPainter {
  final List<_Neutron> neutrons;
  final List<_Nucleus> nuclei;
  final List<_FissionProduct> products;

  _FissionPainter({
    required this.neutrons,
    required this.nuclei,
    required this.products,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background grid
    final gridPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), gridPaint);
    }
    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), gridPaint);
    }

    // Draw nuclei
    for (var nucleus in nuclei) {
      if (!nucleus.isFissioned) {
        _drawUraniumNucleus(canvas, nucleus.x, nucleus.y);
      } else if (nucleus.fissionTime < 0.5) {
        // Draw fission animation
        _drawFissionAnimation(canvas, nucleus.x, nucleus.y, nucleus.fissionTime);
      }
    }

    // Draw fission products
    for (var product in products) {
      final paint = Paint()..color = product.color;
      canvas.drawCircle(Offset(product.x, product.y), 12, paint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: product.type,
          style: const TextStyle(color: Colors.white, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(product.x - 15, product.y + 15));
    }

    // Draw neutrons
    for (var neutron in neutrons) {
      if (!neutron.absorbed) {
        final paint = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(neutron.x, neutron.y), 5, paint);

        // Draw motion trail
        final trailPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.3)
          ..strokeWidth = 2;
        canvas.drawLine(
          Offset(neutron.x - neutron.vx * 3, neutron.y - neutron.vy * 3),
          Offset(neutron.x, neutron.y),
          trailPaint,
        );
      }
    }

    // Draw title
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Nuclear Fission of Uranium-235',
        style: TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, 10));
  }

  void _drawUraniumNucleus(Canvas canvas, double x, double y) {
    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(x, y), 25, glowPaint);

    // Main nucleus
    final nucleusPaint = Paint()..color = Colors.amber;
    canvas.drawCircle(Offset(x, y), 20, nucleusPaint);

    // Protons and neutrons inside
    final protonPaint = Paint()..color = Colors.red[700]!;
    final neutronPaint = Paint()..color = Colors.blue[300]!;

    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final r = 10.0;
      final px = x + r * math.cos(angle);
      final py = y + r * math.sin(angle);
      canvas.drawCircle(Offset(px, py), 4, i % 2 == 0 ? protonPaint : neutronPaint);
    }

    // Label
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'U-235',
        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - 15, y + 25));
  }

  void _drawFissionAnimation(Canvas canvas, double x, double y, double t) {
    // Expanding energy ring
    final ringPaint = Paint()
      ..color = Colors.yellow.withValues(alpha: 1 - t * 2)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(x, y), 20 + t * 100, ringPaint);

    // Flash
    if (t < 0.1) {
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: 1 - t * 10)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset(x, y), 40, flashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FissionPainter oldDelegate) => true;
}
