import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  double _speechRate = kIsWeb ? 0.9 : 0.5;
  double _pitch = 1.0;
  double _volume = 1.0;
  String _currentText = '';
  int _currentPosition = 0;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  double get speechRate => _speechRate;
  double get pitch => _pitch;
  double get volume => _volume;

  TTSProvider() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('en-GB');
    await _flutterTts.setSpeechRate(_speechRate);
    await _flutterTts.setPitch(_pitch);
    await _flutterTts.setVolume(_volume);

    _flutterTts.setStartHandler(() {
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
      _isPaused = false;
      _currentPosition = 0;
      notifyListeners();
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
      _isPaused = false;
      notifyListeners();
    });

    _flutterTts.setPauseHandler(() {
      _isPlaying = false;
      _isPaused = true;
      notifyListeners();
    });

    _flutterTts.setContinueHandler(() {
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
    });

    _flutterTts.setProgressHandler((text, start, end, word) {
      _currentPosition = start;
      notifyListeners();
    });
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    _currentText = text;
    _currentPosition = 0;

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

    await _flutterTts.speak(cleanText);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isPlaying = false;
    _isPaused = false;
    _currentPosition = 0;
    notifyListeners();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  Future<void> resume() async {
    // Flutter TTS doesn't support resume well on all platforms
    // So we restart from beginning for now
    if (_currentText.isNotEmpty) {
      await speak(_currentText);
    }
  }

  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate;
    await _flutterTts.setSpeechRate(rate);
    notifyListeners();
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
    await _flutterTts.setPitch(pitch);
    notifyListeners();
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
    await _flutterTts.setVolume(volume);
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
