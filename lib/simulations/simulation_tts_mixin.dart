import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tts_provider.dart';

/// A mixin that provides TTS (Text-to-Speech) functionality for simulations.
/// This allows simulations to narrate what's happening as users interact.
mixin SimulationTTSMixin<T extends StatefulWidget> on State<T> {
  TTSProvider? _ttsProvider;
  bool _ttsEnabled = true;
  String _lastSpokenText = '';
  DateTime _lastSpeakTime = DateTime.now();

  /// Minimum time between TTS announcements to avoid spam
  static const Duration _minSpeakInterval = Duration(milliseconds: 1500);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsProvider = Provider.of<TTSProvider>(context, listen: false);
  }

  /// Speaks the given text if TTS is enabled and enough time has passed
  void speakSimulation(String text, {bool force = false}) {
    if (!_ttsEnabled || _ttsProvider == null) return;
    if (text.isEmpty || text == _lastSpokenText) return;

    final now = DateTime.now();
    if (!force && now.difference(_lastSpeakTime) < _minSpeakInterval) return;

    _lastSpokenText = text;
    _lastSpeakTime = now;
    _ttsProvider!.speak(text);
  }

  /// Stops any ongoing TTS speech
  void stopSimulationSpeech() {
    _ttsProvider?.stop();
  }

  /// Toggles TTS on/off
  void toggleTTS() {
    setState(() {
      _ttsEnabled = !_ttsEnabled;
      if (!_ttsEnabled) {
        stopSimulationSpeech();
      }
    });
  }

  bool get isTTSEnabled => _ttsEnabled;

  /// Builds a TTS toggle button widget
  Widget buildTTSToggle() {
    return IconButton(
      onPressed: toggleTTS,
      icon: Icon(
        _ttsEnabled ? Icons.volume_up : Icons.volume_off,
        color: _ttsEnabled ? Colors.cyan : Colors.grey,
      ),
      tooltip: _ttsEnabled ? 'Disable voice-over' : 'Enable voice-over',
    );
  }

  @override
  void dispose() {
    stopSimulationSpeech();
    super.dispose();
  }
}
