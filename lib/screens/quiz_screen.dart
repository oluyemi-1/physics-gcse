import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../models/topic.dart';
import '../providers/app_provider.dart';
import '../widgets/scientific_calculator.dart';

class QuizScreen extends StatefulWidget {
  final Quiz quiz;
  final Topic topic;

  const QuizScreen({
    super.key,
    required this.quiz,
    required this.topic,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;
  bool _isQuizComplete = false;
  late ConfettiController _confettiController;
  final List<int?> _userAnswers = [];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _userAnswers.addAll(List.filled(widget.quiz.questions.length, null));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Question get _currentQuestion => widget.quiz.questions[_currentQuestionIndex];

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;
      _userAnswers[_currentQuestionIndex] = index;

      if (index == _currentQuestion.correctIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() {
    setState(() {
      _isQuizComplete = true;
    });

    // Save result
    context.read<AppProvider>().saveQuizResult(
          widget.topic.id,
          widget.quiz.id,
          _score,
          widget.quiz.questions.length,
        );

    // Celebrate if score is good
    if (_score / widget.quiz.questions.length >= 0.7) {
      _confettiController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _isQuizComplete ? _buildResultScreen() : _buildQuizScreen(),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                widget.topic.color,
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

  Widget _buildQuizScreen() {
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
                  ScientificCalculator(accentColor: widget.topic.color),
                  if (_hasAnswered) ...[
                    const SizedBox(height: 24),
                    _buildExplanation(),
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
            onPressed: () => _showExitDialog(),
          ),
          Expanded(
            child: Text(
              widget.quiz.title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: widget.topic.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_score/${_currentQuestionIndex + (_hasAnswered ? 1 : 0)}',
              style: TextStyle(
                color: widget.topic.color,
                fontWeight: FontWeight.bold,
              ),
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
                'Question ${_currentQuestionIndex + 1}/${widget.quiz.questions.length}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${((_currentQuestionIndex + 1) / widget.quiz.questions.length * 100).toInt()}%',
                style: TextStyle(
                  color: widget.topic.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / widget.quiz.questions.length,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(widget.topic.color),
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
            widget.topic.color.withValues(alpha: 0.8),
            widget.topic.color.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.topic.color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
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
          const SizedBox(height: 20),
          Text(
            _currentQuestion.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (_currentQuestion.formula != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _currentQuestion.formula!,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
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
      children: _currentQuestion.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = _selectedAnswerIndex == index;
        final isCorrect = index == _currentQuestion.correctIndex;
        final showResult = _hasAnswered;

        Color getBackgroundColor() {
          if (!showResult) {
            return isSelected
                ? widget.topic.color.withValues(alpha: 0.2)
                : Theme.of(context).cardColor;
          }
          if (isCorrect) return Colors.green.withValues(alpha: 0.2);
          if (isSelected && !isCorrect) return Colors.red.withValues(alpha: 0.2);
          return Theme.of(context).cardColor;
        }

        Color getBorderColor() {
          if (!showResult) {
            return isSelected ? widget.topic.color : Colors.transparent;
          }
          if (isCorrect) return Colors.green;
          if (isSelected && !isCorrect) return Colors.red;
          return Colors.transparent;
        }

        IconData? getIcon() {
          if (!showResult) return null;
          if (isCorrect) return Icons.check_circle;
          if (isSelected && !isCorrect) return Icons.cancel;
          return null;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _selectAnswer(index),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getBackgroundColor(),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: getBorderColor(),
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.topic.color
                          : Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (getIcon() != null)
                    Icon(
                      getIcon(),
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                ],
              ),
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.2);
      }).toList(),
    );
  }

  Widget _buildExplanation() {
    final isCorrect = _selectedAnswerIndex == _currentQuestion.correctIndex;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.celebration : Icons.lightbulb,
                color: isCorrect ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                isCorrect ? 'Correct!' : 'Explanation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isCorrect ? Colors.green : Colors.orange,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentQuestion.explanation,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.5,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildNextButton() {
    final isLastQuestion =
        _currentQuestionIndex == widget.quiz.questions.length - 1;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _nextQuestion,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.topic.color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          isLastQuestion ? 'See Results' : 'Next Question',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildResultScreen() {
    final percentage = _score / widget.quiz.questions.length;
    final grade = _getGrade(percentage);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildResultCard(percentage, grade),
            const SizedBox(height: 24),
            _buildScoreBreakdown(),
            const SizedBox(height: 24),
            _buildActionButtons(),
            const SizedBox(height: 24),
            _buildReviewSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(double percentage, String grade) {
    Color getGradeColor() {
      if (percentage >= 0.8) return Colors.green;
      if (percentage >= 0.6) return Colors.orange;
      return Colors.red;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getGradeColor().withValues(alpha: 0.8),
            getGradeColor().withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: getGradeColor().withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            grade,
            style: const TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            '${(percentage * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getResultMessage(percentage),
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildScoreBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Correct', '$_score', Colors.green),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildStatItem(
              'Incorrect', '${widget.quiz.questions.length - _score}', Colors.red),
          Container(
            height: 40,
            width: 1,
            color: Colors.grey.withValues(alpha: 0.3),
          ),
          _buildStatItem('Total', '${widget.quiz.questions.length}', widget.topic.color),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _currentQuestionIndex = 0;
                _score = 0;
                _selectedAnswerIndex = null;
                _hasAnswered = false;
                _isQuizComplete = false;
                _userAnswers.clear();
                _userAnswers.addAll(List.filled(widget.quiz.questions.length, null));
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
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
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.check),
            label: const Text('Done'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.topic.color,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildReviewSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Answers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...widget.quiz.questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            final userAnswer = _userAnswers[index];
            final isCorrect = userAnswer == question.correctIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.3)
                      : Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCorrect ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Q${index + 1}: ${question.question}',
                      style: const TextStyle(fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  String _getGrade(double percentage) {
    if (percentage >= 0.9) return 'A*';
    if (percentage >= 0.8) return 'A';
    if (percentage >= 0.7) return 'B';
    if (percentage >= 0.6) return 'C';
    if (percentage >= 0.5) return 'D';
    if (percentage >= 0.4) return 'E';
    return 'U';
  }

  String _getResultMessage(double percentage) {
    if (percentage >= 0.9) return 'Outstanding! You\'re a physics master!';
    if (percentage >= 0.8) return 'Excellent work! Keep it up!';
    if (percentage >= 0.7) return 'Good job! You\'re doing well!';
    if (percentage >= 0.6) return 'Not bad! A bit more practice will help.';
    if (percentage >= 0.5) return 'Keep studying! You can improve!';
    return 'Don\'t give up! Review the lessons and try again.';
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your progress will be lost if you exit now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
