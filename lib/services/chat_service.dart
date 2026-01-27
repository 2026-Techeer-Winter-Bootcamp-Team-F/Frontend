import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/config/api_config.dart';
import 'package:my_app/services/api_client.dart';

class ChatService {
  final ApiClient _api = ApiClient();
  static const String _sessionsKey = 'chat_sessions';

  /// 채팅방 생성 (카드 추천용) - session_id 반환
  Future<Map<String, dynamic>> makeRoom() async {
    final data = await _api.post(ApiConfig.chatMakeRoom);
    return Map<String, dynamic>.from(data);
  }

  /// 채팅방 메시지 전송 (카드 추천) - session_id 필요
  Future<Map<String, dynamic>> sendMessage({
    required String question,
    required String sessionId,
  }) async {
    final data = await _api.post(
      ApiConfig.chatSendMessage,
      body: {
        'question': question,
        'session_id': sessionId,
      },
    );
    return Map<String, dynamic>.from(data);
  }

  /// AI 채팅 기록 조회
  Future<List<Map<String, dynamic>>> getChatHistory() async {
    final data = await _api.get(ApiConfig.chat);
    return List<Map<String, dynamic>>.from(
      (data as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }

  /// AI 채팅 메시지 전송 (금융 상담)
  Future<Map<String, dynamic>> sendAiMessage({
    required String message,
  }) async {
    final data = await _api.post(
      ApiConfig.chat,
      body: {'message': message},
    );
    return Map<String, dynamic>.from(data);
  }

  // === 로컬 세션 저장 ===

  /// 저장된 채팅 세션 목록 조회
  Future<List<Map<String, dynamic>>> getSavedSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_sessionsKey);
    if (json == null) return [];
    return List<Map<String, dynamic>>.from(
      (jsonDecode(json) as List).map((e) => Map<String, dynamic>.from(e)),
    );
  }

  /// 채팅 세션 저장/업데이트
  Future<void> saveSession({
    required String sessionId,
    required String title,
    required String lastMessage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getSavedSessions();

    final idx = sessions.indexWhere((s) => s['session_id'] == sessionId);

    if (idx >= 0) {
      // 기존 세션: title 유지, lastMessage만 업데이트
      sessions[idx]['last_message'] = lastMessage;
      sessions[idx]['updated_at'] = DateTime.now().toIso8601String();
    } else {
      sessions.add({
        'session_id': sessionId,
        'title': title,
        'last_message': lastMessage,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    await prefs.setString(_sessionsKey, jsonEncode(sessions));
  }
}
