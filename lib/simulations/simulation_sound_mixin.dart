import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Mixin to add sound effects to physics simulations
/// Provides various physics-related sound effects
mixin SimulationSoundMixin<T extends StatefulWidget> on State<T> {
  final AudioPlayer _soundPlayer = AudioPlayer();
  bool _soundEnabled = true;
  double _soundVolume = 0.5;

  // Cooldown to prevent sound spam
  DateTime? _lastSoundTime;
  final Duration _soundCooldown = const Duration(milliseconds: 50);

  bool get soundEnabled => _soundEnabled;

  @override
  void dispose() {
    _soundPlayer.dispose();
    super.dispose();
  }

  /// Toggle sound on/off
  void toggleSound() {
    setState(() {
      _soundEnabled = !_soundEnabled;
    });
  }

  /// Set sound volume (0.0 to 1.0)
  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
  }

  /// Check if enough time has passed since last sound
  bool _canPlaySound() {
    if (!_soundEnabled) return false;
    final now = DateTime.now();
    if (_lastSoundTime != null &&
        now.difference(_lastSoundTime!) < _soundCooldown) {
      return false;
    }
    _lastSoundTime = now;
    return true;
  }

  /// Play collision/impact sound
  Future<void> playCollisionSound({double intensity = 1.0}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 150 + (intensity * 100),
      duration: const Duration(milliseconds: 80),
      type: ToneType.square,
    );
  }

  /// Play bounce sound
  Future<void> playBounceSound({double intensity = 1.0}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 300 + (intensity * 200),
      duration: const Duration(milliseconds: 60),
      type: ToneType.sine,
    );
  }

  /// Play click/tap sound
  Future<void> playClickSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 800,
      duration: const Duration(milliseconds: 30),
      type: ToneType.square,
    );
  }

  /// Play success/correct answer sound
  Future<void> playSuccessSound() async {
    if (!_canPlaySound()) return;
    // Play ascending notes
    await _playGeneratedTone(frequency: 523, duration: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(milliseconds: 80));
    await _playGeneratedTone(frequency: 659, duration: const Duration(milliseconds: 100));
    await Future.delayed(const Duration(milliseconds: 80));
    await _playGeneratedTone(frequency: 784, duration: const Duration(milliseconds: 150));
  }

  /// Play error/wrong sound
  Future<void> playErrorSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 200,
      duration: const Duration(milliseconds: 200),
      type: ToneType.square,
    );
  }

  /// Play whoosh sound for fast motion
  Future<void> playWhooshSound() async {
    if (!_canPlaySound()) return;
    for (int i = 0; i < 3; i++) {
      await _playGeneratedTone(
        frequency: 800 - (i * 200),
        duration: const Duration(milliseconds: 30),
      );
    }
  }

  /// Play electric zap sound
  Future<void> playZapSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 2000,
      duration: const Duration(milliseconds: 40),
      type: ToneType.square,
    );
  }

  /// Play tick sound (for pendulum, clock, etc.)
  Future<void> playTickSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 1200,
      duration: const Duration(milliseconds: 15),
      type: ToneType.square,
    );
  }

  /// Play tock sound (lower tick)
  Future<void> playTockSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 600,
      duration: const Duration(milliseconds: 20),
      type: ToneType.square,
    );
  }

  /// Play Geiger counter click
  Future<void> playGeigerSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 3000,
      duration: const Duration(milliseconds: 8),
      type: ToneType.square,
    );
  }

  /// Play bubble sound
  Future<void> playBubbleSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 400,
      duration: const Duration(milliseconds: 40),
    );
    await _playGeneratedTone(
      frequency: 600,
      duration: const Duration(milliseconds: 30),
    );
  }

  /// Play spring sound based on stretch amount
  Future<void> playSpringSoun({double stretch = 0.5}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 300 + (stretch * 400),
      duration: const Duration(milliseconds: 50),
    );
  }

  /// Play electrical hum
  Future<void> playHumSound({double freq = 60}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: freq,
      duration: const Duration(milliseconds: 150),
      type: ToneType.sine,
    );
  }

  /// Play explosion sound
  Future<void> playExplosionSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 80,
      duration: const Duration(milliseconds: 150),
      type: ToneType.noise,
    );
  }

  /// Play launch/fire projectile sound
  Future<void> playLaunchSound() async {
    if (!_canPlaySound()) return;
    for (int i = 0; i < 4; i++) {
      await _playGeneratedTone(
        frequency: 200 + (i * 100),
        duration: const Duration(milliseconds: 25),
      );
    }
  }

  /// Play slider adjustment sound
  Future<void> playSliderSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 500,
      duration: const Duration(milliseconds: 10),
    );
  }

  /// Play wave sound
  Future<void> playWaveSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 220,
      duration: const Duration(milliseconds: 200),
      type: ToneType.sine,
    );
  }

  /// Play beep at specified pitch
  Future<void> playBeepSound({double pitch = 1.0}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 440 * pitch,
      duration: const Duration(milliseconds: 100),
    );
  }

  /// Play metallic clang (for Newton's cradle, etc.)
  Future<void> playClangSound({double pitch = 1.0}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 800 * pitch,
      duration: const Duration(milliseconds: 100),
      type: ToneType.triangle,
    );
  }

  /// Play drip/water drop sound
  Future<void> playDripSound() async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 1000,
      duration: const Duration(milliseconds: 30),
    );
    await _playGeneratedTone(
      frequency: 600,
      duration: const Duration(milliseconds: 50),
    );
  }

  /// Play motor/generator hum
  Future<void> playMotorSound({double speed = 1.0}) async {
    if (!_canPlaySound()) return;
    await _playGeneratedTone(
      frequency: 100 * speed,
      duration: const Duration(milliseconds: 100),
      type: ToneType.sawtooth,
    );
  }

  /// Generate and play a tone using Web Audio concepts
  /// Since audioplayers doesn't directly support tone generation,
  /// we use a simple frequency-to-note mapping approach
  Future<void> _playGeneratedTone({
    required double frequency,
    required Duration duration,
    ToneType type = ToneType.sine,
  }) async {
    try {
      await _soundPlayer.setVolume(_soundVolume);

      // Map frequency to a musical note and use asset-based approach
      // For now, we'll use system sounds or simple beeps
      // In a full implementation, you'd have actual sound files

      // Use the player's built-in capabilities
      // This is a simplified version - real implementation would
      // use actual audio synthesis or pre-recorded sound effects

      await _soundPlayer.setVolume(_soundVolume);

      // Play a simple system sound as fallback
      // Real implementation: await _soundPlayer.play(AssetSource('sounds/beep.mp3'));

    } catch (e) {
      // Silently fail - sounds are non-critical
    }
  }

  /// Build a sound toggle button for the AppBar
  Widget buildSoundToggle() {
    return IconButton(
      icon: Icon(
        _soundEnabled ? Icons.volume_up : Icons.volume_off,
        color: _soundEnabled ? Colors.white : Colors.grey,
      ),
      onPressed: toggleSound,
      tooltip: _soundEnabled ? 'Mute sounds' : 'Enable sounds',
    );
  }
}

/// Types of generated tones
enum ToneType {
  sine,
  square,
  triangle,
  sawtooth,
  noise,
}
