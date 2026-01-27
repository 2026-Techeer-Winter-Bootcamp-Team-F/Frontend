import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:my_app/config/api_config.dart';
import 'package:my_app/utils/api_exception.dart';

class ApiClient {
  final http.Client _client = http.Client();
  String? _token;

  static const String _tokenKey = 'access_token';

  // 싱글톤
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  /// 앱 시작 시 저장된 토큰 불러오기
  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  /// 토큰 저장 (메모리 + 로컬 스토리지)
  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// 토큰 삭제 (로그아웃)
  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  bool get hasToken => _token != null;

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Uri _buildUri(String path, {Map<String, String>? queryParams}) {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    if (queryParams != null) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<dynamic> get(String path, {Map<String, String>? queryParams}) async {
    final response = await _client.get(
      _buildUri(path, queryParams: queryParams),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<dynamic> post(String path, {Map<String, dynamic>? body, Map<String, String>? extraHeaders}) async {
    final headers = _headers;
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    final response = await _client.post(
      _buildUri(path),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String path, {Map<String, dynamic>? body}) async {
    final response = await _client.put(
      _buildUri(path),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path) async {
    final response = await _client.delete(
      _buildUri(path),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    }

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException();
      case 404:
        throw NotFoundException();
      default:
        throw ApiException(
          statusCode: response.statusCode,
          message: response.body,
        );
    }
  }
}
