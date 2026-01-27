import 'package:my_app/config/api_config.dart';
import 'package:my_app/services/api_client.dart';

class UserService {
  final ApiClient _api = ApiClient();

  /// 로그인 - 전화번호 + 비밀번호
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final data = await _api.post(
      ApiConfig.login,
      body: {'phone': phone, 'password': password},
    );
    // 토큰 저장
    if (data['token'] != null) {
      await _api.setToken(data['token']);
    }
    return data;
  }

  /// 회원가입
  Future<Map<String, dynamic>> signup({
    required String phone,
    required String password,
    required String name,
    required String email,
  }) async {
    final data = await _api.post(
      ApiConfig.signup,
      body: {
        'phone': phone,
        'password': password,
        'name': name,
        'email': email,
      },
    );
    // 토큰 저장
    if (data['token'] != null) {
      await _api.setToken(data['token']);
    }
    return data;
  }
}
