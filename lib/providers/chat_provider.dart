import 'package:flutter/foundation.dart';
import 'package:my_app/services/api_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['content'] ?? json['message'] ?? '',
      isUser: json['is_user'] ?? json['sender'] == 'user',
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}

class ChatProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  int? _roomId;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  int? get roomId => _roomId;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  // 채팅방 생성 또는 기존 방 사용
  Future<void> initializeRoom() async {
    if (_roomId != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.createChatRoom();
      _roomId = response['room_id'] ?? response['id'];

      // 환영 메시지 추가
      _messages = [
        ChatMessage(
          text: '안녕하세요! BeneFit AI 금융 비서입니다.\n\n소비 내역, 카드 혜택, 구독 서비스 등에 대해 무엇이든 물어보세요.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      ];

      // 기존 메시지가 있다면 로드
      if (response['messages'] != null) {
        final existingMessages = (response['messages'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();
        if (existingMessages.isNotEmpty) {
          _messages = existingMessages;
        }
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '채팅방을 초기화하는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 메시지 전송
  Future<bool> sendMessage(String text) async {
    if (_roomId == null || text.trim().isEmpty) return false;

    // 사용자 메시지 즉시 추가
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.add(userMessage);
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.sendMessage(
        roomId: _roomId!,
        message: text,
      );

      // AI 응답 추가
      final aiResponse = ChatMessage(
        text: response['response'] ?? response['message'] ?? '응답을 받지 못했습니다.',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(aiResponse);

      _isSending = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      // 에러 발생 시 에러 메시지를 AI 응답으로 표시
      _messages.add(ChatMessage(
        text: '죄송합니다. 오류가 발생했습니다: ${e.message}',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isSending = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '메시지 전송에 실패했습니다.';
      _messages.add(ChatMessage(
        text: '죄송합니다. 메시지 전송에 실패했습니다. 다시 시도해주세요.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isSending = false;
      notifyListeners();
      return false;
    }
  }

  // 채팅 초기화
  void resetChat() {
    _roomId = null;
    _messages = [];
    _errorMessage = null;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
