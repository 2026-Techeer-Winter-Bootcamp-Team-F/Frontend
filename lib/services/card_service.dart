// lib/services/card_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/user_card.dart';

class CardService {
  static const String baseUrl = 'http://localhost:80/api';
  
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // 내 카드 목록 조회
  Future<List<UserCard>> getMyCards() async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/cards/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['cards'] as List)
          .map((card) => UserCard.fromJson(card))
          .toList();
    } else if (response.statusCode == 401) {
      throw Exception('인증이 필요합니다. 다시 로그인해주세요.');
    } else {
      throw Exception('카드 목록 조회 실패: ${response.statusCode}');
    }
  }
}
