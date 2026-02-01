import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class VoltmeterSimulation extends StatefulWidget {
  const VoltmeterSimulation({super.key});

  @override
  State<VoltmeterSimulation> createState() => _VoltmeterSimulationState();
}

class _VoltmeterSimulationState extends State<VoltmeterSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _batteryVoltage = 6.0;
  double _r1 = 50.0;
  double _r2 = 50.0;
  bool _twoResistorMode = false;
  bool _hasSpokenIntro = false;

  double _displayedVoltage = 0.0;
  double _phase = 0.0;

  double get _totalResistance => _twoResistorMode ? _r1 + _r2 : _r1;
  double get _current => _batteryVoltage / _totalResistance;
  double get _vR1 => _twoResistorMode
      ? _batteryVoltage * _r1 / _totalResistance
      : _batteryVoltage;
  double get _vR2 => _twoResistorMode
      ? _batteryVoltage * _r2 / _totalResistance
      : 0.0;
  double get _targetVoltage => _vR1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Voltmeter simulation! '
          'A voltmeter measures the potential difference, or voltage, across a component. '
          'It must be connected in parallel and has very high internal resistance '
          'so it draws negligible current.',
          force: true,
        );
      }
    });
  }

  void _update() {
    setState(() {
      _displayedVoltage += (_targetVoltage - _displayedVoltage) * 0.05;
      _phase = (_phase + 0.02 * (_current * 10).clamp(0.5, 3.0)) % 1.0;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onBatteryVoltageChanged(double value) {
    setState(() => _batteryVoltage = value);
    speakSimulation(
      'Battery voltage set to ${value.toStringAsFixed(1)} volts. '
      'Voltmeter reads ${_vR1.toStringAsFixed(2)} volts across R1.',
    );
  }

  void _onR1Changed(double value) {
    setState(() => _r1 = value);
    speakSimulation(
      'Resistor 1 set to ${value.toStringAsFixed(0)} ohms. '
      'Voltage across R1 is ${_vR1.toStringAsFixed(2)} volts.',
    );
  }

  void _onR2Changed(double value) {
    setState(() => _r2 = value);
    speakSimulation(
      'Resistor 2 set to ${value.toStringAsFixed(0)} ohms. '
      'Voltage across R1 is ${_vR1.toStringAsFixed(2)} volts, '
      'across R2 is ${_vR2.toStringAsFixed(2)} volts.',
    );
  }

  void _onCircuitTypeChanged(bool twoResistors) {
    setState(() => _twoResistorMode = twoResistors);
    if (twoResistors) {
      speakSimulation(
        'Switched to two resistors in series. '
        'The voltage is now shared between both resistors using the potential divider rule. '
        'V1 equals V total times R1 divided by R1 plus R2.',
        force: true,
      );
    } else {
      speakSimulation(
        'Switched to single resistor mode. '
        'The full battery voltage appears across the single resistor.',
        force: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TTS toggle
        Padding(
          padding: const EdgeInsets.only(top: 8, right: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [buildTTSToggle()],
          ),
        ),

        // Canvas
        Expanded(
          flex: 3,
          child: CustomPaint(
            painter: _VoltmeterPainter(
              batteryVoltage: _batteryVoltage,
              r1: _r1,
              r2: _r2,
              twoResistorMode: _twoResistorMode,
              current: _current,
              vR1: _vR1,
              vR2: _vR2,
              displayedVoltage: _displayedVoltage,
              phase: _phase,
            ),
            size: Size.infinite,
          ),
        ),

        // Info panel
        _buildInfoPanel(),

        // Controls
        _buildControls(),
      ],
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                'V total',
                '${_batteryVoltage.toStringAsFixed(1)} V',
                Colors.yellow,
              ),
              _buildInfoItem(
                'I = V/R',
                '${(_current * 1000).toStringAsFixed(1)} mA',
                Colors.cyan,
              ),
              _buildInfoItem(
                'V across R1',
                '${_vR1.toStringAsFixed(2)} V',
                Colors.green,
              ),
              if (_twoResistorMode)
                _buildInfoItem(
                  'V across R2',
                  '${_vR2.toStringAsFixed(2)} V',
                  Colors.orange,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Voltmeter connected in PARALLEL  |  Very HIGH internal resistance',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          if (_twoResistorMode)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'V1 = Vtotal x R1/(R1+R2) = ${_batteryVoltage.toStringAsFixed(1)} x ${_r1.toStringAsFixed(0)}/${_totalResistance.toStringAsFixed(0)} = ${_vR1.toStringAsFixed(2)} V',
                style: const TextStyle(color: Colors.white70, fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Circuit type selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Single Resistor'),
                selected: !_twoResistorMode,
                selectedColor: Colors.cyan.shade700,
                onSelected: (selected) {
                  if (selected) _onCircuitTypeChanged(false);
                },
              ),
              const SizedBox(width: 12),
              ChoiceChip(
                label: const Text('Two Resistors (Series)'),
                selected: _twoResistorMode,
                selectedColor: Colors.cyan.shade700,
                onSelected: (selected) {
                  if (selected) _onCircuitTypeChanged(true);
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Battery voltage slider
          _buildSlider(
            'Battery (V)',
            _batteryVoltage,
            1,
            12,
            '${_batteryVoltage.toStringAsFixed(1)} V',
            _onBatteryVoltageChanged,
            Colors.yellow,
          ),

          // R1 slider
          _buildSlider(
            'R1 (\u03A9)',
            _r1,
            10,
            100,
            '${_r1.toStringAsFixed(0)} \u03A9',
            _onR1Changed,
            Colors.orange,
          ),

          // R2 slider (only in two-resistor mode)
          if (_twoResistorMode)
            _buildSlider(
              'R2 (\u03A9)',
              _r2,
              10,
              100,
              '${_r2.toStringAsFixed(0)} \u03A9',
              _onR2Changed,
              Colors.green,
            ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13),
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
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter for the voltmeter simulation canvas
// ---------------------------------------------------------------------------
class _VoltmeterPainter extends CustomPainter {
  final double batteryVoltage;
  final double r1;
  final double r2;
  final bool twoResistorMode;
  final double current;
  final double vR1;
  final double vR2;
  final double displayedVoltage;
  final double phase;

  _VoltmeterPainter({
    required this.batteryVoltage,
    required this.r1,
    required this.r2,
    required this.twoResistorMode,
    required this.current,
    required this.vR1,
    required this.vR2,
    required this.displayedVoltage,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Circuit rectangle
    final rectW = size.width * 0.48;
    final rectH = size.height * 0.60;
    final left = cx - rectW / 2;
    final top = cy - rectH / 2 + 10;
    final right = cx + rectW / 2;
    final bottom = cy + rectH / 2 + 10;

    final wirePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // --- Draw circuit wires ---
    // Top wire (battery sits at top-centre)
    canvas.drawLine(Offset(left, top), Offset(cx - 25, top), wirePaint);
    canvas.drawLine(Offset(cx + 25, top), Offset(right, top), wirePaint);
    // Right wire
    canvas.drawLine(Offset(right, top), Offset(right, bottom), wirePaint);
    // Bottom wire
    canvas.drawLine(Offset(left, bottom), Offset(right, bottom), wirePaint);
    // Left wire
    canvas.drawLine(Offset(left, top), Offset(left, bottom), wirePaint);

    // --- Battery at top ---
    _drawBattery(canvas, Offset(cx, top), batteryVoltage);

    // --- Resistor(s) on bottom wire ---
    if (twoResistorMode) {
      final r1x = left + (right - left) * 0.33;
      final r2x = left + (right - left) * 0.67;
      _drawResistor(canvas, Offset(r1x, bottom), r1, 'R1');
      _drawResistor(canvas, Offset(r2x, bottom), r2, 'R2');

      // Junction points for voltmeter taps (across R1)
      _drawVoltmeterConnectionWires(
        canvas,
        Offset(r1x - 35, bottom),
        Offset(r1x + 35, bottom),
        Offset(left - 55, cy + 20),
      );
    } else {
      _drawResistor(canvas, Offset(cx, bottom), r1, 'R1');

      _drawVoltmeterConnectionWires(
        canvas,
        Offset(left, bottom),
        Offset(right, bottom),
        Offset(left - 55, cy + 20),
      );
    }

    // --- Voltmeter symbol (circle with V) to the left ---
    _drawVoltmeterSymbol(canvas, Offset(left - 55, cy + 20));

    // --- Analog gauge ---
    final gaugeCenter = Offset(right + size.width * 0.18, cy);
    final gaugeRadius = math.min(size.width * 0.15, size.height * 0.22);
    _drawAnalogGauge(canvas, gaugeCenter, gaugeRadius, batteryVoltage, displayedVoltage);

    // --- Animated current dots ---
    _drawCurrentDots(canvas, left, top, right, bottom, cx);

    // --- Voltage labels ---
    _drawLabel(canvas, 'I = ${(current * 1000).toStringAsFixed(1)} mA',
        Offset(left + 4, top + 14), Colors.cyan, 10);
    _drawLabel(canvas, 'V = ${batteryVoltage.toStringAsFixed(1)} V',
        Offset(cx - 18, top - 28), Colors.yellow, 10);
  }

  // ---- Battery symbol ----
  void _drawBattery(Canvas canvas, Offset center, double voltage) {
    final paint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Long line (+)
    canvas.drawLine(
      Offset(center.dx + 8, center.dy - 14),
      Offset(center.dx + 8, center.dy + 14),
      paint,
    );
    // Short line (-)
    paint.strokeWidth = 5;
    canvas.drawLine(
      Offset(center.dx - 8, center.dy - 8),
      Offset(center.dx - 8, center.dy + 8),
      paint,
    );

    // +/- labels
    _drawLabel(canvas, '+', Offset(center.dx + 14, center.dy - 8), Colors.yellow, 11);
    _drawLabel(canvas, '\u2212', Offset(center.dx - 22, center.dy - 8), Colors.yellow, 11);
  }

  // ---- Zigzag resistor ----
  void _drawResistor(Canvas canvas, Offset center, double value, String label) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(center.dx - 30, center.dy);
    const zigCount = 5;
    for (int i = 0; i < zigCount; i++) {
      final x = center.dx - 30 + (i + 0.5) * 60 / zigCount;
      final yOff = (i.isEven ? -10 : 10).toDouble();
      path.lineTo(x, center.dy + yOff);
    }
    path.lineTo(center.dx + 30, center.dy);
    canvas.drawPath(path, paint);

    _drawLabel(canvas, '$label=${value.toStringAsFixed(0)}\u03A9',
        Offset(center.dx - 28, center.dy + 14), Colors.orange, 10);
  }

  // ---- Dashed wires from main circuit to voltmeter ----
  void _drawVoltmeterConnectionWires(
      Canvas canvas, Offset tapA, Offset tapB, Offset vmCenter) {
    final dashPaint = Paint()
      ..color = Colors.redAccent.withValues(alpha: 0.7)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw dashed lines from taps to voltmeter
    _drawDashedLine(canvas, tapA, Offset(vmCenter.dx, vmCenter.dy - 14), dashPaint);
    _drawDashedLine(canvas, tapB, Offset(vmCenter.dx, vmCenter.dy + 14), dashPaint);

    // Small junction dots on the main circuit
    final dotPaint = Paint()..color = Colors.redAccent;
    canvas.drawCircle(tapA, 4, dotPaint);
    canvas.drawCircle(tapB, 4, dotPaint);
  }

  void _drawDashedLine(Canvas canvas, Offset a, Offset b, Paint paint) {
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final dist = math.sqrt(dx * dx + dy * dy);
    const dashLen = 6.0;
    const gapLen = 4.0;
    final steps = dist / (dashLen + gapLen);
    for (int i = 0; i < steps; i++) {
      final t1 = i * (dashLen + gapLen) / dist;
      final t2 = (i * (dashLen + gapLen) + dashLen) / dist;
      if (t2 > 1) break;
      canvas.drawLine(
        Offset(a.dx + dx * t1, a.dy + dy * t1),
        Offset(a.dx + dx * t2, a.dy + dy * t2),
        paint,
      );
    }
  }

  // ---- Voltmeter circle with "V" ----
  void _drawVoltmeterSymbol(Canvas canvas, Offset center) {
    final circlePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, 16, circlePaint);

    final tp = TextPainter(
      text: const TextSpan(
        text: 'V',
        style: TextStyle(
          color: Colors.redAccent,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));

    _drawLabel(canvas, 'Voltmeter',
        Offset(center.dx - 24, center.dy + 20), Colors.redAccent, 9);
  }

  // ---- Large analog gauge ----
  void _drawAnalogGauge(Canvas canvas, Offset center, double radius,
      double maxV, double reading) {
    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    final arcPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      arcPaint,
    );
    // Outer rim
    canvas.drawCircle(center, radius, arcPaint);

    // Scale markings
    final tickPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5;
    final majorDivisions = maxV.ceil();
    for (int i = 0; i <= majorDivisions; i++) {
      final frac = i / majorDivisions;
      final angle = math.pi + frac * math.pi;
      final outerP = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      final isMajor = (i % (majorDivisions > 6 ? 2 : 1)) == 0;
      final innerP = Offset(
        center.dx + (radius - (isMajor ? 16 : 10)) * math.cos(angle),
        center.dy + (radius - (isMajor ? 16 : 10)) * math.sin(angle),
      );
      canvas.drawLine(innerP, outerP, tickPaint);

      // Number labels for major ticks
      if (isMajor) {
        final labelVal = (i / majorDivisions * maxV);
        final labelP = Offset(
          center.dx + (radius - 26) * math.cos(angle) - 6,
          center.dy + (radius - 26) * math.sin(angle) - 6,
        );
        _drawLabel(canvas, labelVal.toStringAsFixed(0), labelP, Colors.white60, 9);
      }
    }

    // Needle
    final clampedReading = reading.clamp(0.0, maxV);
    final needleAngle = math.pi + (clampedReading / maxV) * math.pi;
    final needleTip = Offset(
      center.dx + (radius - 18) * math.cos(needleAngle),
      center.dy + (radius - 18) * math.sin(needleAngle),
    );
    final needlePaint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleTip, needlePaint);

    // Center pivot dot
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // Digital readout below gauge
    final readoutBg = Paint()..color = Colors.black;
    final readoutRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.48),
        width: radius * 0.9,
        height: 22,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(readoutRect, readoutBg);

    final tp = TextPainter(
      text: TextSpan(
        text: '${reading.toStringAsFixed(2)} V',
        style: const TextStyle(
          color: Colors.greenAccent,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(
        center.dx - tp.width / 2,
        center.dy + radius * 0.48 - tp.height / 2,
      ),
    );

    // "VOLTS" label
    _drawLabel(canvas, 'VOLTS',
        Offset(center.dx - 16, center.dy + radius * 0.48 + 14), Colors.white38, 9);
  }

  // ---- Animated current dots ----
  void _drawCurrentDots(Canvas canvas, double left, double top, double right,
      double bottom, double cx) {
    final dotPaint = Paint()..color = Colors.yellowAccent;
    final dotCount = (current * 200).clamp(4, 14).toInt();

    final perimeter = 2 * (right - left) + 2 * (bottom - top);

    for (int i = 0; i < dotCount; i++) {
      final t = (phase + i / dotCount) % 1.0;
      final d = t * perimeter;

      Offset pos;
      final segTop = right - left; // top segment
      final segRight = bottom - top; // right segment
      final segBottom = right - left; // bottom segment

      if (d < segTop) {
        // Top wire: left to right
        pos = Offset(left + d, top);
      } else if (d < segTop + segRight) {
        // Right wire: top to bottom
        pos = Offset(right, top + (d - segTop));
      } else if (d < segTop + segRight + segBottom) {
        // Bottom wire: right to left
        pos = Offset(right - (d - segTop - segRight), bottom);
      } else {
        // Left wire: bottom to top
        pos = Offset(left, bottom - (d - segTop - segRight - segBottom));
      }

      canvas.drawCircle(pos, 3.5, dotPaint);
    }
  }

  // ---- Utility label painter ----
  void _drawLabel(Canvas canvas, String text, Offset position, Color color,
      double fontSize) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, position);
  }

  @override
  bool shouldRepaint(covariant _VoltmeterPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.displayedVoltage != displayedVoltage ||
        oldDelegate.batteryVoltage != batteryVoltage ||
        oldDelegate.r1 != r1 ||
        oldDelegate.r2 != r2 ||
        oldDelegate.twoResistorMode != twoResistorMode;
  }
}
