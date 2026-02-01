import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class ElectrolysisSimulation extends StatefulWidget {
  const ElectrolysisSimulation({super.key});

  @override
  State<ElectrolysisSimulation> createState() => _ElectrolysisSimulationState();
}

class _ElectrolysisSimulationState extends State<ElectrolysisSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();
  bool _hasSpokenIntro = false;

  // State
  String _selectedElectrolyte = 'h2so4';
  double _voltage = 6.0;
  bool _showIonLabels = true;

  // Ion particle system
  final List<_Ion> _ions = [];
  final List<_Bubble> _bubbles = [];

  // Electrolyte data
  static const Map<String, _ElectrolyteData> _electrolytes = {
    'h2so4': _ElectrolyteData(
      name: 'Dilute H\u2082SO\u2084 (Water)',
      shortName: 'Dilute Sulfuric Acid',
      isElectrolyte: true,
      solutionColor: Color(0x44448AFF),
      cationLabel: 'H\u207A',
      anionLabel: 'SO\u2084\u00B2\u207B',
      cathodeReaction: '2H\u207A + 2e\u207B \u2192 H\u2082 (gas)',
      anodeReaction: '4OH\u207B \u2192 O\u2082 + 2H\u2082O + 4e\u207B',
      cathodeProduct: 'Hydrogen gas (H\u2082)',
      anodeProduct: 'Oxygen gas (O\u2082)',
      cathodeBubbles: true,
      anodeBubbles: true,
      copperDeposit: false,
    ),
    'cuso4': _ElectrolyteData(
      name: 'CuSO\u2084 Solution',
      shortName: 'Copper Sulfate Solution',
      isElectrolyte: true,
      solutionColor: Color(0x4400BCD4),
      cationLabel: 'Cu\u00B2\u207A',
      anionLabel: 'SO\u2084\u00B2\u207B',
      cathodeReaction: 'Cu\u00B2\u207A + 2e\u207B \u2192 Cu (solid)',
      anodeReaction: '4OH\u207B \u2192 O\u2082 + 2H\u2082O + 4e\u207B',
      cathodeProduct: 'Copper metal deposited',
      anodeProduct: 'Oxygen gas (O\u2082)',
      cathodeBubbles: false,
      anodeBubbles: true,
      copperDeposit: true,
    ),
    'nacl': _ElectrolyteData(
      name: 'Brine (NaCl)',
      shortName: 'Brine (Sodium Chloride)',
      isElectrolyte: true,
      solutionColor: Color(0x4466BB6A),
      cationLabel: 'Na\u207A',
      anionLabel: 'Cl\u207B',
      cathodeReaction: '2H\u207A + 2e\u207B \u2192 H\u2082 (gas)',
      anodeReaction: '2Cl\u207B \u2192 Cl\u2082 + 2e\u207B',
      cathodeProduct: 'Hydrogen gas (H\u2082)',
      anodeProduct: 'Chlorine gas (Cl\u2082)',
      cathodeBubbles: true,
      anodeBubbles: true,
      copperDeposit: false,
    ),
    'sugar': _ElectrolyteData(
      name: 'Sugar Solution',
      shortName: 'Sugar Solution (non-electrolyte)',
      isElectrolyte: false,
      solutionColor: Color(0x33FFD54F),
      cationLabel: '',
      anionLabel: '',
      cathodeReaction: 'No reaction',
      anodeReaction: 'No reaction',
      cathodeProduct: 'None',
      anodeProduct: 'None',
      cathodeBubbles: false,
      anodeBubbles: false,
      copperDeposit: false,
    ),
  };

  _ElectrolyteData get _currentData => _electrolytes[_selectedElectrolyte]!;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);
    _initIons();
    _controller.repeat();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Electrolysis simulation! Electrolysis uses direct current '
          'to decompose ionic compounds. Cations, which are positive ions, migrate to '
          'the cathode, the negative electrode. Anions, which are negative ions, migrate '
          'to the anode, the positive electrode. Select an electrolyte and adjust the '
          'voltage to see how electrolysis works.',
          force: true,
        );
      }
    });
  }

  void _initIons() {
    _ions.clear();
    if (!_currentData.isElectrolyte) return;

    for (int i = 0; i < 16; i++) {
      final isPositive = i < 8;
      _ions.add(_Ion(
        x: 0.2 + _random.nextDouble() * 0.6,
        y: 0.25 + _random.nextDouble() * 0.45,
        vx: 0,
        isPositive: isPositive,
        label: isPositive ? _currentData.cationLabel : _currentData.anionLabel,
      ));
    }
  }

  void _update() {
    setState(() {
      final data = _currentData;
      if (!data.isElectrolyte) return;

      final speed = _voltage / 1200.0;

      // Update ions
      for (var ion in _ions) {
        if (ion.isPositive) {
          // Cations drift toward cathode (left, x ~ 0.15)
          ion.vx = -speed;
        } else {
          // Anions drift toward anode (right, x ~ 0.85)
          ion.vx = speed;
        }

        ion.x += ion.vx;
        // Small vertical wobble
        ion.y += math.sin(ion.x * 40 + ion.y * 30) * 0.001;
        ion.y = ion.y.clamp(0.25, 0.70);

        // Respawn when reaching electrode
        if (ion.isPositive && ion.x < 0.14) {
          ion.x = 0.75 + _random.nextDouble() * 0.08;
          ion.y = 0.25 + _random.nextDouble() * 0.45;
        } else if (!ion.isPositive && ion.x > 0.86) {
          ion.x = 0.17 + _random.nextDouble() * 0.08;
          ion.y = 0.25 + _random.nextDouble() * 0.45;
        }
      }

      // Generate bubbles
      if (_random.nextDouble() < _voltage / 30.0) {
        if (data.cathodeBubbles) {
          _bubbles.add(_Bubble(
            x: 0.15 + _random.nextDouble() * 0.03 - 0.015,
            y: 0.65 - _random.nextDouble() * 0.30,
            radius: 1.5 + _random.nextDouble() * 2.0,
            speed: 0.002 + _random.nextDouble() * 0.002,
            isCathode: true,
          ));
        }
        if (data.anodeBubbles) {
          _bubbles.add(_Bubble(
            x: 0.85 + _random.nextDouble() * 0.03 - 0.015,
            y: 0.65 - _random.nextDouble() * 0.30,
            radius: 1.5 + _random.nextDouble() * 2.0,
            speed: 0.002 + _random.nextDouble() * 0.002,
            isCathode: false,
          ));
        }
      }

      // Update bubbles
      for (var bubble in _bubbles) {
        bubble.y -= bubble.speed;
        bubble.x += math.sin(bubble.y * 80) * 0.0005;
      }
      _bubbles.removeWhere((b) => b.y < 0.10);
    });
  }

  void _onElectrolyteChanged(String value) {
    setState(() {
      _selectedElectrolyte = value;
      _bubbles.clear();
      _initIons();
    });

    final data = _electrolytes[value]!;
    if (!data.isElectrolyte) {
      speakSimulation(
        'Sugar solution is a non-electrolyte. It does not contain free ions, '
        'so no current flows and no electrolysis occurs.',
        force: true,
      );
    } else {
      String description;
      switch (value) {
        case 'h2so4':
          description = 'Dilute sulfuric acid. The ions present are hydrogen ions and '
              'sulfate ions. Hydrogen gas is produced at the cathode and oxygen gas at the anode.';
          break;
        case 'cuso4':
          description = 'Copper sulfate solution. The ions present are copper two plus ions '
              'and sulfate ions. Copper metal is deposited at the cathode and oxygen gas is '
              'produced at the anode.';
          break;
        case 'nacl':
          description = 'Brine, a concentrated sodium chloride solution. The ions present are '
              'sodium ions and chloride ions. Hydrogen gas is produced at the cathode and '
              'chlorine gas at the anode.';
          break;
        default:
          description = '';
      }
      speakSimulation(description, force: true);
    }
  }

  void _onVoltageChanged(double value) {
    setState(() => _voltage = value);
    speakSimulation(
      'Voltage set to ${value.toStringAsFixed(1)} volts. '
      '${value > 8 ? "Higher voltage means faster ion migration." : ""}',
    );
  }

  void _onShowLabelsToggled(bool value) {
    setState(() => _showIonLabels = value);
    speakSimulation(
      value ? 'Ion labels are now visible.' : 'Ion labels hidden.',
      force: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = _currentData;

    return SingleChildScrollView(
      child: Column(
        children: [
          // TTS toggle
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [buildTTSToggle()],
            ),
          ),

          // Electrolyte selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _electrolytes.entries.map((entry) {
                  final isSelected = _selectedElectrolyte == entry.key;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ChoiceChip(
                      label: Text(
                        entry.value.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? Colors.white : Colors.white70,
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: Colors.cyan.withValues(alpha: 0.7),
                      backgroundColor: Colors.white10,
                      onSelected: (_) => _onElectrolyteChanged(entry.key),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Animated canvas
          Container(
            height: 300,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _ElectrolysisPainter(
                      data: data,
                      voltage: _voltage,
                      ions: _ions,
                      bubbles: _bubbles,
                      showLabels: _showIonLabels,
                      phase: _controller.value,
                    ),
                    size: Size.infinite,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Voltage slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const SizedBox(
                  width: 100,
                  child: Text(
                    'Voltage (V)',
                    style: TextStyle(color: Colors.yellow, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Colors.yellow,
                      thumbColor: Colors.yellow,
                      inactiveTrackColor: Colors.yellow.withValues(alpha: 0.3),
                    ),
                    child: Slider(
                      value: _voltage,
                      min: 1,
                      max: 12,
                      onChanged: _onVoltageChanged,
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                    '${_voltage.toStringAsFixed(1)} V',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Ion labels toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Show Ion Labels',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Switch(
                  value: _showIonLabels,
                  onChanged: _onShowLabelsToggled,
                  activeColor: Colors.cyan,
                ),
              ],
            ),
          ),

          // Info panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row with badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.shortName,
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: data.isElectrolyte
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: data.isElectrolyte ? Colors.green : Colors.red,
                        ),
                      ),
                      child: Text(
                        data.isElectrolyte ? 'Electrolyte' : 'Non-electrolyte',
                        style: TextStyle(
                          color: data.isElectrolyte ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Cathode reaction
                _buildReactionRow(
                  'Cathode (\u2212)',
                  data.cathodeReaction,
                  Colors.grey[400]!,
                ),
                const SizedBox(height: 6),

                // Anode reaction
                _buildReactionRow(
                  'Anode (+)',
                  data.anodeReaction,
                  const Color(0xFFCD7F32),
                ),
                const SizedBox(height: 10),

                // Products
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Products: ',
                      style: TextStyle(
                        color: Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        data.isElectrolyte
                            ? 'Cathode: ${data.cathodeProduct}  |  Anode: ${data.anodeProduct}'
                            : 'No products \u2014 no free ions to carry current',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                const Divider(color: Colors.white24),
                const SizedBox(height: 6),

                // Key terms
                const Text(
                  'Key Terms',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                _buildKeyTerm(
                  'Cations (+)',
                  'positive ions that migrate to the Cathode (\u2212)',
                  Colors.orange,
                ),
                const SizedBox(height: 2),
                _buildKeyTerm(
                  'Anions (\u2212)',
                  'negative ions that migrate to the Anode (+)',
                  Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionRow(String electrode, String reaction, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            electrode,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            reaction,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildKeyTerm(String term, String description, Color color) {
    return Row(
      children: [
        Icon(Icons.circle, size: 8, color: color),
        const SizedBox(width: 6),
        Text(
          '$term \u2192 ',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data model for electrolytes
// ---------------------------------------------------------------------------
class _ElectrolyteData {
  final String name;
  final String shortName;
  final bool isElectrolyte;
  final Color solutionColor;
  final String cationLabel;
  final String anionLabel;
  final String cathodeReaction;
  final String anodeReaction;
  final String cathodeProduct;
  final String anodeProduct;
  final bool cathodeBubbles;
  final bool anodeBubbles;
  final bool copperDeposit;

  const _ElectrolyteData({
    required this.name,
    required this.shortName,
    required this.isElectrolyte,
    required this.solutionColor,
    required this.cationLabel,
    required this.anionLabel,
    required this.cathodeReaction,
    required this.anodeReaction,
    required this.cathodeProduct,
    required this.anodeProduct,
    required this.cathodeBubbles,
    required this.anodeBubbles,
    required this.copperDeposit,
  });
}

// ---------------------------------------------------------------------------
// Ion particle
// ---------------------------------------------------------------------------
class _Ion {
  double x; // 0..1 normalised within canvas
  double y;
  double vx;
  bool isPositive;
  String label;

  _Ion({
    required this.x,
    required this.y,
    required this.vx,
    required this.isPositive,
    required this.label,
  });
}

// ---------------------------------------------------------------------------
// Bubble particle
// ---------------------------------------------------------------------------
class _Bubble {
  double x;
  double y;
  double radius;
  double speed;
  bool isCathode;

  _Bubble({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.isCathode,
  });
}

// ---------------------------------------------------------------------------
// Custom painter
// ---------------------------------------------------------------------------
class _ElectrolysisPainter extends CustomPainter {
  final _ElectrolyteData data;
  final double voltage;
  final List<_Ion> ions;
  final List<_Bubble> bubbles;
  final bool showLabels;
  final double phase;

  _ElectrolysisPainter({
    required this.data,
    required this.voltage,
    required this.ions,
    required this.bubbles,
    required this.showLabels,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawPowerSupply(canvas, w, h);
    _drawWires(canvas, w, h);
    _drawBeaker(canvas, w, h);
    _drawElectrodes(canvas, w, h);
    _drawSolution(canvas, w, h);
    _drawIons(canvas, w, h);
    _drawBubbles(canvas, w, h);
    _drawElectrodeLabels(canvas, w, h);
    _drawReactionLabels(canvas, w, h);

    if (!data.isElectrolyte) {
      _drawNonElectrolyteOverlay(canvas, w, h);
    }
  }

  void _drawPowerSupply(Canvas canvas, double w, double h) {
    final boxRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.06),
      width: w * 0.30,
      height: h * 0.08,
    );
    final boxPaint = Paint()
      ..color = Colors.grey[800]!
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = Colors.grey[600]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
      boxPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
      borderPaint,
    );

    // Battery symbol - two parallel lines
    final bx = w * 0.5;
    final by = h * 0.06;
    final battPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Long line (positive)
    canvas.drawLine(Offset(bx + 6, by - 10), Offset(bx + 6, by + 10), battPaint);
    // Short line (negative)
    battPaint.strokeWidth = 2.5;
    canvas.drawLine(Offset(bx - 6, by - 6), Offset(bx - 6, by + 6), battPaint);

    // + and - labels on supply
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = const TextSpan(
      text: '+',
      style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset(bx + 14, by - 6));

    tp.text = const TextSpan(
      text: '\u2212',
      style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold),
    );
    tp.layout();
    tp.paint(canvas, Offset(bx - 22, by - 6));

    // DC label
    tp.text = const TextSpan(
      text: 'DC',
      style: TextStyle(color: Colors.white54, fontSize: 9),
    );
    tp.layout();
    tp.paint(canvas, Offset(bx - 6, by + 12));
  }

  void _drawWires(Canvas canvas, double w, double h) {
    final wirePaint = Paint()
      ..color = Colors.grey[500]!
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Left wire: from DC negative terminal down to cathode
    final leftX = w * 0.15;
    final path1 = Path()
      ..moveTo(w * 0.5 - w * 0.15, h * 0.10)
      ..lineTo(leftX, h * 0.10)
      ..lineTo(leftX, h * 0.22);
    canvas.drawPath(path1, wirePaint);

    // Right wire: from DC positive terminal down to anode
    final rightX = w * 0.85;
    final path2 = Path()
      ..moveTo(w * 0.5 + w * 0.15, h * 0.10)
      ..lineTo(rightX, h * 0.10)
      ..lineTo(rightX, h * 0.22);
    canvas.drawPath(path2, wirePaint);
  }

  void _drawBeaker(Canvas canvas, double w, double h) {
    final beakerRect = Rect.fromLTRB(w * 0.05, h * 0.20, w * 0.95, h * 0.80);
    final beakerPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Draw three sides (no top)
    final beakerPath = Path()
      ..moveTo(beakerRect.left, beakerRect.top)
      ..lineTo(beakerRect.left, beakerRect.bottom)
      ..lineTo(beakerRect.right, beakerRect.bottom)
      ..lineTo(beakerRect.right, beakerRect.top);

    canvas.drawPath(beakerPath, beakerPaint);
  }

  void _drawSolution(Canvas canvas, double w, double h) {
    final solutionRect = Rect.fromLTRB(w * 0.06, h * 0.28, w * 0.94, h * 0.79);
    final solutionPaint = Paint()
      ..color = data.solutionColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(solutionRect, solutionPaint);
  }

  void _drawElectrodes(Canvas canvas, double w, double h) {
    // Cathode (left, grey) - negative electrode
    final cathodeRect = Rect.fromCenter(
      center: Offset(w * 0.15, h * 0.48),
      width: w * 0.04,
      height: h * 0.38,
    );
    final cathodePaint = Paint()..color = Colors.grey[500]!;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cathodeRect, const Radius.circular(2)),
      cathodePaint,
    );

    // Copper deposit layer on cathode (CuSO4 only)
    if (data.copperDeposit) {
      final depositPaint = Paint()..color = const Color(0xFFCD7F32).withValues(alpha: 0.7);
      final depositRect = Rect.fromLTRB(
        cathodeRect.right - 3,
        cathodeRect.top + 4,
        cathodeRect.right + 2,
        cathodeRect.bottom - 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(depositRect, const Radius.circular(1)),
        depositPaint,
      );
    }

    // Anode (right, copper-coloured) - positive electrode
    final anodeRect = Rect.fromCenter(
      center: Offset(w * 0.85, h * 0.48),
      width: w * 0.04,
      height: h * 0.38,
    );
    final anodePaint = Paint()..color = const Color(0xFFCD7F32);
    canvas.drawRRect(
      RRect.fromRectAndRadius(anodeRect, const Radius.circular(2)),
      anodePaint,
    );
  }

  void _drawElectrodeLabels(Canvas canvas, double w, double h) {
    final tp = TextPainter(textDirection: TextDirection.ltr);

    // Cathode label "\u2212"
    tp.text = const TextSpan(
      text: '\u2212',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(w * 0.15 - tp.width / 2, h * 0.20 - 18));

    // "Cathode" text
    tp.text = const TextSpan(
      text: 'Cathode',
      style: TextStyle(color: Colors.white60, fontSize: 9),
    );
    tp.layout();
    tp.paint(canvas, Offset(w * 0.15 - tp.width / 2, h * 0.20 - 4));

    // Anode label "+"
    tp.text = const TextSpan(
      text: '+',
      style: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
    tp.layout();
    tp.paint(canvas, Offset(w * 0.85 - tp.width / 2, h * 0.20 - 18));

    // "Anode" text
    tp.text = const TextSpan(
      text: 'Anode',
      style: TextStyle(color: Colors.white60, fontSize: 9),
    );
    tp.layout();
    tp.paint(canvas, Offset(w * 0.85 - tp.width / 2, h * 0.20 - 4));
  }

  void _drawReactionLabels(Canvas canvas, double w, double h) {
    if (!data.isElectrolyte) return;

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 2,
      textAlign: TextAlign.center,
    );

    // Cathode product label
    tp.text = TextSpan(
      text: data.cathodeProduct,
      style: const TextStyle(color: Colors.white54, fontSize: 8),
    );
    tp.layout(maxWidth: 100);
    tp.paint(canvas, Offset(w * 0.02, h * 0.82));

    // Anode product label
    tp.text = TextSpan(
      text: data.anodeProduct,
      style: const TextStyle(color: Colors.white54, fontSize: 8),
    );
    tp.layout(maxWidth: 100);
    tp.paint(canvas, Offset(w * 0.98 - math.min(tp.width, 100), h * 0.82));
  }

  void _drawIons(Canvas canvas, double w, double h) {
    for (var ion in ions) {
      final px = ion.x * w;
      final py = ion.y * h;
      final radius = 8.0;

      final color = ion.isPositive
          ? const Color(0xFFFF7043) // orange-red for cations
          : const Color(0xFF42A5F5); // blue for anions

      final paint = Paint()..color = color;
      canvas.drawCircle(Offset(px, py), radius, paint);

      // Border
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2;
      canvas.drawCircle(Offset(px, py), radius, borderPaint);

      // "+" or "\u2212" on ion
      final signTp = TextPainter(textDirection: TextDirection.ltr);
      signTp.text = TextSpan(
        text: ion.isPositive ? '+' : '\u2212',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      signTp.layout();
      signTp.paint(canvas, Offset(px - signTp.width / 2, py - signTp.height / 2));

      // Label (e.g., "H+", "SO4 2-")
      if (showLabels && ion.label.isNotEmpty) {
        final labelTp = TextPainter(textDirection: TextDirection.ltr);
        labelTp.text = TextSpan(
          text: ion.label,
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        );
        labelTp.layout();
        labelTp.paint(canvas, Offset(px - labelTp.width / 2, py + radius + 2));
      }
    }
  }

  void _drawBubbles(Canvas canvas, double w, double h) {
    for (var bubble in bubbles) {
      final bx = bubble.x * w;
      final by = bubble.y * h;
      final bubblePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      canvas.drawCircle(Offset(bx, by), bubble.radius, bubblePaint);

      // Tiny highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(bx - bubble.radius * 0.3, by - bubble.radius * 0.3),
        bubble.radius * 0.3,
        highlightPaint,
      );
    }
  }

  void _drawNonElectrolyteOverlay(Canvas canvas, double w, double h) {
    // Dimming overlay on the solution area
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTRB(w * 0.06, h * 0.28, w * 0.94, h * 0.79),
      overlayPaint,
    );

    // "No free ions" indicator
    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    tp.text = const TextSpan(
      text: 'No free ions\nNo current flows',
      style: TextStyle(
        color: Colors.redAccent,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    );
    tp.layout(maxWidth: w * 0.6);
    tp.paint(canvas, Offset(w * 0.5 - tp.width / 2, h * 0.50 - tp.height / 2));

    // Red cross over circuit
    final crossPaint = Paint()
      ..color = Colors.red.withValues(alpha: 0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.35, h * 0.40), Offset(w * 0.65, h * 0.60), crossPaint);
    canvas.drawLine(Offset(w * 0.65, h * 0.40), Offset(w * 0.35, h * 0.60), crossPaint);
  }

  @override
  bool shouldRepaint(covariant _ElectrolysisPainter oldDelegate) {
    return oldDelegate.phase != phase ||
        oldDelegate.voltage != voltage ||
        oldDelegate.showLabels != showLabels ||
        oldDelegate.data.name != data.name;
  }
}
