import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class HalfLifeSimulation extends StatefulWidget {
  const HalfLifeSimulation({super.key});

  @override
  State<HalfLifeSimulation> createState() => _HalfLifeSimulationState();
}

class _HalfLifeSimulationState extends State<HalfLifeSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  final int _totalAtoms = 100;
  int _decayedAtoms = 0;
  double _timeElapsed = 0.0;
  double _halfLife = 5.0; // seconds
  bool _isRunning = false;
  bool _hasSpokenIntro = false;

  final List<_Atom> _atoms = [];
  final math.Random _random = math.Random();

  // Data for graph
  final List<Offset> _decayCurve = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(_updateDecay);

    _initializeAtoms();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Half-Life simulation! '
          'Radioactive decay is a random process where unstable nuclei emit radiation. '
          'The half-life is the time taken for half the radioactive atoms to decay. '
          'Watch as the blue atoms randomly decay to grey over time.',
          force: true,
        );
      }
    });
  }

  void _initializeAtoms() {
    _atoms.clear();
    _decayCurve.clear();
    _decayCurve.add(const Offset(0, 100));

    for (int i = 0; i < _totalAtoms; i++) {
      _atoms.add(_Atom(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        decayed: false,
      ));
    }
    _decayedAtoms = 0;
    _timeElapsed = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateDecay() {
    if (!_isRunning) return;

    setState(() {
      _timeElapsed += 0.05;

      // Calculate decay probability based on half-life
      // P(decay) = 1 - 0.5^(dt/t_half)
      final decayProbability = 1 - math.pow(0.5, 0.05 / _halfLife);

      for (var atom in _atoms) {
        if (!atom.decayed && _random.nextDouble() < decayProbability) {
          atom.decayed = true;
          _decayedAtoms++;
        }
      }

      // Record data point
      final remaining = ((_totalAtoms - _decayedAtoms) / _totalAtoms * 100);
      if (_decayCurve.isEmpty ||
          _timeElapsed - _decayCurve.last.dx > 0.2) {
        _decayCurve.add(Offset(_timeElapsed, remaining));
      }

      // Check for milestone announcements
      final percentRemaining = remaining;
      if (percentRemaining <= 50 && percentRemaining > 48 && _decayCurve.length < 30) {
        speakSimulation(
          'About 50% of atoms remain. One half-life has passed.',
        );
      } else if (percentRemaining <= 25 && percentRemaining > 23 && _decayCurve.length < 60) {
        speakSimulation(
          'About 25% remain. Two half-lives have passed.',
        );
      }

      // Stop if all decayed
      if (_decayedAtoms >= _totalAtoms) {
        _isRunning = false;
        _controller.stop();
        speakSimulation(
          'All atoms have decayed. The decay curve shows exponential decrease.',
          force: true,
        );
      }
    });
  }

  void _toggleSimulation() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _resetSimulation() {
    setState(() {
      _isRunning = false;
      _controller.stop();
      _initializeAtoms();
    });
    speakSimulation(
      'Simulation reset. All atoms are now undecayed.',
      force: true,
    );
  }

  void _onHalfLifeChanged(double value) {
    setState(() {
      _halfLife = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingAtoms = _totalAtoms - _decayedAtoms;
    final percentRemaining = (remainingAtoms / _totalAtoms * 100).toStringAsFixed(1);

    return Column(
      children: [
        // Atom visualization
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade700),
            ),
            child: CustomPaint(
              painter: _AtomGridPainter(atoms: _atoms),
              size: Size.infinite,
            ),
          ),
        ),

        // Decay curve graph
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _DecayCurvePainter(
                dataPoints: _decayCurve,
                halfLife: _halfLife,
                maxTime: math.max(20.0, _timeElapsed + 5),
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Info panel
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Remaining',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '$remainingAtoms ($percentRemaining%)',
                    style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Time Elapsed',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '${_timeElapsed.toStringAsFixed(1)} s',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Half-Life',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text(
                    '${_halfLife.toStringAsFixed(1)} s',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Controls
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Half-life slider
              Row(
                children: [
                  const SizedBox(
                      width: 90,
                      child: Text('Half-Life:',
                          style: TextStyle(color: Colors.white, fontSize: 12))),
                  Expanded(
                    child: Slider(
                      value: _halfLife,
                      min: 1.0,
                      max: 15.0,
                      onChanged: _isRunning ? null : _onHalfLifeChanged,
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
                      ElevatedButton.icon(
                        onPressed: _toggleSimulation,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'Pause' : 'Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isRunning ? Colors.orange : Colors.green,
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
      ],
    );
  }
}

class _Atom {
  final double x;
  final double y;
  bool decayed;

  _Atom({required this.x, required this.y, required this.decayed});
}

class _AtomGridPainter extends CustomPainter {
  final List<_Atom> atoms;

  _AtomGridPainter({required this.atoms});

  @override
  void paint(Canvas canvas, Size size) {
    final activeColor = Colors.cyan;
    final decayedColor = Colors.grey[700]!;

    for (var atom in atoms) {
      final paint = Paint()
        ..color = atom.decayed ? decayedColor : activeColor;

      final x = 20 + atom.x * (size.width - 40);
      final y = 20 + atom.y * (size.height - 40);

      canvas.drawCircle(Offset(x, y), 6, paint);

      // Add glow for active atoms
      if (!atom.decayed) {
        final glowPaint = Paint()
          ..color = activeColor.withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
        canvas.drawCircle(Offset(x, y), 8, glowPaint);
      }
    }

    // Legend
    final textPainter = TextPainter(
      text: TextSpan(
        children: [
          TextSpan(
            text: '● Active  ',
            style: TextStyle(color: activeColor, fontSize: 12),
          ),
          TextSpan(
            text: '● Decayed',
            style: TextStyle(color: decayedColor, fontSize: 12),
          ),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 5));
  }

  @override
  bool shouldRepaint(covariant _AtomGridPainter oldDelegate) => true;
}

class _DecayCurvePainter extends CustomPainter {
  final List<Offset> dataPoints;
  final double halfLife;
  final double maxTime;

  _DecayCurvePainter({
    required this.dataPoints,
    required this.halfLife,
    required this.maxTime,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;
    final graphWidth = size.width - padding * 2;
    final graphHeight = size.height - padding;

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(padding, 10),
      Offset(padding, size.height - 20),
      axisPaint,
    );
    canvas.drawLine(
      Offset(padding, size.height - 20),
      Offset(size.width - 10, size.height - 20),
      axisPaint,
    );

    // Draw theoretical decay curve
    final theoreticalPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final theoreticalPath = Path();
    for (int i = 0; i <= graphWidth.toInt(); i++) {
      final t = (i / graphWidth) * maxTime;
      final remaining = 100 * math.pow(0.5, t / halfLife);
      final x = padding + i;
      final y = 10 + (100 - remaining) / 100 * graphHeight;

      if (i == 0) {
        theoreticalPath.moveTo(x, y);
      } else {
        theoreticalPath.lineTo(x, y);
      }
    }
    canvas.drawPath(theoreticalPath, theoreticalPaint);

    // Draw actual data points
    if (dataPoints.length > 1) {
      final dataPaint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final dataPath = Path();
      for (int i = 0; i < dataPoints.length; i++) {
        final point = dataPoints[i];
        final x = padding + (point.dx / maxTime) * graphWidth;
        final y = 10 + (100 - point.dy) / 100 * graphHeight;

        if (i == 0) {
          dataPath.moveTo(x, y);
        } else {
          dataPath.lineTo(x, y);
        }
      }
      canvas.drawPath(dataPath, dataPaint);
    }

    // Draw 50% line
    final halfLinePaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    final halfY = 10 + graphHeight / 2;
    canvas.drawLine(
      Offset(padding, halfY),
      Offset(size.width - 10, halfY),
      halfLinePaint,
    );

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: '100%',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(5, 8));

    textPainter.text = const TextSpan(
      text: '50%',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, halfY - 5));

    textPainter.text = const TextSpan(
      text: 'Time (s)',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 50, size.height - 15));

    // Legend
    textPainter.text = const TextSpan(
      text: '— Theoretical  — Actual',
      style: TextStyle(color: Colors.white54, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 120, 5));
  }

  @override
  bool shouldRepaint(covariant _DecayCurvePainter oldDelegate) {
    return dataPoints.length != oldDelegate.dataPoints.length;
  }
}
