import '../models/topic.dart';
import '../models/search_result.dart';
import '../data/physics_data.dart';
import '../data/question_bank.dart';

// ---------------------------------------------------------------------------
// Private index models
// ---------------------------------------------------------------------------

class _IndexedLesson {
  final String topicId;
  final String lessonId;
  final String title;
  final String content;
  final List<String> keyPoints;
  final List<String> formulas;
  final List<String> titleTokens;
  final List<String> contentTokens;
  final List<String> keyPointTokens;
  final List<String> formulaTokens;

  const _IndexedLesson({
    required this.topicId,
    required this.lessonId,
    required this.title,
    required this.content,
    required this.keyPoints,
    required this.formulas,
    required this.titleTokens,
    required this.contentTokens,
    required this.keyPointTokens,
    required this.formulaTokens,
  });
}

class _IndexedQuestion {
  final String topicId;
  final String questionId;
  final String questionText;
  final String explanation;
  final String? formula;
  final int correctIndex;
  final List<String> options;
  final List<String> questionTokens;
  final List<String> explanationTokens;
  final List<String> formulaTokens;

  const _IndexedQuestion({
    required this.topicId,
    required this.questionId,
    required this.questionText,
    required this.explanation,
    this.formula,
    required this.correctIndex,
    required this.options,
    required this.questionTokens,
    required this.explanationTokens,
    required this.formulaTokens,
  });
}

class _IndexedSimulation {
  final String topicId;
  final String simulationId;
  final String title;
  final String description;
  final SimulationType type;
  final List<String> titleTokens;
  final List<String> descriptionTokens;

  const _IndexedSimulation({
    required this.topicId,
    required this.simulationId,
    required this.title,
    required this.description,
    required this.type,
    required this.titleTokens,
    required this.descriptionTokens,
  });
}

// ---------------------------------------------------------------------------
// PhysicsSearchService  (singleton)
// ---------------------------------------------------------------------------

class PhysicsSearchService {
  static final PhysicsSearchService _instance =
      PhysicsSearchService._internal();
  factory PhysicsSearchService() => _instance;
  PhysicsSearchService._internal();

  // -----------------------------------------------------------------------
  // State
  // -----------------------------------------------------------------------

  bool _isIndexed = false;
  final List<_IndexedLesson> _lessonIndex = [];
  final List<_IndexedQuestion> _questionIndex = [];
  final List<_IndexedSimulation> _simulationIndex = [];

  // -----------------------------------------------------------------------
  // Stop words
  // -----------------------------------------------------------------------

  static const Set<String> _stopWords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would', 'could',
    'should', 'may', 'might', 'shall', 'can', 'need', 'dare', 'ought',
    'used', 'to', 'of', 'in', 'for', 'on', 'with', 'at', 'by', 'from',
    'as', 'into', 'through', 'during', 'before', 'after', 'above', 'below',
    'between', 'out', 'off', 'over', 'under', 'again', 'further', 'then',
    'once', 'here', 'there', 'when', 'where', 'why', 'how', 'all', 'each',
    'every', 'both', 'few', 'more', 'most', 'other', 'some', 'such', 'no',
    'nor', 'not', 'only', 'own', 'same', 'so', 'than', 'too', 'very',
    'just', 'because', 'but', 'and', 'or', 'if', 'while', 'about',
    'what', 'which', 'who', 'whom', 'this', 'that', 'these', 'those',
    'am', 'it', 'its', 'my', 'your', 'his', 'her', 'our', 'their',
    'me', 'him', 'us', 'them', 'i', 'you', 'he', 'she', 'we', 'they',
    'tell', 'explain', 'describe', 'define', 'show', 'give',
  };

  // -----------------------------------------------------------------------
  // Synonym map
  // -----------------------------------------------------------------------

  static const Map<String, List<String>> _synonyms = {
    'speed': ['velocity', 'rate', 'fast', 'slow'],
    'velocity': ['speed', 'rate'],
    'force': ['newton', 'newtons', 'push', 'pull', 'thrust', 'drag', 'weight'],
    'newton': ['force', 'newtons'],
    'current': ['ampere', 'amps', 'amp', 'amperes', 'flow'],
    'ampere': ['current', 'amps', 'amp'],
    'voltage': ['potential', 'volts', 'pd', 'emf'],
    'volts': ['voltage', 'potential'],
    'resistance': ['ohm', 'ohms', 'resistor', 'resistors'],
    'ohm': ['resistance', 'ohms'],
    'power': ['watts', 'watt'],
    'watts': ['power', 'watt'],
    'energy': ['joule', 'joules', 'work'],
    'joule': ['energy', 'joules'],
    'momentum': ['impulse', 'collision', 'crash'],
    'wave': ['waves', 'oscillation', 'vibration', 'ripple'],
    'waves': ['wave', 'oscillation'],
    'frequency': ['hertz', 'hz', 'pitch'],
    'wavelength': ['lambda', 'wave'],
    'acceleration': [
      'accelerate',
      'deceleration',
      'decelerate',
      'speeding',
    ],
    'gravity': ['gravitational', 'weight', 'falling', 'freefall'],
    'mass': ['kilogram', 'kg', 'heavy'],
    'pressure': ['pascal', 'pascals'],
    'temperature': ['thermal', 'heat', 'hot', 'cold', 'celsius', 'kelvin'],
    'heat': [
      'thermal',
      'temperature',
      'conduction',
      'convection',
      'radiation',
    ],
    'nuclear': ['radioactive', 'radioactivity', 'decay', 'atom', 'nucleus'],
    'fission': ['splitting', 'nuclear'],
    'fusion': ['joining', 'merging', 'nuclear', 'star'],
    'magnet': ['magnetic', 'magnetism', 'electromagnet'],
    'magnetic': ['magnet', 'magnetism'],
    'circuit': ['circuits', 'series', 'parallel', 'electrical'],
    'lens': ['lenses', 'converging', 'diverging', 'convex', 'concave'],
    'mirror': ['mirrors', 'reflection', 'reflect'],
    'refraction': ['refract', 'bending', 'snell'],
    'diffraction': ['diffract', 'gap', 'slit'],
    'star': ['stars', 'stellar', 'sun', 'supernova', 'dwarf'],
    'orbit': ['orbits', 'orbital', 'satellite', 'circular'],
    'density': ['dense', 'volume'],
    'spring': ['springs', 'hooke', 'elastic', 'extension'],
    'electrolysis': ['electrode', 'electrolyte', 'cathode', 'anode'],
    'electrode': ['electrolysis', 'cathode', 'anode'],
    'electroplating': ['plating', 'coating', 'electrolysis'],
    'efficiency': ['efficient', 'machine', 'mechanical'],
  };

  // -----------------------------------------------------------------------
  // Tokenization
  // -----------------------------------------------------------------------

  List<String> _tokenize(String input) {
    final lower = input.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    final parts = cleaned.split(RegExp(r'\s+'));
    return parts
        .where((t) => t.length >= 2 && !_stopWords.contains(t))
        .toList();
  }

  // -----------------------------------------------------------------------
  // Synonym expansion
  // -----------------------------------------------------------------------

  /// Returns a map where key = token, value = true if direct, false if synonym.
  Map<String, bool> _expandWithSynonyms(List<String> tokens) {
    final result = <String, bool>{};

    for (final token in tokens) {
      // Direct token always takes priority
      result[token] = true;

      final synonymList = _synonyms[token];
      if (synonymList != null) {
        for (final syn in synonymList) {
          // Only add as synonym if not already present as a direct token
          if (!result.containsKey(syn)) {
            result[syn] = false;
          }
        }
      }
    }

    return result;
  }

  // -----------------------------------------------------------------------
  // Index building
  // -----------------------------------------------------------------------

  void _buildIndex() {
    if (_isIndexed) return;

    final topics = PhysicsData.getAllTopics();

    for (final topic in topics) {
      // Index lessons
      for (final lesson in topic.lessons) {
        _lessonIndex.add(_IndexedLesson(
          topicId: topic.id,
          lessonId: lesson.id,
          title: lesson.title,
          content: lesson.content,
          keyPoints: lesson.keyPoints,
          formulas: lesson.formulas,
          titleTokens: _tokenize(lesson.title),
          contentTokens: _tokenize(lesson.content),
          keyPointTokens:
              _tokenize(lesson.keyPoints.join(' ')),
          formulaTokens:
              _tokenize(lesson.formulas.join(' ')),
        ));
      }

      // Index simulations
      for (final sim in topic.simulations) {
        _simulationIndex.add(_IndexedSimulation(
          topicId: topic.id,
          simulationId: sim.id,
          title: sim.title,
          description: sim.description,
          type: sim.type,
          titleTokens: _tokenize(sim.title),
          descriptionTokens: _tokenize(sim.description),
        ));
      }
    }

    // Index questions from the question bank
    const topicIds = [
      'forces_motion',
      'waves',
      'electricity',
      'magnetism',
      'space',
      'energy',
      'nuclear',
      'thermal',
    ];

    for (final topicId in topicIds) {
      final questions = QuestionBank.getQuestionsForTopic(topicId);
      for (final q in questions) {
        _questionIndex.add(_IndexedQuestion(
          topicId: topicId,
          questionId: q.id,
          questionText: q.question,
          explanation: q.explanation,
          formula: q.formula,
          correctIndex: q.correctIndex,
          options: q.options,
          questionTokens: _tokenize(q.question),
          explanationTokens: _tokenize(q.explanation),
          formulaTokens:
              q.formula != null ? _tokenize(q.formula!) : const [],
        ));
      }
    }

    _isIndexed = true;
  }

  // -----------------------------------------------------------------------
  // Scoring helpers
  // -----------------------------------------------------------------------

  double _countMatches(
    Map<String, bool> queryTokens,
    List<String> fieldTokens,
    double weight,
    double synonymMultiplier,
  ) {
    double score = 0.0;
    for (final fieldToken in fieldTokens) {
      final isDirect = queryTokens[fieldToken];
      if (isDirect == null) continue; // no match
      if (isDirect) {
        score += weight;
      } else {
        score += weight * synonymMultiplier;
      }
    }
    return score;
  }

  double _scoreLesson(
    Map<String, bool> queryTokens,
    _IndexedLesson lesson,
    String originalQuery,
  ) {
    const synonymMul = 0.5;
    final totalQueryTokens = queryTokens.length;
    if (totalQueryTokens == 0) return 0.0;

    double raw = 0.0;
    raw += _countMatches(queryTokens, lesson.titleTokens, 5.0, synonymMul);
    raw += _countMatches(queryTokens, lesson.keyPointTokens, 3.0, synonymMul);
    raw += _countMatches(queryTokens, lesson.formulaTokens, 2.5, synonymMul);
    raw += _countMatches(queryTokens, lesson.contentTokens, 1.0, synonymMul);

    // Exact phrase substring bonus
    final lowerQuery = originalQuery.toLowerCase();
    if (lesson.title.toLowerCase().contains(lowerQuery) ||
        lesson.content.toLowerCase().contains(lowerQuery)) {
      raw += 1.0;
    }

    // Normalize by query token count
    return raw / totalQueryTokens;
  }

  double _scoreQuestion(
    Map<String, bool> queryTokens,
    _IndexedQuestion question,
    String originalQuery,
  ) {
    const synonymMul = 0.5;
    final totalQueryTokens = queryTokens.length;
    if (totalQueryTokens == 0) return 0.0;

    double raw = 0.0;
    raw += _countMatches(
        queryTokens, question.questionTokens, 3.0, synonymMul);
    raw += _countMatches(
        queryTokens, question.explanationTokens, 2.0, synonymMul);
    raw += _countMatches(
        queryTokens, question.formulaTokens, 2.5, synonymMul);

    // Exact phrase substring bonus
    final lowerQuery = originalQuery.toLowerCase();
    if (question.questionText.toLowerCase().contains(lowerQuery) ||
        question.explanation.toLowerCase().contains(lowerQuery)) {
      raw += 1.0;
    }

    return raw / totalQueryTokens;
  }

  double _scoreSimulation(
    Map<String, bool> queryTokens,
    _IndexedSimulation sim,
    String originalQuery,
  ) {
    const synonymMul = 0.5;
    final totalQueryTokens = queryTokens.length;
    if (totalQueryTokens == 0) return 0.0;

    double raw = 0.0;
    raw += _countMatches(queryTokens, sim.titleTokens, 4.0, synonymMul);
    raw += _countMatches(queryTokens, sim.descriptionTokens, 2.0, synonymMul);

    // Exact phrase substring bonus
    final lowerQuery = originalQuery.toLowerCase();
    if (sim.title.toLowerCase().contains(lowerQuery) ||
        sim.description.toLowerCase().contains(lowerQuery)) {
      raw += 1.0;
    }

    return raw / totalQueryTokens;
  }

  // -----------------------------------------------------------------------
  // Converter methods  (indexed model -> SearchResult)
  // -----------------------------------------------------------------------

  SearchResult _toLessonResult(_IndexedLesson l, double score) {
    final snippet = l.keyPoints.isNotEmpty
        ? l.keyPoints.first
        : _firstSentence(l.content);

    return SearchResult(
      type: SearchResultType.lesson,
      score: score,
      title: l.title,
      snippet: snippet,
      fullContent: l.content,
      topicId: l.topicId,
      lessonId: l.lessonId,
      formula: l.formulas.isNotEmpty ? l.formulas.join(', ') : null,
    );
  }

  SearchResult _toQuestionResult(_IndexedQuestion q, double score) {
    return SearchResult(
      type: SearchResultType.question,
      score: score,
      title: q.questionText,
      snippet: q.explanation,
      topicId: q.topicId,
      questionId: q.questionId,
      formula: q.formula,
    );
  }

  SearchResult _toSimResult(_IndexedSimulation s, double score) {
    return SearchResult(
      type: SearchResultType.simulation,
      score: score,
      title: s.title,
      snippet: s.description,
      topicId: s.topicId,
      simulationId: s.simulationId,
    );
  }

  // -----------------------------------------------------------------------
  // Best answer generation
  // -----------------------------------------------------------------------

  String _generateBestAnswer(
    List<SearchResult> topLessons,
    List<SearchResult> topQuestions,
    String query,
  ) {
    // Find the single highest-scoring result across lessons and questions
    SearchResult? best;
    for (final r in topLessons) {
      if (best == null || r.score > best.score) best = r;
    }
    for (final r in topQuestions) {
      if (best == null || r.score > best.score) best = r;
    }

    if (best == null) {
      return "I couldn't find information on that topic.";
    }

    final buffer = StringBuffer();
    buffer.writeln("Here's what I found about ${best.title}:\n");

    if (best.type == SearchResultType.question) {
      buffer.write(best.snippet);
      if (best.formula != null && best.formula!.isNotEmpty) {
        buffer.write('\n\nKey formula: ${best.formula}');
      }
    } else {
      // Lesson: first 2-3 sentences from content, plus best key point
      final content = best.fullContent ?? best.snippet;
      final sentences = content.split('. ');
      final firstFew =
          sentences.take(3).join('. ').trimRight();
      buffer.write(firstFew);
      if (!firstFew.endsWith('.')) {
        buffer.write('.');
      }

      // Append the most relevant keyPoint (snippet is already the first)
      if (best.snippet.isNotEmpty &&
          best.snippet != firstFew &&
          !firstFew.contains(best.snippet)) {
        buffer.write('\n\nKey point: ${best.snippet}');
      }
    }

    return buffer.toString();
  }

  // -----------------------------------------------------------------------
  // Main search method
  // -----------------------------------------------------------------------

  SearchResponse search(String query) {
    if (!_isIndexed) _buildIndex();

    final rawTokens = _tokenize(query);
    if (rawTokens.isEmpty) return SearchResponse.empty(query);

    final queryTokens = _expandWithSynonyms(rawTokens);

    // Score all content
    final scoredLessons = _lessonIndex
        .map((l) => _toLessonResult(l, _scoreLesson(queryTokens, l, query)))
        .where((r) => r.score > 0.3)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final scoredQuestions = _questionIndex
        .map((q) =>
            _toQuestionResult(q, _scoreQuestion(queryTokens, q, query)))
        .where((r) => r.score > 0.3)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final scoredSimulations = _simulationIndex
        .map((s) => _toSimResult(s, _scoreSimulation(queryTokens, s, query)))
        .where((r) => r.score > 0.3)
        .toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    final topLessons = scoredLessons.take(3).toList();
    final topQuestions = scoredQuestions.take(5).toList();
    final topSimulations = scoredSimulations.take(3).toList();

    // Extract formulas from top results
    final topFormulas = <SearchResult>[];
    for (final q in topQuestions) {
      if (q.formula != null && q.formula!.isNotEmpty) {
        topFormulas.add(SearchResult(
          type: SearchResultType.formula,
          score: q.score,
          title: 'Formula',
          snippet: q.formula!,
          topicId: q.topicId,
        ));
      }
    }
    for (final l in topLessons) {
      if (l.formula != null && l.formula!.isNotEmpty) {
        topFormulas.add(SearchResult(
          type: SearchResultType.formula,
          score: l.score,
          title: 'Formula',
          snippet: l.formula!,
          topicId: l.topicId,
        ));
      }
    }

    if (topLessons.isEmpty &&
        topQuestions.isEmpty &&
        topSimulations.isEmpty) {
      return SearchResponse.empty(query);
    }

    final bestAnswer =
        _generateBestAnswer(topLessons, topQuestions, query);

    return SearchResponse(
      query: query,
      bestAnswer: bestAnswer,
      lessons: topLessons,
      questions: topQuestions,
      simulations: topSimulations,
      formulas: topFormulas.take(3).toList(),
      hasResults: true,
    );
  }

  // -----------------------------------------------------------------------
  // Utility
  // -----------------------------------------------------------------------

  String _firstSentence(String text) {
    final idx = text.indexOf('. ');
    if (idx == -1) return text;
    return text.substring(0, idx + 1);
  }
}
