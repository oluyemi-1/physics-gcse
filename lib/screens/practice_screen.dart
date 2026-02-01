import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'package:provider/provider.dart';
import '../models/topic.dart';
import '../providers/tts_provider.dart';

/// A shuffled question that keeps track of the original correct answer
class ShuffledQuestion {
  final Question original;
  final List<String> shuffledOptions;
  final int shuffledCorrectIndex;

  ShuffledQuestion({
    required this.original,
    required this.shuffledOptions,
    required this.shuffledCorrectIndex,
  });

  String get question => original.question;
  String get explanation => original.explanation;
  String? get formula => original.formula;
  List<String> get options => shuffledOptions;
  int get correctIndex => shuffledCorrectIndex;
}

class PracticeScreen extends StatefulWidget {
  final List<Question> questions;
  final String topicName;
  final Color topicColor;
  final bool showExplanations;

  const PracticeScreen({
    super.key,
    required this.questions,
    required this.topicName,
    required this.topicColor,
    this.showExplanations = true,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  bool _isComplete = false;
  late ConfettiController _confettiController;
  late List<ShuffledQuestion> _shuffledQuestions;

  // TTS state
  bool _ttsEnabled = true;
  TTSProvider? _ttsProvider;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _shuffledQuestions = _shuffleAllQuestions(widget.questions);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ttsProvider = Provider.of<TTSProvider>(context, listen: false);
    // Speak the first question after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _speakQuestion();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _ttsProvider?.stop();
    super.dispose();
  }

  /// Shuffles all questions' options to distribute correct answers evenly
  List<ShuffledQuestion> _shuffleAllQuestions(List<Question> questions) {
    return questions.map((q) {
      // Create a list of indices [0, 1, 2, 3]
      final indices = List.generate(q.options.length, (i) => i);
      indices.shuffle();

      // Reorder options according to shuffled indices
      final shuffledOptions = indices.map((i) => q.options[i]).toList();

      // Find where the correct answer ended up
      final newCorrectIndex = indices.indexOf(q.correctIndex);

      return ShuffledQuestion(
        original: q,
        shuffledOptions: shuffledOptions,
        shuffledCorrectIndex: newCorrectIndex,
      );
    }).toList();
  }

  ShuffledQuestion get _currentQuestion => _shuffledQuestions[_currentQuestionIndex];

  void _speak(String text) {
    if (_ttsEnabled && _ttsProvider != null) {
      _ttsProvider!.speak(text);
    }
  }

  void _stopSpeaking() {
    _ttsProvider?.stop();
  }

  void _speakQuestion() {
    if (!_ttsEnabled) return;
    final q = _currentQuestion;
    final optionLetters = ['A', 'B', 'C', 'D'];
    final optionsText = q.options.asMap().entries
        .map((e) => '${optionLetters[e.key]}: ${e.value}')
        .join('. ');
    _speak('Question ${_currentQuestionIndex + 1}. ${q.question}. Options: $optionsText');
  }

  void _toggleTTS() {
    setState(() {
      _ttsEnabled = !_ttsEnabled;
      if (!_ttsEnabled) {
        _stopSpeaking();
      }
    });
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;

      if (index == _currentQuestion.correctIndex) {
        _score++;
        _speak('Correct! ${widget.showExplanations ? _currentQuestion.explanation : ''}');
      } else {
        final correctLetter = ['A', 'B', 'C', 'D'][_currentQuestion.correctIndex];
        _speak('Incorrect. The correct answer is $correctLetter. ${widget.showExplanations ? _currentQuestion.explanation : ''}');
      }
    });
  }

  void _nextQuestion() {
    _stopSpeaking();
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
      // Speak the new question after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        _speakQuestion();
      });
    } else {
      _finishPractice();
    }
  }

  void _finishPractice() {
    setState(() {
      _isComplete = true;
    });

    final percentage = (_score / widget.questions.length * 100).round();
    if (percentage >= 70) {
      _confettiController.play();
      _speak('Congratulations! You scored $percentage percent. $_score out of ${widget.questions.length} correct. Great job!');
    } else {
      _speak('Practice complete. You scored $percentage percent. $_score out of ${widget.questions.length} correct. Keep practicing!');
    }
  }

  void _restartPractice() {
    _stopSpeaking();
    setState(() {
      // Reshuffle questions for variety
      _shuffledQuestions = _shuffleAllQuestions(widget.questions);
      _currentQuestionIndex = 0;
      _score = 0;
      _selectedAnswerIndex = null;
      _hasAnswered = false;
      _isComplete = false;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _speakQuestion();
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Practice?'),
        content: Text(
          'You\'ve answered $_currentQuestionIndex out of ${widget.questions.length} questions.\n'
          'Current score: $_score correct',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue'),
          ),
          TextButton(
            onPressed: () {
              _stopSpeaking();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isComplete ? _buildResultScreen() : _buildPracticeScreen(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                widget.topicColor,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.pink,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeScreen() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildQuestionCard(),
                  const SizedBox(height: 24),
                  _buildAnswerOptions(),
                  if (_hasAnswered && widget.showExplanations) ...[
                    const SizedBox(height: 24),
                    _buildExplanation(),
                  ],
                  if (_hasAnswered) ...[
                    const SizedBox(height: 24),
                    _buildNextButton(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close),
            ),
            onPressed: _showExitDialog,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  'Practice Mode',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  widget.topicName,
                  style: TextStyle(
                    color: widget.topicColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // TTS Toggle Button
          IconButton(
            onPressed: _toggleTTS,
            icon: Icon(
              _ttsEnabled ? Icons.volume_up : Icons.volume_off,
              color: _ttsEnabled ? widget.topicColor : Colors.grey,
            ),
            tooltip: _ttsEnabled ? 'Disable voice' : 'Enable voice',
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.topicColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$_score',
                  style: TextStyle(
                    color: widget.topicColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentQuestionIndex + 1}/${widget.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${((_currentQuestionIndex + 1) / widget.questions.length * 100).toInt()}%',
                style: TextStyle(
                  color: widget.topicColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.questions.length,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(widget.topicColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.topicColor.withValues(alpha: 0.8),
            widget.topicColor.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.topicColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              // Replay question button
              IconButton(
                onPressed: _speakQuestion,
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.replay,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                tooltip: 'Read question again',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _currentQuestion.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentQuestion.formula != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentQuestion.formula!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildAnswerOptions() {
    return Column(
      children: List.generate(
        _currentQuestion.options.length,
        (index) => _buildAnswerOption(index),
      ),
    );
  }

  Widget _buildAnswerOption(int index) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == _currentQuestion.correctIndex;
    final showResult = _hasAnswered;

    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData? icon;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.15);
        borderColor = Colors.green;
        textColor = Colors.green;
        icon = Icons.check_circle;
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: 0.15);
        borderColor = Colors.red;
        textColor = Colors.red;
        icon = Icons.cancel;
      } else {
        backgroundColor = Colors.transparent;
        borderColor = Colors.grey.withValues(alpha: 0.3);
        textColor = Colors.grey;
        icon = null;
      }
    } else {
      backgroundColor = isSelected
          ? widget.topicColor.withValues(alpha: 0.15)
          : Colors.transparent;
      borderColor = isSelected
          ? widget.topicColor
          : Colors.grey.withValues(alpha: 0.3);
      textColor = isSelected ? widget.topicColor : Colors.white;
      icon = null;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _hasAnswered ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _currentQuestion.options[index],
                  style: TextStyle(
                    fontSize: 15,
                    color: showResult ? textColor : Colors.white,
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, color: textColor)
                    .animate()
                    .scale(duration: 300.ms, curve: Curves.elasticOut),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1);
  }

  Widget _buildExplanation() {
    final isCorrect = _selectedAnswerIndex == _currentQuestion.correctIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: (isCorrect ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isCorrect ? Colors.green : Colors.orange).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle : Icons.info,
                color: isCorrect ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct!' : 'Explanation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isCorrect ? Colors.green : Colors.orange,
                ),
              ),
              const Spacer(),
              // Replay explanation button
              IconButton(
                onPressed: () {
                  _speak(_currentQuestion.explanation);
                },
                icon: Icon(
                  Icons.volume_up,
                  color: isCorrect ? Colors.green : Colors.orange,
                  size: 20,
                ),
                tooltip: 'Read explanation',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.explanation,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (_currentQuestion.formula != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.functions, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Formula: ${_currentQuestion.formula}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildNextButton() {
    final isLastQuestion = _currentQuestionIndex == widget.questions.length - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.topicColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastQuestion ? 'See Results' : 'Next Question',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(isLastQuestion ? Icons.done_all : Icons.arrow_forward),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildResultScreen() {
    final percentage = (_score / widget.questions.length * 100).round();
    final isPassing = percentage >= 70;

    String message;
    IconData icon;
    Color color;

    if (percentage >= 90) {
      message = 'Outstanding! You\'re a physics master!';
      icon = Icons.emoji_events;
      color = Colors.amber;
    } else if (percentage >= 70) {
      message = 'Great job! Keep up the good work!';
      icon = Icons.celebration;
      color = Colors.green;
    } else if (percentage >= 50) {
      message = 'Good effort! Review the explanations to improve.';
      icon = Icons.thumb_up;
      color = Colors.orange;
    } else {
      message = 'Keep practicing! You\'ll get there.';
      icon = Icons.fitness_center;
      color = Colors.blue;
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 80, color: color),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Practice Complete!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 8),
            Text(
              widget.topicName,
              style: TextStyle(
                color: widget.topicColor,
                fontSize: 16,
              ),
            ).animate().fadeIn(delay: 250.ms),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.topicColor.withValues(alpha: 0.8),
                    widget.topicColor.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    '$percentage%',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_score out of ${widget.questions.length} correct',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(isPassing ? Icons.check_circle : Icons.lightbulb, color: color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(color: color, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _restartPractice,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: widget.topicColor,
                      side: BorderSide(color: widget.topicColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _stopSpeaking();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.done),
                    label: const Text('Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.topicColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                _stopSpeaking();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Setup'),
            ).animate().fadeIn(delay: 550.ms),
          ],
        ),
      ),
    );
  }
}
