import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

/// Newton's Cradle Simulation demonstrating conservation of momentum and energy
/// Shows elastic collisions transferring momentum through a series of balls
class NewtonsCradleSimulation extends StatefulWidget {
  const NewtonsCradleSimulation({super.key});

  @override
  State<NewtonsCradleSimulation> createState() => _NewtonsCradleSimulationState();
}

class _NewtonsCradleSimulationState extends State<NewtonsCradleSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  final int _numBalls = 5;
  final List<double> _angles = [];
  final List<double> _velocities = [];
  final double _stringLength = 150.0;
  final double _ballRadius = 20.0;
  final double _gravity = 9.81;
  final double _damping = 0.999;

  int _ballsReleased = 1;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    // Initialize ball states
    for (var i = 0; i < _numBalls; i++) {
      _angles.add(0.0);
      _velocities.add(0.0);
    }

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(_updatePhysics);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Newton\'s Cradle Simulation. This classic physics toy demonstrates conservation of momentum and energy. '
        'When one ball swings and hits the row, the ball on the opposite end swings out. '
        'The momentum and kinetic energy transfer through the stationary balls almost perfectly.',
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updatePhysics() {
    if (!_isRunning) return;

    setState(() {
      const dt = 1 / 60;
      final angularFrequency = math.sqrt(_gravity / (_stringLength / 100));

      // Update physics for each ball
      for (var i = 0; i < _numBalls; i++) {
        // Pendulum equation: α = -(g/L) * sin(θ)
        final acceleration = -angularFrequency * angularFrequency * math.sin(_angles[i]);
        _velocities[i] += acceleration * dt;
        _velocities[i] *= _damping;
        _angles[i] += _velocities[i] * dt;
      }

      // Check for collisions between adjacent balls
      for (var i = 0; i < _numBalls - 1; i++) {
        // Calculate ball positions
        final x1 = i * _ballRadius * 2 + _stringLength * math.sin(_angles[i]);
        final x2 = (i + 1) * _ballRadius * 2 + _stringLength * math.sin(_angles[i + 1]);

        // Check if balls are touching (collision)
        if ((x2 - x1) < _ballRadius * 2) {
          // Play collision sound based on velocity
          final impactSpeed = (_velocities[i] - _velocities[i + 1]).abs();
          if (impactSpeed > 0.5) {
            context.read<SoundProvider>().playClang(pitch: 0.8 + (impactSpeed * 0.2));
          }

          // Elastic collision - swap velocities (equal mass)
          final temp = _velocities[i];
          _velocities[i] = _velocities[i + 1];
          _velocities[i + 1] = temp;

          // Prevent overlap
          final overlap = _ballRadius * 2 - (x2 - x1);
          _angles[i] -= overlap / (2 * _stringLength);
          _angles[i + 1] += overlap / (2 * _stringLength);
        }
      }
    });
  }

  void _releaseBalls() {
    setState(() {
      // Reset all balls
      for (var i = 0; i < _numBalls; i++) {
        _angles[i] = 0.0;
        _velocities[i] = 0.0;
      }

      // Release the specified number of balls from the left
      for (var i = 0; i < _ballsReleased; i++) {
        _angles[i] = -math.pi / 4; // 45 degrees
      }

      _isRunning = true;
    });

    speakSimulation(
      'Releasing $_ballsReleased ball${_ballsReleased > 1 ? "s" : ""}. Watch the momentum transfer!',
    );
  }

  void _reset() {
    setState(() {
      for (var i = 0; i < _numBalls; i++) {
        _angles[i] = 0.0;
        _velocities[i] = 0.0;
      }
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Newton\'s Cradle'),
        backgroundColor: Colors.blueGrey.shade800,
        actions: [
          Consumer<SoundProvider>(
            builder: (context, sound, _) => IconButton(
              icon: Icon(
                sound.soundEnabled ? Icons.volume_up : Icons.volume_off,
                color: sound.soundEnabled ? Colors.white : Colors.grey,
              ),
              onPressed: sound.toggleSound,
              tooltip: sound.soundEnabled ? 'Mute sounds' : 'Enable sounds',
            ),
          ),
          buildTTSToggle(),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blueGrey.shade900, Colors.black],
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
    // Calculate total kinetic and potential energy
    double totalKE = 0;
    double totalPE = 0;
    const mass = 1.0; // kg

    for (var i = 0; i < _numBalls; i++) {
      // KE = 0.5 * m * v²
      final velocity = _velocities[i] * _stringLength / 100;
      totalKE += 0.5 * mass * velocity * velocity;

      // PE = m * g * h where h = L * (1 - cos(θ))
      final height = (_stringLength / 100) * (1 - math.cos(_angles[i]));
      totalPE += mass * _gravity * height;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.shade300),
      ),
      child: Column(
        children: [
          const Text(
            'Newton\'s Cradle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Balls to Release', '$_ballsReleased'),
              _buildInfoItem('Kinetic Energy', '${totalKE.toStringAsFixed(2)} J', Colors.orange),
              _buildInfoItem('Potential Energy', '${totalPE.toStringAsFixed(2)} J', Colors.green),
              _buildInfoItem('Total Energy', '${(totalKE + totalPE).toStringAsFixed(2)} J', Colors.amber),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Conservation Laws: Momentum (mv) and Kinetic Energy (½mv²) are conserved in elastic collisions',
              style: TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, [Color? color]) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        Text(
          value,
          style: TextStyle(
            color: color ?? Colors.white,
            fontSize: 13,
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
          painter: _NewtonsCradlePainter(
            numBalls: _numBalls,
            angles: _angles,
            stringLength: _stringLength,
            ballRadius: _ballRadius,
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.black45,
      child: Column(
        children: [
          // Number of balls to release
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Balls to release: ', style: TextStyle(color: Colors.white)),
              ...List.generate(3, (index) {
                final n = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text('$n'),
                    selected: _ballsReleased == n,
                    selectedColor: Colors.blueGrey.shade400,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _ballsReleased = n);
                      }
                    },
                  ),
                );
              }),
            ],
          ),

          const SizedBox(height: 12),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _releaseBalls,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Release'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Key physics concepts
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'm₁v₁ + m₂v₂ = m₁v₁\' + m₂v₂\' (Conservation of Momentum)\n'
              '½m₁v₁² + ½m₂v₂² = ½m₁v₁\'² + ½m₂v₂\'² (Conservation of KE)',
              style: TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewtonsCradlePainter extends CustomPainter {
  final int numBalls;
  final List<double> angles;
  final double stringLength;
  final double ballRadius;

  _NewtonsCradlePainter({
    required this.numBalls,
    required this.angles,
    required this.stringLength,
    required this.ballRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final topY = 50.0;

    // Draw frame
    _drawFrame(canvas, size, centerX, topY);

    // Calculate spacing
    final totalWidth = (numBalls - 1) * ballRadius * 2;
    final startX = centerX - totalWidth / 2;

    // Draw each ball and string
    for (var i = 0; i < numBalls; i++) {
      final anchorX = startX + i * ballRadius * 2;
      final anchorY = topY;

      // Calculate ball position based on angle
      final ballX = anchorX + stringLength * math.sin(angles[i]);
      final ballY = anchorY + stringLength * math.cos(angles[i]);

      // Draw string
      final stringPaint = Paint()
        ..color = Colors.grey.shade400
        ..strokeWidth = 2;
      canvas.drawLine(Offset(anchorX, anchorY), Offset(ballX, ballY), stringPaint);

      // Draw ball
      _drawBall(canvas, Offset(ballX, ballY), i);
    }

    // Draw labels
    _drawLabels(canvas, size);
  }

  void _drawFrame(Canvas canvas, Size size, double centerX, double topY) {
    final framePaint = Paint()
      ..color = Colors.brown.shade700
      ..strokeWidth = 6;

    final totalWidth = (numBalls - 1) * ballRadius * 2 + 60;

    // Top bar
    canvas.drawLine(
      Offset(centerX - totalWidth / 2, topY),
      Offset(centerX + totalWidth / 2, topY),
      framePaint,
    );

    // Vertical supports
    canvas.drawLine(
      Offset(centerX - totalWidth / 2, topY),
      Offset(centerX - totalWidth / 2, topY + stringLength + ballRadius + 50),
      framePaint,
    );
    canvas.drawLine(
      Offset(centerX + totalWidth / 2, topY),
      Offset(centerX + totalWidth / 2, topY + stringLength + ballRadius + 50),
      framePaint,
    );

    // Base
    canvas.drawLine(
      Offset(centerX - totalWidth / 2 - 20, topY + stringLength + ballRadius + 50),
      Offset(centerX + totalWidth / 2 + 20, topY + stringLength + ballRadius + 50),
      framePaint,
    );
  }

  void _drawBall(Canvas canvas, Offset center, int index) {
    // Ball gradient for 3D effect
    final gradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      colors: [Colors.grey.shade300, Colors.grey.shade600],
    );

    final ballPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: ballRadius),
      );

    canvas.drawCircle(center, ballRadius, ballPaint);

    // Highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha(100);
    canvas.drawCircle(
      Offset(center.dx - ballRadius * 0.3, center.dy - ballRadius * 0.3),
      ballRadius * 0.2,
      highlightPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, ballRadius, borderPaint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Newton\'s Cradle demonstrates:\n'
            '• Conservation of Momentum\n'
            '• Conservation of Kinetic Energy\n'
            '• Nearly Elastic Collisions',
        style: TextStyle(color: Colors.white54, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, size.height - 80));
  }

  @override
  bool shouldRepaint(covariant _NewtonsCradlePainter oldDelegate) {
    return true; // Always repaint for animation
  }
}
