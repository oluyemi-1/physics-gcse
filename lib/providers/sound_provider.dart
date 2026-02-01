import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:typed_data';
import 'dart:math' as math;

/// Provider for physics simulation sound effects
/// Generates simple tones programmatically
class SoundProvider extends ChangeNotifier {
  bool _soundEnabled = true;
  double _volume = 0.5;
  final AudioPlayer _player = AudioPlayer();

  // Cooldown tracking
  DateTime? _lastSoundTime;
  final Duration _minInterval = const Duration(milliseconds: 30);

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    notifyListeners();
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  bool _canPlay() {
    if (!_soundEnabled) return false;
    final now = DateTime.now();
    if (_lastSoundTime != null && now.difference(_lastSoundTime!) < _minInterval) {
      return false;
    }
    _lastSoundTime = now;
    return true;
  }

  /// Generate WAV data for a sine wave tone
  Uint8List _generateTone({
    required double frequency,
    required int durationMs,
    double volume = 0.5,
    WaveType waveType = WaveType.sine,
  }) {
    const sampleRate = 22050;
    final numSamples = (sampleRate * durationMs / 1000).round();

    // WAV header + data
    final wavData = BytesBuilder();

    // RIFF header
    wavData.add([0x52, 0x49, 0x46, 0x46]); // "RIFF"
    final fileSize = 36 + numSamples * 2;
    wavData.add(_intToBytes(fileSize, 4));
    wavData.add([0x57, 0x41, 0x56, 0x45]); // "WAVE"

    // fmt chunk
    wavData.add([0x66, 0x6D, 0x74, 0x20]); // "fmt "
    wavData.add(_intToBytes(16, 4)); // Chunk size
    wavData.add(_intToBytes(1, 2)); // Audio format (PCM)
    wavData.add(_intToBytes(1, 2)); // Num channels (mono)
    wavData.add(_intToBytes(sampleRate, 4)); // Sample rate
    wavData.add(_intToBytes(sampleRate * 2, 4)); // Byte rate
    wavData.add(_intToBytes(2, 2)); // Block align
    wavData.add(_intToBytes(16, 2)); // Bits per sample

    // data chunk
    wavData.add([0x64, 0x61, 0x74, 0x61]); // "data"
    wavData.add(_intToBytes(numSamples * 2, 4));

    // Generate samples
    for (int i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      double sample;

      switch (waveType) {
        case WaveType.sine:
          sample = math.sin(2 * math.pi * frequency * t);
          break;
        case WaveType.square:
          sample = math.sin(2 * math.pi * frequency * t) > 0 ? 1.0 : -1.0;
          break;
        case WaveType.triangle:
          final phase = (frequency * t) % 1.0;
          sample = 4 * (phase < 0.5 ? phase : 1 - phase) - 1;
          break;
        case WaveType.sawtooth:
          sample = 2 * ((frequency * t) % 1.0) - 1;
          break;
        case WaveType.noise:
          sample = (math.Random().nextDouble() * 2) - 1;
          break;
      }

      // Apply envelope (fade in/out)
      final envelope = _calculateEnvelope(i, numSamples);
      sample *= envelope * volume;

      // Convert to 16-bit PCM
      final pcmValue = (sample * 32767).round().clamp(-32768, 32767);
      wavData.add(_intToBytes(pcmValue, 2));
    }

    return wavData.toBytes();
  }

  double _calculateEnvelope(int sample, int totalSamples) {
    const attackSamples = 100;
    const releaseSamples = 200;

    if (sample < attackSamples) {
      return sample / attackSamples;
    } else if (sample > totalSamples - releaseSamples) {
      return (totalSamples - sample) / releaseSamples;
    }
    return 1.0;
  }

  List<int> _intToBytes(int value, int bytes) {
    final result = <int>[];
    for (int i = 0; i < bytes; i++) {
      result.add((value >> (8 * i)) & 0xFF);
    }
    return result;
  }

  Future<void> _playTone({
    required double frequency,
    required int durationMs,
    WaveType waveType = WaveType.sine,
  }) async {
    if (!_canPlay()) return;

    try {
      final wavData = _generateTone(
        frequency: frequency,
        durationMs: durationMs,
        volume: _volume,
        waveType: waveType,
      );

      await _player.play(BytesSource(wavData));
    } catch (e) {
      // Silently fail
    }
  }

  // ============== Sound Effect Methods ==============

  /// Collision/impact sound
  Future<void> playCollision({double intensity = 1.0}) async {
    await _playTone(
      frequency: 150 + (intensity * 100),
      durationMs: 80,
      waveType: WaveType.square,
    );
  }

  /// Bounce sound
  Future<void> playBounce({double intensity = 1.0}) async {
    await _playTone(
      frequency: 300 + (intensity * 200),
      durationMs: 60,
      waveType: WaveType.sine,
    );
  }

  /// Click/tap sound
  Future<void> playClick() async {
    await _playTone(frequency: 800, durationMs: 30, waveType: WaveType.square);
  }

  /// Success sound (ascending notes)
  Future<void> playSuccess() async {
    if (!_canPlay()) return;
    await _playTone(frequency: 523, durationMs: 100);
    await Future.delayed(const Duration(milliseconds: 80));
    await _playTone(frequency: 659, durationMs: 100);
    await Future.delayed(const Duration(milliseconds: 80));
    await _playTone(frequency: 784, durationMs: 150);
  }

  /// Error sound
  Future<void> playError() async {
    await _playTone(frequency: 200, durationMs: 200, waveType: WaveType.square);
  }

  /// Whoosh for fast motion
  Future<void> playWhoosh() async {
    if (!_canPlay()) return;
    for (int i = 0; i < 3; i++) {
      await _playTone(frequency: 800 - (i * 200), durationMs: 30);
    }
  }

  /// Electric zap
  Future<void> playZap() async {
    await _playTone(frequency: 2000, durationMs: 40, waveType: WaveType.square);
  }

  /// Tick (pendulum, timer)
  Future<void> playTick() async {
    await _playTone(frequency: 1200, durationMs: 15, waveType: WaveType.square);
  }

  /// Tock (lower tick)
  Future<void> playTock() async {
    await _playTone(frequency: 600, durationMs: 20, waveType: WaveType.square);
  }

  /// Geiger counter click
  Future<void> playGeiger() async {
    await _playTone(frequency: 3000, durationMs: 8, waveType: WaveType.square);
  }

  /// Bubble/boiling
  Future<void> playBubble() async {
    if (!_canPlay()) return;
    await _playTone(frequency: 400, durationMs: 40);
    await _playTone(frequency: 600, durationMs: 30);
  }

  /// Spring stretch
  Future<void> playSpring({double stretch = 0.5}) async {
    await _playTone(frequency: 300 + (stretch * 400), durationMs: 50);
  }

  /// Electrical hum
  Future<void> playHum({double freq = 60}) async {
    await _playTone(frequency: freq, durationMs: 150, waveType: WaveType.sine);
  }

  /// Explosion
  Future<void> playExplosion() async {
    await _playTone(frequency: 80, durationMs: 150, waveType: WaveType.noise);
  }

  /// Launch projectile
  Future<void> playLaunch() async {
    if (!_canPlay()) return;
    for (int i = 0; i < 4; i++) {
      await _playTone(frequency: 200 + (i * 100), durationMs: 25);
    }
  }

  /// Slider tick
  Future<void> playSlider() async {
    await _playTone(frequency: 500, durationMs: 10);
  }

  /// Wave/water
  Future<void> playWave() async {
    await _playTone(frequency: 220, durationMs: 200, waveType: WaveType.sine);
  }

  /// Beep
  Future<void> playBeep({double pitch = 1.0}) async {
    await _playTone(frequency: 440 * pitch, durationMs: 100);
  }

  /// Metallic clang
  Future<void> playClang({double pitch = 1.0}) async {
    await _playTone(frequency: 800 * pitch, durationMs: 100, waveType: WaveType.triangle);
  }

  /// Drip
  Future<void> playDrip() async {
    if (!_canPlay()) return;
    await _playTone(frequency: 1000, durationMs: 30);
    await _playTone(frequency: 600, durationMs: 50);
  }

  /// Motor hum
  Future<void> playMotor({double speed = 1.0}) async {
    await _playTone(frequency: 100 * speed, durationMs: 100, waveType: WaveType.sawtooth);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

enum WaveType {
  sine,
  square,
  triangle,
  sawtooth,
  noise,
}
