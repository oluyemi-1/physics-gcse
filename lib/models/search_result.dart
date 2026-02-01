enum SearchResultType {
  lesson,
  question,
  simulation,
  formula,
  keyPoint,
}

class SearchResult {
  final SearchResultType type;
  final double score;
  final String title;
  final String snippet;
  final String? fullContent;
  final String topicId;
  final String? lessonId;
  final String? questionId;
  final String? simulationId;
  final String? formula;
  final List<String> matchedKeywords;

  const SearchResult({
    required this.type,
    required this.score,
    required this.title,
    required this.snippet,
    this.fullContent,
    required this.topicId,
    this.lessonId,
    this.questionId,
    this.simulationId,
    this.formula,
    this.matchedKeywords = const [],
  });
}

class SearchResponse {
  final String query;
  final String bestAnswer;
  final List<SearchResult> lessons;
  final List<SearchResult> questions;
  final List<SearchResult> simulations;
  final List<SearchResult> formulas;
  final bool hasResults;

  const SearchResponse({
    required this.query,
    required this.bestAnswer,
    this.lessons = const [],
    this.questions = const [],
    this.simulations = const [],
    this.formulas = const [],
    this.hasResults = true,
  });

  factory SearchResponse.empty(String query) {
    return SearchResponse(
      query: query,
      bestAnswer:
          "I couldn't find a specific answer for that question. "
          'Try asking about a specific physics concept like forces, waves, '
          'electricity, or energy.',
      hasResults: false,
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final SearchResponse? response;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.response,
    required this.timestamp,
  });
}
