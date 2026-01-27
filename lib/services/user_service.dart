import 'package:my_app/config/api_config.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/api_client.dart';

class UserService {
  final ApiClient _api = ApiClient();

  /// 유저 프로필 조회 (카드 목록 포함)
  Future<User> getProfile() async {
    final data = await _api.get(ApiConfig.userProfile);
    return User.fromJson(data);
  }

  /// 로그인 - 전화번호 + 비밀번호
  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final data = await _api.post(
      ApiConfig.login,
      body: {'phone': phone, 'password': password},
    );
    final token = data['token']?['access'];
    if (token != null) {
      await _api.setToken(token);
    }
    return data;
  }

  /// 회원가입
  Future<Map<String, dynamic>> signup({
    required String phone,
    required String password,
    required String name,
    required String email,
    required String birthDate,
  }) async {
    final data = await _api.post(
      ApiConfig.signup,
      body: {
        'phone': phone,
        'password': password,
        'name': name,
        'email': email,
        'birth_date': birthDate,
      },
    );
    final token = data['result']?['token']?['access'];
    if (token != null) {
      await _api.setToken(token);
    }
    return data;
  }
}
