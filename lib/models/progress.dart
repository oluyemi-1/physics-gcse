class UserProgress {
  final Map<String, TopicProgress> topicProgress;
  final int totalPoints;
  final int streak;
  final DateTime? lastStudyDate;

  UserProgress({
    required this.topicProgress,
    this.totalPoints = 0,
    this.streak = 0,
    this.lastStudyDate,
  });

  factory UserProgress.empty() {
    return UserProgress(topicProgress: {});
  }

  UserProgress copyWith({
    Map<String, TopicProgress>? topicProgress,
    int? totalPoints,
    int? streak,
    DateTime? lastStudyDate,
  }) {
    return UserProgress(
      topicProgress: topicProgress ?? this.topicProgress,
      totalPoints: totalPoints ?? this.totalPoints,
      streak: streak ?? this.streak,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topicProgress': topicProgress.map((key, value) => MapEntry(key, value.toJson())),
      'totalPoints': totalPoints,
      'streak': streak,
      'lastStudyDate': lastStudyDate?.toIso8601String(),
    };
  }

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      topicProgress: (json['topicProgress'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, TopicProgress.fromJson(value)),
          ) ??
          {},
      totalPoints: json['totalPoints'] ?? 0,
      streak: json['streak'] ?? 0,
      lastStudyDate: json['lastStudyDate'] != null
          ? DateTime.parse(json['lastStudyDate'])
          : null,
    );
  }
}

class TopicProgress {
  final Set<String> completedLessons;
  final Map<String, QuizResult> quizResults;
  final Set<String> viewedSimulations;

  TopicProgress({
    Set<String>? completedLessons,
    Map<String, QuizResult>? quizResults,
    Set<String>? viewedSimulations,
  })  : completedLessons = completedLessons ?? {},
        quizResults = quizResults ?? {},
        viewedSimulations = viewedSimulations ?? {};

  double get completionPercentage {
    int total = completedLessons.length + quizResults.length + viewedSimulations.length;
    return total > 0 ? total / 10.0 : 0.0; // Approximate percentage
  }

  Map<String, dynamic> toJson() {
    return {
      'completedLessons': completedLessons.toList(),
      'quizResults': quizResults.map((key, value) => MapEntry(key, value.toJson())),
      'viewedSimulations': viewedSimulations.toList(),
    };
  }

  factory TopicProgress.fromJson(Map<String, dynamic> json) {
    return TopicProgress(
      completedLessons: Set<String>.from(json['completedLessons'] ?? []),
      quizResults: (json['quizResults'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, QuizResult.fromJson(value)),
          ) ??
          {},
      viewedSimulations: Set<String>.from(json['viewedSimulations'] ?? []),
    );
  }
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions : 0;

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'],
      totalQuestions: json['totalQuestions'],
      completedAt: DateTime.parse(json['completedAt']),
    );
  }
}
