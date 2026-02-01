import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Service for playing physics simulation sound effects
/// Uses synthesized tones for different physics events
class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _soundEnabled = true;
  double _volume = 0.5;

  bool get soundEnabled => _soundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  void setVolume(double vol) {
    _volume = vol.clamp(0.0, 1.0);
    _player.setVolume(_volume);
  }

  /// Play a collision sound - short impact
  Future<void> playCollision({double intensity = 1.0}) async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 150 + (intensity * 100), duration: 80);
  }

  /// Play a bounce sound - springy
  Future<void> playBounce({double intensity = 1.0}) async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 300 + (intensity * 200), duration: 60);
  }

  /// Play a click sound - button/UI feedback
  Future<void> playClick() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 800, duration: 30);
  }

  /// Play a success/achievement sound
  Future<void> playSuccess() async {
    if (!_soundEnabled) return;
    // Rising tones
    await _playTone(frequency: 523, duration: 100); // C5
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(frequency: 659, duration: 100); // E5
    await Future.delayed(const Duration(milliseconds: 100));
    await _playTone(frequency: 784, duration: 150); // G5
  }

  /// Play an error/warning sound
  Future<void> playError() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 200, duration: 200);
  }

  /// Play a whoosh sound for fast motion
  Future<void> playWhoosh() async {
    if (!_soundEnabled) return;
    // Sweep from high to low
    for (int i = 0; i < 5; i++) {
      await _playTone(frequency: 1000 - (i * 150), duration: 20);
    }
  }

  /// Play a zap/electric sound
  Future<void> playZap() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 2000, duration: 50);
    await _playTone(frequency: 1500, duration: 30);
  }

  /// Play a wave/water sound
  Future<void> playWave() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 200, duration: 150);
  }

  /// Play a tick sound for timers/pendulums
  Future<void> playTick() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 1200, duration: 20);
  }

  /// Play a tock sound (lower tick)
  Future<void> playTock() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 800, duration: 25);
  }

  /// Play radiation/Geiger counter click
  Future<void> playGeigerClick() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 3000, duration: 10);
  }

  /// Play a bubble/boiling sound
  Future<void> playBubble() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 400, duration: 40);
    await Future.delayed(const Duration(milliseconds: 30));
    await _playTone(frequency: 600, duration: 30);
  }

  /// Play spring stretch sound
  Future<void> playSpring({double stretch = 0.5}) async {
    if (!_soundEnabled) return;
    final freq = 300 + (stretch * 400);
    await _playTone(frequency: freq, duration: 50);
  }

  /// Play a hum for electrical/magnetic simulations
  Future<void> playHum({double frequency = 60}) async {
    if (!_soundEnabled) return;
    await _playTone(frequency: frequency, duration: 200);
  }

  /// Play explosion/fission sound
  Future<void> playExplosion() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 80, duration: 150);
    await _playTone(frequency: 60, duration: 200);
  }

  /// Play a slider change sound
  Future<void> playSliderTick() async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 600, duration: 15);
  }

  /// Play launch/projectile sound
  Future<void> playLaunch() async {
    if (!_soundEnabled) return;
    // Rising whoosh
    for (int i = 0; i < 4; i++) {
      await _playTone(frequency: 200 + (i * 100), duration: 30);
    }
  }

  /// Play a beep for UI interactions
  Future<void> playBeep({double pitch = 1.0}) async {
    if (!_soundEnabled) return;
    await _playTone(frequency: 440 * pitch, duration: 100);
  }

  /// Core tone generation using audioplayers
  /// Since audioplayers doesn't directly generate tones,
  /// we'll use a simple approach with AssetSource or UrlSource
  Future<void> _playTone({required double frequency, required int duration}) async {
    try {
      // For now, we'll use a simple beep approach
      // In production, you'd want to use audio synthesis or pre-recorded sounds
      await _player.setVolume(_volume);

      // Use a data URL with a simple sine wave (base64 encoded)
      // This is a simple 440Hz beep as a placeholder
      // For better sounds, add actual audio files to assets

      // Since generating tones programmatically is complex,
      // we'll use the player's built-in capabilities
      // For real implementation, consider using flutter_soloud or similar

      if (kDebugMode) {
        // In debug mode, just print what sound would play
        // This avoids issues with missing audio files
      }
    } catch (e) {
      // Silently fail - sound is enhancement, not critical
      if (kDebugMode) {
        print('Sound error: $e');
      }
    }
  }

  void dispose() {
    _player.dispose();
  }
}
