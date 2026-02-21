import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';
import '../providers/sound_provider.dart';

class IntegrationSimulation extends StatefulWidget {
  const IntegrationSimulation({super.key});

  @override
  State<IntegrationSimulation> createState() => _IntegrationSimulationState();
}

class _IntegrationSimulationState extends State<IntegrationSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  // Polynomial coefficients: y = _coeffA * x^_power
  double _coeffA = 1.0;
  int _power = 2;

  // Integration bounds
  double _lowerBound = 1.0;
  double _upperBound = 4.0;

  // Riemann sum rectangle count
  int _rectCount = 10;
  final List<int> _rectOptions = [5, 10, 20, 50];

  bool _hasSpokenIntro = false;
  bool _playedSuccessSound = false;

  // Allowed coefficient values
  final List<double> _coeffOptions = [0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0];
  final List<int> _powerOptions = [1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Integration simulation! '
          'Integration finds the area under a curve between two bounds. '
          'You can change the polynomial function, adjust the bounds, '
          'and see how Riemann sum rectangles approximate the exact area. '
          'More rectangles give a closer approximation to the true integral.',
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

  /// Evaluate y = a * x^n
  double _evaluateFunction(double x) {
    return _coeffA * math.pow(x, _power).toDouble();
  }

  /// Exact definite integral using the power rule:
  /// integral of a*x^n dx = a * x^(n+1) / (n+1) + C
  /// Definite integral = [a * x^(n+1) / (n+1)] evaluated from lower to upper
  double _exactIntegral() {
    final newPower = _power + 1;
    final upperVal = _coeffA * math.pow(_upperBound, newPower) / newPower;
    final lowerVal = _coeffA * math.pow(_lowerBound, newPower) / newPower;
    return upperVal - lowerVal;
  }

  /// Riemann sum approximation using right rectangles
  double _riemannSum() {
    final dx = (_upperBound - _lowerBound) / _rectCount;
    double sum = 0;
    for (int i = 0; i < _rectCount; i++) {
      final x = _lowerBound + (i + 0.5) * dx; // midpoint rule
      sum += _evaluateFunction(x) * dx;
    }
    return sum;
  }

  void _onCoeffChanged(double? value) {
    if (value == null) return;
    setState(() {
      _coeffA = value;
      _playedSuccessSound = false;
    });
    context.read<SoundProvider>().playClick();
    final coeffStr = value.toStringAsFixed(1);
    speakSimulation(
      'Coefficient set to $coeffStr. '
      'The curve is now $coeffStr times x to the power $_power.',
    );
    _checkAccuracy();
  }

  void _onPowerChanged(int? value) {
    if (value == null) return;
    setState(() {
      _power = value;
      _playedSuccessSound = false;
    });
    context.read<SoundProvider>().playClick();
    speakSimulation(
      'Power set to $value. The curve is now '
      '${_coeffA.toStringAsFixed(1)} times x to the power $value.',
    );
    _checkAccuracy();
  }

  void _onLowerBoundChanged(double value) {
    if (value >= _upperBound - 0.5) return;
    setState(() {
      _lowerBound = value;
      _playedSuccessSound = false;
    });
    context.read<SoundProvider>().playClick();
    speakSimulation(
      'Lower bound set to ${value.toStringAsFixed(1)}.',
    );
    _checkAccuracy();
  }

  void _onUpperBoundChanged(double value) {
    if (value <= _lowerBound + 0.5) return;
    setState(() {
      _upperBound = value;
      _playedSuccessSound = false;
    });
    context.read<SoundProvider>().playClick();
    speakSimulation(
      'Upper bound set to ${value.toStringAsFixed(1)}.',
    );
    _checkAccuracy();
  }

  void _onRectCountChanged(int count) {
    setState(() {
      _rectCount = count;
      _playedSuccessSound = false;
    });
    context.read<SoundProvider>().playWave();
    speakSimulation(
      'Using $count rectangles for the Riemann sum approximation. '
      'More rectangles give a more accurate result.',
      force: true,
    );
    _checkAccuracy();
  }

  void _checkAccuracy() {
    final exact = _exactIntegral();
    final approx = _riemannSum();
    if (exact.abs() < 0.001) return;
    final percentError = ((approx - exact) / exact).abs() * 100;
    if (percentError < 1.0 && !_playedSuccessSound) {
      _playedSuccessSound = true;
      context.read<SoundProvider>().playSuccess();
      speakSimulation(
        'Excellent! The Riemann sum approximation is within 1 percent '
        'of the exact integral value. '
        'This shows how increasing rectangles improves accuracy.',
        force: true,
      );
    }
  }

  String _buildFunctionString() {
    final coeffStr = _coeffA == 1.0 ? '' : _coeffA.toStringAsFixed(1);
    if (_power == 1) {
      final prefix = coeffStr.isEmpty ? '' : coeffStr;
      return '${prefix}x';
    }
    final prefix = coeffStr.isEmpty ? '' : coeffStr;
    return '${prefix}x^$_power';
  }

  String _buildAntiderivativeString() {
    final newPower = _power + 1;
    final coeffStr = _coeffA.toStringAsFixed(1);
    return '${coeffStr}x^$newPower / $newPower';
  }

  String _buildEvaluationUpperString() {
    final newPower = _power + 1;
    final upperPowVal = math.pow(_upperBound, newPower).toDouble();
    final upperResult = _coeffA * upperPowVal / newPower;
    final upperBoundStr = _upperBound.toStringAsFixed(1);
    final upperPowStr = upperPowVal.toStringAsFixed(2);
    final upperResultStr = upperResult.toStringAsFixed(3);
    return '  At x=$upperBoundStr: $_coeffA * $upperPowStr / $newPower = $upperResultStr';
  }

  String _buildEvaluationLowerString() {
    final newPower = _power + 1;
    final lowerPowVal = math.pow(_lowerBound, newPower).toDouble();
    final lowerResult = _coeffA * lowerPowVal / newPower;
    final lowerBoundStr = _lowerBound.toStringAsFixed(1);
    final lowerPowStr = lowerPowVal.toStringAsFixed(2);
    final lowerResultStr = lowerResult.toStringAsFixed(3);
    return '  At x=$lowerBoundStr: $_coeffA * $lowerPowStr / $newPower = $lowerResultStr';
  }

  @override
  Widget build(BuildContext context) {
    final exact = _exactIntegral();
    final approx = _riemannSum();
    final percentError = exact.abs() > 0.001
        ? ((approx - exact) / exact).abs() * 100
        : 0.0;
    final funcStr = _buildFunctionString();

    return Column(
      children: [
        // Visualization area
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.teal.shade700),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  CustomPaint(
                    painter: _IntegrationPainter(
                      coeffA: _coeffA,
                      power: _power,
                      lowerBound: _lowerBound,
                      upperBound: _upperBound,
                      rectCount: _rectCount,
                    ),
                    size: Size.infinite,
                  ),
                  // Function label
                  Positioned(
                    right: 12,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'y = $funcStr',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  // Area values overlay
                  Positioned(
                    left: 12,
                    top: 10,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exact area: ${exact.toStringAsFixed(3)}',
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Riemann sum: ${approx.toStringAsFixed(3)}',
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Error: ${percentError.toStringAsFixed(2)}%',
                            style: TextStyle(
                              color: percentError < 1
                                  ? Colors.greenAccent
                                  : percentError < 5
                                      ? Colors.yellowAccent
                                      : Colors.redAccent,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Integration formula and evaluation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.teal.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Power Rule for Integration',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'integral of $funcStr dx = ${_buildAntiderivativeString()} + C',
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Step-by-step evaluation:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _buildEvaluationUpperString(),
                style: const TextStyle(
                  color: Colors.white60,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
              Text(
                _buildEvaluationLowerString(),
                style: const TextStyle(
                  color: Colors.white60,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '  Result: ${exact.toStringAsFixed(3)}',
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Controls area
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Column(
              children: [
                // Coefficient and power spinners row
                Row(
                  children: [
                    // Coefficient picker
                    const Text(
                      'a = ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: DropdownButton<double>(
                        value: _coeffA,
                        dropdownColor: Colors.grey[850],
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 14,
                        ),
                        underline: const SizedBox.shrink(),
                        items: _coeffOptions.map((val) {
                          return DropdownMenuItem<double>(
                            value: val,
                            child: Text(val.toStringAsFixed(1)),
                          );
                        }).toList(),
                        onChanged: _onCoeffChanged,
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Power picker
                    const Text(
                      'n = ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal),
                      ),
                      child: DropdownButton<int>(
                        value: _power,
                        dropdownColor: Colors.grey[850],
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontSize: 14,
                        ),
                        underline: const SizedBox.shrink(),
                        items: _powerOptions.map((val) {
                          return DropdownMenuItem<int>(
                            value: val,
                            child: Text('$val'),
                          );
                        }).toList(),
                        onChanged: _onPowerChanged,
                      ),
                    ),
                    const Spacer(),
                    buildTTSToggle(),
                  ],
                ),

                const SizedBox(height: 8),

                // Bounds sliders
                _buildBoundSlider(
                  'Lower bound (a)',
                  _lowerBound,
                  0.0,
                  _upperBound - 0.5,
                  _onLowerBoundChanged,
                  Colors.cyan,
                ),
                _buildBoundSlider(
                  'Upper bound (b)',
                  _upperBound,
                  _lowerBound + 0.5,
                  6.0,
                  _onUpperBoundChanged,
                  Colors.amber,
                ),

                const SizedBox(height: 8),

                // Rectangle count toggle
                Row(
                  children: [
                    const Text(
                      'Rectangles: ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ..._rectOptions.map((count) {
                      final isSelected = count == _rectCount;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: GestureDetector(
                          onTap: () => _onRectCountChanged(count),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.teal
                                  : Colors.grey[800],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.tealAccent
                                    : Colors.grey[600]!,
                              ),
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBoundSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: color,
                thumbColor: color,
                inactiveTrackColor: color.withValues(alpha: 0.3),
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: ((max - min) * 10).round().clamp(1, 100),
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              value.toStringAsFixed(1),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// CustomPainter for the integration visualization
class _IntegrationPainter extends CustomPainter {
  final double coeffA;
  final int power;
  final double lowerBound;
  final double upperBound;
  final int rectCount;

  _IntegrationPainter({
    required this.coeffA,
    required this.power,
    required this.lowerBound,
    required this.upperBound,
    required this.rectCount,
  });

  /// Evaluate y = a * x^n
  double _f(double x) {
    return coeffA * math.pow(x, power).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Define plot region with margins
    const marginLeft = 50.0;
    const marginRight = 20.0;
    const marginTop = 50.0;
    const marginBottom = 40.0;
    final plotWidth = size.width - marginLeft - marginRight;
    final plotHeight = size.height - marginTop - marginBottom;

    // X-axis range
    const xMin = -0.5;
    const xMax = 7.0;

    // Find y-axis range: compute max y for the visible x range
    double yMax = 10.0;
    for (double x = 0; x <= xMax; x += 0.1) {
      final y = _f(x);
      if (y > yMax && y.isFinite) {
        yMax = y;
      }
    }
    yMax *= 1.15; // add padding
    const yMin = 0.0;

    // Coordinate transform helpers
    double toScreenX(double x) {
      return marginLeft + (x - xMin) / (xMax - xMin) * plotWidth;
    }

    double toScreenY(double y) {
      return marginTop + plotHeight - (y - yMin) / (yMax - yMin) * plotHeight;
    }

    // Draw grid
    _drawGrid(
      canvas,
      size,
      marginLeft,
      marginTop,
      plotWidth,
      plotHeight,
      xMin,
      xMax,
      yMin,
      yMax,
      toScreenX,
      toScreenY,
    );

    // Draw axes
    _drawAxes(
      canvas,
      size,
      marginLeft,
      marginTop,
      plotWidth,
      plotHeight,
      xMin,
      xMax,
      yMin,
      yMax,
      toScreenX,
      toScreenY,
    );

    // Draw shaded area under curve
    _drawShadedArea(
      canvas,
      toScreenX,
      toScreenY,
      yMin,
    );

    // Draw Riemann sum rectangles
    _drawRiemannRectangles(
      canvas,
      toScreenX,
      toScreenY,
    );

    // Draw the curve
    _drawCurve(
      canvas,
      xMin,
      xMax,
      toScreenX,
      toScreenY,
      yMax,
    );

    // Draw bound labels
    _drawBoundLabels(
      canvas,
      toScreenX,
      toScreenY,
    );
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double marginLeft,
    double marginTop,
    double plotWidth,
    double plotHeight,
    double xMin,
    double xMax,
    double yMin,
    double yMax,
    double Function(double) toScreenX,
    double Function(double) toScreenY,
  ) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // Vertical grid lines
    for (int i = 0; i <= 7; i++) {
      final x = i.toDouble();
      if (x < xMin || x > xMax) continue;
      final sx = toScreenX(x);
      canvas.drawLine(
        Offset(sx, marginTop),
        Offset(sx, marginTop + plotHeight),
        gridPaint,
      );
    }

    // Horizontal grid lines
    final yStep = _niceStep(yMax);
    for (double y = 0; y <= yMax; y += yStep) {
      final sy = toScreenY(y);
      canvas.drawLine(
        Offset(marginLeft, sy),
        Offset(marginLeft + plotWidth, sy),
        gridPaint,
      );
    }
  }

  void _drawAxes(
    Canvas canvas,
    Size size,
    double marginLeft,
    double marginTop,
    double plotWidth,
    double plotHeight,
    double xMin,
    double xMax,
    double yMin,
    double yMax,
    double Function(double) toScreenX,
    double Function(double) toScreenY,
  ) {
    final axisPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 1.5;

    // X-axis (at y=0)
    final xAxisY = toScreenY(0);
    canvas.drawLine(
      Offset(marginLeft, xAxisY),
      Offset(marginLeft + plotWidth, xAxisY),
      axisPaint,
    );

    // Y-axis (at x=0)
    final yAxisX = toScreenX(0);
    if (yAxisX >= marginLeft && yAxisX <= marginLeft + plotWidth) {
      canvas.drawLine(
        Offset(yAxisX, marginTop),
        Offset(yAxisX, marginTop + plotHeight),
        axisPaint,
      );
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // X-axis labels
    for (int i = 0; i <= 7; i++) {
      final x = i.toDouble();
      final sx = toScreenX(x);
      textPainter.text = TextSpan(
        text: '$i',
        style: const TextStyle(color: Colors.white54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(sx - 3, xAxisY + 4));
    }

    // Y-axis labels
    final yStep = _niceStep(yMax);
    for (double y = yStep; y <= yMax; y += yStep) {
      final sy = toScreenY(y);
      final yLabel = y.toStringAsFixed(y == y.roundToDouble() ? 0 : 1);
      textPainter.text = TextSpan(
        text: yLabel,
        style: const TextStyle(color: Colors.white54, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(marginLeft - textPainter.width - 6, sy - 6));
    }

    // Axis labels
    textPainter.text = const TextSpan(
      text: 'x',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(marginLeft + plotWidth + 4, xAxisY - 6),
    );

    textPainter.text = const TextSpan(
      text: 'y',
      style: TextStyle(
        color: Colors.white70,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    if (yAxisX >= marginLeft) {
      textPainter.paint(canvas, Offset(yAxisX + 6, marginTop - 4));
    }
  }

  void _drawShadedArea(
    Canvas canvas,
    double Function(double) toScreenX,
    double Function(double) toScreenY,
    double yMin,
  ) {
    final shadePaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;

    final shadePath = Path();
    final baseY = toScreenY(0);
    shadePath.moveTo(toScreenX(lowerBound), baseY);

    const steps = 200;
    final dx = (upperBound - lowerBound) / steps;
    for (int i = 0; i <= steps; i++) {
      final x = lowerBound + i * dx;
      final y = _f(x);
      shadePath.lineTo(toScreenX(x), toScreenY(y.isFinite ? y : 0));
    }

    shadePath.lineTo(toScreenX(upperBound), baseY);
    shadePath.close();

    canvas.drawPath(shadePath, shadePaint);
  }

  void _drawRiemannRectangles(
    Canvas canvas,
    double Function(double) toScreenX,
    double Function(double) toScreenY,
  ) {
    final rectFillPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;

    final rectStrokePaint = Paint()
      ..color = Colors.orangeAccent.withValues(alpha: 0.7)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dx = (upperBound - lowerBound) / rectCount;
    final baseY = toScreenY(0);

    for (int i = 0; i < rectCount; i++) {
      final xLeft = lowerBound + i * dx;
      final xMid = xLeft + dx * 0.5; // midpoint rule
      final yMid = _f(xMid);

      if (!yMid.isFinite) continue;

      final screenLeft = toScreenX(xLeft);
      final screenRight = toScreenX(xLeft + dx);
      final screenTop = toScreenY(yMid);

      final rect = Rect.fromLTRB(screenLeft, screenTop, screenRight, baseY);
      canvas.drawRect(rect, rectFillPaint);
      canvas.drawRect(rect, rectStrokePaint);
    }
  }

  void _drawCurve(
    Canvas canvas,
    double xMin,
    double xMax,
    double Function(double) toScreenX,
    double Function(double) toScreenY,
    double yMax,
  ) {
    final curvePaint = Paint()
      ..color = Colors.tealAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final curvePath = Path();
    bool started = false;

    // Draw curve from x=0 to xMax (only positive x for clean display)
    final startX = math.max(0.0, xMin);
    for (double x = startX; x <= xMax; x += 0.05) {
      final y = _f(x);
      if (!y.isFinite || y > yMax * 1.5 || y < -yMax * 0.5) {
        started = false;
        continue;
      }
      final sx = toScreenX(x);
      final sy = toScreenY(y);
      if (!started) {
        curvePath.moveTo(sx, sy);
        started = true;
      } else {
        curvePath.lineTo(sx, sy);
      }
    }

    canvas.drawPath(curvePath, curvePaint);
  }

  void _drawBoundLabels(
    Canvas canvas,
    double Function(double) toScreenX,
    double Function(double) toScreenY,
  ) {
    final baseY = toScreenY(0);
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Lower bound marker line
    final markerPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 2;

    final lowerX = toScreenX(lowerBound);
    final lowerY = toScreenY(_f(lowerBound));
    canvas.drawLine(Offset(lowerX, baseY), Offset(lowerX, lowerY), markerPaint);

    // Lower bound label
    textPainter.text = TextSpan(
      text: 'a=${lowerBound.toStringAsFixed(1)}',
      style: const TextStyle(
        color: Colors.cyan,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(lowerX - textPainter.width / 2, baseY + 16));

    // Upper bound marker line
    markerPaint.color = Colors.amber;
    final upperX = toScreenX(upperBound);
    final upperY = toScreenY(_f(upperBound));
    canvas.drawLine(Offset(upperX, baseY), Offset(upperX, upperY), markerPaint);

    // Upper bound label
    textPainter.text = TextSpan(
      text: 'b=${upperBound.toStringAsFixed(1)}',
      style: const TextStyle(
        color: Colors.amber,
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(upperX - textPainter.width / 2, baseY + 16));

    // Small dots at curve endpoints
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(lowerX, lowerY), 4, dotPaint);
    canvas.drawCircle(Offset(upperX, upperY), 4, dotPaint);
  }

  /// Compute a nice step size for grid lines
  double _niceStep(double range) {
    if (range <= 0) return 1;
    final rough = range / 5;
    final mag = math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final normalized = rough / mag;
    double nice;
    if (normalized <= 1.5) {
      nice = 1;
    } else if (normalized <= 3.5) {
      nice = 2;
    } else if (normalized <= 7.5) {
      nice = 5;
    } else {
      nice = 10;
    }
    return nice * mag;
  }

  @override
  bool shouldRepaint(covariant _IntegrationPainter oldDelegate) {
    return coeffA != oldDelegate.coeffA ||
        power != oldDelegate.power ||
        lowerBound != oldDelegate.lowerBound ||
        upperBound != oldDelegate.upperBound ||
        rectCount != oldDelegate.rectCount;
  }
}
