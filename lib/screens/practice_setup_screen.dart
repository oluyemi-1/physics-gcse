import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../data/question_bank.dart';
import '../models/topic.dart';
import 'practice_screen.dart';

class PracticeSetupScreen extends StatefulWidget {
  final String? preselectedTopicId;
  final Color? topicColor;

  const PracticeSetupScreen({
    super.key,
    this.preselectedTopicId,
    this.topicColor,
  });

  @override
  State<PracticeSetupScreen> createState() => _PracticeSetupScreenState();
}

class _PracticeSetupScreenState extends State<PracticeSetupScreen> {
  String _selectedTopic = 'all';
  int _questionCount = 10;
  bool _shuffleQuestions = true;
  bool _showExplanations = true;

  final Map<String, String> _topicNames = {
    'all': 'All Topics',
    'forces_motion': 'Forces & Motion',
    'waves': 'Waves',
    'electricity': 'Electricity',
    'magnetism': 'Magnetism',
    'space': 'Space',
    'energy': 'Energy',
    'nuclear': 'Nuclear Physics',
    'thermal': 'Thermal Physics',
  };

  final Map<String, IconData> _topicIcons = {
    'all': Icons.all_inclusive,
    'forces_motion': Icons.speed,
    'waves': Icons.waves,
    'electricity': Icons.bolt,
    'magnetism': Icons.compass_calibration,
    'space': Icons.rocket_launch,
    'energy': Icons.local_fire_department,
    'nuclear': Icons.science,
    'thermal': Icons.thermostat,
  };

  final Map<String, Color> _topicColors = {
    'all': Colors.purple,
    'forces_motion': Colors.blue,
    'waves': Colors.teal,
    'electricity': Colors.amber,
    'magnetism': Colors.red,
    'space': Colors.indigo,
    'energy': Colors.orange,
    'nuclear': Colors.green,
    'thermal': Colors.deepOrange,
  };

  @override
  void initState() {
    super.initState();
    if (widget.preselectedTopicId != null) {
      _selectedTopic = widget.preselectedTopicId!;
    }
  }

  int get _availableQuestions {
    if (_selectedTopic == 'all') {
      return QuestionBank.totalQuestionCount;
    }
    return QuestionBank.getQuestionsForTopic(_selectedTopic).length;
  }

  List<Question> _getQuestions() {
    List<Question> questions;
    if (_selectedTopic == 'all') {
      questions = [];
      for (var topicId in _topicNames.keys) {
        if (topicId != 'all') {
          questions.addAll(QuestionBank.getQuestionsForTopic(topicId));
        }
      }
    } else {
      questions = List.from(QuestionBank.getQuestionsForTopic(_selectedTopic));
    }

    if (_shuffleQuestions) {
      questions.shuffle();
    }

    return questions.take(_questionCount).toList();
  }

  void _startPractice() {
    final questions = _getQuestions();
    if (questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions available for this topic')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PracticeScreen(
          questions: questions,
          topicName: _topicNames[_selectedTopic]!,
          topicColor: widget.topicColor ?? _topicColors[_selectedTopic]!,
          showExplanations: _showExplanations,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.topicColor ?? _topicColors[_selectedTopic]!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Mode'),
        backgroundColor: primaryColor.withValues(alpha: 0.8),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Icon(Icons.fitness_center, size: 48, color: Colors.white),
                  const SizedBox(height: 12),
                  const Text(
                    'Practice Questions',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${QuestionBank.totalQuestionCount} questions available',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.2),

            const SizedBox(height: 24),

            // Topic Selection
            Text(
              'Select Topic',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedTopic,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  borderRadius: BorderRadius.circular(12),
                  items: _topicNames.entries.map((entry) {
                    final count = entry.key == 'all'
                        ? QuestionBank.totalQuestionCount
                        : QuestionBank.getQuestionsForTopic(entry.key).length;
                    return DropdownMenuItem(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(_topicIcons[entry.key],
                               color: _topicColors[entry.key], size: 24),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value)),
                          Text('($count)',
                               style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTopic = value!;
                      // Adjust question count if it exceeds available
                      if (_questionCount > _availableQuestions) {
                        _questionCount = _availableQuestions;
                      }
                    });
                  },
                ),
              ),
            ).animate().fadeIn(delay: 150.ms),

            const SizedBox(height: 24),

            // Question Count
            Text(
              'Number of Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _questionCount.toDouble(),
                    min: 5,
                    max: _availableQuestions.toDouble().clamp(5, 50),
                    divisions: ((_availableQuestions.clamp(5, 50) - 5) ~/ 5).clamp(1, 9),
                    activeColor: primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _questionCount = value.toInt();
                      });
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_questionCount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 250.ms),

            // Quick select buttons
            Wrap(
              spacing: 8,
              children: [5, 10, 20, 30, 50]
                  .where((n) => n <= _availableQuestions)
                  .map((count) => ActionChip(
                        label: Text('$count'),
                        backgroundColor: _questionCount == count
                            ? primaryColor
                            : Colors.grey[200],
                        labelStyle: TextStyle(
                          color: _questionCount == count
                              ? Colors.white
                              : Colors.black87,
                        ),
                        onPressed: () {
                          setState(() {
                            _questionCount = count;
                          });
                        },
                      ))
                  .toList(),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Options
            Text(
              'Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ).animate().fadeIn(delay: 350.ms),
            const SizedBox(height: 12),

            _buildOptionTile(
              'Shuffle Questions',
              'Randomize question order',
              Icons.shuffle,
              _shuffleQuestions,
              (value) => setState(() => _shuffleQuestions = value),
              primaryColor,
            ).animate().fadeIn(delay: 400.ms),

            _buildOptionTile(
              'Show Explanations',
              'Display explanations after each answer',
              Icons.lightbulb_outline,
              _showExplanations,
              (value) => setState(() => _showExplanations = value),
              primaryColor,
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 32),

            // Start Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startPractice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_arrow, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Start Practice ($_questionCount questions)',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Info text
            Center(
              child: Text(
                'Questions include explanations and simulator references',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 550.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        secondary: Icon(icon, color: color),
        value: value,
        activeColor: color,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
