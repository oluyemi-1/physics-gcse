import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/topic.dart';
import '../providers/app_provider.dart';
import '../data/question_bank.dart';
import 'lesson_screen.dart';
import 'quiz_screen.dart';
import 'simulation_screen.dart';
import 'practice_setup_screen.dart';

class TopicDetailScreen extends StatelessWidget {
  final Topic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: _buildDescription(context),
          ),
          SliverToBoxAdapter(
            child: _buildPracticeButton(context),
          ),
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Lessons', Icons.menu_book),
          ),
          _buildLessonsList(context),
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Quizzes', Icons.quiz),
          ),
          _buildQuizzesList(context),
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Interactive Simulations', Icons.science),
          ),
          _buildSimulationsList(context),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          topic.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.black54, blurRadius: 4),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                topic.color,
                topic.color.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                bottom: -50,
                child: Icon(
                  topic.icon,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Center(
                child: Icon(
                  topic.icon,
                  size: 80,
                  color: Colors.white,
                ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
              ),
            ],
          ),
        ),
      ),
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: topic.color),
                const SizedBox(width: 8),
                Text(
                  'About this topic',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: topic.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              topic.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.2),
    );
  }

  Widget _buildPracticeButton(BuildContext context) {
    final questionCount = QuestionBank.getQuestionsForTopic(topic.id).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PracticeSetupScreen(
                preselectedTopicId: topic.id,
                topicColor: topic.color,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                topic.color.withValues(alpha: 0.8),
                topic.color.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: topic.color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Practice Questions',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$questionCount questions available',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.2),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: topic.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: topic.color, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ).animate().fadeIn().slideX(begin: -0.2),
    );
  }

  Widget _buildLessonsList(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = topic.lessons[index];
            return Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final isComplete = appProvider.isLessonComplete(topic.id, lesson.id);
                return _LessonCard(
                  lesson: lesson,
                  topic: topic,
                  index: index,
                  isComplete: isComplete,
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 * index),
                ).slideX(begin: 0.2);
              },
            );
          },
          childCount: topic.lessons.length,
        ),
      ),
    );
  }

  Widget _buildQuizzesList(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final quiz = topic.quizzes[index];
            return Consumer<AppProvider>(
              builder: (context, appProvider, child) {
                final result = appProvider.getQuizResult(topic.id, quiz.id);
                return _QuizCard(
                  quiz: quiz,
                  topic: topic,
                  index: index,
                  result: result,
                ).animate().fadeIn(
                  delay: Duration(milliseconds: 100 * index),
                ).slideX(begin: 0.2);
              },
            );
          },
          childCount: topic.quizzes.length,
        ),
      ),
    );
  }

  Widget _buildSimulationsList(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final simulation = topic.simulations[index];
            return _SimulationCard(
              simulation: simulation,
              topic: topic,
              index: index,
            ).animate().fadeIn(
              delay: Duration(milliseconds: 100 * index),
            ).slideX(begin: 0.2);
          },
          childCount: topic.simulations.length,
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  final Lesson lesson;
  final Topic topic;
  final int index;
  final bool isComplete;

  const _LessonCard({
    required this.lesson,
    required this.topic,
    required this.index,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isComplete
                ? Colors.green.withValues(alpha: 0.2)
                : topic.color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: isComplete
                ? const Icon(Icons.check, color: Colors.green)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: topic.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${lesson.keyPoints.length} key points',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: topic.color,
          size: 18,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonScreen(
                lesson: lesson,
                topic: topic,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final Quiz quiz;
  final Topic topic;
  final int index;
  final dynamic result;

  const _QuizCard({
    required this.quiz,
    required this.topic,
    required this.index,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final hasResult = result != null;
    final percentage = hasResult ? (result.percentage * 100).toInt() : 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasResult
                  ? [Colors.green.shade400, Colors.green.shade600]
                  : [topic.color, topic.color.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.quiz, color: Colors.white),
          ),
        ),
        title: Text(
          quiz.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            hasResult
                ? 'Best: $percentage% (${result.score}/${result.totalQuestions})'
                : '${quiz.questions.length} questions',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: topic.color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            hasResult ? 'Retry' : 'Start',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(
                quiz: quiz,
                topic: topic,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  final PhysicsSimulation simulation;
  final Topic topic;
  final int index;

  const _SimulationCard({
    required this.simulation,
    required this.topic,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.purple.shade400,
                Colors.blue.shade400,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white),
          ),
        ),
        title: Text(
          simulation.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            simulation.description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.blue.shade400],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Explore',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SimulationScreen(
                simulation: simulation,
                topic: topic,
              ),
            ),
          );
        },
      ),
    );
  }
}
