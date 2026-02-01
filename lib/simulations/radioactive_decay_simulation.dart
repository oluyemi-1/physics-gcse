import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class RadioactiveDecaySimulation extends StatefulWidget {
  const RadioactiveDecaySimulation({super.key});

  @override
  State<RadioactiveDecaySimulation> createState() => _RadioactiveDecaySimulationState();
}

class _RadioactiveDecaySimulationState extends State<RadioactiveDecaySimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  final int _initialAtoms = 100;
  int _remainingAtoms = 100;
  double _halfLife = 5.0; // seconds
  double _elapsedTime = 0;
  bool _isRunning = false;
  String _decayType = 'alpha'; // alpha, beta, gamma
  bool _hasSpokenIntro = false;
  bool _hasSpokenHalfLife = false;

  final List<Atom> _atoms = [];
  final List<DecayParticle> _particles = [];
  final math.Random _random = math.Random();
  final List<DataPoint> _decayData = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateSimulation);
    _initAtoms();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Radioactive Decay Simulation. This demonstrates how unstable atoms decay over time. '
          'Choose a decay type: alpha, beta, or gamma. Each atom has a random chance of decaying based on the half-life. '
          'The half-life is the time it takes for half of the atoms to decay. Watch the decay curve show the exponential decrease.',
          force: true,
        );
      }
    });
  }

  void _initAtoms() {
    _atoms.clear();
    _particles.clear();
    _decayData.clear();
    for (int i = 0; i < _initialAtoms; i++) {
      _atoms.add(Atom(
        x: 50 + _random.nextDouble() * 220,
        y: 30 + _random.nextDouble() * 140,
        isDecayed: false,
        decayTime: _random.nextDouble() * _halfLife * 5,
      ));
    }
    _remainingAtoms = _initialAtoms;
    _elapsedTime = 0;
    _decayData.add(DataPoint(0, _initialAtoms.toDouble()));
  }

  void _updateSimulation() {
    if (!_isRunning) return;

    setState(() {
      _elapsedTime += 0.05;

      // Check for decays based on probability
      double decayProbability = 1 - math.pow(0.5, 0.05 / _halfLife).toDouble();

      for (var atom in _atoms) {
        if (!atom.isDecayed && _random.nextDouble() < decayProbability) {
          atom.isDecayed = true;
          _remainingAtoms--;

          // Play Geiger counter click sound
          context.read<SoundProvider>().playGeiger();

          // Create decay particle
          _particles.add(DecayParticle(
            x: atom.x,
            y: atom.y,
            vx: (_random.nextDouble() - 0.5) * 10,
            vy: (_random.nextDouble() - 0.5) * 10,
            type: _decayType,
            life: 1.0,
          ));
        }
      }

      // Update particles
      for (var particle in _particles) {
        particle.x += particle.vx;
        particle.y += particle.vy;
        particle.life -= 0.02;
      }
      _particles.removeWhere((p) => p.life <= 0);

      // Record data point every 0.5 seconds
      if ((_elapsedTime * 20).round() % 10 == 0) {
        _decayData.add(DataPoint(_elapsedTime, _remainingAtoms.toDouble()));
      }

      // Announce when first half-life is reached
      if (!_hasSpokenHalfLife && _elapsedTime >= _halfLife) {
        _hasSpokenHalfLife = true;
        speakSimulation(
          'One half-life has passed! Approximately half of the original atoms should have decayed by now. '
          'Currently $_remainingAtoms atoms remain out of $_initialAtoms.',
          force: true,
        );
      }

      // Stop if all decayed
      if (_remainingAtoms <= 0) {
        _stopSimulation();
        speakSimulation(
          'All atoms have decayed! The simulation is complete. This took ${_elapsedTime.toStringAsFixed(1)} seconds, '
          'or ${(_elapsedTime / _halfLife).toStringAsFixed(1)} half-lives.',
          force: true,
        );
      }
    });
  }

  void _startSimulation() {
    setState(() {
      _isRunning = true;
      _hasSpokenHalfLife = false;
    });
    _controller.repeat();
    speakSimulation(
      'Simulation started! Watch as atoms randomly decay. The cyan atoms are undecayed, and grey atoms have decayed. '
      'Each decay releases a $_decayType particle shown in ${_getParticleColorName()}.',
      force: true,
    );
  }

  void _stopSimulation() {
    setState(() {
      _isRunning = false;
    });
    _controller.stop();
    final percentDecayed = ((_initialAtoms - _remainingAtoms) / _initialAtoms * 100).toStringAsFixed(0);
    speakSimulation(
      'Simulation paused. ${_initialAtoms - _remainingAtoms} atoms have decayed, which is $percentDecayed percent of the original sample. '
      'Time elapsed: ${_elapsedTime.toStringAsFixed(1)} seconds, or ${(_elapsedTime / _halfLife).toStringAsFixed(1)} half-lives.',
      force: true,
    );
  }

  void _resetSimulation() {
    _stopSimulation();
    setState(() {
      _initAtoms();
      _hasSpokenHalfLife = false;
    });
    speakSimulation('Simulation reset. All atoms are now undecayed. Adjust the settings and press Start to begin again.', force: true);
  }

  String _getParticleColorName() {
    switch (_decayType) {
      case 'alpha':
        return 'red';
      case 'beta':
        return 'blue';
      case 'gamma':
        return 'green';
      default:
        return 'white';
    }
  }

  void _onDecayTypeChanged(String type) {
    setState(() {
      _decayType = type;
      _initAtoms();
    });
    _speakDecayType(type);
  }

  void _speakDecayType(String type) {
    switch (type) {
      case 'alpha':
        speakSimulation(
          'Alpha decay selected. In alpha decay, the nucleus emits an alpha particle containing 2 protons and 2 neutrons. '
          'This is essentially a helium nucleus. The mass number decreases by 4 and atomic number by 2.',
          force: true,
        );
        break;
      case 'beta':
        speakSimulation(
          'Beta decay selected. In beta decay, a neutron converts into a proton and releases an electron called a beta particle. '
          'The mass number stays the same but the atomic number increases by 1.',
          force: true,
        );
        break;
      case 'gamma':
        speakSimulation(
          'Gamma decay selected. In gamma decay, the nucleus releases excess energy as high-frequency electromagnetic radiation. '
          'There is no change in mass number or atomic number, just energy release.',
          force: true,
        );
        break;
    }
  }

  void _onHalfLifeChanged(double value) {
    setState(() {
      _halfLife = value;
      _initAtoms();
    });
    speakSimulation(
      'Half-life set to ${value.toStringAsFixed(1)} seconds. This means after ${value.toStringAsFixed(1)} seconds, '
      'approximately half of the remaining atoms will have decayed.',
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
        // Decay type selector
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildTTSToggle(),
              const SizedBox(width: 8),
              _buildDecayButton('Alpha (α)', 'alpha', Colors.red),
              const SizedBox(width: 8),
              _buildDecayButton('Beta (β)', 'beta', Colors.blue),
              const SizedBox(width: 8),
              _buildDecayButton('Gamma (γ)', 'gamma', Colors.green),
            ],
          ),
        ),
        // Atom visualization
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: CustomPaint(
              painter: AtomsPainter(
                atoms: _atoms,
                particles: _particles,
                decayType: _decayType,
              ),
              size: Size.infinite,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Decay curve graph
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Decay Curve (N vs t)',
                  style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: CustomPaint(
                    painter: DecayCurvePainter(
                      dataPoints: _decayData,
                      halfLife: _halfLife,
                      initialAtoms: _initialAtoms,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Stats
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard('Remaining', '$_remainingAtoms', Colors.cyan),
              _buildStatCard('Decayed', '${_initialAtoms - _remainingAtoms}', Colors.orange),
              _buildStatCard('Time', '${_elapsedTime.toStringAsFixed(1)}s', Colors.white),
              _buildStatCard('Half-lives', (_elapsedTime / _halfLife).toStringAsFixed(1), Colors.purple),
            ],
          ),
        ),
        // Half-life slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('Half-life:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _halfLife,
                  min: 1,
                  max: 15,
                  onChanged: _isRunning ? null : _onHalfLifeChanged,
                  activeColor: Colors.amber,
                ),
              ),
              Text('${_halfLife.toStringAsFixed(1)}s', style: const TextStyle(color: Colors.amber, fontSize: 12)),
            ],
          ),
        ),
        // Controls
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _isRunning ? null : _startSimulation,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _isRunning ? _stopSimulation : null,
                icon: const Icon(Icons.pause),
                label: const Text('Pause'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _resetSimulation,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ],
          ),
        ),
        // Info
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Text(
            _getDecayInfo(),
            style: const TextStyle(color: Colors.white70, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDecayButton(String label, String type, Color color) {
    final isSelected = _decayType == type;
    return GestureDetector(
      onTap: _isRunning ? null : () => _onDecayTypeChanged(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  String _getDecayInfo() {
    switch (_decayType) {
      case 'alpha':
        return 'Alpha decay: Nucleus emits 2 protons + 2 neutrons (helium nucleus).\nMass number decreases by 4, atomic number decreases by 2.';
      case 'beta':
        return 'Beta decay: Neutron converts to proton, emitting an electron.\nMass number stays same, atomic number increases by 1.';
      case 'gamma':
        return 'Gamma decay: Nucleus releases excess energy as electromagnetic radiation.\nNo change in mass number or atomic number.';
      default:
        return '';
    }
  }
}

class Atom {
  double x;
  double y;
  bool isDecayed;
  double decayTime;

  Atom({
    required this.x,
    required this.y,
    required this.isDecayed,
    required this.decayTime,
  });
}

class DecayParticle {
  double x;
  double y;
  double vx;
  double vy;
  String type;
  double life;

  DecayParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.type,
    required this.life,
  });
}

class DataPoint {
  final double time;
  final double count;
  DataPoint(this.time, this.count);
}

class AtomsPainter extends CustomPainter {
  final List<Atom> atoms;
  final List<DecayParticle> particles;
  final String decayType;

  AtomsPainter({
    required this.atoms,
    required this.particles,
    required this.decayType,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw container
    final containerPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(40, 20, 240, 160),
        const Radius.circular(8),
      ),
      containerPaint,
    );

    // Draw atoms
    for (var atom in atoms) {
      final paint = Paint()
        ..color = atom.isDecayed
            ? Colors.grey.withValues(alpha: 0.3)
            : Colors.cyan;
      canvas.drawCircle(Offset(atom.x, atom.y), atom.isDecayed ? 4 : 6, paint);

      if (!atom.isDecayed) {
        // Glow effect
        final glowPaint = Paint()
          ..color = Colors.cyan.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(atom.x, atom.y), 8, glowPaint);
      }
    }

    // Draw decay particles
    for (var particle in particles) {
      Color particleColor;
      double particleSize;

      switch (particle.type) {
        case 'alpha':
          particleColor = Colors.red;
          particleSize = 5;
          break;
        case 'beta':
          particleColor = Colors.blue;
          particleSize = 3;
          break;
        case 'gamma':
          particleColor = Colors.green;
          particleSize = 2;
          break;
        default:
          particleColor = Colors.white;
          particleSize = 3;
      }

      final paint = Paint()
        ..color = particleColor.withValues(alpha: particle.life);
      canvas.drawCircle(Offset(particle.x, particle.y), particleSize, paint);

      // Trail effect
      final trailPaint = Paint()
        ..color = particleColor.withValues(alpha: particle.life * 0.3)
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(particle.x, particle.y),
        Offset(particle.x - particle.vx * 2, particle.y - particle.vy * 2),
        trailPaint,
      );
    }

    // Legend
    final legendY = size.height - 15;
    _drawLegendItem(canvas, 50, legendY, Colors.cyan, 'Undecayed');
    _drawLegendItem(canvas, 140, legendY, Colors.grey, 'Decayed');
    _drawLegendItem(canvas, 220, legendY, _getParticleColor(), 'Particle');
  }

  Color _getParticleColor() {
    switch (decayType) {
      case 'alpha': return Colors.red;
      case 'beta': return Colors.blue;
      case 'gamma': return Colors.green;
      default: return Colors.white;
    }
  }

  void _drawLegendItem(Canvas canvas, double x, double y, Color color, String label) {
    canvas.drawCircle(Offset(x, y), 4, Paint()..color = color);
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: Colors.white54, fontSize: 9),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x + 8, y - 5));
  }

  @override
  bool shouldRepaint(covariant AtomsPainter oldDelegate) => true;
}

class DecayCurvePainter extends CustomPainter {
  final List<DataPoint> dataPoints;
  final double halfLife;
  final int initialAtoms;

  DecayCurvePainter({
    required this.dataPoints,
    required this.halfLife,
    required this.initialAtoms,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;

    // Draw axes
    canvas.drawLine(Offset(35, 0), Offset(35, size.height - 20), axisPaint);
    canvas.drawLine(Offset(35, size.height - 20), Offset(size.width, size.height - 20), axisPaint);

    // Draw theoretical decay curve
    final theoreticalPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final theoreticalPath = Path();
    bool first = true;
    for (double t = 0; t <= halfLife * 5; t += 0.1) {
      final n = initialAtoms * math.pow(0.5, t / halfLife);
      final x = 35 + (t / (halfLife * 5)) * (size.width - 45);
      final y = size.height - 20 - (n / initialAtoms) * (size.height - 30);
      if (first) {
        theoreticalPath.moveTo(x, y);
        first = false;
      } else {
        theoreticalPath.lineTo(x, y);
      }
    }
    canvas.drawPath(theoreticalPath, theoreticalPaint);

    // Draw actual data points
    if (dataPoints.isEmpty) return;

    final dataPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final dataPath = Path();
    first = true;
    for (final point in dataPoints) {
      final x = 35 + (point.time / (halfLife * 5)) * (size.width - 45);
      final y = size.height - 20 - (point.count / initialAtoms) * (size.height - 30);
      if (first) {
        dataPath.moveTo(x, y.clamp(0, size.height - 20));
        first = false;
      } else {
        dataPath.lineTo(x, y.clamp(0, size.height - 20));
      }
    }
    canvas.drawPath(dataPath, dataPaint);

    // Draw half-life markers
    final markerPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.5)
      ..strokeWidth = 1;

    for (int i = 1; i <= 4; i++) {
      final x = 35 + (i / 5) * (size.width - 45);
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height - 20),
        markerPaint..strokeWidth = 0.5,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${i}T½',
          style: const TextStyle(color: Colors.amber, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 10, size.height - 15));
    }

    // Y-axis labels
    for (int i = 0; i <= 4; i++) {
      final y = size.height - 20 - (i / 4) * (size.height - 30);
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${(initialAtoms * i / 4).round()}',
          style: const TextStyle(color: Colors.white54, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(5, y - 5));
    }
  }

  @override
  bool shouldRepaint(covariant DecayCurvePainter oldDelegate) =>
      oldDelegate.dataPoints.length != dataPoints.length;
}
