import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class CapacitorsSimulation extends StatefulWidget {
  const CapacitorsSimulation({super.key});

  @override
  State<CapacitorsSimulation> createState() => _CapacitorsSimulationState();
}

class _CapacitorsSimulationState extends State<CapacitorsSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  double _voltage = 5.0;
  double _capacitance = 100.0; // microfarads
  double _charge = 0.0;
  double _time = 0.0;
  bool _isCharging = false;
  bool _isDischarging = false;
  bool _hasSpokenIntro = false;

  final double _resistance = 1000.0; // ohms

  final List<Offset> _chargeData = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updateCharge);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Capacitors simulation! '
          'A capacitor stores electrical energy in an electric field between two plates. '
          'When charging, current flows onto the plates. When discharging, the stored energy is released. '
          'The time constant RC determines how quickly the capacitor charges or discharges.',
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

  void _updateCharge() {
    if (!_isCharging && !_isDischarging) return;

    setState(() {
      final dt = 0.016;
      _time += dt;

      // Time constant τ = RC (in seconds)
      final tau = _resistance * _capacitance / 1000000; // Convert µF to F
      final maxCharge = _capacitance * _voltage; // Q = CV

      if (_isCharging) {
        // Q = Q_max * (1 - e^(-t/RC))
        _charge = maxCharge * (1 - math.exp(-_time / tau));

        if (_charge >= maxCharge * 0.99) {
          _isCharging = false;
          _controller.stop();
          speakSimulation(
            'Capacitor fully charged. Charge: ${_charge.toStringAsFixed(1)} microcoulombs. '
            'Energy stored: ${(_getStoredEnergy() * 1000).toStringAsFixed(2)} millijoules.',
          );
        }
      } else if (_isDischarging) {
        // Q = Q_0 * e^(-t/RC)
        final initialCharge = _chargeData.isNotEmpty ? _chargeData.first.dy : _charge;
        _charge = initialCharge * math.exp(-_time / tau);

        if (_charge <= initialCharge * 0.01) {
          _isDischarging = false;
          _controller.stop();
          _charge = 0;
          speakSimulation(
            'Capacitor fully discharged. All stored energy has been released.',
          );
        }
      }

      // Record data
      if (_chargeData.isEmpty || _time - _chargeData.last.dx > 0.05) {
        _chargeData.add(Offset(_time, _charge));
      }
    });
  }

  void _startCharging() {
    if (_isCharging || _isDischarging) return;
    setState(() {
      _isCharging = true;
      _isDischarging = false;
      _time = 0;
      _chargeData.clear();
      _chargeData.add(Offset(0, _charge));
      _controller.repeat();
    });
    speakSimulation(
      'Charging capacitor. Current flows onto the plates, building up charge.',
      force: true,
    );
  }

  void _startDischarging() {
    if (_isCharging || _isDischarging || _charge < 1) return;
    setState(() {
      _isDischarging = true;
      _isCharging = false;
      _time = 0;
      _chargeData.clear();
      _chargeData.add(Offset(0, _charge));
      _controller.repeat();
    });
    speakSimulation(
      'Discharging capacitor. Stored energy is released as current flows.',
      force: true,
    );
  }

  void _reset() {
    setState(() {
      _isCharging = false;
      _isDischarging = false;
      _controller.stop();
      _charge = 0;
      _time = 0;
      _chargeData.clear();
    });
  }

  double _getStoredEnergy() {
    // E = 0.5 * C * V² = 0.5 * Q * V = 0.5 * Q² / C
    final chargeInCoulombs = _charge / 1000000;
    final capacitanceInFarads = _capacitance / 1000000;
    return 0.5 * chargeInCoulombs * chargeInCoulombs / capacitanceInFarads;
  }

  double _getCurrent() {
    if (!_isCharging && !_isDischarging) return 0;
    final tau = _resistance * _capacitance / 1000000;
    final maxCharge = _capacitance * _voltage;

    if (_isCharging) {
      return (maxCharge / 1000000 / tau) * math.exp(-_time / tau) * 1000; // mA
    } else {
      final initialCharge = _chargeData.isNotEmpty ? _chargeData.first.dy : _charge;
      return (initialCharge / 1000000 / tau) * math.exp(-_time / tau) * 1000; // mA
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxCharge = _capacitance * _voltage;
    final tau = _resistance * _capacitance / 1000000;
    final current = _getCurrent();
    final energy = _getStoredEnergy();

    return Column(
      children: [
        // Capacitor visualization
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.shade700),
            ),
            child: CustomPaint(
              painter: _CapacitorPainter(
                chargeLevel: _charge / maxCharge,
                isCharging: _isCharging,
                isDischarging: _isDischarging,
                current: current,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Charge graph
        Expanded(
          flex: 1,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _ChargeGraphPainter(
                dataPoints: _chargeData,
                maxCharge: maxCharge,
                tau: tau,
                isCharging: _isCharging,
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
            color: Colors.cyan.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Charge',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    '${_charge.toStringAsFixed(1)} µC',
                    style: const TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Current',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    '${current.toStringAsFixed(2)} mA',
                    style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('Energy',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    '${(energy * 1000).toStringAsFixed(2)} mJ',
                    style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ],
              ),
              Column(
                children: [
                  const Text('τ (RC)',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(
                    '${tau.toStringAsFixed(2)} s',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
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
              // Voltage slider
              Row(
                children: [
                  SizedBox(
                      width: 90,
                      child: Text('V: ${_voltage.toStringAsFixed(0)}V',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12))),
                  Expanded(
                    child: Slider(
                      value: _voltage,
                      min: 1,
                      max: 12,
                      onChanged: _isCharging || _isDischarging
                          ? null
                          : (v) => setState(() => _voltage = v),
                      activeColor: Colors.red,
                    ),
                  ),
                ],
              ),

              // Capacitance slider
              Row(
                children: [
                  SizedBox(
                      width: 90,
                      child: Text('C: ${_capacitance.toStringAsFixed(0)}µF',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12))),
                  Expanded(
                    child: Slider(
                      value: _capacitance,
                      min: 10,
                      max: 500,
                      onChanged: _isCharging || _isDischarging
                          ? null
                          : (v) => setState(() => _capacitance = v),
                      activeColor: Colors.cyan,
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
                        onPressed: _startCharging,
                        icon: const Icon(Icons.battery_charging_full, size: 18),
                        label: const Text('Charge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _startDischarging,
                        icon: const Icon(Icons.battery_0_bar, size: 18),
                        label: const Text('Discharge'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh, color: Colors.white),
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

class _CapacitorPainter extends CustomPainter {
  final double chargeLevel;
  final bool isCharging;
  final bool isDischarging;
  final double current;

  _CapacitorPainter({
    required this.chargeLevel,
    required this.isCharging,
    required this.isDischarging,
    required this.current,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw circuit
    final wirePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 3;

    // Left wire (to battery)
    canvas.drawLine(Offset(30, centerY), Offset(centerX - 40, centerY), wirePaint);

    // Right wire (through resistor back)
    canvas.drawLine(Offset(centerX + 40, centerY), Offset(size.width - 30, centerY), wirePaint);
    canvas.drawLine(Offset(size.width - 30, centerY), Offset(size.width - 30, centerY + 80), wirePaint);
    canvas.drawLine(Offset(size.width - 30, centerY + 80), Offset(30, centerY + 80), wirePaint);
    canvas.drawLine(Offset(30, centerY + 80), Offset(30, centerY), wirePaint);

    // Draw battery
    final batteryPaint = Paint()..strokeWidth = 4;
    batteryPaint.color = Colors.red;
    canvas.drawLine(Offset(30, centerY - 15), Offset(30, centerY + 15), batteryPaint);
    batteryPaint.color = Colors.blue;
    canvas.drawLine(Offset(22, centerY - 8), Offset(22, centerY + 8), batteryPaint);

    // Draw switch
    final switchPaint = Paint()
      ..color = isCharging || isDischarging ? Colors.green : Colors.red
      ..strokeWidth = 3;
    if (isCharging || isDischarging) {
      canvas.drawLine(Offset(50, centerY), Offset(70, centerY), switchPaint);
    } else {
      canvas.drawLine(Offset(50, centerY), Offset(65, centerY - 15), switchPaint);
    }
    canvas.drawCircle(Offset(50, centerY), 4, switchPaint..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(70, centerY), 4, switchPaint);

    // Draw capacitor plates
    final platePaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 6;

    // Left plate
    canvas.drawLine(
      Offset(centerX - 15, centerY - 40),
      Offset(centerX - 15, centerY + 40),
      platePaint,
    );

    // Right plate
    canvas.drawLine(
      Offset(centerX + 15, centerY - 40),
      Offset(centerX + 15, centerY + 40),
      platePaint,
    );

    // Draw charge on plates
    if (chargeLevel > 0.05) {
      final chargePaint = Paint()..style = PaintingStyle.fill;

      // Positive charges on left plate
      chargePaint.color = Colors.red;
      final chargeCount = (chargeLevel * 6).ceil();
      for (int i = 0; i < chargeCount; i++) {
        final y = centerY - 30 + i * 12;
        _drawPlusSign(canvas, Offset(centerX - 25, y), chargePaint);
      }

      // Negative charges on right plate
      chargePaint.color = Colors.blue;
      for (int i = 0; i < chargeCount; i++) {
        final y = centerY - 30 + i * 12;
        _drawMinusSign(canvas, Offset(centerX + 25, y), chargePaint);
      }

      // Electric field lines between plates
      final fieldPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: 0.4)
        ..strokeWidth = 1;
      for (int i = 0; i < 5; i++) {
        final y = centerY - 25 + i * 12.5;
        canvas.drawLine(Offset(centerX - 12, y), Offset(centerX + 12, y), fieldPaint);
        // Arrow
        canvas.drawLine(Offset(centerX + 5, y), Offset(centerX, y - 3), fieldPaint);
        canvas.drawLine(Offset(centerX + 5, y), Offset(centerX, y + 3), fieldPaint);
      }
    }

    // Draw resistor
    final resistorPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final resistorPath = Path();
    final rX = size.width - 30;
    final rY = centerY + 40;
    resistorPath.moveTo(rX, rY - 15);
    for (int i = 0; i < 6; i++) {
      resistorPath.lineTo(rX + (i.isEven ? -8 : 8), rY - 10 + i * 5);
    }
    resistorPath.lineTo(rX, rY + 20);
    canvas.drawPath(resistorPath, resistorPaint);

    // Draw current arrows if charging/discharging
    if ((isCharging || isDischarging) && current > 0.01) {
      final arrowPaint = Paint()
        ..color = Colors.yellow
        ..strokeWidth = 2;

      // Current direction
      final direction = isCharging ? 1.0 : -1.0;

      // Draw arrows along the wire
      for (double x = 80; x < centerX - 50; x += 40) {
        _drawArrow(canvas, Offset(x, centerY), direction > 0, arrowPaint);
      }
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'C',
      style: TextStyle(color: Colors.cyan, fontSize: 14, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(centerX - 5, centerY + 50));

    textPainter.text = const TextSpan(
      text: 'R',
      style: TextStyle(color: Colors.orange, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 20, centerY + 35));

    textPainter.text = const TextSpan(
      text: 'V',
      style: TextStyle(color: Colors.red, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(10, centerY - 25));
  }

  void _drawPlusSign(Canvas canvas, Offset center, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - 4, center.dy),
      Offset(center.dx + 4, center.dy),
      paint..strokeWidth = 2,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 4),
      Offset(center.dx, center.dy + 4),
      paint,
    );
  }

  void _drawMinusSign(Canvas canvas, Offset center, Paint paint) {
    canvas.drawLine(
      Offset(center.dx - 4, center.dy),
      Offset(center.dx + 4, center.dy),
      paint..strokeWidth = 2,
    );
  }

  void _drawArrow(Canvas canvas, Offset position, bool rightward, Paint paint) {
    final dir = rightward ? 1.0 : -1.0;
    canvas.drawLine(
      Offset(position.dx - 8 * dir, position.dy),
      Offset(position.dx + 8 * dir, position.dy),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx + 8 * dir, position.dy),
      Offset(position.dx + 3 * dir, position.dy - 4),
      paint,
    );
    canvas.drawLine(
      Offset(position.dx + 8 * dir, position.dy),
      Offset(position.dx + 3 * dir, position.dy + 4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CapacitorPainter oldDelegate) {
    return chargeLevel != oldDelegate.chargeLevel ||
        isCharging != oldDelegate.isCharging ||
        isDischarging != oldDelegate.isDischarging;
  }
}

class _ChargeGraphPainter extends CustomPainter {
  final List<Offset> dataPoints;
  final double maxCharge;
  final double tau;
  final bool isCharging;

  _ChargeGraphPainter({
    required this.dataPoints,
    required this.maxCharge,
    required this.tau,
    required this.isCharging,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 40.0;
    final graphWidth = size.width - padding - 10;
    final graphHeight = size.height - 30;

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

    // Draw max charge line
    final maxPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(padding, 15),
      Offset(size.width - 10, 15),
      maxPaint,
    );

    // Draw time constant markers
    final tauPaint = Paint()
      ..color = Colors.orange.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    for (int i = 1; i <= 3; i++) {
      final x = padding + (i * tau / (5 * tau)) * graphWidth;
      if (x < size.width - 10) {
        canvas.drawLine(
          Offset(x, 10),
          Offset(x, size.height - 20),
          tauPaint,
        );
      }
    }

    // Draw data curve
    if (dataPoints.length > 1) {
      final curvePaint = Paint()
        ..color = Colors.green
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      final maxTime = math.max(5 * tau, dataPoints.last.dx + 0.5);

      for (int i = 0; i < dataPoints.length; i++) {
        final point = dataPoints[i];
        final x = padding + (point.dx / maxTime) * graphWidth;
        final y = 10 + graphHeight * (1 - point.dy / maxCharge);

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, curvePaint);
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = const TextSpan(
      text: 'Q',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(5, 5));

    textPainter.text = const TextSpan(
      text: 't',
      style: TextStyle(color: Colors.white54, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 15, size.height - 15));

    textPainter.text = TextSpan(
      text: 'Q = ${maxCharge.toStringAsFixed(0)}µC',
      style: const TextStyle(color: Colors.cyan, fontSize: 9),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 70, 3));
  }

  @override
  bool shouldRepaint(covariant _ChargeGraphPainter oldDelegate) {
    return dataPoints.length != oldDelegate.dataPoints.length;
  }
}
