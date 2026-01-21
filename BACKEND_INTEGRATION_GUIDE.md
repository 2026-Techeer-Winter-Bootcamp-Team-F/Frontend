# 백엔드 API 연동 가이드

## 📋 필수 설정 사항

### 현재 엑세스 토큰 임시로 넣어뒀으니 수정해야함
### 위에 확인

### 1. API 베이스 URL 설정

**파일**: `lib/services/transaction_service.dart`
**라인**: 8

```dart
static const String baseUrl = 'http://localhost:8000/api';
```

#### 변경 방법:
- **로컬 테스트**: `http://localhost:8000/api` (현재 설정)
- **개발 서버**: `http://dev.your-api.com/api`
- **프로덕션**: `https://api.your-domain.com/api`

**⚠️ 중요**: 실제 백엔드 서버의 URL로 변경 필요!

---

### 2. 인증 토큰 설정

현재 `TransactionService`는 Bearer 토큰 인증을 사용합니다.

#### 토큰 설정 방법:

**옵션 A: 로그인 후 토큰 저장** (권장)
```dart
// 로그인 성공 후
final transactionService = TransactionService();
transactionService.setAuthToken(loginResponse['token']);
```

**옵션 B: SharedPreferences에서 토큰 가져오기**
```dart
// lib/services/transaction_service.dart에 추가
Future<void> loadAuthToken() async {
  final prefs = await SharedPreferences.getInstance();
  _authToken = prefs.getString('auth_token');
}

// 사용 시
await _transactionService.loadAuthToken();
```

**옵션 C: 전역 싱글톤 사용**
```dart
// lib/services/transaction_service.dart를 싱글톤으로 변경
class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();
  
  // 나머지 코드...
}
```

---

## 🔌 API 엔드포인트 목록

백엔드에서 구현해야 할 API 엔드포인트:

### 1. 누적 데이터
```
GET /api/transactions/accumulated?year={year}&month={month}
```
**응답 예시**:
```json
{
  "total": 646137,
  "dailyData": [
    {"day": 1, "amount": 15000},
    {"day": 2, "amount": 35000},
    ...
  ]
}
```

### 2. 일별 요약 (캘린더용)
```
GET /api/transactions/daily-summary?year={year}&month={month}
```
**응답 예시**:
```json
{
  "expenses": {
    "1": -118620,
    "2": -75745,
    "3": -57402,
    ...
  }
}
```

### 3. 일별 상세 거래 내역
```
GET /api/transactions/daily-detail?year={year}&month={month}&day={day}
```
**응답 예시**:
```json
{
  "transactions": [
    {
      "name": "스타벅스",
      "category": "cafe",
      "amount": -5500,
      "currency": null
    },
    {
      "name": "키움 | 자예별 | 토스뱅크",
      "category": "github",
      "amount": -15727,
      "currency": "(-10 USD)"
    }
  ]
}
```

### 4. 주간 평균
```
GET /api/transactions/weekly-average?year={year}&month={month}
```
**응답 예시**:
```json
{
  "average": 200000
}
```

### 5. 월간 평균
```
GET /api/transactions/monthly-average?year={year}&month={month}
```
**응답 예시**:
```json
{
  "average": 880000
}
```

### 6. 카테고리별 요약
```
GET /api/transactions/category-summary?year={year}&month={month}
```
**응답 예시**:
```json
{
  "categories": [
    {
      "name": "쇼핑",
      "emoji": "🛍️",
      "amount": 317918,
      "change": -235312,
      "percent": 49,
      "color": "#4CAF50"
    },
    {
      "name": "이체",
      "emoji": "🏦",
      "amount": 142562,
      "change": -146449,
      "percent": 22,
      "color": "#2196F3"
    }
  ]
}
```

### 7. 지난달 비교
```
GET /api/transactions/month-comparison?year={year}&month={month}
```
**응답 예시**:
```json
{
  "thisMonthTotal": 646137,
  "lastMonthSameDay": 1014051,
  "thisMonthData": [
    {"day": 1, "amount": 15000},
    {"day": 2, "amount": 35000},
    ...
  ],
  "lastMonthData": [
    {"day": 1, "amount": 25000},
    {"day": 2, "amount": 55000},
    ...
  ]
}
```

---

## 📱 카테고리 아이콘 매핑

프론트엔드에서 지원하는 카테고리 타입:

| category 값 | 아이콘 | 색상 |
|------------|--------|------|
| `shopping` | 🛍️ | Grey |
| `food` | 🍴 | Orange |
| `cafe` | ☕ | Brown |
| `transport` | 🚌 | Blue |
| `money` | 💰 | Blue |
| `github` | 💻 | Black |
| 기타 | 🧾 | Grey |

**백엔드에서 보내야 할 category 값**: 위 표의 "category 값" 컬럼 참고

---

## 🔧 테스트 방법

### 1. 로컬 백엔드 연결 테스트
```dart
// lib/screens/home/home_page.dart의 initState에서
@override
void initState() {
  super.initState();
  // TODO: 로그인 후 토큰 설정 (임시로 하드코딩 가능)
  // _transactionService.setAuthToken('your-test-token-here');
  _loadHomeData();
}
```

### 2. Mock 데이터로 테스트
```dart
// lib/services/transaction_service.dart에 Mock 모드 추가
static const bool useMockData = true; // 개발 중에만 true

Future<AccumulatedData> getAccumulatedData(int year, int month) async {
  if (useMockData) {
    // Mock 데이터 반환
    return AccumulatedData(
      total: 646137,
      dailyData: [
        DailyAccumulated(day: 1, amount: 15000),
        DailyAccumulated(day: 2, amount: 35000),
      ],
    );
  }
  // 실제 API 호출...
}
```

### 3. 에러 핸들링 테스트
- 네트워크 오류 시: 에러 메시지 표시 + "다시 시도" 버튼
- 인증 실패 시: 401 에러 → 로그인 페이지로 이동
- 빈 데이터: 더미 데이터로 폴백

---

## 🚀 실행 및 확인

### 1. 패키지 설치
```bash
flutter pub get
```

### 2. 앱 실행
```bash
flutter run -d chrome
```

### 3. 확인 사항
- [ ] 앱 시작 시 로딩 인디케이터 표시
- [ ] API 호출 성공 시 데이터 표시
- [ ] API 호출 실패 시 에러 메시지 + 다시 시도 버튼
- [ ] 월 변경 시 새로운 데이터 로드
- [ ] 캘린더 날짜 클릭 시 거래 내역 로드
- [ ] 아래로 당겨서 새로고침 (RefreshIndicator)

---

## 🔒 보안 고려사항

### 1. 토큰 저장
현재는 메모리에만 저장되므로 앱 재시작 시 사라집니다.

**개선 방법**:
```dart
// 토큰 저장
final prefs = await SharedPreferences.getInstance();
await prefs.setString('auth_token', token);

// 토큰 불러오기
final token = prefs.getString('auth_token');
if (token != null) {
  _transactionService.setAuthToken(token);
}
```

### 2. HTTPS 사용
프로덕션 환경에서는 반드시 HTTPS 사용:
```dart
static const String baseUrl = 'https://api.your-domain.com/api';
```

### 3. 토큰 만료 처리
```dart
// 401 에러 시 처리
if (response.statusCode == 401) {
  // 토큰 만료 → 로그인 페이지로 이동
  Navigator.pushReplacementNamed(context, '/login');
  throw Exception('인증 토큰이 만료되었습니다');
}
```

---

## 📞 다음 단계

백엔드 연동을 완료하기 위해 필요한 정보:

1. **백엔드 API 베이스 URL** - `http://localhost:8080/api`를 실제 URL로 변경
2. **인증 토큰 획득 방법** - 로그인 API에서 받은 토큰을 `setAuthToken()`으로 설정
3. **API 응답 형식 확인** - 위의 JSON 예시와 동일한 형식으로 응답하는지 확인
4. **카테고리 값 매핑** - 백엔드에서 보내는 category 값이 프론트엔드와 일치하는지 확인

모든 설정이 완료되면 앱을 실행하여 테스트하세요!
