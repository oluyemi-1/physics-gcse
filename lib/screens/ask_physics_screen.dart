import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/search_result.dart';
import '../services/physics_search_service.dart';
import '../data/physics_data.dart';
import '../providers/tts_provider.dart';
import 'lesson_screen.dart';
import 'simulation_screen.dart';

class AskPhysicsScreen extends StatefulWidget {
  const AskPhysicsScreen({super.key});

  @override
  State<AskPhysicsScreen> createState() => _AskPhysicsScreenState();
}

class _AskPhysicsScreenState extends State<AskPhysicsScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final PhysicsSearchService _searchService = PhysicsSearchService();
  final List<ChatMessage> _messages = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: 'Hello! I\'m your GCSE Physics assistant. Ask me anything about '
          'forces, waves, electricity, energy, space, and more!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleSubmit(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _textController.clear();

    setState(() {
      _messages.add(ChatMessage(
        text: trimmed,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isSearching = true;
    });

    final response = _searchService.search(trimmed);

    setState(() {
      _messages.add(ChatMessage(
        text: trimmed,
        isUser: false,
        response: response,
        timestamp: DateTime.now(),
      ));
      _isSearching = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.white),
            SizedBox(width: 8),
            Text('Ask Physics'),
          ],
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00BCD4), Color(0xFF6C63FF)],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: _messages.length + (_isSearching ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) {
          return _buildLoadingIndicator();
        }
        final message = _messages[index];
        return message.isUser
            ? _buildUserMessage(message)
            : _buildAIResponse(message);
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 48, top: 8, bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1F2940),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00BCD4),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  'Searching...',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }

  Widget _buildUserMessage(ChatMessage message) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 64, right: 16, top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple.shade700, Colors.blue.shade700],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
  }

  Widget _buildAIResponse(ChatMessage message) {
    if (message.response == null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin:
              const EdgeInsets.only(left: 16, right: 48, top: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2940),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology,
                            color: Color(0xFF00BCD4), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Physics Assistant',
                          style: TextStyle(
                            color: Color(0xFF00BCD4),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      message.text,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              _buildSuggestionChips(),
            ],
          ),
        ),
      ).animate().fadeIn().slideX(begin: -0.2);
    }

    final response = message.response!;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 48, top: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAnswerCard(response),
            if (response.simulations.isNotEmpty) ...[
              _buildSectionHeader(
                  'Try these simulations', Icons.play_circle, Colors.purple),
              ...response.simulations
                  .map((r) => _buildSimulationResultCard(r)),
            ],
            if (response.questions.isNotEmpty) ...[
              _buildSectionHeader(
                  'Related questions', Icons.help_outline, Colors.orange),
              ...response.questions.map((r) => _buildQuestionResultCard(r)),
            ],
            if (response.lessons.isNotEmpty) ...[
              _buildSectionHeader(
                  'Learn more', Icons.menu_book, Colors.green),
              ...response.lessons.map((r) => _buildLessonResultCard(r)),
            ],
          ],
        ),
      ),
    ).animate().fadeIn().slideX(begin: -0.2);
  }

  Widget _buildAnswerCard(SearchResponse response) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2940),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome,
                  color: Color(0xFF00BCD4), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Answer',
                style: TextStyle(
                  color: Color(0xFF00BCD4),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Consumer<TTSProvider>(
                builder: (ctx, tts, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${tts.speechRate.toStringAsFixed(1)}x',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: Slider(
                        value: tts.speechRate,
                        min: 0.25,
                        max: 1.5,
                        divisions: 10,
                        onChanged: (v) => tts.setSpeechRate(v),
                        activeColor: const Color(0xFF00BCD4),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        tts.isPlaying ? Icons.stop : Icons.volume_up,
                        color: const Color(0xFF00BCD4),
                      ),
                      onPressed: () => tts.isPlaying
                          ? tts.stop()
                          : tts.speak(response.bestAnswer),
                      iconSize: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            response.bestAnswer,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationResultCard(SearchResult result) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => _navigateToSimulation(result),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade700, Colors.blue.shade700],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.play_circle_fill,
                  color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      result.snippet,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.white70, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionResultCard(SearchResult result) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1F2940),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              result.title,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            leading:
                const Icon(Icons.help_outline, color: Colors.orange, size: 20),
            iconColor: Colors.white54,
            collapsedIconColor: Colors.white54,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.snippet,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    if (result.formula != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.cyan.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          result.formula!,
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonResultCard(SearchResult result) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () => _navigateToLesson(result),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1F2940),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.menu_book, color: Colors.green, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.snippet,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Text(
                'Read',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.arrow_forward_ios,
                  color: Colors.green, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          'What is Ohm\'s law?',
          'How do waves work?',
          'Formula for momentum',
          'Explain gravity',
          'What is nuclear fission?',
          'How do circuits work?',
          'What is density?',
          'Explain electrolysis',
        ]
            .map((q) => ActionChip(
                  label: Text(
                    q,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  backgroundColor: const Color(0xFF1F2940),
                  side: BorderSide(
                    color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
                  ),
                  onPressed: () => _handleSubmit(q),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: const BoxDecoration(
        color: Color(0xFF16213E),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Ask a physics question...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF00BCD4)),
                filled: true,
                fillColor: const Color(0xFF1F2940),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
              ),
              onSubmitted: _handleSubmit,
              textInputAction: TextInputAction.send,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF6C63FF)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: _isSearching
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: () => _handleSubmit(_textController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSimulation(SearchResult result) {
    final topics = PhysicsData.getAllTopics();
    final topic = topics.firstWhere(
      (t) => t.id == result.topicId,
      orElse: () => topics.first,
    );
    final simulation = topic.simulations.firstWhere(
      (s) => s.id == result.simulationId,
      orElse: () => topic.simulations.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SimulationScreen(simulation: simulation, topic: topic),
      ),
    );
  }

  void _navigateToLesson(SearchResult result) {
    final topics = PhysicsData.getAllTopics();
    final topic = topics.firstWhere(
      (t) => t.id == result.topicId,
      orElse: () => topics.first,
    );
    final lesson = topic.lessons.firstWhere(
      (l) => l.id == result.lessonId,
      orElse: () => topic.lessons.first,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(lesson: lesson, topic: topic),
      ),
    );
  }
}
