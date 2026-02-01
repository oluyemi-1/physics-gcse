import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress.dart';
import '../models/topic.dart';
import '../data/physics_data.dart';
import '../services/supabase_config.dart';
import '../services/supabase_service.dart';

class AppProvider extends ChangeNotifier {
  UserProgress _progress = UserProgress.empty();
  List<Topic> _topics = [];
  bool _isLoading = true;
  int _selectedNavIndex = 0;
  final SupabaseService _supabaseService = SupabaseService();
  bool _syncing = false;

  UserProgress get progress => _progress;
  List<Topic> get topics => _topics;
  bool get isLoading => _isLoading;
  int get selectedNavIndex => _selectedNavIndex;
  bool get syncing => _syncing;

  AppProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _topics = PhysicsData.getAllTopics();
    await _loadProgress();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressJson = prefs.getString('user_progress');
      if (progressJson != null) {
        _progress = UserProgress.fromJson(jsonDecode(progressJson));
      }
    } catch (e) {
      _progress = UserProgress.empty();
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_progress', jsonEncode(_progress.toJson()));
    } catch (e) {
      debugPrint('Error saving progress: $e');
    }
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void markLessonComplete(String topicId, String lessonId) {
    final topicProgress = _progress.topicProgress[topicId] ?? TopicProgress();
    topicProgress.completedLessons.add(lessonId);

    _progress = _progress.copyWith(
      topicProgress: {
        ..._progress.topicProgress,
        topicId: topicProgress,
      },
      totalPoints: _progress.totalPoints + 10,
    );

    _updateStreak();
    _saveProgress();
    _pushToCloud();
    notifyListeners();
  }

  void saveQuizResult(String topicId, String quizId, int score, int total) {
    final topicProgress = _progress.topicProgress[topicId] ?? TopicProgress();
    topicProgress.quizResults[quizId] = QuizResult(
      score: score,
      totalQuestions: total,
      completedAt: DateTime.now(),
    );

    final pointsEarned = (score / total * 50).round();

    _progress = _progress.copyWith(
      topicProgress: {
        ..._progress.topicProgress,
        topicId: topicProgress,
      },
      totalPoints: _progress.totalPoints + pointsEarned,
    );

    _updateStreak();
    _saveProgress();
    _pushToCloud();
    notifyListeners();
  }

  void markSimulationViewed(String topicId, String simulationId) {
    final topicProgress = _progress.topicProgress[topicId] ?? TopicProgress();
    topicProgress.viewedSimulations.add(simulationId);

    _progress = _progress.copyWith(
      topicProgress: {
        ..._progress.topicProgress,
        topicId: topicProgress,
      },
      totalPoints: _progress.totalPoints + 5,
    );

    _saveProgress();
    _pushToCloud();
    notifyListeners();
  }

  /// Fire-and-forget push to Supabase if user is logged in.
  void _pushToCloud() {
    if (supabase.auth.currentUser == null) return;
    _supabaseService.pushProgress(_progress);
  }

  /// Pull from Supabase, merge with local, save merged to both.
  /// Called after login or when user taps "Sync Now".
  Future<void> syncNow() async {
    if (supabase.auth.currentUser == null) return;

    _syncing = true;
    notifyListeners();

    try {
      final cloud = await _supabaseService.pullProgress();
      if (cloud != null) {
        _progress = SupabaseService.mergeProgress(_progress, cloud);
      }
      await _saveProgress();
      await _supabaseService.pushProgress(_progress);
    } catch (e) {
      debugPrint('AppProvider.syncNow error: $e');
    }

    _syncing = false;
    notifyListeners();
  }

  void _updateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_progress.lastStudyDate != null) {
      final lastDate = DateTime(
        _progress.lastStudyDate!.year,
        _progress.lastStudyDate!.month,
        _progress.lastStudyDate!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Same day, no change
        return;
      } else if (difference == 1) {
        // Consecutive day
        _progress = _progress.copyWith(
          streak: _progress.streak + 1,
          lastStudyDate: now,
        );
      } else {
        // Streak broken
        _progress = _progress.copyWith(
          streak: 1,
          lastStudyDate: now,
        );
      }
    } else {
      _progress = _progress.copyWith(
        streak: 1,
        lastStudyDate: now,
      );
    }
  }

  double getTopicProgress(String topicId) {
    final topic = _topics.firstWhere((t) => t.id == topicId);
    final topicProgress = _progress.topicProgress[topicId];

    if (topicProgress == null) return 0.0;

    int totalItems = topic.lessons.length + topic.quizzes.length + topic.simulations.length;
    int completedItems = topicProgress.completedLessons.length +
        topicProgress.quizResults.length +
        topicProgress.viewedSimulations.length;

    return totalItems > 0 ? completedItems / totalItems : 0.0;
  }

  double getOverallProgress() {
    if (_topics.isEmpty) return 0.0;

    double totalProgress = 0;
    for (var topic in _topics) {
      totalProgress += getTopicProgress(topic.id);
    }

    return totalProgress / _topics.length;
  }

  bool isLessonComplete(String topicId, String lessonId) {
    return _progress.topicProgress[topicId]?.completedLessons.contains(lessonId) ?? false;
  }

  QuizResult? getQuizResult(String topicId, String quizId) {
    return _progress.topicProgress[topicId]?.quizResults[quizId];
  }

  Future<void> resetProgress() async {
    _progress = UserProgress.empty();
    await _saveProgress();
    notifyListeners();
  }
}
