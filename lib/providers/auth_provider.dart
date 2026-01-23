import 'package:flutter/foundation.dart';
import 'package:my_app/models/user.dart';
import 'package:my_app/services/api_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // 앱 시작 시 인증 상태 확인
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _api.loadTokens();
      if (_api.isAuthenticated) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // 로그인
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.login(email: email, password: password);

      // 사용자 정보가 응답에 포함되어 있다면 저장
      if (response['user'] != null) {
        _user = User.fromJson(response['user']);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = '로그인 중 오류가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 회원가입
  Future<bool> signup({
    required String email,
    required String password,
    required String name,
    String? ageGroup,
    String? gender,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _api.signup(
        email: email,
        password: password,
        name: name,
        ageGroup: ageGroup,
        gender: gender,
      );

      // 회원가입 성공 후 자동 로그인
      return await login(email: email, password: password);
    } on ApiException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = '회원가입 중 오류가 발생했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 로그아웃
  Future<void> logout() async {
    await _api.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // 에러 메시지 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
