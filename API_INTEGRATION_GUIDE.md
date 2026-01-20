# 회원가입 및 로그인 API 연동 가이드

## 📋 개요
Flutter 앱에서 백엔드 API와 회원가입/로그인 기능을 연동하는 방법입니다.

## 🔧 설정 완료된 항목

### 1. 생성된 파일
- `lib/services/auth_service.dart` - 인증 서비스 클래스

### 2. 수정된 파일
- `lib/screens/auth/login_page.dart` - 로그인 화면
- `lib/screens/auth/signup_page.dart` - 회원가입 화면
- `lib/screens/splash/splash_page.dart` - 스플래시 화면 (로그인 상태 확인)

## 🚀 사용 방법

### 1. 백엔드 서버 URL 설정

`lib/services/auth_service.dart` 파일에서 백엔드 서버 주소를 수정하세요:

```dart
class AuthService {
  // 실제 백엔드 서버 주소로 변경
  static const String baseUrl = 'http://localhost:8000/api';
  // 또는
  // static const String baseUrl = 'https://your-api.com/api';
```

### 2. 백엔드 API 엔드포인트

다음 API 엔드포인트가 필요합니다:

#### 로그인
```
POST /api/auth/login
Content-Type: application/json

Request Body:
{
  "email": "user@example.com",
  "password": "password123"
}

Response (200):
{
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "name": "홍길동",
    "email": "user@example.com",
    "age_group": "30대",
    "gender": "남성"
  }
}

Response (400/401):
{
  "message": "로그인 실패 메시지"
}
```

#### 회원가입
```
POST /api/auth/signup
Content-Type: application/json

Request Body:
{
  "name": "홍길동",
  "email": "user@example.com",
  "password": "password123",
  "age_group": "30대",
  "gender": "남성"
}

Response (201):
{
  "token": "jwt_token_here",
  "user": {
    "id": "1",
    "name": "홍길동",
    "email": "user@example.com",
    "age_group": "30대",
    "gender": "남성"
  }
}

Response (400):
{
  "message": "회원가입 실패 메시지"
}
```

### 3. 다른 화면에서 인증 사용하기

#### 로그아웃
```dart
import 'package:my_app/services/auth_service.dart';

// 로그아웃
final authService = AuthService();
await authService.logout();

// 로그인 화면으로 이동
Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const LoginPage()),
  (route) => false,
);
```

#### 사용자 정보 가져오기
```dart
import 'package:my_app/services/auth_service.dart';

final authService = AuthService();
final user = await authService.getUserInfo();

if (user != null) {
  print('사용자 이름: ${user.name}');
  print('이메일: ${user.email}');
}
```

#### 인증된 API 요청하기
```dart
import 'package:http/http.dart' as http;
import 'package:my_app/services/auth_service.dart';

final authService = AuthService();
final headers = await authService.getAuthHeaders();

// 예시: 카드 목록 가져오기
final response = await http.get(
  Uri.parse('${AuthService.baseUrl}/cards'),
  headers: headers,
);

if (response.statusCode == 200) {
  // 성공
  final data = jsonDecode(response.body);
} else if (response.statusCode == 401) {
  // 인증 만료 - 로그인 화면으로
  await authService.logout();
  // 로그인 화면으로 이동
}
```

### 4. 로그인 상태 확인
```dart
final authService = AuthService();
final isLoggedIn = await authService.isLoggedIn();

if (isLoggedIn) {
  // 로그인된 상태
} else {
  // 로그인 안 된 상태
}
```

## 📱 앱 동작 흐름

1. **앱 시작** → `SplashPage`에서 로그인 상태 확인
2. **로그인 상태 O** → `MainNavigation`으로 이동
3. **로그인 상태 X** → `LoginPage`로 이동
4. **로그인/회원가입 성공** → 토큰 저장 → `MainNavigation`으로 이동
5. **로그아웃** → 토큰 삭제 → `LoginPage`로 이동

## 🔒 보안 고려사항

### 현재 구현
- JWT 토큰을 `SharedPreferences`에 저장 (기본 구현)
- HTTPS 사용 권장

### 추가 보안 강화 (선택사항)
```dart
// flutter_secure_storage 패키지 사용
// pubspec.yaml에 추가:
// flutter_secure_storage: ^9.0.0

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// 토큰 저장
await storage.write(key: 'auth_token', value: token);

// 토큰 읽기
final token = await storage.read(key: 'auth_token');

// 토큰 삭제
await storage.delete(key: 'auth_token');
```

## 🧪 테스트

### 백엔드 없이 테스트하기

임시로 Mock API를 만들어 테스트할 수 있습니다:

```dart
// auth_service.dart의 login 메서드를 임시로 수정

Future<AuthResult> login(String email, String password) async {
  // 테스트용 임시 응답
  await Future.delayed(const Duration(seconds: 1));
  
  if (email == 'test@test.com' && password == '123456') {
    await _saveToken('mock_token_123');
    await _saveUserInfo({
      'id': '1',
      'name': '테스트 사용자',
      'email': email,
    });
    
    return AuthResult(
      success: true,
      message: '로그인 성공',
      user: User(
        id: '1',
        name: '테스트 사용자',
        email: email,
      ),
    );
  } else {
    return AuthResult(
      success: false,
      message: '이메일 또는 비밀번호가 올바르지 않습니다',
    );
  }
}
```

## 🐛 문제 해결

### 1. 네트워크 오류
- Android: `android/app/src/main/AndroidManifest.xml`에 인터넷 권한 추가
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

- iOS: `ios/Runner/Info.plist`에 HTTP 허용 추가 (개발 시)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### 2. CORS 오류 (웹에서 테스트 시)
백엔드에서 CORS 설정 필요

### 3. 토큰 만료 처리
```dart
// API 응답에서 401 처리
if (response.statusCode == 401) {
  final authService = AuthService();
  await authService.logout();
  // 로그인 화면으로 리다이렉트
}
```

## 📦 필요한 패키지

현재 `pubspec.yaml`에 이미 포함되어 있습니다:
- `http: ^1.2.0` - HTTP 요청
- `shared_preferences: ^2.3.0` - 로컬 저장소

## 🎯 다음 단계

1. 백엔드 API 서버 설정
2. `auth_service.dart`의 `baseUrl` 수정
3. 앱 실행 및 테스트
4. 필요시 보안 강화 (flutter_secure_storage)
5. 토큰 만료 처리 로직 추가
6. 리프레시 토큰 구현 (선택사항)
