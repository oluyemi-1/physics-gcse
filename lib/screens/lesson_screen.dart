import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/topic.dart';
import '../providers/app_provider.dart';
import '../providers/tts_provider.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final Topic topic;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.topic,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTTSControls = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TTSProvider(),
      child: Scaffold(
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: _buildContent(context),
            ),
          ],
        ),
        floatingActionButton: _buildTTSButton(context),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 160,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.lesson.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.topic.color,
                widget.topic.color.withValues(alpha: 0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                bottom: -30,
                child: Icon(
                  Icons.menu_book,
                  size: 150,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
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
        onPressed: () {
          context.read<TTSProvider>().stop();
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content card
          _buildContentCard(context).animate().fadeIn().slideY(begin: 0.2),
          const SizedBox(height: 20),

          // Key points section
          _buildKeyPointsSection(context)
              .animate()
              .fadeIn(delay: 200.ms)
              .slideY(begin: 0.2),

          // Formulas section (if any)
          if (widget.lesson.formulas.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildFormulasSection(context)
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2),
          ],

          const SizedBox(height: 20),

          // Mark complete button
          _buildCompleteButton(context)
              .animate()
              .fadeIn(delay: 600.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildContentCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.article, color: widget.topic.color),
              const SizedBox(width: 8),
              Text(
                'Lesson Content',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.topic.color,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Consumer<TTSProvider>(
                builder: (context, tts, child) {
                  return IconButton(
                    icon: Icon(
                      tts.isPlaying ? Icons.stop : Icons.volume_up,
                      color: widget.topic.color,
                    ),
                    onPressed: () {
                      if (tts.isPlaying) {
                        tts.stop();
                      } else {
                        tts.speak(widget.lesson.content);
                      }
                    },
                    tooltip: tts.isPlaying ? 'Stop reading' : 'Read aloud',
                  );
                },
              ),
            ],
          ),
          const Divider(height: 24),
          SelectableText(
            widget.lesson.content,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.8,
                  fontSize: 15,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyPointsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.topic.color.withValues(alpha: 0.1),
            widget.topic.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.topic.color.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: widget.topic.color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb, color: widget.topic.color),
              ),
              const SizedBox(width: 12),
              Text(
                'Key Points',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: widget.topic.color,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.lesson.keyPoints.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.topic.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.5,
                          ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
                  delay: Duration(milliseconds: 300 + (entry.key * 100)),
                );
          }),
        ],
      ),
    );
  }

  Widget _buildFormulasSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.indigo.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.functions, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              const Text(
                'Important Formulas',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.lesson.formulas.map((formula) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                formula,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, appProvider, child) {
        final isComplete = appProvider.isLessonComplete(
          widget.topic.id,
          widget.lesson.id,
        );

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isComplete
                ? null
                : () {
                    appProvider.markLessonComplete(
                      widget.topic.id,
                      widget.lesson.id,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Text('Lesson completed! +10 points'),
                          ],
                        ),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
            icon: Icon(isComplete ? Icons.check : Icons.done_all),
            label: Text(isComplete ? 'Completed' : 'Mark as Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: isComplete ? Colors.green : widget.topic.color,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTTSButton(BuildContext context) {
    return Consumer<TTSProvider>(
      builder: (context, tts, child) {
        if (!_showTTSControls && !tts.isPlaying) {
          return FloatingActionButton(
            backgroundColor: widget.topic.color,
            onPressed: () {
              setState(() {
                _showTTSControls = true;
              });
            },
            child: const Icon(Icons.headphones, color: Colors.white),
          );
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      tts.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: widget.topic.color,
                    ),
                    onPressed: () {
                      if (tts.isPlaying) {
                        tts.stop();
                      } else {
                        tts.speak(widget.lesson.content);
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: () {
                      tts.stop();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      tts.stop();
                      setState(() {
                        _showTTSControls = false;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.speed, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${tts.speechRate.toStringAsFixed(1)}x',
                    style: const TextStyle(fontSize: 12),
                  ),
                  SizedBox(
                    width: 140,
                    child: Slider(
                      value: tts.speechRate,
                      min: 0.25,
                      max: 1.5,
                      divisions: 10,
                      onChanged: (value) {
                        tts.setSpeechRate(value);
                      },
                      activeColor: widget.topic.color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn().scale();
      },
    );
  }
}
