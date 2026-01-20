import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Android 에뮬레이터에서 localhost 접근
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  String? _accessToken;
  String? _refreshToken;

  // 토큰 로드
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // 토큰 저장
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // 토큰 삭제 (로그아웃)
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
    _refreshToken = null;
  }

  // 인증 여부 확인
  bool get isAuthenticated => _accessToken != null;

  // 공통 헤더
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  // GET 요청
  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // POST 요청
  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  // DELETE 요청
  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // 응답 처리
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else if (response.statusCode == 401) {
      // 토큰 만료 - 로그아웃 처리 필요
      throw ApiException(401, '인증이 만료되었습니다. 다시 로그인해주세요.');
    } else {
      String message = '오류가 발생했습니다.';
      try {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body is Map) {
          message = body['detail'] ?? body['message'] ?? message;
        }
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }
  }

  // ============ 인증 API ============

  Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    String? ageGroup,
    String? gender,
  }) async {
    final response = await post('/users/signup', body: {
      'email': email,
      'password': password,
      'name': name,
      if (ageGroup != null) 'age_group': ageGroup,
      if (gender != null) 'gender': gender,
    });
    return response;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await post('/users/login', body: {
      'email': email,
      'password': password,
    });

    // 토큰 저장
    if (response['access'] != null && response['refresh'] != null) {
      await saveTokens(response['access'], response['refresh']);
    }

    return response;
  }

  Future<void> logout() async {
    await clearTokens();
  }

  // ============ 카드 API ============

  Future<List<dynamic>> getMyCards() async {
    final response = await get('/cards/');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getRecommendedCards() async {
    final response = await get('/cards/recommend/');
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getBenefitAnalysis() async {
    final response = await get('/cards/benefit_analysis/');
    return response;
  }

  // ============ 지출 API ============

  Future<Map<String, dynamic>> getExpenseAnalysis(String month) async {
    final response = await get('/expense/analysis/?month=$month');
    return response;
  }

  Future<List<dynamic>> getMonthlyExpenses(String month) async {
    final response = await get('/expense/expenses/?month=$month');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getSubscriptions() async {
    final response = await get('/expense/subscriptions/');
    return response as List<dynamic>;
  }

  Future<void> deleteSubscription(int id) async {
    await delete('/expense/subscriptions/$id/');
  }

  // ============ 채팅 API ============

  Future<Map<String, dynamic>> createChatRoom() async {
    final response = await post('/chat/make_room/');
    return response;
  }

  Future<Map<String, dynamic>> sendMessage({
    required int roomId,
    required String message,
  }) async {
    final response = await post('/chat/send_message/', body: {
      'room_id': roomId,
      'message': message,
    });
    return response;
  }
}
