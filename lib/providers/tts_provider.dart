import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSProvider extends ChangeNotifier {
  FlutterTts? _flutterTts;
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = kIsWeb ? 0.8 : 0.45;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _currentText = '';
  List<String> _chunks = [];
  int _currentChunkIndex = 0;
  bool _stopRequested = false;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;

  TTSProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      _flutterTts = FlutterTts();
      final tts = _flutterTts!;

      await tts.setLanguage('en-GB');
      await tts.setSpeechRate(_speechRate);
      await tts.setPitch(_pitch);
      await tts.setVolume(_volume);

      tts.setStartHandler(() {
        _isPlaying = true;
        _isPaused = false;
        notifyListeners();
      });

      tts.setCompletionHandler(() {
        // Speak the next chunk if available
        _currentChunkIndex++;
        if (!_stopRequested && _currentChunkIndex < _chunks.length) {
          _flutterTts?.speak(_chunks[_currentChunkIndex]);
        } else {
          _isPlaying = false;
          _isPaused = false;
          _chunks = [];
          _currentChunkIndex = 0;
          notifyListeners();
        }
      });

      tts.setCancelHandler(() {
        _isPlaying = false;
        _isPaused = false;
        notifyListeners();
      });

      tts.setErrorHandler((msg) {
        _isPlaying = false;
        _isPaused = false;
        notifyListeners();
      });
    } catch (e) {
      debugPrint('TTS init failed: $e');
      _flutterTts = null;
    }
  }

  /// Split text into sentences to avoid the Web Speech API cutting off.
  List<String> _splitIntoChunks(String text) {
    // Split on sentence boundaries
    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    final List<String> chunks = [];
    String current = '';

    for (final sentence in sentences) {
      // Keep chunks under ~200 chars to stay well within the limit
      if (current.isNotEmpty && (current.length + sentence.length) > 200) {
        chunks.add(current.trim());
        current = sentence;
      } else {
        current = current.isEmpty ? sentence : '$current $sentence';
      }
    }
    if (current.trim().isNotEmpty) {
      chunks.add(current.trim());
    }

    return chunks.isEmpty ? [text] : chunks;
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    if (_flutterTts == null) return;

    _currentText = text;
    _stopRequested = false;

    // Clean text for better TTS
    String cleanText = text
        .replaceAll('•', '')
        .replaceAll('→', 'gives')
        .replaceAll('×', 'times')
        .replaceAll('÷', 'divided by')
        .replaceAll('²', ' squared')
        .replaceAll('³', ' cubed')
        .replaceAll('≈', 'approximately equals')
        .replaceAll('=', ' equals ')
        .replaceAll('/', ' divided by ')
        .replaceAll('λ', 'lambda')
        .replaceAll('ρ', 'rho')
        .replaceAll('Ω', 'ohms');

    await _flutterTts!.stop();

    if (kIsWeb) {
      // Split into chunks to avoid Web Speech API timeout
      _chunks = _splitIntoChunks(cleanText);
      _currentChunkIndex = 0;
      await _flutterTts!.speak(_chunks[0]);
    } else {
      _chunks = [];
      _currentChunkIndex = 0;
      await _flutterTts!.speak(cleanText);
    }
  }

  Future<void> stop() async {
    _stopRequested = true;
    _chunks = [];
    _currentChunkIndex = 0;
    try {
      await _flutterTts?.stop();
    } catch (_) {}
    _isPlaying = false;
    _isPaused = false;
    notifyListeners();
  }

  Future<void> pause() async {
    await _flutterTts?.pause();
    _isPaused = true;
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_currentText.isNotEmpty) {
      await speak(_currentText);
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts?.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts?.setPitch(pitch);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _flutterTts?.setVolume(volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _stopRequested = true;
    try {
      _flutterTts?.stop();
    } catch (_) {}
    super.dispose();
  }
}
