import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

/// Interactive Differentiation Explorer Simulation
/// Covers: Power rule visualisation with interactive graph, tangent line,
/// gradient display, and step-by-step breakdown.
class DifferentiationSimulation extends StatefulWidget {
  const DifferentiationSimulation({super.key});

  @override
  State<DifferentiationSimulation> createState() =>
      _DifferentiationSimulationState();
}

class _DifferentiationSimulationState extends State<DifferentiationSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Function parameters: y = ax^n
  int _coefficient = 1; // a
  int _power = 2; // n

  // Draggable point x-position along the curve (graph coordinates)
  double _pointX = 1.5;

  // Graph coordinate range
  final double _xMin = -4.0;
  final double _xMax = 4.0;
  final double _yMin = -5.0;
  final double _yMax = 10.0;

  bool _hasSpokenIntro = false;
  bool _showSteps = true;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Differentiation Explorer! '
          'This simulation shows the power rule for differentiation. '
          'Adjust the coefficient and power to change the function y equals a x to the n. '
          'Drag the point along the curve to see the tangent line and gradient at any position.',
          force: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ==================== Calculation helpers ====================

  /// Evaluate y = ax^n at a given x
  double _evaluateFunction(double x) {
    if (_power == 0) return _coefficient.toDouble();
    return _coefficient * math.pow(x, _power).toDouble();
  }

  /// Evaluate dy/dx = n * a * x^(n-1) at a given x
  double _evaluateDerivative(double x) {
    if (_power == 0) return 0.0;
    int derivCoeff = _power * _coefficient;
    int derivPower = _power - 1;
    if (derivPower == 0) return derivCoeff.toDouble();
    return derivCoeff * math.pow(x, derivPower).toDouble();
  }

  /// Format a term like 3x^2 for display
  String _formatTerm(int coeff, int power) {
    if (power == 0) return coeff.toString();
    if (coeff == 0) return '0';
    String c;
    if (coeff == 1) {
      c = '';
    } else if (coeff == -1) {
      c = '-';
    } else {
      c = coeff.toString();
    }
    if (power == 1) return '${c}x';
    return '${c}x^$power';
  }

  String get _functionString => 'y = ${_formatTerm(_coefficient, _power)}';

  String get _derivativeString {
    if (_power == 0) return 'dy/dx = 0';
    int derivCoeff = _power * _coefficient;
    int derivPower = _power - 1;
    return 'dy/dx = ${_formatTerm(derivCoeff, derivPower)}';
  }

  // ==================== Event handlers ====================

  void _onCoefficientChanged(int newValue) {
    setState(() {
      _coefficient = newValue;
    });
    context.read<SoundProvider>().playClick();
    _speakDerivative();
  }

  void _onPowerChanged(int newValue) {
    setState(() {
      _power = newValue;
    });
    context.read<SoundProvider>().playClick();
    _speakDerivative();
  }

  void _speakDerivative() {
    if (_power == 0) {
      speakSimulation(
        'The function is y equals $_coefficient, a constant. '
        'The derivative of a constant is zero.',
      );
      return;
    }
    int derivCoeff = _power * _coefficient;
    int derivPower = _power - 1;
    String derivTermSpoken;
    if (derivPower == 0) {
      derivTermSpoken = '$derivCoeff';
    } else if (derivPower == 1) {
      derivTermSpoken = '$derivCoeff x';
    } else {
      derivTermSpoken = '$derivCoeff x to the power $derivPower';
    }
    double gradientVal = _evaluateDerivative(_pointX);
    String gradStr = gradientVal.toStringAsFixed(2);
    speakSimulation(
      'The derivative of $_coefficient x to the power $_power is $derivTermSpoken. '
      'At x equals ${_pointX.toStringAsFixed(1)}, the gradient is $gradStr.',
    );
  }

  void _onPointDragged(double newGraphX) {
    double clamped = newGraphX.clamp(_xMin + 0.2, _xMax - 0.2);
    setState(() {
      _pointX = clamped;
    });
    context.read<SoundProvider>().playSlider();
  }

  // ==================== Build methods ====================

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Graph area
        Expanded(
          flex: 4,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.tealAccent.shade700),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      double pixelX = details.localPosition.dx;
                      double graphX = _pixelToGraphX(
                        pixelX,
                        constraints.maxWidth,
                      );
                      _onPointDragged(graphX);
                    },
                    onTapDown: (details) {
                      double pixelX = details.localPosition.dx;
                      double graphX = _pixelToGraphX(
                        pixelX,
                        constraints.maxWidth,
                      );
                      _onPointDragged(graphX);
                    },
                    child: CustomPaint(
                      painter: _DifferentiationGraphPainter(
                        coefficient: _coefficient,
                        power: _power,
                        pointX: _pointX,
                        xMin: _xMin,
                        xMax: _xMax,
                        yMin: _yMin,
                        yMax: _yMax,
                      ),
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // Derivative and gradient info bar
        _buildGradientInfoBar(),

        // Controls: coefficient and power spinners
        _buildCoefficientAndPowerControls(),

        // Step-by-step breakdown and formula
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                _buildDerivativeDisplay(),
                const SizedBox(height: 8),
                if (_showSteps) _buildStepByStep(),
                const SizedBox(height: 8),
                _buildFormulaReference(),
              ],
            ),
          ),
        ),

        // Bottom row: TTS toggle and steps toggle
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showSteps = !_showSteps;
                  });
                  context.read<SoundProvider>().playClick();
                },
                icon: Icon(
                  _showSteps
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white70,
                  size: 18,
                ),
                label: Text(
                  _showSteps ? 'Hide Steps' : 'Show Steps',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              buildTTSToggle(),
            ],
          ),
        ),
      ],
    );
  }

  /// Convert a pixel x coordinate to graph x coordinate
  double _pixelToGraphX(double pixelX, double width) {
    double fraction = pixelX / width;
    return _xMin + fraction * (_xMax - _xMin);
  }

  Widget _buildGradientInfoBar() {
    double yVal = _evaluateFunction(_pointX);
    double gradient = _evaluateDerivative(_pointX);
    bool yInRange = yVal.isFinite && yVal.abs() < 1e6;
    bool gradInRange = gradient.isFinite && gradient.abs() < 1e6;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.tealAccent.withAlpha(80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoChip(
            'x',
            _pointX.toStringAsFixed(2),
            Colors.white,
          ),
          _infoChip(
            'y',
            yInRange ? yVal.toStringAsFixed(2) : '--',
            Colors.cyanAccent,
          ),
          _infoChip(
            'dy/dx',
            gradInRange ? gradient.toStringAsFixed(2) : '--',
            Colors.orangeAccent,
          ),
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withAlpha(40),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Gradient',
                        style: TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        gradInRange ? gradient.toStringAsFixed(3) : '--',
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: color.withAlpha(180), fontSize: 10),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildCoefficientAndPowerControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'y = ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          _buildSpinner(
            'a',
            _coefficient,
            -5,
            5,
            _onCoefficientChanged,
            Colors.cyanAccent,
          ),
          const Text(
            'x',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          _buildPowerSelector(),
        ],
      ),
    );
  }

  Widget _buildSpinner(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
    Color accentColor,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            if (value > min) onChanged(value - 1);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.remove, color: Colors.white54, size: 18),
          ),
        ),
        Container(
          width: 42,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: accentColor.withAlpha(40),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            value.toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (value < max) onChanged(value + 1);
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.add, color: Colors.white54, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildPowerSelector() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Select Power (n)',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: 200,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(8, (i) {
                  bool isSelected = _power == i;
                  return GestureDetector(
                    onTap: () {
                      _onPowerChanged(i);
                      Navigator.pop(dialogContext);
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.tealAccent
                            : Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          i.toString(),
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orangeAccent.withAlpha(40),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _power.toString(),
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.arrow_drop_down,
              color: Colors.orangeAccent,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDerivativeDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        children: [
          Text(
            _functionString,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 20,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_downward, color: Colors.tealAccent, size: 24),
              SizedBox(width: 6),
              Text(
                'd/dx',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF22c55e), Color(0xFF16a34a)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _derivativeString,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepByStep() {
    int derivCoeff = _power * _coefficient;
    int derivPower = _power - 1;

    if (_power == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(),
            const SizedBox(height: 10),
            _buildStepRow(
              1,
              'y = $_coefficient (a constant)',
              Colors.cyan,
            ),
            _buildStepRow(
              2,
              'The derivative of any constant is 0',
              Colors.purple,
            ),
            _buildStepRow(3, 'dy/dx = 0', Colors.green),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepHeader(),
          const SizedBox(height: 10),
          _buildStepRow(
            1,
            'Identify: a = $_coefficient, n = $_power',
            Colors.cyan,
          ),
          _buildStepRow(
            2,
            'Power rule: dy/dx = n * a * x^(n-1)',
            Colors.cyan,
          ),
          _buildStepRow(
            3,
            'Multiply coefficient: $_power * $_coefficient = $derivCoeff',
            Colors.purple,
          ),
          _buildStepRow(
            4,
            'Reduce power: $_power - 1 = $derivPower',
            Colors.purple,
          ),
          _buildStepRow(
            5,
            'Result: ${_formatTerm(derivCoeff, derivPower)}',
            Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    return const Row(
      children: [
        Icon(Icons.lightbulb, color: Colors.amber, size: 18),
        SizedBox(width: 8),
        Text(
          'Step-by-Step',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStepRow(int number, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withAlpha(60),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormulaReference() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withAlpha(30),
            Colors.orange.withAlpha(30),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.functions, color: Colors.amber, size: 18),
              SizedBox(width: 8),
              Text(
                'Power Rule Reference',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _formulaBullet('If y = ax^n'),
          _formulaBullet('then dy/dx = n * a * x^(n-1)'),
          _formulaBullet('d/dx (constant) = 0'),
          _formulaBullet('The tangent gradient = dy/dx at that point'),
        ],
      ),
    );
  }

  Widget _formulaBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Custom Painter ====================

class _DifferentiationGraphPainter extends CustomPainter {
  final int coefficient;
  final int power;
  final double pointX;
  final double xMin;
  final double xMax;
  final double yMin;
  final double yMax;

  _DifferentiationGraphPainter({
    required this.coefficient,
    required this.power,
    required this.pointX,
    required this.xMin,
    required this.xMax,
    required this.yMin,
    required this.yMax,
  });

  /// Evaluate y = ax^n
  double _f(double x) {
    if (power == 0) return coefficient.toDouble();
    return coefficient * math.pow(x, power).toDouble();
  }

  /// Evaluate dy/dx = n * a * x^(n-1)
  double _dfdx(double x) {
    if (power == 0) return 0.0;
    int derivCoeff = power * coefficient;
    int derivPower = power - 1;
    if (derivPower == 0) return derivCoeff.toDouble();
    return derivCoeff * math.pow(x, derivPower).toDouble();
  }

  /// Convert graph x to pixel x
  double _toPixelX(double graphX, double width) {
    return (graphX - xMin) / (xMax - xMin) * width;
  }

  /// Convert graph y to pixel y (inverted for screen)
  double _toPixelY(double graphY, double height) {
    return height - (graphY - yMin) / (yMax - yMin) * height;
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawAxes(canvas, size);
    _drawCurve(canvas, size);
    _drawTangentLine(canvas, size);
    _drawPoint(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withAlpha(15)
      ..strokeWidth = 0.5;

    // Vertical grid lines
    for (int gx = xMin.ceil(); gx <= xMax.floor(); gx++) {
      double px = _toPixelX(gx.toDouble(), size.width);
      canvas.drawLine(Offset(px, 0), Offset(px, size.height), gridPaint);
    }

    // Horizontal grid lines
    for (int gy = yMin.ceil(); gy <= yMax.floor(); gy++) {
      double py = _toPixelY(gy.toDouble(), size.height);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), gridPaint);
    }
  }

  void _drawAxes(Canvas canvas, Size size) {
    final axisPaint = Paint()
      ..color = Colors.white.withAlpha(120)
      ..strokeWidth = 1.5;

    // X axis (y=0)
    double y0 = _toPixelY(0, size.height);
    if (y0 >= 0 && y0 <= size.height) {
      canvas.drawLine(Offset(0, y0), Offset(size.width, y0), axisPaint);
    }

    // Y axis (x=0)
    double x0 = _toPixelX(0, size.width);
    if (x0 >= 0 && x0 <= size.width) {
      canvas.drawLine(Offset(x0, 0), Offset(x0, size.height), axisPaint);
    }

    // Axis tick marks and labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // X axis labels
    for (int gx = xMin.ceil(); gx <= xMax.floor(); gx++) {
      if (gx == 0) continue;
      double px = _toPixelX(gx.toDouble(), size.width);
      if (y0 >= 0 && y0 <= size.height) {
        canvas.drawLine(
          Offset(px, y0 - 3),
          Offset(px, y0 + 3),
          axisPaint,
        );
      }
      textPainter.text = TextSpan(
        text: gx.toString(),
        style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 9),
      );
      textPainter.layout();
      double labelY = (y0 + 5).clamp(0, size.height - 12);
      textPainter.paint(canvas, Offset(px - textPainter.width / 2, labelY));
    }

    // Y axis labels
    for (int gy = yMin.ceil(); gy <= yMax.floor(); gy++) {
      if (gy == 0) continue;
      double py = _toPixelY(gy.toDouble(), size.height);
      if (x0 >= 0 && x0 <= size.width) {
        canvas.drawLine(
          Offset(x0 - 3, py),
          Offset(x0 + 3, py),
          axisPaint,
        );
      }
      textPainter.text = TextSpan(
        text: gy.toString(),
        style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 9),
      );
      textPainter.layout();
      double labelX = (x0 + 5).clamp(0, size.width - 20);
      textPainter.paint(canvas, Offset(labelX, py - textPainter.height / 2));
    }
  }

  void _drawCurve(Canvas canvas, Size size) {
    final curvePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    bool started = false;
    int steps = size.width.toInt();
    if (steps < 100) steps = 100;

    for (int i = 0; i <= steps; i++) {
      double graphX = xMin + (xMax - xMin) * i / steps;
      double graphY = _f(graphX);

      // Skip if value is way out of range
      if (!graphY.isFinite || graphY.abs() > 1e6) {
        started = false;
        continue;
      }

      double px = _toPixelX(graphX, size.width);
      double py = _toPixelY(graphY, size.height);

      // Only draw within reasonable bounds
      if (py < -size.height || py > size.height * 2) {
        started = false;
        continue;
      }

      if (!started) {
        path.moveTo(px, py);
        started = true;
      } else {
        path.lineTo(px, py);
      }
    }

    canvas.drawPath(path, curvePaint);
  }

  void _drawTangentLine(Canvas canvas, Size size) {
    double yAtPoint = _f(pointX);
    double slope = _dfdx(pointX);

    if (!yAtPoint.isFinite || !slope.isFinite) return;
    if (yAtPoint.abs() > 1e6 || slope.abs() > 1e6) return;

    // Draw a tangent line segment centred at the point,
    // extending a fixed distance in graph-x each direction.
    double extent = 1.5;
    double x1 = pointX - extent;
    double y1 = yAtPoint + slope * (x1 - pointX);
    double x2 = pointX + extent;
    double y2 = yAtPoint + slope * (x2 - pointX);

    final tangentPaint = Paint()
      ..color = Colors.orangeAccent.withAlpha(200)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    double px1 = _toPixelX(x1, size.width);
    double py1 = _toPixelY(y1, size.height);
    double px2 = _toPixelX(x2, size.width);
    double py2 = _toPixelY(y2, size.height);

    canvas.drawLine(Offset(px1, py1), Offset(px2, py2), tangentPaint);

    // Draw a dashed style visual indicator for the slope triangle
    double midPx = _toPixelX(pointX, size.width);
    double midPy = _toPixelY(yAtPoint, size.height);
    double runEndPx = _toPixelX(pointX + 1.0, size.width);
    double runEndPy = _toPixelY(yAtPoint, size.height);
    double riseEndPx = _toPixelX(pointX + 1.0, size.width);
    double riseEndPy = _toPixelY(yAtPoint + slope, size.height);

    // Only draw slope triangle if slope is reasonable
    if (slope.abs() < 20) {
      final slopeTrianglePaint = Paint()
        ..color = Colors.orangeAccent.withAlpha(60)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      // Horizontal run
      canvas.drawLine(
        Offset(midPx, midPy),
        Offset(runEndPx, runEndPy),
        slopeTrianglePaint,
      );
      // Vertical rise
      canvas.drawLine(
        Offset(riseEndPx, runEndPy),
        Offset(riseEndPx, riseEndPy),
        slopeTrianglePaint,
      );

      // Label "run = 1" and "rise = slope"
      final textPainter = TextPainter(textDirection: TextDirection.ltr);
      textPainter.text = const TextSpan(
        text: 'run=1',
        style: TextStyle(color: Colors.orangeAccent, fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset((midPx + runEndPx) / 2 - textPainter.width / 2, midPy + 4),
      );

      String riseStr = slope.toStringAsFixed(1);
      textPainter.text = TextSpan(
        text: 'rise=$riseStr',
        style: const TextStyle(color: Colors.orangeAccent, fontSize: 8),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(riseEndPx + 4, (runEndPy + riseEndPy) / 2 - 5),
      );
    }
  }

  void _drawPoint(Canvas canvas, Size size) {
    double yAtPoint = _f(pointX);
    if (!yAtPoint.isFinite || yAtPoint.abs() > 1e6) return;

    double px = _toPixelX(pointX, size.width);
    double py = _toPixelY(yAtPoint, size.height);

    // Outer glow
    final glowPaint = Paint()
      ..color = Colors.tealAccent.withAlpha(50)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(px, py), 14, glowPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = Colors.tealAccent.withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(px, py), 10, ringPaint);

    // Inner dot
    final dotPaint = Paint()
      ..color = Colors.tealAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(px, py), 5, dotPaint);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Function label at top-left
    String funcStr;
    if (power == 0) {
      funcStr = 'y = $coefficient';
    } else if (power == 1) {
      if (coefficient == 1) {
        funcStr = 'y = x';
      } else if (coefficient == -1) {
        funcStr = 'y = -x';
      } else {
        funcStr = 'y = ${coefficient}x';
      }
    } else {
      if (coefficient == 1) {
        funcStr = 'y = x^$power';
      } else if (coefficient == -1) {
        funcStr = 'y = -x^$power';
      } else {
        funcStr = 'y = ${coefficient}x^$power';
      }
    }

    textPainter.text = TextSpan(
      text: funcStr,
      style: const TextStyle(
        color: Colors.cyanAccent,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        fontFamily: 'monospace',
      ),
    );
    textPainter.layout();
    // Background behind label
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(8, 8, textPainter.width + 12, textPainter.height + 8),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.black.withAlpha(160),
    );
    textPainter.paint(canvas, const Offset(14, 12));

    // Instruction at bottom
    textPainter.text = TextSpan(
      text: 'Tap or drag to move point',
      style: TextStyle(
        color: Colors.white.withAlpha(100),
        fontSize: 10,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size.width / 2 - textPainter.width / 2,
        size.height - 18,
      ),
    );

    // X axis label
    textPainter.text = TextSpan(
      text: 'x',
      style: TextStyle(
        color: Colors.white.withAlpha(150),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(size.width - 16, _toPixelY(0, size.height) - 16),
    );

    // Y axis label
    textPainter.text = TextSpan(
      text: 'y',
      style: TextStyle(
        color: Colors.white.withAlpha(150),
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(_toPixelX(0, size.width) + 6, 4),
    );
  }

  @override
  bool shouldRepaint(covariant _DifferentiationGraphPainter oldDelegate) {
    return coefficient != oldDelegate.coefficient ||
        power != oldDelegate.power ||
        pointX != oldDelegate.pointX;
  }
}
