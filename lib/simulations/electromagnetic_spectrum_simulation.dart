import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'simulation_tts_mixin.dart';

class ElectromagneticSpectrumSimulation extends StatefulWidget {
  const ElectromagneticSpectrumSimulation({super.key});

  @override
  State<ElectromagneticSpectrumSimulation> createState() =>
      _ElectromagneticSpectrumSimulationState();
}

class _ElectromagneticSpectrumSimulationState
    extends State<ElectromagneticSpectrumSimulation>
    with SingleTickerProviderStateMixin, SimulationTTSMixin {
  late AnimationController _controller;
  double _phase = 0.0;
  bool _hasSpokenIntro = false;

  int _selectedIndex = 3; // Start with visible light

  final List<_EMWave> _waves = [
    _EMWave(
      name: 'Radio Waves',
      wavelengthRange: '> 1 m',
      frequencyRange: '< 300 MHz',
      color: Colors.red.shade900,
      uses: 'Broadcasting, communication, WiFi',
      dangers: 'Generally safe at normal levels',
      wavelengthScale: 100.0,
    ),
    _EMWave(
      name: 'Microwaves',
      wavelengthRange: '1 mm - 1 m',
      frequencyRange: '300 MHz - 300 GHz',
      color: Colors.red.shade700,
      uses: 'Cooking, satellite communication, radar',
      dangers: 'Can heat body tissue',
      wavelengthScale: 50.0,
    ),
    _EMWave(
      name: 'Infrared',
      wavelengthRange: '700 nm - 1 mm',
      frequencyRange: '300 GHz - 430 THz',
      color: Colors.red,
      uses: 'Heating, thermal imaging, remote controls',
      dangers: 'Can cause burns',
      wavelengthScale: 25.0,
    ),
    _EMWave(
      name: 'Visible Light',
      wavelengthRange: '400 - 700 nm',
      frequencyRange: '430 - 750 THz',
      color: Colors.yellow,
      uses: 'Vision, photography, optical fibres',
      dangers: 'Bright light can damage eyes',
      wavelengthScale: 15.0,
    ),
    _EMWave(
      name: 'Ultraviolet',
      wavelengthRange: '10 - 400 nm',
      frequencyRange: '750 THz - 30 PHz',
      color: Colors.purple,
      uses: 'Sterilisation, fluorescent lamps, tanning',
      dangers: 'Skin cancer, sunburn, eye damage',
      wavelengthScale: 8.0,
    ),
    _EMWave(
      name: 'X-rays',
      wavelengthRange: '0.01 - 10 nm',
      frequencyRange: '30 PHz - 30 EHz',
      color: Colors.blue,
      uses: 'Medical imaging, security scanners',
      dangers: 'Cell damage, cancer risk',
      wavelengthScale: 4.0,
    ),
    _EMWave(
      name: 'Gamma Rays',
      wavelengthRange: '< 0.01 nm',
      frequencyRange: '> 30 EHz',
      color: Colors.green,
      uses: 'Cancer treatment, sterilisation',
      dangers: 'Severe cell damage, radiation sickness',
      wavelengthScale: 2.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16),
    )..addListener(_updatePhase);
    _controller.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasSpokenIntro) {
        _hasSpokenIntro = true;
        speakSimulation(
          'Welcome to the Electromagnetic Spectrum simulation! '
          'All electromagnetic waves travel at the speed of light in a vacuum. '
          'They differ in wavelength and frequency. '
          'From longest to shortest wavelength: radio, microwaves, infrared, visible light, ultraviolet, X-rays, and gamma rays. '
          'Tap on different wave types to learn about their uses and dangers.',
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

  void _updatePhase() {
    setState(() {
      _phase += 0.05;
      if (_phase > 2 * math.pi) {
        _phase -= 2 * math.pi;
      }
    });
  }

  void _selectWave(int index) {
    setState(() {
      _selectedIndex = index;
    });

    final wave = _waves[index];
    speakSimulation(
      '${wave.name}. Wavelength: ${wave.wavelengthRange}. '
      'Uses include ${wave.uses}. '
      'Dangers: ${wave.dangers}.',
      force: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedWave = _waves[_selectedIndex];

    return Column(
      children: [
        // Spectrum bar
        Container(
          height: 60,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: List.generate(_waves.length, (index) {
              final wave = _waves[index];
              final isSelected = index == _selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _selectWave(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: wave.color.withValues(alpha: isSelected ? 1.0 : 0.5),
                      borderRadius: BorderRadius.horizontal(
                        left: index == 0 ? const Radius.circular(7) : Radius.zero,
                        right: index == _waves.length - 1
                            ? const Radius.circular(7)
                            : Radius.zero,
                      ),
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          wave.name.split(' ')[0],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // Wave visualization
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selectedWave.color),
            ),
            child: CustomPaint(
              painter: _EMWavePainter(
                phase: _phase,
                wavelengthScale: selectedWave.wavelengthScale,
                color: selectedWave.color,
              ),
              size: Size.infinite,
            ),
          ),
        ),

        // Arrow showing relationship
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.red, size: 16),
                  const Text(' Long λ, Low f ',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                ],
              ),
              const Text('WAVELENGTH',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              Row(
                children: [
                  const Text(' Short λ, High f ',
                      style: TextStyle(color: Colors.white70, fontSize: 10)),
                  const Icon(Icons.arrow_forward, color: Colors.purple, size: 16),
                ],
              ),
            ],
          ),
        ),

        // Info panel
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: selectedWave.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: selectedWave.color.withValues(alpha: 0.5)),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      selectedWave.name,
                      style: TextStyle(
                        color: selectedWave.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow('Wavelength', selectedWave.wavelengthRange, Icons.straighten),
                  _buildInfoRow('Frequency', selectedWave.frequencyRange, Icons.speed),
                  _buildInfoRow('Uses', selectedWave.uses, Icons.lightbulb_outline),
                  _buildInfoRow('Dangers', selectedWave.dangers, Icons.warning_amber),
                ],
              ),
            ),
          ),
        ),

        // Formula and TTS toggle
        Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'c = f × λ = 3×10⁸ m/s',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ),
              buildTTSToggle(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white54, size: 16),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
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

class _EMWave {
  final String name;
  final String wavelengthRange;
  final String frequencyRange;
  final Color color;
  final String uses;
  final String dangers;
  final double wavelengthScale;

  _EMWave({
    required this.name,
    required this.wavelengthRange,
    required this.frequencyRange,
    required this.color,
    required this.uses,
    required this.dangers,
    required this.wavelengthScale,
  });
}

class _EMWavePainter extends CustomPainter {
  final double phase;
  final double wavelengthScale;
  final Color color;

  _EMWavePainter({
    required this.phase,
    required this.wavelengthScale,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final amplitude = size.height * 0.35;

    // Draw E-field wave
    final ePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final ePath = Path();
    for (int x = 0; x < size.width.toInt(); x++) {
      final waveX = x / wavelengthScale;
      final y = centerY - amplitude * math.sin(waveX - phase);

      if (x == 0) {
        ePath.moveTo(x.toDouble(), y);
      } else {
        ePath.lineTo(x.toDouble(), y);
      }
    }
    canvas.drawPath(ePath, ePaint);

    // Draw B-field wave (perpendicular, shown as dotted line representing out of screen)
    final bPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (int x = 0; x < size.width.toInt(); x += 3) {
      final waveX = x / wavelengthScale;
      final y = centerY - amplitude * 0.3 * math.cos(waveX - phase);

      canvas.drawCircle(Offset(x.toDouble(), y), 1, bPaint..style = PaintingStyle.fill);
    }

    // Draw center axis
    final axisPaint = Paint()
      ..color = Colors.white24
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, centerY),
      Offset(size.width, centerY),
      axisPaint,
    );

    // Draw wavelength indicator
    final wavelengthPixels = wavelengthScale * 2 * math.pi;
    if (wavelengthPixels < size.width - 40) {
      final markerPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 2;

      final markerY = size.height - 25;
      canvas.drawLine(
        Offset(20, markerY),
        Offset(20 + wavelengthPixels, markerY),
        markerPaint,
      );

      // End caps
      canvas.drawLine(Offset(20, markerY - 5), Offset(20, markerY + 5), markerPaint);
      canvas.drawLine(
        Offset(20 + wavelengthPixels, markerY - 5),
        Offset(20 + wavelengthPixels, markerY + 5),
        markerPaint,
      );

      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'λ',
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(20 + wavelengthPixels / 2 - 5, markerY - 20));
    }

    // Labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
      text: 'E-field',
      style: TextStyle(color: color, fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 10));

    textPainter.text = TextSpan(
      text: 'B-field (⊙)',
      style: TextStyle(color: color.withValues(alpha: 0.6), fontSize: 10),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(10, 25));

    // Direction arrow
    final arrowPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;
    canvas.drawLine(
      Offset(size.width - 60, 15),
      Offset(size.width - 20, 15),
      arrowPaint,
    );

    final arrowPath = Path()
      ..moveTo(size.width - 20, 15)
      ..lineTo(size.width - 30, 10)
      ..lineTo(size.width - 30, 20)
      ..close();
    canvas.drawPath(arrowPath, arrowPaint..style = PaintingStyle.fill);

    textPainter.text = const TextSpan(
      text: 'c',
      style: TextStyle(color: Colors.white54, fontSize: 12),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width - 45, 20));
  }

  @override
  bool shouldRepaint(covariant _EMWavePainter oldDelegate) {
    return phase != oldDelegate.phase ||
        wavelengthScale != oldDelegate.wavelengthScale ||
        color != oldDelegate.color;
  }
}
