import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/progress.dart';
import 'supabase_config.dart';

class SupabaseService {
  /// Push all local progress to Supabase (upsert).
  /// Uses gcse_ prefixed tables to share the Supabase project with A-level app.
  Future<void> pushProgress(UserProgress progress) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // 1. Upsert gcse_study_progress
      await supabase.from('gcse_study_progress').upsert({
        'id': userId,
        'total_points': progress.totalPoints,
        'streak': progress.streak,
        'last_study_date': progress.lastStudyDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      // 2. Upsert gcse_topic_progress for each topic
      for (final entry in progress.topicProgress.entries) {
        await supabase.from('gcse_topic_progress').upsert(
          {
            'user_id': userId,
            'topic_id': entry.key,
            'completed_lessons': entry.value.completedLessons.toList(),
            'viewed_simulations': entry.value.viewedSimulations.toList(),
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id,topic_id',
        );

        // 3. Upsert gcse_quiz_results for each quiz in this topic
        for (final quizEntry in entry.value.quizResults.entries) {
          await supabase.from('gcse_quiz_results').upsert(
            {
              'user_id': userId,
              'topic_id': entry.key,
              'quiz_id': quizEntry.key,
              'score': quizEntry.value.score,
              'total_questions': quizEntry.value.totalQuestions,
              'completed_at': quizEntry.value.completedAt.toIso8601String(),
            },
            onConflict: 'user_id,quiz_id',
          );
        }
      }
    } catch (e) {
      debugPrint('Error pushing progress: $e');
    }
  }

  /// Pull all progress from Supabase for the current user.
  Future<UserProgress?> pullProgress() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      // 1. Fetch gcse_study_progress
      final studyData = await supabase
          .from('gcse_study_progress')
          .select()
          .eq('id', userId)
          .maybeSingle();

      // 2. Fetch all gcse_topic_progress rows
      final topicRows = await supabase
          .from('gcse_topic_progress')
          .select()
          .eq('user_id', userId);

      // 3. Fetch all gcse_quiz_results rows
      final quizRows = await supabase
          .from('gcse_quiz_results')
          .select()
          .eq('user_id', userId);

      // Group quiz results by topic_id
      final Map<String, Map<String, QuizResult>> quizzesByTopic = {};
      for (final row in quizRows) {
        final topicId = row['topic_id'] as String;
        final quizId = row['quiz_id'] as String;
        quizzesByTopic.putIfAbsent(topicId, () => {});
        quizzesByTopic[topicId]![quizId] = QuizResult(
          score: row['score'] as int,
          totalQuestions: row['total_questions'] as int,
          completedAt: DateTime.parse(row['completed_at'] as String),
        );
      }

      // Build TopicProgress map
      final Map<String, TopicProgress> topicProgress = {};
      for (final row in topicRows) {
        final topicId = row['topic_id'] as String;
        topicProgress[topicId] = TopicProgress(
          completedLessons:
              Set<String>.from(row['completed_lessons'] as List? ?? []),
          quizResults: quizzesByTopic[topicId] ?? {},
          viewedSimulations:
              Set<String>.from(row['viewed_simulations'] as List? ?? []),
        );
      }

      // Build UserProgress
      return UserProgress(
        topicProgress: topicProgress,
        totalPoints: studyData?['total_points'] as int? ?? 0,
        streak: studyData?['streak'] as int? ?? 0,
        lastStudyDate: studyData?['last_study_date'] != null
            ? DateTime.parse(studyData!['last_study_date'] as String)
            : null,
      );
    } catch (e) {
      debugPrint('Error pulling progress: $e');
      return null;
    }
  }

  /// Merge local and cloud progress.
  /// - Union of sets for completedLessons/viewedSimulations
  /// - Highest score wins for quizzes
  /// - Max of totalPoints, streak
  /// - Latest lastStudyDate
  static UserProgress mergeProgress(UserProgress local, UserProgress cloud) {
    final allTopicIds = {
      ...local.topicProgress.keys,
      ...cloud.topicProgress.keys,
    };

    final Map<String, TopicProgress> mergedTopics = {};
    for (final topicId in allTopicIds) {
      final localTopic = local.topicProgress[topicId];
      final cloudTopic = cloud.topicProgress[topicId];

      if (localTopic == null) {
        mergedTopics[topicId] = cloudTopic!;
      } else if (cloudTopic == null) {
        mergedTopics[topicId] = localTopic;
      } else {
        // Union of completed lessons
        final mergedLessons = {
          ...localTopic.completedLessons,
          ...cloudTopic.completedLessons,
        };

        // Union of viewed simulations
        final mergedSimulations = {
          ...localTopic.viewedSimulations,
          ...cloudTopic.viewedSimulations,
        };

        // Merge quiz results: keep highest score
        final allQuizIds = {
          ...localTopic.quizResults.keys,
          ...cloudTopic.quizResults.keys,
        };
        final Map<String, QuizResult> mergedQuizzes = {};
        for (final quizId in allQuizIds) {
          final localQuiz = localTopic.quizResults[quizId];
          final cloudQuiz = cloudTopic.quizResults[quizId];

          if (localQuiz == null) {
            mergedQuizzes[quizId] = cloudQuiz!;
          } else if (cloudQuiz == null) {
            mergedQuizzes[quizId] = localQuiz;
          } else {
            mergedQuizzes[quizId] =
                localQuiz.score >= cloudQuiz.score ? localQuiz : cloudQuiz;
          }
        }

        mergedTopics[topicId] = TopicProgress(
          completedLessons: mergedLessons,
          quizResults: mergedQuizzes,
          viewedSimulations: mergedSimulations,
        );
      }
    }

    // Latest lastStudyDate
    DateTime? mergedLastStudyDate;
    if (local.lastStudyDate != null && cloud.lastStudyDate != null) {
      mergedLastStudyDate = local.lastStudyDate!.isAfter(cloud.lastStudyDate!)
          ? local.lastStudyDate
          : cloud.lastStudyDate;
    } else {
      mergedLastStudyDate = local.lastStudyDate ?? cloud.lastStudyDate;
    }

    return UserProgress(
      topicProgress: mergedTopics,
      totalPoints: max(local.totalPoints, cloud.totalPoints),
      streak: max(local.streak, cloud.streak),
      lastStudyDate: mergedLastStudyDate,
    );
  }

  /// Create a profile row for a newly signed-up user.
  Future<void> createProfile(String displayName) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await supabase.from('gcse_profiles').upsert({
        'id': userId,
        'display_name': displayName,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating profile: $e');
    }
  }

  /// Fetch the user's display name.
  Future<String?> getDisplayName() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await supabase
          .from('gcse_profiles')
          .select('display_name')
          .eq('id', userId)
          .maybeSingle();

      return data?['display_name'] as String?;
    } catch (e) {
      debugPrint('Error fetching display name: $e');
      return null;
    }
  }
}
