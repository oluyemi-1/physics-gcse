import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

/// Electroplating & Electro-Refining Simulation
/// Demonstrates coating objects with metal and purifying metals via electrolysis.
class ElectroplatingSimulation extends StatefulWidget {
  const ElectroplatingSimulation({super.key});

  @override
  State<ElectroplatingSimulation> createState() =>
      _ElectroplatingSimulationState();
}

class _MetalIon {
  double x, y, vx, vy;
  bool isImpurity;

  _MetalIon({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    this.isImpurity = false,
  });
}

typedef _MetalData = ({
  Color color,
  String electrolyte,
  String anodeReaction,
  String cathodeReaction,
  String application,
});

class _ElectroplatingSimulationState extends State<ElectroplatingSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  final math.Random _random = math.Random();

  // Mode: true = electroplating, false = electro-refining
  bool _isElectroplating = true;

  // Selected metal
  String _selectedMetal = 'Copper';

  // Simulation parameters
  double _voltage = 6.0;
  double _timeElapsed = 0.0;
  bool _isPlaying = false;
  double _coatingThickness = 0.0;
  double _anodeShrink = 0.0;

  // Particle system
  final List<_MetalIon> _ions = [];

  final Map<String, _MetalData> _metals = {
    'Copper': (
      color: Colors.orange,
      electrolyte: 'Copper Sulfate (CuSO\u2084)',
      anodeReaction: 'Cu \u2192 Cu\u00B2\u207A + 2e\u207B',
      cathodeReaction: 'Cu\u00B2\u207A + 2e\u207B \u2192 Cu',
      application: 'Circuit boards, corrosion protection',
    ),
    'Silver': (
      color: const Color(0xFFC0C0C0),
      electrolyte: 'Silver Nitrate (AgNO\u2083)',
      anodeReaction: 'Ag \u2192 Ag\u207A + e\u207B',
      cathodeReaction: 'Ag\u207A + e\u207B \u2192 Ag',
      application: 'Jewelry, cutlery, electronics',
    ),
    'Gold': (
      color: Colors.amber,
      electrolyte: 'Gold Cyanide Solution',
      anodeReaction: 'Au \u2192 Au\u00B3\u207A + 3e\u207B',
      cathodeReaction: 'Au\u00B3\u207A + 3e\u207B \u2192 Au',
      application: 'Jewelry, electronics, aerospace',
    ),
    'Chromium': (
      color: const Color(0xFFB0C4DE),
      electrolyte: 'Chromic Acid Solution',
      anodeReaction: 'Cr \u2192 Cr\u00B3\u207A + 3e\u207B',
      cathodeReaction: 'Cr\u00B3\u207A + 3e\u207B \u2192 Cr',
      application: 'Car parts, taps, tools',
    ),
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_update);
    _controller.repeat();
    _initIons();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      speakSimulation(
        'Welcome to the Electroplating simulation! Electroplating uses electrolysis '
        'to coat an object with a thin layer of metal. The object to be plated is '
        'the cathode, and the plating metal is the anode.',
        force: true,
      );
    });
  }

  void _initIons() {
    _ions.clear();
    for (int i = 0; i < 10; i++) {
      _spawnIon();
    }
  }

  void _spawnIon({bool forceImpurity = false}) {
    // Ions start near the anode (right side) of the bath area.
    // Normalized coordinates: anode region is roughly x 0.65-0.75, y 0.3-0.75
    final isImpurity =
        forceImpurity || (!_isElectroplating && _random.nextDouble() < 0.25);
    _ions.add(_MetalIon(
      x: 0.68 + _random.nextDouble() * 0.06,
      y: 0.35 + _random.nextDouble() * 0.35,
      vx: 0,
      vy: 0,
      isImpurity: isImpurity,
    ));
  }

  void _update() {
    if (!_isPlaying) return;

    setState(() {
      final dt = 0.016; // ~16ms per frame
      final speedFactor = _voltage / 6.0;

      _timeElapsed += dt * speedFactor;
      if (_timeElapsed > 60.0) {
        _timeElapsed = 60.0;
        _isPlaying = false;
      }

      _coatingThickness = (_timeElapsed * _voltage / 720.0).clamp(0.0, 0.12);
      _anodeShrink = (_timeElapsed * _voltage / 800.0).clamp(0.0, 0.10);

      // Move ions
      for (final ion in _ions) {
        if (ion.isImpurity) {
          // Impurities drift downward (settle as sludge)
          ion.vy += 0.0004;
          ion.vx *= 0.97;
          ion.x += ion.vx;
          ion.y += ion.vy;
        } else {
          // Metal ions move from anode (right) toward cathode (left)
          final targetX = 0.30;
          final targetY = 0.40 + _random.nextDouble() * 0.25;
          final dx = targetX - ion.x;
          final dy = targetY - ion.y;
          final dist = math.sqrt(dx * dx + dy * dy);

          if (dist > 0.01) {
            ion.vx += (dx / dist) * 0.0008 * speedFactor;
            ion.vy += (dy / dist) * 0.0003 * speedFactor;
          }

          // Random jitter
          ion.vx += (_random.nextDouble() - 0.5) * 0.0003;
          ion.vy += (_random.nextDouble() - 0.5) * 0.0003;

          // Damping
          ion.vx *= 0.96;
          ion.vy *= 0.96;

          ion.x += ion.vx;
          ion.y += ion.vy;
        }
      }

      // Respawn ions that have reached cathode or settled
      _ions.removeWhere((ion) {
        if (ion.isImpurity && ion.y > 0.78) return true;
        if (!ion.isImpurity && ion.x < 0.32) return true;
        return false;
      });

      while (_ions.length < 10) {
        _spawnIon();
      }
    });
  }

  void _reset() {
    setState(() {
      _timeElapsed = 0.0;
      _coatingThickness = 0.0;
      _anodeShrink = 0.0;
      _isPlaying = false;
      _initIons();
    });
  }

  void _onModeChanged(bool electroplating) {
    setState(() {
      _isElectroplating = electroplating;
      _reset();
    });
    if (!electroplating) {
      speakSimulation(
        'In electro-refining, impure metal is the anode and pure metal is deposited '
        'on the cathode. Impurities fall to the bottom as sludge.',
        force: true,
      );
    } else {
      speakSimulation(
        'Electroplating mode selected. The object to be coated is the cathode. '
        'Pure metal dissolves from the anode and deposits onto the cathode.',
        force: true,
      );
    }
  }

  void _onMetalChanged(String metal) {
    final data = _metals[metal]!;
    setState(() {
      _selectedMetal = metal;
      _reset();
    });
    speakSimulation(
      '$metal selected. The electrolyte is ${data.electrolyte}. '
      'Application: ${data.application}.',
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
    final metalData = _metals[_selectedMetal]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Electroplating & Electro-Refining'),
        backgroundColor: Colors.teal.shade800,
        actions: [buildTTSToggle()],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade900, Colors.black],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildModeSelector(),
              _buildMetalSelector(),
              _buildSimulationCanvas(metalData),
              _buildControls(),
              _buildInfoPanel(metalData),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ChoiceChip(
            label: const Text('Electroplating'),
            selected: _isElectroplating,
            selectedColor: Colors.teal.shade400,
            onSelected: (selected) {
              if (selected) _onModeChanged(true);
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Electro-Refining'),
            selected: !_isElectroplating,
            selectedColor: Colors.teal.shade400,
            onSelected: (selected) {
              if (selected) _onModeChanged(false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMetalSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: _metals.keys.map((metal) {
          final data = _metals[metal]!;
          return ChoiceChip(
            label: Text(metal, style: const TextStyle(fontSize: 12)),
            selected: _selectedMetal == metal,
            selectedColor: data.color.withAlpha(180),
            avatar: CircleAvatar(
              backgroundColor: data.color,
              radius: 8,
            ),
            onSelected: (selected) {
              if (selected) _onMetalChanged(metal);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSimulationCanvas(_MetalData metalData) {
    return Container(
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade700),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: _ElectroplatingPainter(
              metalColor: metalData.color,
              isElectroplating: _isElectroplating,
              voltage: _voltage,
              timeElapsed: _timeElapsed,
              coatingThickness: _coatingThickness,
              anodeShrink: _anodeShrink,
              ions: _ions,
              isPlaying: _isPlaying,
            ),
          );
        },
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          // Voltage slider
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.yellow, size: 18),
              const SizedBox(width: 4),
              const Text('Voltage:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _voltage,
                  min: 1.0,
                  max: 12.0,
                  divisions: 22,
                  activeColor: Colors.yellow,
                  onChanged: (value) => setState(() => _voltage = value),
                ),
              ),
              Text(
                '${_voltage.toStringAsFixed(1)} V',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),

          // Time slider
          Row(
            children: [
              const Icon(Icons.timer, color: Colors.cyan, size: 18),
              const SizedBox(width: 4),
              const Text('Time:', style: TextStyle(color: Colors.white, fontSize: 12)),
              Expanded(
                child: Slider(
                  value: _timeElapsed.clamp(0.0, 60.0),
                  min: 0.0,
                  max: 60.0,
                  activeColor: Colors.cyan,
                  onChanged: _isPlaying
                      ? null
                      : (value) {
                          setState(() {
                            _timeElapsed = value;
                            _coatingThickness =
                                (_timeElapsed * _voltage / 720.0).clamp(0.0, 0.12);
                            _anodeShrink =
                                (_timeElapsed * _voltage / 800.0).clamp(0.0, 0.10);
                          });
                        },
                ),
              ),
              Text(
                '${_timeElapsed.toStringAsFixed(1)} s',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),

          // Play / Pause / Reset buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isPlaying ? 'Pause' : 'Play'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isPlaying ? Colors.orange : Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPanel(_MetalData metalData) {
    final thicknessMicrons = (_coatingThickness * 1000).toStringAsFixed(1);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.teal.shade900.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.shade600.withAlpha(120)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isElectroplating ? 'Electroplating' : 'Electro-Refining',
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _infoRow('Metal', _selectedMetal),
          _infoRow('Electrolyte', metalData.electrolyte),
          _infoRow('Anode reaction', metalData.anodeReaction),
          _infoRow('Cathode reaction', metalData.cathodeReaction),
          _infoRow('Coating thickness', '$thicknessMicrons \u00B5m'),
          _infoRow('Application', metalData.application),
          if (!_isElectroplating) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.brown.shade900.withAlpha(120),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Impurities such as gold, silver, and platinum settle as '
                'anode sludge and can be recovered as valuable by-products.',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter for the electroplating / electro-refining visualisation
// ---------------------------------------------------------------------------
class _ElectroplatingPainter extends CustomPainter {
  final Color metalColor;
  final bool isElectroplating;
  final double voltage;
  final double timeElapsed;
  final double coatingThickness;
  final double anodeShrink;
  final List<_MetalIon> ions;
  final bool isPlaying;

  _ElectroplatingPainter({
    required this.metalColor,
    required this.isElectroplating,
    required this.voltage,
    required this.timeElapsed,
    required this.coatingThickness,
    required this.anodeShrink,
    required this.ions,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    _drawPowerSupply(canvas, w, h);
    _drawWires(canvas, w, h);
    _drawBath(canvas, w, h);
    _drawElectrolyte(canvas, w, h);
    _drawAnode(canvas, w, h);
    _drawCathode(canvas, w, h);
    _drawIons(canvas, w, h);
    if (!isElectroplating) {
      _drawSludge(canvas, w, h);
    }
    _drawLabels(canvas, w, h);
  }

  // ---- Power supply at top ----
  void _drawPowerSupply(Canvas canvas, double w, double h) {
    final boxRect = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.08),
      width: w * 0.28,
      height: h * 0.10,
    );
    final boxPaint = Paint()..color = Colors.grey.shade800;
    final borderPaint = Paint()
      ..color = Colors.grey.shade500
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
      boxPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(6)),
      borderPaint,
    );

    // DC label
    _drawText(canvas, 'DC Supply', Offset(w * 0.5, h * 0.065),
        fontSize: 11, color: Colors.white, center: true);

    // + and - terminals
    _drawText(canvas, '\u2212', Offset(w * 0.39, h * 0.065),
        fontSize: 14, color: Colors.blue, center: true, bold: true);
    _drawText(canvas, '+', Offset(w * 0.61, h * 0.065),
        fontSize: 14, color: Colors.red, center: true, bold: true);
  }

  // ---- Wires from supply to electrodes ----
  void _drawWires(Canvas canvas, double w, double h) {
    // Left wire (cathode, negative) - blue
    final leftWire = Paint()
      ..color = Colors.blue.shade400
      ..strokeWidth = 2.5;
    // From left terminal down to cathode
    canvas.drawLine(Offset(w * 0.39, h * 0.13), Offset(w * 0.39, h * 0.18), leftWire);
    canvas.drawLine(Offset(w * 0.39, h * 0.18), Offset(w * 0.25, h * 0.18), leftWire);
    canvas.drawLine(Offset(w * 0.25, h * 0.18), Offset(w * 0.25, h * 0.28), leftWire);

    // Right wire (anode, positive) - red
    final rightWire = Paint()
      ..color = Colors.red.shade400
      ..strokeWidth = 2.5;
    canvas.drawLine(Offset(w * 0.61, h * 0.13), Offset(w * 0.61, h * 0.18), rightWire);
    canvas.drawLine(Offset(w * 0.61, h * 0.18), Offset(w * 0.75, h * 0.18), rightWire);
    canvas.drawLine(Offset(w * 0.75, h * 0.18), Offset(w * 0.75, h * 0.28), rightWire);
  }

  // ---- Electrolytic bath container ----
  void _drawBath(Canvas canvas, double w, double h) {
    final bathRect = Rect.fromLTRB(w * 0.10, h * 0.25, w * 0.90, h * 0.85);
    final bathPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(bathRect, const Radius.circular(4)),
      bathPaint,
    );
  }

  // ---- Electrolyte solution filling the bath ----
  void _drawElectrolyte(Canvas canvas, double w, double h) {
    final solutionRect = Rect.fromLTRB(w * 0.11, h * 0.30, w * 0.89, h * 0.84);
    final solutionColor = metalColor.withAlpha(45);
    final solutionPaint = Paint()..color = solutionColor;
    canvas.drawRect(solutionRect, solutionPaint);
  }

  // ---- Anode (right side, +) ----
  void _drawAnode(Canvas canvas, double w, double h) {
    final shrink = anodeShrink * w;
    final anodeLeft = w * 0.68 + shrink * 0.5;
    final anodeRight = w * 0.78 - shrink * 0.5;
    final anodeTop = h * 0.32;
    final anodeBottom = h * 0.72;

    if (anodeRight <= anodeLeft) return;

    final anodeRect = Rect.fromLTRB(anodeLeft, anodeTop, anodeRight, anodeBottom);
    final anodePaint = Paint()..color = metalColor.withAlpha(220);
    canvas.drawRRect(
      RRect.fromRectAndRadius(anodeRect, const Radius.circular(3)),
      anodePaint,
    );

    // Label inside anode
    if (isElectroplating) {
      _drawText(
        canvas,
        'Pure\n$_metalName',
        Offset((anodeLeft + anodeRight) / 2, (anodeTop + anodeBottom) / 2 - 6),
        fontSize: 9,
        color: Colors.black87,
        center: true,
      );
    } else {
      _drawText(
        canvas,
        'Impure\nMetal',
        Offset((anodeLeft + anodeRight) / 2, (anodeTop + anodeBottom) / 2 - 6),
        fontSize: 9,
        color: Colors.black87,
        center: true,
      );
    }
  }

  String get _metalName {
    // Derive short name from the color (painter doesn't receive string name)
    // We rely on the labels drawn in _drawLabels instead.
    return '';
  }

  // ---- Cathode (left side, -) ----
  void _drawCathode(Canvas canvas, double w, double h) {
    if (isElectroplating) {
      _drawCathodeObject(canvas, w, h);
    } else {
      _drawCathodePureBar(canvas, w, h);
    }
  }

  /// Electroplating mode: draw a spoon / key-like object being coated.
  void _drawCathodeObject(Canvas canvas, double w, double h) {
    final cx = w * 0.25;
    final cy = h * 0.52;

    // Key / spoon outline (simplified: oval head + rectangular handle)
    final bodyPaint = Paint()..color = Colors.grey.shade500;
    // Handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 30), width: 12, height: 50),
        const Radius.circular(3),
      ),
      bodyPaint,
    );
    // Head (oval)
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy - 12), width: 36, height: 44),
      bodyPaint,
    );

    // Coating layer (grows with coatingThickness)
    if (coatingThickness > 0) {
      final coatPixels = coatingThickness * w;
      final coatPaint = Paint()
        ..color = metalColor.withAlpha(200)
        ..style = PaintingStyle.stroke
        ..strokeWidth = coatPixels.clamp(1.0, 14.0);

      // Coat around the head
      canvas.drawOval(
        Rect.fromCenter(center: Offset(cx, cy - 12), width: 36, height: 44),
        coatPaint,
      );
      // Coat around the handle
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, cy + 30), width: 12, height: 50),
          const Radius.circular(3),
        ),
        coatPaint,
      );
    }
  }

  /// Electro-refining mode: thin pure-metal bar that grows.
  void _drawCathodePureBar(Canvas canvas, double w, double h) {
    final growth = coatingThickness * w * 1.5;
    final barLeft = w * 0.22 - growth;
    final barRight = w * 0.28 + growth;
    final barTop = h * 0.32;
    final barBottom = h * 0.72;

    final barRect = Rect.fromLTRB(barLeft, barTop, barRight, barBottom);
    final barPaint = Paint()..color = metalColor.withAlpha(230);
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
      barPaint,
    );
    _drawText(
      canvas,
      'Pure\nMetal',
      Offset((barLeft + barRight) / 2, (barTop + barBottom) / 2 - 6),
      fontSize: 9,
      color: Colors.black87,
      center: true,
    );
  }

  // ---- Animated metal ions ----
  void _drawIons(Canvas canvas, double w, double h) {
    for (final ion in ions) {
      final px = ion.x * w;
      final py = ion.y * h;
      if (ion.isImpurity) {
        final paint = Paint()..color = Colors.brown.shade800;
        canvas.drawCircle(Offset(px, py), 3.5, paint);
      } else {
        final paint = Paint()..color = metalColor.withAlpha(210);
        canvas.drawCircle(Offset(px, py), 4, paint);

        // Tiny + to represent cation
        _drawText(canvas, '+', Offset(px, py - 3),
            fontSize: 7, color: Colors.white, center: true, bold: true);
      }
    }
  }

  // ---- Sludge at the bottom (electro-refining only) ----
  void _drawSludge(Canvas canvas, double w, double h) {
    if (timeElapsed < 0.5) return;

    final sludgeAmount = (timeElapsed * voltage / 400.0).clamp(0.0, 1.0);
    final sludgeHeight = 8 + sludgeAmount * 18;
    final sludgeRect =
        Rect.fromLTRB(w * 0.15, h * 0.84 - sludgeHeight, w * 0.85, h * 0.84);
    final sludgePaint = Paint()..color = Colors.brown.shade900.withAlpha(200);
    canvas.drawRRect(
      RRect.fromRectAndRadius(sludgeRect, const Radius.circular(3)),
      sludgePaint,
    );

    // Speckles in sludge
    final rand = math.Random(42);
    final speckPaint = Paint()..color = Colors.brown.shade700;
    for (int i = 0; i < (sludgeAmount * 20).toInt(); i++) {
      final sx = w * 0.16 + rand.nextDouble() * w * 0.68;
      final sy = h * 0.84 - sludgeHeight + rand.nextDouble() * sludgeHeight;
      canvas.drawCircle(Offset(sx, sy), 2, speckPaint);
    }

    _drawText(
      canvas,
      'Impurities (sludge)',
      Offset(w * 0.50, h * 0.84 - sludgeHeight / 2 - 4),
      fontSize: 9,
      color: Colors.white70,
      center: true,
    );
  }

  // ---- Labels ----
  void _drawLabels(Canvas canvas, double w, double h) {
    // Cathode label
    _drawText(canvas, 'Cathode (\u2212)', Offset(w * 0.25, h * 0.24),
        fontSize: 11, color: Colors.blue.shade300, center: true, bold: true);

    // Anode label
    _drawText(canvas, 'Anode (+)', Offset(w * 0.73, h * 0.24),
        fontSize: 11, color: Colors.red.shade300, center: true, bold: true);

    // Electrolyte label
    _drawText(canvas, 'Electrolyte solution', Offset(w * 0.50, h * 0.89),
        fontSize: 10, color: Colors.white54, center: true);

    // Ion flow arrow (simple text arrow)
    if (isPlaying || timeElapsed > 0) {
      final arrowY = h * 0.50;
      final arrowPaint = Paint()
        ..color = Colors.white38
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(w * 0.60, arrowY), Offset(w * 0.38, arrowY), arrowPaint);
      // Arrowhead
      canvas.drawLine(Offset(w * 0.38, arrowY), Offset(w * 0.41, arrowY - 4), arrowPaint);
      canvas.drawLine(Offset(w * 0.38, arrowY), Offset(w * 0.41, arrowY + 4), arrowPaint);

      _drawText(canvas, 'Metal ions', Offset(w * 0.49, arrowY - 12),
          fontSize: 8, color: Colors.white38, center: true);
    }

    // Coating thickness indicator on cathode
    if (coatingThickness > 0.001) {
      final thickMicrons = (coatingThickness * 1000).toStringAsFixed(1);
      _drawText(
        canvas,
        'Coating: $thickMicrons \u00B5m',
        Offset(w * 0.25, h * 0.80),
        fontSize: 9,
        color: Colors.tealAccent,
        center: true,
      );
    }
  }

  // ---- Helper: draw text on canvas ----
  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 12,
    Color color = Colors.white,
    bool center = false,
    bool bold = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          height: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: center ? TextAlign.center : TextAlign.left,
    );
    textPainter.layout();
    final offset = center
        ? Offset(position.dx - textPainter.width / 2, position.dy)
        : position;
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ElectroplatingPainter oldDelegate) {
    return oldDelegate.timeElapsed != timeElapsed ||
        oldDelegate.voltage != voltage ||
        oldDelegate.isElectroplating != isElectroplating ||
        oldDelegate.coatingThickness != coatingThickness ||
        oldDelegate.anodeShrink != anodeShrink ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.metalColor != metalColor;
  }
}
