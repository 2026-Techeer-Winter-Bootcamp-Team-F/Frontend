import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/services/chat_service.dart';

class ChatPage extends StatefulWidget {
  final String sessionId;
  final bool isNewChat;

  const ChatPage({super.key, required this.sessionId, this.isNewChat = true});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isFirstMessage = true;

  final List<String> _suggestedQuestions = [
    '이번 달 커피값 얼마나 썼어?',
    '내 카드보다 더 좋은 거 있어?',
    '내 소비 패턴 분석해줘',
    '연회비 아까운 카드 있어?',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isNewChat) {
      _showWelcomeMessage();
    } else {
      _loadPreviousChat();
    }
  }

  Future<void> _showWelcomeMessage() async {
    const welcomeText = '안녕하세요! 카드 혜택 도우미 BeneFit이에요. \n고객님의 소비 패턴을 분석하고, \n딱 맞는 카드 혜택을 추천해 드릴게요.\n무엇이든 편하게 물어보세요!';

    // 빈 메시지 추가
    setState(() {
      _messages.add(ChatMessage(text: '', isUser: false, timestamp: DateTime.now()));
    });

    // SSE 스트리밍 효과
    await _streamText(welcomeText);
  }

  void _loadPreviousChat() {
    // 이전 대화 목데이터 (SSE 없이 바로 표시)
    final mockHistory = _getMockChatHistory(widget.sessionId);
    setState(() {
      _messages.addAll(mockHistory);
    });
  }

  List<ChatMessage> _getMockChatHistory(String sessionId) {
    if (sessionId == 'mock_session_1') {
      return [
        ChatMessage(text: '이번 달 커피값 얼마나 썼어?', isUser: true, timestamp: DateTime.now().subtract(const Duration(hours: 2))),
        ChatMessage(text: '이번 달 커피 관련 소비를 분석해봤어요! ☕\n\n총 지출: 47,500원 (12회)\n주로 이용한 곳: 스타벅스, 이디야\n\n💡 현재 사용 중인 신한카드로 스타벅스에서 10% 할인 받고 계세요!\n추가로 토스 카드를 사용하면 카페 업종 5% 적립도 가능해요.', isUser: false, timestamp: DateTime.now().subtract(const Duration(hours: 2))),
      ];
    } else if (sessionId == 'mock_session_2') {
      return [
        ChatMessage(text: '카드 추천해줘', isUser: true, timestamp: DateTime.now().subtract(const Duration(days: 1))),
        ChatMessage(text: '고객님의 소비 패턴을 분석해서 추천드릴게요! 💳\n\n🏆 추천 카드: 신한카드 Deep Dream\n- 연회비: 12,000원 (전월 30만원 이상 시 면제)\n- 스트리밍 10% 할인\n- 카페/편의점 5% 적립\n- 대중교통 5% 적립\n\n현재 소비 패턴 기준 월 약 15,000원 절약 가능해요!', isUser: false, timestamp: DateTime.now().subtract(const Duration(days: 1))),
      ];
    } else if (sessionId == 'mock_session_3') {
      return [
        ChatMessage(text: '내 소비 패턴 분석해줘', isUser: true, timestamp: DateTime.now().subtract(const Duration(days: 3))),
        ChatMessage(text: '고객님의 이번 달 소비 패턴이에요! 📊\n\n🍽️ 식비: 324,000원 (32%)\n🚗 교통: 89,000원 (9%)\n🛒 쇼핑: 215,000원 (21%)\n☕ 카페: 47,500원 (5%)\n🎬 문화/여가: 65,000원 (6%)\n📦 기타: 274,500원 (27%)\n\n💡 식비가 가장 많네요! 배달앱 할인 카드를 추천드릴까요?', isUser: false, timestamp: DateTime.now().subtract(const Duration(days: 3))),
      ];
    } else if (sessionId == 'mock_session_4') {
      return [
        ChatMessage(text: '연회비 아까운 카드 있어?', isUser: true, timestamp: DateTime.now().subtract(const Duration(days: 7))),
        ChatMessage(text: '연회비 대비 혜택을 분석해봤어요! 💰\n\n✅ 신한카드 Deep Dream\n- 연회비 12,000원 / 받은 혜택 45,000원\n- 효율: 275% 👍\n\n⚠️ BC카드 바로클리어\n- 연회비 15,000원 / 받은 혜택 8,000원\n- 효율: 53% (사용 빈도 낮음)\n\n💡 BC카드는 해지를 고려해보세요!', isUser: false, timestamp: DateTime.now().subtract(const Duration(days: 7))),
      ];
    }
    return [
      ChatMessage(text: '안녕하세요! 카드 혜택 도우미 BeneFit이에요.\n무엇이든 편하게 물어보세요!', isUser: false, timestamp: DateTime.now()),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // 목데이터 응답 (API 연동 주석처리) - SSE 스트리밍 효과
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final response = _getMockResponse(text);
    final responseText = response['text'] ?? '';
    final imagePath = response['image'];

    // 빈 메시지 추가 후 스트리밍 효과
    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: '', isUser: false, timestamp: DateTime.now(), imagePath: imagePath));
    });

    // 한 글자씩 스트리밍
    await _streamText(responseText, imagePath: imagePath);
    _scrollToBottom();

    /* 기존 API 연동 코드
    try {
      final response = await _chatService.sendMessage(
        question: text,
        sessionId: widget.sessionId,
      );
      if (!mounted) return;

      final responseText = _formatResponse(response);
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(text: responseText, isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();

      // 세션 정보 로컬 저장
      await _chatService.saveSession(
        sessionId: widget.sessionId,
        title: text,
        lastMessage: responseText.length > 50 ? '${responseText.substring(0, 50)}...' : responseText,
      );
      _isFirstMessage = false;
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMessage(
          text: '죄송합니다. 응답을 받지 못했습니다. 잠시 후 다시 시도해주세요.',
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
      _scrollToBottom();
    }
    */
  }

  Future<void> _streamText(String fullText, {String? imagePath}) async {
    final messageIndex = _messages.length - 1;
    String currentText = '';

    for (int i = 0; i < fullText.length; i++) {
      if (!mounted) return;

      currentText += fullText[i];
      setState(() {
        _messages[messageIndex] = ChatMessage(
          text: currentText,
          isUser: false,
          timestamp: _messages[messageIndex].timestamp,
          imagePath: imagePath,
        );
      });

      // 스크롤 유지
      if (i % 10 == 0) _scrollToBottom();

      // 글자마다 딜레이 (빠르게)
      await Future.delayed(const Duration(milliseconds: 15));
    }
    _scrollToBottom();
  }

  Map<String, String?> _getMockResponse(String question) {
    if (question.contains('커피') || question.contains('카페')) {
      return {
        'text': '이번 달 커피 관련 소비를 분석해봤어요! ☕\n\n'
            '총 지출: 47,500원 (12회)\n'
            '주로 이용한 곳: 스타벅스, 이디야\n\n'
            '💡 현재 사용 중인 신한카드로 스타벅스에서 10% 할인 받고 계세요!\n'
            '추가로 토스 카드를 사용하면 카페 업종 5% 적립도 가능해요.',
        'image': null,
      };
    } else if (question.contains('좋은') && question.contains('카드') ||
               question.contains('더') && question.contains('카드')) {
      return {
        'text': '고객님의 소비 패턴을 분석해봤어요! 💳\n\n'
            '현재 사용 중인 국민카드보다 더 좋은 카드를 찾았어요!\n\n'
            '🏆 추천 카드: 신한카드 Deep Dream\n'
            '- 연회비: 12,000원 (전월 30만원 이상 시 면제)\n'
            '- 스트리밍 10% 할인\n'
            '- 카페/편의점 5% 적립\n'
            '- 대중교통 5% 적립\n\n'
            '현재 카드 대비 월 약 18,000원 더 절약할 수 있어요!',
        'image': 'assets/images/mywallet_kookmin_card.png',
      };
    } else if (question.contains('카드') && question.contains('추천')) {
      return {
        'text': '고객님의 소비 패턴을 분석해서 추천드릴게요! 💳\n\n'
            '🏆 추천 카드: 신한카드 Deep Dream\n'
            '- 연회비: 12,000원 (전월 30만원 이상 시 면제)\n'
            '- 스트리밍 10% 할인\n'
            '- 카페/편의점 5% 적립\n'
            '- 대중교통 5% 적립\n\n'
            '현재 소비 패턴 기준 월 약 15,000원 절약 가능해요!',
        'image': null,
      };
    } else if (question.contains('소비') && question.contains('패턴')) {
      return {
        'text': '고객님의 이번 달 소비 패턴이에요! 📊\n\n'
            '🍽️ 식비: 324,000원 (32%)\n'
            '🚗 교통: 89,000원 (9%)\n'
            '🛒 쇼핑: 215,000원 (21%)\n'
            '☕ 카페: 47,500원 (5%)\n'
            '🎬 문화/여가: 65,000원 (6%)\n'
            '📦 기타: 274,500원 (27%)\n\n'
            '💡 식비가 가장 많네요! 배달앱 할인 카드를 추천드릴까요?',
        'image': null,
      };
    } else if (question.contains('연회비')) {
      return {
        'text': '연회비 대비 혜택을 분석해봤어요! 💰\n\n'
            '✅ 신한카드 Deep Dream\n'
            '- 연회비 12,000원 / 받은 혜택 45,000원\n'
            '- 효율: 275% 👍\n\n'
            '⚠️ BC카드 바로클리어\n'
            '- 연회비 15,000원 / 받은 혜택 8,000원\n'
            '- 효율: 53% (사용 빈도 낮음)\n\n'
            '💡 BC카드는 해지를 고려해보세요!',
        'image': null,
      };
    } else {
      return {
        'text': '네, 궁금하신 점을 말씀해 주시면 자세히 안내해 드릴게요! 😊\n\n'
            '다음과 같은 질문을 해보실 수 있어요:\n'
            '• 이번 달 소비 분석\n'
            '• 카드 추천\n'
            '• 혜택 비교\n'
            '• 연회비 효율 분석',
        'image': null,
      };
    }
  }

  String _formatResponse(Map<String, dynamic> response) {
    final type = response['type'];
    if (type == 'CARD_INFO') {
      final cards = (response['data']?['cards'] as List?) ?? [];
      if (cards.isEmpty) return '추천할 카드를 찾지 못했어요.';

      final buffer = StringBuffer('추천 카드를 찾았어요!\n');
      for (final card in cards) {
        buffer.writeln();
        buffer.writeln('${card['card_name']} (${card['company']})');
        final fee = card['annual_fee_domestic'];
        if (fee != null) buffer.writeln('연회비: ${_formatNumber(fee)}원');
        final waiver = card['fee_waiver_rule'];
        if (waiver != null) buffer.writeln('면제조건: $waiver');
        final benefits = (card['benefits'] as List?) ?? [];
        if (benefits.isNotEmpty) {
          buffer.writeln('혜택:');
          for (final b in benefits) {
            final limit = b['benefit_limit'];
            buffer.writeln(
              '  - ${b['category_name']} ${b['benefit_rate']}'
              '${limit != null ? ' (한도 ${_formatNumber(limit)}원)' : ''}',
            );
          }
        }
      }
      return buffer.toString().trim();
    }
    return response['message']?.toString() ?? '응답을 처리할 수 없습니다.';
  }

  String _formatNumber(dynamic number) {
    if (number == null) return '0';
    final n = number is int ? number : (number as num).toInt();
    return n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'BeneFit',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 8,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('BeneFit'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: const Center(
                child: Text('BeneFit',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: -0.3),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isUser ? 16 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        message.imagePath!,
                        width: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '📍 현재 사용 중인 카드',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2)),
              ],
            ),
            child: const Center(
              child: Text('BeneFit',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 9, letterSpacing: -0.3),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [_buildDot(0), _buildDot(1), _buildDot(2)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: AppColors.textSecondary.withOpacity(0.5), shape: BoxShape.circle),
        );
      },
    );
  }

  Widget _buildSuggestedQuestions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이런 질문을 해보세요',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          // 2x2 그리드 배치
          Row(
            children: [
              Expanded(child: _buildQuestionChip(_suggestedQuestions[0])),
              const SizedBox(width: 8),
              Expanded(child: _buildQuestionChip(_suggestedQuestions[1])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildQuestionChip(_suggestedQuestions[2])),
              const SizedBox(width: 8),
              Expanded(child: _buildQuestionChip(_suggestedQuestions[3])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionChip(String question) {
    return InkWell(
      onTap: () {
        _messageController.text = question;
        _sendMessage();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        ),
        child: Text(
          question,
          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildSuggestedQuestionsOld() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('이런 질문을 해보세요',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((question) {
              return InkWell(
                onTap: () {
                  _messageController.text = question;
                  _sendMessage();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  ),
                  child: Text(question,
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: TextStyle(color: Colors.grey.shade500),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imagePath;

  ChatMessage({required this.text, required this.isUser, required this.timestamp, this.imagePath});
}