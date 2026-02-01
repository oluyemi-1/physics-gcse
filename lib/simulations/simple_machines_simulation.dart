import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Simple Machines Simulation demonstrating mechanical advantage,
/// velocity ratio, and efficiency for levers, pulleys, inclined planes,
/// and wheel & axle systems.
class SimpleMachinesSimulation extends StatefulWidget {
  const SimpleMachinesSimulation({super.key});

  @override
  State<SimpleMachinesSimulation> createState() =>
      _SimpleMachinesSimulationState();
}

enum MachineType { lever, pulley, inclinedPlane, wheelAndAxle }

class _SimpleMachinesSimulationState extends State<SimpleMachinesSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;

  MachineType _machineType = MachineType.lever;
  double _load = 200.0; // N
  double _effort = 100.0; // N
  double _geometryParam = 2.0; // meaning varies by machine type

  bool _hasSpokenIntro = false;

  // Fixed reference values per machine type
  static const double _leverLoadArm = 1.0; // m
  static const double _inclinedPlaneHeight = 2.0; // m
  static const double _wheelAxleRadius = 0.5; // m

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addListener(_update);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Simple Machines Simulation. '
          'Simple machines make work easier by changing the size or direction of a force. '
          'Explore levers, pulleys, inclined planes, and wheel and axle systems. '
          'Adjust the load, effort, and geometry to see how mechanical advantage, '
          'velocity ratio, and efficiency change.',
          force: true,
        );
      }
    });
  }

  void _update() {
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- Computed physics values ---

  String get _geometryLabel {
    switch (_machineType) {
      case MachineType.lever:
        return 'Effort Arm';
      case MachineType.pulley:
        return 'Ropes';
      case MachineType.inclinedPlane:
        return 'Slope Length';
      case MachineType.wheelAndAxle:
        return 'Wheel Radius';
    }
  }

  String get _geometryUnit {
    switch (_machineType) {
      case MachineType.lever:
        return 'm';
      case MachineType.pulley:
        return '';
      case MachineType.inclinedPlane:
        return 'm';
      case MachineType.wheelAndAxle:
        return 'm';
    }
  }

  double get _geometryMin {
    switch (_machineType) {
      case MachineType.lever:
        return 0.5;
      case MachineType.pulley:
        return 1.0;
      case MachineType.inclinedPlane:
        return 2.0;
      case MachineType.wheelAndAxle:
        return 0.5;
    }
  }

  double get _geometryMax {
    switch (_machineType) {
      case MachineType.lever:
        return 5.0;
      case MachineType.pulley:
        return 6.0;
      case MachineType.inclinedPlane:
        return 10.0;
      case MachineType.wheelAndAxle:
        return 5.0;
    }
  }

  int get _geometryDivisions {
    switch (_machineType) {
      case MachineType.pulley:
        return 5; // 1-6 in integer steps
      default:
        return 0; // continuous
    }
  }

  double get _mechanicalAdvantage => _load / _effort;

  double get _velocityRatio {
    switch (_machineType) {
      case MachineType.lever:
        return _geometryParam / _leverLoadArm;
      case MachineType.pulley:
        return _geometryParam.roundToDouble();
      case MachineType.inclinedPlane:
        return _geometryParam / _inclinedPlaneHeight;
      case MachineType.wheelAndAxle:
        return _geometryParam / _wheelAxleRadius;
    }
  }

  double get _efficiency {
    if (_velocityRatio == 0) return 0;
    final raw = (_mechanicalAdvantage / _velocityRatio) * 100;
    return raw.clamp(0, 100);
  }

  double get _effortDistance {
    switch (_machineType) {
      case MachineType.lever:
        return _geometryParam; // effort arm length
      case MachineType.pulley:
        return _geometryParam.roundToDouble(); // rope pulled = n * load distance
      case MachineType.inclinedPlane:
        return _geometryParam; // slope length
      case MachineType.wheelAndAxle:
        return 2 * math.pi * _geometryParam; // circumference of wheel
    }
  }

  double get _loadDistance {
    switch (_machineType) {
      case MachineType.lever:
        return _leverLoadArm;
      case MachineType.pulley:
        return 1.0; // unit lift
      case MachineType.inclinedPlane:
        return _inclinedPlaneHeight;
      case MachineType.wheelAndAxle:
        return 2 * math.pi * _wheelAxleRadius;
    }
  }

  double get _workInput => _effort * _effortDistance;
  double get _workOutput => _load * _loadDistance;

  Color get _efficiencyColor {
    if (_efficiency >= 80) return Colors.green;
    if (_efficiency >= 50) return Colors.amber;
    return Colors.red;
  }

  // --- Callbacks ---

  void _onMachineTypeChanged(MachineType type) {
    setState(() {
      _machineType = type;
      // Reset geometry to sensible default for each type
      switch (type) {
        case MachineType.lever:
          _geometryParam = 2.0;
          break;
        case MachineType.pulley:
          _geometryParam = 2.0;
          break;
        case MachineType.inclinedPlane:
          _geometryParam = 5.0;
          break;
        case MachineType.wheelAndAxle:
          _geometryParam = 2.0;
          break;
      }
    });
    _speakMachineDescription(type);
  }

  void _speakMachineDescription(MachineType type) {
    switch (type) {
      case MachineType.lever:
        speakSimulation(
          'Lever selected. A lever is a rigid bar that rotates around a fulcrum. '
          'The effort arm is the distance from the fulcrum to where effort is applied. '
          'The load arm is fixed at $_leverLoadArm metre. '
          'Velocity ratio equals effort arm divided by load arm.',
          force: true,
        );
        break;
      case MachineType.pulley:
        speakSimulation(
          'Pulley selected. A pulley system uses ropes and wheels to lift loads. '
          'The velocity ratio equals the number of supporting ropes. '
          'More ropes means less effort needed but more rope to pull.',
          force: true,
        );
        break;
      case MachineType.inclinedPlane:
        speakSimulation(
          'Inclined Plane selected. A ramp reduces the effort needed to raise a load. '
          'The height is fixed at $_inclinedPlaneHeight metres. '
          'Velocity ratio equals slope length divided by height. '
          'A longer, gentler slope gives a greater mechanical advantage.',
          force: true,
        );
        break;
      case MachineType.wheelAndAxle:
        speakSimulation(
          'Wheel and Axle selected. A large wheel is attached to a smaller axle. '
          'The axle radius is fixed at $_wheelAxleRadius metres. '
          'Velocity ratio equals wheel radius divided by axle radius. '
          'A larger wheel gives greater mechanical advantage.',
          force: true,
        );
        break;
    }
  }

  void _onLoadChanged(double value) {
    setState(() => _load = value);
    speakSimulation(
      'Load set to ${value.toStringAsFixed(0)} Newtons. '
      'Mechanical advantage is now ${_mechanicalAdvantage.toStringAsFixed(2)}. '
      'Efficiency is ${_efficiency.toStringAsFixed(1)} percent.',
    );
  }

  void _onEffortChanged(double value) {
    setState(() => _effort = value);
    speakSimulation(
      'Effort set to ${value.toStringAsFixed(0)} Newtons. '
      'Mechanical advantage is now ${_mechanicalAdvantage.toStringAsFixed(2)}. '
      'Efficiency is ${_efficiency.toStringAsFixed(1)} percent.',
    );
  }

  void _onGeometryChanged(double value) {
    setState(() {
      _geometryParam =
          _machineType == MachineType.pulley ? value.roundToDouble() : value;
    });
    final paramDisplay = _machineType == MachineType.pulley
        ? '${_geometryParam.toInt()}'
        : _geometryParam.toStringAsFixed(1);
    speakSimulation(
      '$_geometryLabel set to $paramDisplay $_geometryUnit. '
      'Velocity ratio is now ${_velocityRatio.toStringAsFixed(2)}. '
      'Efficiency is ${_efficiency.toStringAsFixed(1)} percent.',
    );
  }

  // --- Build methods ---

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Machine type selector
        _buildMachineSelector(),
        // Canvas area
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _SimpleMachinesPainter(
                    machineType: _machineType,
                    load: _load,
                    effort: _effort,
                    geometryParam: _geometryParam,
                    efficiency: _efficiency,
                    animationValue: _controller.value,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Info panel
        _buildInfoPanel(),
        // Controls
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: _buildControls(),
          ),
        ),
      ],
    );
  }

  Widget _buildMachineSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: MachineType.values.map((type) {
            final label = _labelForType(type);
            final icon = _iconForType(type);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                avatar: Icon(icon, size: 16),
                label: Text(label, style: const TextStyle(fontSize: 11)),
                selected: _machineType == type,
                selectedColor: Colors.teal.withValues(alpha: 0.6),
                onSelected: (selected) {
                  if (selected) _onMachineTypeChanged(type);
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  String _labelForType(MachineType type) {
    switch (type) {
      case MachineType.lever:
        return 'Lever';
      case MachineType.pulley:
        return 'Pulley';
      case MachineType.inclinedPlane:
        return 'Inclined Plane';
      case MachineType.wheelAndAxle:
        return 'Wheel & Axle';
    }
  }

  IconData _iconForType(MachineType type) {
    switch (type) {
      case MachineType.lever:
        return Icons.balance;
      case MachineType.pulley:
        return Icons.precision_manufacturing;
      case MachineType.inclinedPlane:
        return Icons.signal_cellular_4_bar;
      case MachineType.wheelAndAxle:
        return Icons.settings;
    }
  }

  Widget _buildInfoPanel() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _efficiencyColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          // Top row: MA, VR, Efficiency
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                  'M.A.', _mechanicalAdvantage.toStringAsFixed(2), Colors.cyan),
              _buildInfoItem(
                  'V.R.', _velocityRatio.toStringAsFixed(2), Colors.orange),
              _buildInfoItem(
                'Efficiency',
                '${_efficiency.toStringAsFixed(1)}%',
                _efficiencyColor,
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Bottom row: Work in, Work out
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem('Work In',
                  '${_workInput.toStringAsFixed(1)} J', Colors.green),
              _buildInfoItem('Work Out',
                  '${_workOutput.toStringAsFixed(1)} J', Colors.blue),
            ],
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
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }

  Widget _buildControls() {
    final geomDisplay = _machineType == MachineType.pulley
        ? '${_geometryParam.toInt()} ropes'
        : '${_geometryParam.toStringAsFixed(1)} $_geometryUnit';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [buildTTSToggle()],
        ),
        _buildSlider(
          'Load',
          _load,
          10,
          500,
          '${_load.toStringAsFixed(0)} N',
          _onLoadChanged,
          Colors.blue,
        ),
        _buildSlider(
          'Effort',
          _effort,
          10,
          500,
          '${_effort.toStringAsFixed(0)} N',
          _onEffortChanged,
          Colors.green,
        ),
        _buildSlider(
          _geometryLabel,
          _geometryParam,
          _geometryMin,
          _geometryMax,
          geomDisplay,
          _onGeometryChanged,
          Colors.orange,
          divisions: _geometryDivisions > 0 ? _geometryDivisions : null,
        ),
        const SizedBox(height: 8),
        // Key formulae
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
          ),
          child: const Column(
            children: [
              Text(
                'M.A. = Load / Effort    |    Efficiency = (M.A. / V.R.) x 100%',
                style: TextStyle(
                    color: Colors.white70, fontSize: 10, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2),
              Text(
                'Work = Force x Distance',
                style: TextStyle(
                    color: Colors.white54, fontSize: 10, fontFamily: 'monospace'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    String displayValue,
    ValueChanged<double> onChanged,
    Color color, {
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: color, fontSize: 12)),
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
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 72,
            child: Text(
              displayValue,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// CustomPainter
// ---------------------------------------------------------------------------

class _SimpleMachinesPainter extends CustomPainter {
  final MachineType machineType;
  final double load;
  final double effort;
  final double geometryParam;
  final double efficiency;
  final double animationValue;

  _SimpleMachinesPainter({
    required this.machineType,
    required this.load,
    required this.effort,
    required this.geometryParam,
    required this.efficiency,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (machineType) {
      case MachineType.lever:
        _drawLever(canvas, size);
        break;
      case MachineType.pulley:
        _drawPulley(canvas, size);
        break;
      case MachineType.inclinedPlane:
        _drawInclinedPlane(canvas, size);
        break;
      case MachineType.wheelAndAxle:
        _drawWheelAndAxle(canvas, size);
        break;
    }

    // Efficiency badge in top-right
    _drawEfficiencyBadge(canvas, size);
  }

  // ---- Lever ----
  void _drawLever(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final baseY = size.height * 0.7;
    final beamLen = size.width * 0.8;

    // Total arm = effort arm + load arm
    final totalArm = geometryParam + 1.0; // load arm fixed at 1m
    final fulcrumX = cx - beamLen / 2 + (geometryParam / totalArm) * beamLen;

    // Draw ground line
    final groundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.4)
      ..strokeWidth = 2;
    canvas.drawLine(
        Offset(20, baseY + 35), Offset(size.width - 20, baseY + 35), groundPaint);

    // Fulcrum triangle
    final fulcrumPath = Path()
      ..moveTo(fulcrumX, baseY)
      ..lineTo(fulcrumX - 18, baseY + 35)
      ..lineTo(fulcrumX + 18, baseY + 35)
      ..close();
    canvas.drawPath(fulcrumPath, Paint()..color = Colors.grey);
    canvas.drawPath(
      fulcrumPath,
      Paint()
        ..color = Colors.white38
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Beam
    final beamLeft = cx - beamLen / 2;
    final beamRight = cx + beamLen / 2;
    final beamPaint = Paint()
      ..color = Colors.brown.shade400
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(beamLeft, baseY), Offset(beamRight, baseY), beamPaint);

    // Load side (left of fulcrum)
    final loadX = beamLeft + 10;
    _drawForceArrow(canvas, Offset(loadX, baseY), load, true, Colors.blue,
        '${load.toStringAsFixed(0)} N');

    // Effort side (right of fulcrum)
    final effortX = beamRight - 10;
    _drawForceArrow(canvas, Offset(effortX, baseY), effort, true, Colors.green,
        '${effort.toStringAsFixed(0)} N');

    // Arm labels
    _drawLabel(canvas, Offset((beamLeft + fulcrumX) / 2, baseY - 30),
        'Load arm: 1.0 m', Colors.blue);
    _drawLabel(canvas, Offset((fulcrumX + beamRight) / 2, baseY - 30),
        'Effort arm: ${geometryParam.toStringAsFixed(1)} m', Colors.green);

    // Fulcrum label
    _drawLabel(
        canvas, Offset(fulcrumX, baseY + 40), 'Fulcrum', Colors.white54);

    // Title
    _drawLabel(canvas, Offset(cx, 16), 'LEVER', Colors.white70);
  }

  // ---- Pulley ----
  void _drawPulley(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final topY = 40.0;
    final pulleyRadius = 22.0;
    final numRopes = geometryParam.round();

    // Support beam
    final beamPaint = Paint()
      ..color = Colors.brown.shade600
      ..strokeWidth = 8;
    canvas.drawLine(Offset(cx - 80, topY - 15), Offset(cx + 80, topY - 15), beamPaint);

    // Pulley wheel
    final wheelPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, topY + pulleyRadius), pulleyRadius, wheelPaint);
    final groovePaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
        Offset(cx, topY + pulleyRadius), pulleyRadius - 3, groovePaint);
    canvas.drawCircle(
        Offset(cx, topY + pulleyRadius), 4, Paint()..color = Colors.grey.shade800);

    // Bracket
    canvas.drawLine(
      Offset(cx, topY - 15),
      Offset(cx, topY),
      Paint()
        ..color = Colors.grey.shade700
        ..strokeWidth = 4,
    );

    // Rope and load
    final ropePaint = Paint()
      ..color = Colors.amber.shade700
      ..strokeWidth = 3;
    final loadY = size.height * 0.65;

    // Left rope (to load)
    canvas.drawLine(
        Offset(cx - pulleyRadius, topY + pulleyRadius),
        Offset(cx - pulleyRadius, loadY),
        ropePaint);

    // Right rope (effort side)
    canvas.drawLine(
        Offset(cx + pulleyRadius, topY + pulleyRadius),
        Offset(cx + pulleyRadius, size.height - 30),
        ropePaint);

    // Load box
    final boxSize = 44.0;
    final loadCx = cx - pulleyRadius;
    final boxRect =
        Rect.fromCenter(center: Offset(loadCx, loadY + boxSize / 2), width: boxSize, height: boxSize);
    canvas.drawRect(boxRect, Paint()..color = Colors.blue.shade700);
    canvas.drawRect(
      boxRect,
      Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _drawLabel(canvas, Offset(loadCx, loadY + boxSize / 2 - 6),
        '${load.toStringAsFixed(0)} N', Colors.white);

    // Load arrow (down)
    _drawForceArrow(
        canvas,
        Offset(loadCx, loadY + boxSize + 4),
        load,
        true,
        Colors.blue,
        'Load');

    // Effort arrow (down, pulling rope)
    _drawForceArrow(
        canvas,
        Offset(cx + pulleyRadius, size.height - 30),
        effort,
        true,
        Colors.green,
        'Effort');

    // Number of ropes label
    _drawLabel(canvas, Offset(cx, size.height - 16),
        'Supporting ropes: $numRopes', Colors.orange);

    // Title
    _drawLabel(canvas, Offset(cx, 10), 'PULLEY', Colors.white70);
  }

  // ---- Inclined Plane ----
  void _drawInclinedPlane(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final margin = 40.0;
    final baseY = size.height * 0.78;
    final rampWidth = size.width - 2 * margin;
    final rampHeight = rampWidth * (2.0 / geometryParam);
    final topY = baseY - rampHeight.clamp(0.0, size.height * 0.6);

    // Triangle (ramp)
    final rampPath = Path()
      ..moveTo(margin, baseY)
      ..lineTo(size.width - margin, baseY)
      ..lineTo(size.width - margin, topY)
      ..close();

    canvas.drawPath(rampPath, Paint()..color = Colors.brown.shade700.withValues(alpha: 0.5));
    canvas.drawPath(
      rampPath,
      Paint()
        ..color = Colors.brown.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Load box on slope
    final slopeMidFraction = 0.45;
    final boxX = margin + rampWidth * slopeMidFraction;
    final boxY = baseY - (baseY - topY) * (1 - slopeMidFraction);
    final boxSize = 30.0;

    canvas.save();
    canvas.translate(boxX, boxY);
    final slopeAngle = -math.atan2(baseY - topY, rampWidth);
    canvas.rotate(slopeAngle);
    final boxRect =
        Rect.fromCenter(center: Offset(0, -boxSize / 2 - 2), width: boxSize, height: boxSize);
    canvas.drawRect(boxRect, Paint()..color = Colors.blue.shade700);
    canvas.drawRect(
      boxRect,
      Paint()
        ..color = Colors.blue.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();

    // Effort arrow along slope
    final effortStartX = boxX + 25;
    final effortStartY = boxY - 12;
    final arrowLen = 50.0;
    final dx = arrowLen * math.cos(slopeAngle);
    final dy = arrowLen * math.sin(slopeAngle);
    final arrowPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 3;
    canvas.drawLine(Offset(effortStartX, effortStartY),
        Offset(effortStartX + dx, effortStartY + dy), arrowPaint);
    // Arrowhead
    final headAngle = slopeAngle;
    final hx = effortStartX + dx;
    final hy = effortStartY + dy;
    canvas.drawLine(
      Offset(hx, hy),
      Offset(hx - 10 * math.cos(headAngle - 0.4), hy - 10 * math.sin(headAngle - 0.4)),
      arrowPaint,
    );
    canvas.drawLine(
      Offset(hx, hy),
      Offset(hx - 10 * math.cos(headAngle + 0.4), hy - 10 * math.sin(headAngle + 0.4)),
      arrowPaint,
    );
    _drawLabel(canvas, Offset(hx + 8, hy - 14),
        'Effort ${effort.toStringAsFixed(0)} N', Colors.green);

    // Load arrow (down from box)
    _drawForceArrow(canvas, Offset(boxX, boxY + 4), load, true, Colors.blue,
        'Load ${load.toStringAsFixed(0)} N');

    // Dimension labels
    // Height (right side)
    final heightPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(size.width - margin + 10, baseY),
        Offset(size.width - margin + 10, topY),
        heightPaint);
    _drawLabel(canvas, Offset(size.width - margin + 14, (baseY + topY) / 2),
        'h = 2.0 m', Colors.cyan);

    // Slope label
    _drawLabel(canvas, Offset(cx - 20, baseY + 14),
        'Slope = ${geometryParam.toStringAsFixed(1)} m', Colors.orange);

    // Title
    _drawLabel(canvas, Offset(cx, 10), 'INCLINED PLANE', Colors.white70);
  }

  // ---- Wheel & Axle ----
  void _drawWheelAndAxle(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final maxRadius = math.min(size.width, size.height) * 0.32;

    final wheelRadius = maxRadius * (geometryParam / 5.0).clamp(0.3, 1.0);
    final axleRadius = maxRadius * (0.5 / 5.0).clamp(0.08, 0.3);

    // Outer wheel
    final wheelPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(Offset(cx, cy), wheelRadius, wheelPaint);

    final wheelFillPaint = Paint()
      ..color = Colors.grey.shade800.withValues(alpha: 0.3);
    canvas.drawCircle(Offset(cx, cy), wheelRadius, wheelFillPaint);

    // Inner axle
    final axlePaint = Paint()
      ..color = Colors.brown.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(Offset(cx, cy), axleRadius, axlePaint);

    final axleFillPaint = Paint()
      ..color = Colors.brown.shade700.withValues(alpha: 0.4);
    canvas.drawCircle(Offset(cx, cy), axleRadius, axleFillPaint);

    // Center dot
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.white54);

    // Spokes
    final spokePaint = Paint()
      ..color = Colors.grey.shade600.withValues(alpha: 0.5)
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final angle = i * math.pi / 4 + animationValue * math.pi * 2;
      canvas.drawLine(
        Offset(cx + axleRadius * math.cos(angle), cy + axleRadius * math.sin(angle)),
        Offset(cx + wheelRadius * math.cos(angle), cy + wheelRadius * math.sin(angle)),
        spokePaint,
      );
    }

    // Load hanging from axle (below)
    final loadRopePaint = Paint()
      ..color = Colors.amber.shade700
      ..strokeWidth = 2;
    canvas.drawLine(Offset(cx, cy + axleRadius), Offset(cx, cy + axleRadius + 50), loadRopePaint);
    _drawForceArrow(
        canvas,
        Offset(cx, cy + axleRadius + 50),
        load,
        true,
        Colors.blue,
        'Load ${load.toStringAsFixed(0)} N');

    // Effort pulling on wheel (right side)
    canvas.drawLine(
        Offset(cx + wheelRadius, cy),
        Offset(cx + wheelRadius, cy + 50),
        loadRopePaint);
    _drawForceArrow(
        canvas,
        Offset(cx + wheelRadius, cy + 50),
        effort,
        true,
        Colors.green,
        'Effort ${effort.toStringAsFixed(0)} N');

    // Radius labels
    // Wheel radius
    final rLabelPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 1;
    canvas.drawLine(Offset(cx, cy), Offset(cx + wheelRadius, cy), rLabelPaint);
    _drawLabel(canvas, Offset(cx + wheelRadius / 2, cy - 16),
        'R = ${geometryParam.toStringAsFixed(1)} m', Colors.orange);

    // Axle radius
    canvas.drawLine(Offset(cx, cy), Offset(cx - axleRadius, cy),
        Paint()..color = Colors.cyan..strokeWidth = 1);
    _drawLabel(canvas, Offset(cx - axleRadius - 40, cy - 16), 'r = 0.5 m', Colors.cyan);

    // Title
    _drawLabel(canvas, Offset(cx, 10), 'WHEEL & AXLE', Colors.white70);
  }

  // ---- Shared helpers ----

  void _drawForceArrow(Canvas canvas, Offset start, double forceN, bool down,
      Color color, String label) {
    final arrowLen = (forceN / 10).clamp(15.0, 55.0);
    final end = down
        ? Offset(start.dx, start.dy + arrowLen)
        : Offset(start.dx, start.dy - arrowLen);

    final arrowPaint = Paint()
      ..color = color
      ..strokeWidth = 3;
    canvas.drawLine(start, end, arrowPaint);

    // Arrow head
    if (down) {
      canvas.drawLine(end, Offset(end.dx - 6, end.dy - 8), arrowPaint);
      canvas.drawLine(end, Offset(end.dx + 6, end.dy - 8), arrowPaint);
    } else {
      canvas.drawLine(end, Offset(end.dx - 6, end.dy + 8), arrowPaint);
      canvas.drawLine(end, Offset(end.dx + 6, end.dy + 8), arrowPaint);
    }

    // Label
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(end.dx + 8, end.dy - textPainter.height / 2));
  }

  void _drawLabel(Canvas canvas, Offset position, String text, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(position.dx - textPainter.width / 2, position.dy));
  }

  void _drawEfficiencyBadge(Canvas canvas, Size size) {
    final badgeX = size.width - 55;
    const badgeY = 12.0;
    final color = efficiency >= 80
        ? Colors.green
        : efficiency >= 50
            ? Colors.amber
            : Colors.red;

    // Background
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(badgeX, badgeY + 14), width: 86, height: 28),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, Paint()..color = color.withValues(alpha: 0.2));
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Eff: ${efficiency.toStringAsFixed(1)}%',
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas,
        Offset(badgeX - textPainter.width / 2, badgeY + 14 - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SimpleMachinesPainter oldDelegate) {
    return oldDelegate.machineType != machineType ||
        oldDelegate.load != load ||
        oldDelegate.effort != effort ||
        oldDelegate.geometryParam != geometryParam ||
        oldDelegate.efficiency != efficiency ||
        oldDelegate.animationValue != animationValue;
  }
}
