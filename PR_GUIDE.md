# Pull Request: 홈 페이지 백엔드 API 연동

## 📋 변경사항
홈 페이지 백엔드 API 연동을 구현했습니다. 실시간 거래 데이터를 표시할 수 있습니다.

## ✨ 새로운 기능

### API 서비스 레이어
- `lib/services/transaction_service.dart` (신규) - 7개 API 호출 메서드
- Bearer 토큰 인증 지원
- 병렬 API 호출 최적화 (`Future.wait`)
- 에러 핸들링 및 타임아웃 처리

### 데이터 모델
- `lib/models/home_data.dart` (신규) - 8개 모델 클래스
  * `AccumulatedData` - 누적 소비 데이터
  * `DailySummary` - 일별 요약
  * `Transaction` - 거래 내역 (아이콘/색상 매핑 포함)
  * `WeeklyData` / `MonthlyData` - 주간/월간 평균
  * `CategoryData` - 카테고리별 요약
  * `MonthComparison` - 월간 비교
- JSON 직렬화/역직렬화 지원

### HomePage UI 개선
- 로딩 인디케이터 추가
- 에러 상태 UI 및 "다시 시도" 기능
- RefreshIndicator로 당겨서 새로고침
- 날짜 선택 시 거래 내역 동적 로딩
- 거래 내역 캐싱으로 중복 호출 방지
- 더미 데이터 폴백 (네트워크 오류 대비)

## 🔌 연동된 API 엔드포인트

1. **누적 데이터 조회** - `/api/v1/transactions/accumulated`
2. **일별 요약** - `/api/v1/transactions/daily-summary`
3. **일별 상세 거래 내역** - `/api/v1/transactions/daily-detail`
4. **주간 평균 지출** - `/api/v1/transactions/weekly-average`
5. **월간 평균 지출** - `/api/v1/transactions/monthly-average`
6. **카테고리별 요약** - `/api/v1/transactions/category-summary`
7. **월간 비교 데이터** - `/api/v1/transactions/month-comparison`

## 📦 주요 변경 파일
- `lib/services/transaction_service.dart` (신규) - API 서비스 레이어
- `lib/models/home_data.dart` (신규) - 데이터 모델 8개
- `lib/screens/home/home_page.dart` - HomePage 리팩토링
- `BACKEND_INTEGRATION_GUIDE.md` (신규) - 백엔드 연동 가이드

## 🔧 기술적 구현 사항

### 상태 관리
```dart
// API에서 받아온 데이터
AccumulatedData? accumulatedData;
DailySummary? dailySummary;
WeeklyData? weeklyData;
MonthlyData? monthlyData;
List<CategoryData>? categories;
MonthComparison? monthComparison;
Map<int, List<Transaction>> dailyTransactionsCache = {};

// 로딩/에러 상태
bool isLoading = false;
String? errorMessage;
```

### API 호출 최적화
- **병렬 호출**: 6개 API를 `Future.wait()`로 동시 호출
- **캐싱**: 일별 거래 내역을 메모리에 캐싱하여 중복 호출 방지
- *🎨 특징
- 병렬 API 호출로 로딩 시간 단축 (`Future.wait`)
- 거래 내역 메모리 캐싱으로 중복 호출 방지
- 로딩/에러 상태 UI 구현
- 당겨서 새로고침 (RefreshIndicator)
- 카테고리별 아이콘/색상 자동 매핑
- 더미 데이터 폴백으로 오프라인 UX 보장
- JWT 인증 토큰 지원dart
// lib/screens/home/home_page.dart:139
_transactionService.setAuthToken('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...');
```

### 4. 테스트 시나리오

###📖 문서
자세한 API 사용법은 `BACKEND_INTEGRATION_GUIDE.md` 참고

## 🧪 테스트 시나리오

### 환경 설정
```bash
flutter pub get
flutter run -d chrome
```

### API 설정
1. `lib/services/transaction_service.dart:8` - baseUrl 변경
2. ⚠️ 프로덕션 배포 전 필수 작업
1. 하드코딩된 인증 토큰 제거 (SharedPreferences 사용)
2. API baseUrl을 프로덕션 서버로 변경
3. HTTPS 적용
4. 401 에러 시 로그인 페이지 리다이렉트

## 🔄 향후 개선 사항
- [ ] API 응답 로컬 캐싱 (SharedPreferences/Hive)
- [ ] 오프라인 모드 지원
- [ ] API 타임아웃 및 재시도 로직
- [ ] Unit/Integration 테스트 작성
- [ ] 로깅 및 모니터링

## 🤝 리뷰 포인트
- API 응답 형식이 모델 클래스와 일치하는지 확인
- 에러 핸들링이 모든 API 호출에 적용되었는지
- 병렬 호출 및 캐싱 로직 검증
- 보안: 토큰 관리 및 HTTPS 사용

---

**리뷰어분들께:**  
백엔드 API와 실제 연동 테스트가 필요합니다. 특히 `daily-summary`의 `expenses` 필드와 `category-summary`의 `color` 필드 형식을 확인 부탁드립니다