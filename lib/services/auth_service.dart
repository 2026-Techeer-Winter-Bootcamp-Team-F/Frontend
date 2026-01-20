import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Nginx 주소 사용 API 엔드포인트
  static const String baseUrl = 'http://localhost/api/v1';
  
  // 로그인
  Future<AuthResult> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('로그인 응답: $data'); // 디버깅용
        
        try {
          // 여러 응답 포맷에서 토큰 추출 (string / {access, refresh} / data.token)
          String? token;
          String? refreshToken;
          
          if (data['token'] is String) {
            token = data['token'];
          } else if (data['token'] is Map) {
            // 토큰 객체 {access: "...", refresh: "..."}
            final tokenMap = data['token'] as Map;
            token = tokenMap['access'] as String?;
            refreshToken = tokenMap['refresh'] as String?;
          } else if (data['access_token'] is String) {
            token = data['access_token'];
          } else if (data['data'] is Map && data['data']['token'] is String) {
            token = data['data']['token'];
          }
          
          // 회원가입 응답에 토큰이 없을 수도 있음 (없으면 저장 스킵)
          if (token != null && token.isNotEmpty) {
            await _saveToken(token);
          }
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _saveRefreshToken(refreshToken);
          }
          
          // 사용자 정보 추출 (백엔드가 안 주면 로그인 입력값으로 보완)
          dynamic userData = data['user'] ?? data['data'];

          if (userData is Map) {
            // 이름이나 이메일이 없으면 로그인 입력값으로 보완
            userData = Map<String, dynamic>.from(userData);
            userData.putIfAbsent('email', () => email);
          } else {
            userData = {
              'email': email,
            };
          }

          await _saveUserInfo(userData);
          
          User? user;
          if (userData is Map) {
            // Map<dynamic, dynamic>을 Map<String, dynamic>으로 변환
            final userMap = Map<String, dynamic>.from(userData as Map);
            user = User.fromJson(userMap);
          }
          
          return AuthResult(
            success: true,
            message: '로그인 성공',
            user: user,
          );
        } catch (e) {
          return AuthResult(
            success: false,
            message: '데이터 처리 오류: $e',
          );
        }
      } else {
        final msg = _extractErrorMessage(response, fallback: '로그인 실패');
        return AuthResult(
          success: false,
          message: msg,
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 공통 에러 메시지 파서
  String _extractErrorMessage(http.Response response, {required String fallback}) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map) {
        // 흔한 키들 우선 탐색
        final keys = ['message', 'detail', 'error', 'errors'];
        for (final k in keys) {
          if (body[k] is String && (body[k] as String).isNotEmpty) {
            return body[k];
          }
        }
        // errors가 배열일 때 첫 메시지 사용
        if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
          final first = (body['errors'] as List).first;
          if (first is String) return first;
          if (first is Map && first['message'] is String) return first['message'];
        }
      }
    } catch (_) {
      // JSON 파싱 실패 시 무시
    }

    // 본문을 잘라서 전달 (너무 길면 앞부분만)
    final raw = response.body;
    if (raw.isNotEmpty) {
      return raw.length > 200 ? raw.substring(0, 200) : raw;
    }

    return fallback;
  }

  // 회원가입
  Future<AuthResult> signup({
    required String name,
    required String email,
    required String password,
    String? ageGroup,
    String? gender,
  }) async {
    try {
      // null 값은 보내지 않도록 payload를 구성
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
      };
      if (ageGroup != null) payload['age_group'] = ageGroup;
      if (gender != null) payload['gender'] = gender;

      final response = await http.post(
        Uri.parse('$baseUrl/users/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('회원가입 응답: $data'); // 디버깅용
        
        try {
          // 여러 응답 포맷에서 토큰 추출 (string / {access, refresh} / data.token)
          String? token;
          String? refreshToken;
          
          if (data['token'] is String) {
            token = data['token'];
          } else if (data['token'] is Map) {
            // 토큰 객체 {access: "...", refresh: "..."}
            final tokenMap = data['token'] as Map;
            token = tokenMap['access'] as String?;
            refreshToken = tokenMap['refresh'] as String?;
          } else if (data['access_token'] is String) {
            token = data['access_token'];
          } else if (data['data'] is Map && data['data']['token'] is String) {
            token = data['data']['token'];
          }
            
            // 백엔드 프로필에서 이름을 다시 가져와서 덮어쓰기 (토큰 저장 이후)
            try {
              final profile = await getUserProfile();
              if (profile.success && profile.data != null) {
                await _saveUserInfo(profile.data!.toJson());
              }
            } catch (_) {
              // 프로필 조회 실패는 무시
            }
          // 회원가입 응답에는 토큰이 없을 수 있으므로 있으면 저장, 없으면 건너뜀
          if (token != null && token.isNotEmpty) {
            await _saveToken(token);
          }
          if (refreshToken != null && refreshToken.isNotEmpty) {
            await _saveRefreshToken(refreshToken);
          }
          
          // 사용자 정보 추출 (백엔드가 안 주면 회원가입 입력값으로 보완)
          dynamic userData = data['user'] ?? data['data'];

          if (userData is Map) {
            userData = Map<String, dynamic>.from(userData); // Map<dynamic, dynamic> 방지
            userData.putIfAbsent('name', () => name);
            userData.putIfAbsent('email', () => email);
          } else {
            userData = {
              'name': name,
              'email': email,
            };
          }

          await _saveUserInfo(userData);
          
          User? user;
          if (userData is Map) {
            // Map<dynamic, dynamic>을 Map<String, dynamic>으로 변환
            final userMap = Map<String, dynamic>.from(userData as Map);
            user = User.fromJson(userMap);
          }
          
          final successMsg = (data is Map && data['message'] is String)
              ? data['message'] as String
              : '회원가입 성공';

          return AuthResult(
            success: true,
            message: successMsg,
            user: user,
          );
        } catch (e) {
          return AuthResult(
            success: false,
            message: '데이터 처리 오류: $e',
          );
        }
      } else {
        // 실패 응답 로깅 및 안전 파싱
        print('회원가입 실패 status: ${response.statusCode}, body: ${response.body}');
        final msg = _extractErrorMessage(response, fallback: '회원가입 실패 (status: ${response.statusCode})');
        return AuthResult(success: false, message: msg);
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_info');
  }

  // 토큰 저장
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Refresh 토큰 저장
  Future<void> _saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('refresh_token', refreshToken);
  }

  // 사용자 정보 저장
  Future<void> _saveUserInfo(dynamic user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // user가 Map이면 JSON으로 인코딩
    if (user is Map<String, dynamic>) {
      await prefs.setString('user_info', jsonEncode(user));
    } else if (user is String) {
      // 이미 JSON 문자열이면 그대로 저장
      await prefs.setString('user_info', user);
    }
  }

  // 저장된 토큰 가져오기
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 저장된 사용자 정보 가져오기
  Future<User?> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_info');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // 인증 헤더 가져오기 (다른 API 요청에 사용)
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ===== 데이터 조회 메서드 =====

  // 사용자 정보 상세 조회
  Future<ApiResponse<User>> getUserProfile() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['data'] ?? data);
        await _saveUserInfo(user.toJson());
        
        return ApiResponse(
          success: true,
          data: user,
          message: '사용자 정보 조회 성공',
        );
      } else if (response.statusCode == 401) {
        // 토큰 만료
        await logout();
        return ApiResponse(
          success: false,
          message: '인증 만료. 다시 로그인해주세요.',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: error['message'] ?? '정보 조회 실패',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 카드 목록 조회
  Future<ApiResponse<List<dynamic>>> getCards() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cards/list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cards = (data['data'] ?? data) as List;
        
        return ApiResponse(
          success: true,
          data: cards,
          message: '카드 목록 조회 성공',
        );
      } else if (response.statusCode == 401) {
        await logout();
        return ApiResponse(
          success: false,
          message: '인증 만료',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: error['message'] ?? '조회 실패',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 카드 추천 조회
  Future<ApiResponse<List<dynamic>>> getRecommendedCards() async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/cards/recommend/list'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final cards = (data['data'] ?? data) as List;
        
        return ApiResponse(
          success: true,
          data: cards,
          message: '추천 카드 조회 성공',
        );
      } else if (response.statusCode == 401) {
        await logout();
        return ApiResponse(
          success: false,
          message: '인증 만료',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: error['message'] ?? '조회 실패',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 거래 내역 조회
  Future<ApiResponse<List<dynamic>>> getTransactions({int? limit, int? offset}) async {
    try {
      final headers = await getAuthHeaders();
      String url = '$baseUrl/transactions';
      
      if (limit != null || offset != null) {
        final params = <String, String>{};
        if (limit != null) params['limit'] = limit.toString();
        if (offset != null) params['offset'] = offset.toString();
        url += '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
      }

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transactions = (data['data'] ?? data) as List;
        
        return ApiResponse(
          success: true,
          data: transactions,
          message: '거래 내역 조회 성공',
        );
      } else if (response.statusCode == 401) {
        await logout();
        return ApiResponse(
          success: false,
          message: '인증 만료',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: error['message'] ?? '조회 실패',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }

  // 일반 GET 요청 (다른 엔드포인트 사용)
  Future<ApiResponse<Map<String, dynamic>>> fetchData(String endpoint) async {
    try {
      final headers = await getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse(
          success: true,
          data: data,
          message: '데이터 조회 성공',
        );
      } else if (response.statusCode == 401) {
        await logout();
        return ApiResponse(
          success: false,
          message: '인증 만료',
        );
      } else {
        final error = jsonDecode(response.body);
        return ApiResponse(
          success: false,
          message: error['message'] ?? '조회 실패',
        );
      }
    } catch (e) {
      return ApiResponse(
        success: false,
        message: '네트워크 오류: $e',
      );
    }
  }
}

// 일반 API 응답 클래스
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String message;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
  });
}

// 인증 결과 클래스
class AuthResult {
  final bool success;
  final String message;
  final User? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

// 사용자 클래스
class User {
  final String id;
  final String name;
  final String email;
  final String? ageGroup;
  final String? gender;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.ageGroup,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // 이름 필드가 name 외 다른 키로 올 수 있어 대체 키를 순서대로 확인
    final name = (json['name'] ?? json['username'] ?? json['full_name'] ?? json['nickname'] ?? '')
        .toString();

    return User(
      id: json['id'].toString(),
      name: name,
      email: json['email'],
      ageGroup: json['age_group'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'age_group': ageGroup,
      'gender': gender,
    };
  }
}
