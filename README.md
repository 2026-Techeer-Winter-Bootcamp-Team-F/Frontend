# BeneFit Frontend

개인 금융 관리 및 AI 챗봇 상담 서비스를 제공하는 Flutter 기반 모바일 애플리케이션입니다.

---

## 📱 주요 기능

### 1. 홈 화면 (Home)
- 월간/주간/일간/누적 지출 분석
- 일일 캘린더 기반 거래 상세 조회
- 카테고리별 지출 현황 (파이차트)
- 월별 데이터 비교

### 2. 소비 분석 (Consumption)
- 카드별 지출 분석
- 카테고리별 상세 지출 현황
- 지출 추이 차트

### 3. 카드 관리 (Cards)
- 보유 카드 목록
- 카드별 혜택 분석
- 할인 정보

### 4. 구독 관리 (Subscription)
- 구독 서비스 현황
- 월별 구독비 관리

### 5. 챗봇 상담 (Chat)
- AI 챗봇을 통한 금융 상담
- 추천 질문 제시
- 대화 기록 관리

---

## 🔧 기술 스택

| 분류 | 기술 |
|------|------|
| **Framework** | Flutter 3.x |
| **Language** | Dart |
| **UI Design** | Material Design 3 |
| **Font** | Pretendard (Weights: 200-900) |
| **State Management** | StatefulWidget |
| **Chart Library** | fl_chart 0.69.0 |

---

## 📂 프로젝트 구조

```
lib/
├── main.dart                          # 앱 진입점
├── config/
│   └── theme.dart                     # 색상 및 테마 설정
├── models/
│   ├── card.dart                      # 카드 모델
│   ├── expense.dart                   # 지출 모델
│   ├── subscription.dart              # 구독 모델
│   └── user.dart                      # 사용자 모델
└── screens/
    ├── main_navigation.dart           # 메인 네비게이션 & ChatbotSheet
    ├── home/
    │   └── home_page.dart             # 홈 화면 (지출 분석, 캘린더)
    ├── analysis/                      # 분석 화면
    ├── auth/                          # 인증 화면
    ├── bank/                          # 은행 관련 화면
    ├── cards/                         # 카드 관리 화면
    ├── chat/
    │   └── chat_page.dart             # 채팅 페이지
    ├── home/                          # 홈 화면
    ├── login/                         # 로그인 화면
    ├── onboarding/                    # 온보딩 화면
    ├── splash/                        # 스플래시 화면
    └── subscription/                  # 구독 관리 화면
```

---

## 🎨 색상 시스템

| 색상명 | HEX 코드 | 용도 |
|--------|---------|------|
| Primary | #1560FF | 메인 포인트 색상 (파란색) |
| Text Primary | #1E1E23 | 주요 텍스트 |
| Text Secondary | #64748B | 보조 텍스트 |
| Background | #F8FAFC | 배경색 |
| Card Background | #FFFFFF | 카드 배경 |
| Success | #10B981 | 성공 상태 |
| Warning | #F59E0B | 경고 상태 |
| Error | #EF4444 | 에러 상태 |

---

## 🗂️ 더미 데이터 위치

### 1. 홈 페이지 (`lib/screens/home/home_page.dart`)

#### 일일 지출 데이터
- **변수**: `_dummyDailyExpenses`
- **타입**: `Map<int, int>`
- **설명**: 각 날짜별 총 지출액
- **라인**: 38-60
- **사용처**: 캘린더 일자별 금액 표시

#### 일일 거래 상세
- **변수**: `_dummyTransactions`
- **타입**: `Map<int, List<_TransactionItem>>`
- **설명**: 각 날짜별 거래 내역 (상품명, 금액, 카테고리)
- **라인**: 66-95
- **현재 데이터**: 21일 거래만 포함 (4개 항목)
- **사용처**: 캘린더 날짜 클릭 시 거래 상세 표시

---

### 2. 채팅 페이지 (`lib/screens/chat/chat_page.dart`)

#### 추천 질문 목록
- **변수**: `_suggestedQuestions`
- **타입**: `List<String>`
- **설명**: 사용자에게 제시되는 샘플 질문 4개
- **라인**: 18-22
- **항목**:
  - "이번 달 커피값 얼마나 썼어?"
  - "내 카드보다 더 좋은 거 있어?"
  - "내 소비 패턴 분석해줘"
  - "연회비 아까운 카드 있어?"
- **사용처**: 초기 채팅창에서 추천 질문으로 표시

#### 더미 응답 생성 메서드
- **메서드**: `_generateDummyResponse(String question)`
- **설명**: 질문에 따른 자동 응답 생성 (API 연동 전 임시)
- **라인**: 84-116
- **응답 유형**:
  - 커피/카페 지출 분석
  - 카드 추천 (토스카드)
  - 소비 패턴 분석
  - 연회비 분석
  - 기타 (기본 응답)

---

### 3. 채봇 모달 (`lib/screens/main_navigation.dart`)

#### 대화 목록
- **변수**: `_allConversations`
- **타입**: `List<_Conversation>`
- **설명**: 채봇과의 과거 대화 목록
- **라인**: 213-217
- **항목**:
  - 카드 추천 문의
  - 구독 해지 문의
  - 카페 지출 문의

---

## 🔄 최근 업데이트 (2026-01-26)

### ChatbotSheet 모달 UI 전면 개선
- ✅ 헤더: 로고(원형 BeneFit) + 타이틀 + 닫기(X) 버튼
- ✅ 메시지 카드: 말풍선 꼬리(Triangle Tail) 추가
- ✅ 배경색: 밝은 회색 (#F8F8FB) 적용
- ✅ 로고 텍스트: fontSize 11 → 15pt (더 크고 꽉 찬 느낌)
- ✅ 타이틀 폰트: FontWeight.w800 → w600 (더 가벼운 느낌)
- ✅ 텍스트 간격: 12pt → 1pt (매우 촘촘함)

### ChatPage 채팅 화면 UI 개선
- ✅ 헤더: 뒤로가기 버튼 + BeneFit 로고 + 닫기 버튼
- ✅ 봇 메시지 아바타: 기존 아이콘 → BeneFit 로고(원형)로 변경
- ✅ 사용자 메시지: 우측에 사용자 프로필 아이콘 추가
- ✅ 추천 질문: Primary Color(#1560FF) 파란색으로 통일
- ✅ 추천 질문 버튼: 투명도 및 테두리 강화

### 하단 네비게이션 바
- ✅ 아이콘-텍스트 간격: spacing 4.0 → 2.0 (더 촘촘함)

### 색상 시스템 통일
- ✅ Primary Color: #4F46E5 → #1560FF (파란색으로 전체 통일)
- ✅ 모든 포인트 색상 일관성 유지

---

## 📥 설치 및 실행

### 필수 요구사항
- Flutter 3.x 이상
- Dart 3.x 이상
- iOS 11.0 이상 (macOS)
- Android API 21 이상

### 설치 절차

```bash
# 1. 저장소 클론
git clone https://github.com/2026-Techeer-Winter-Bootcamp-Team-F/Frontend.git

# 2. 프로젝트 디렉토리 이동
cd Frontend

# 3. 의존성 설치
flutter pub get

# 4. 앱 실행
flutter run

# 5. 특정 기기에서 실행 (옵션)
flutter run -d <device-id>
```

---

## 🚀 개발 가이드

### 새로운 기능 추가 시

1. **더미 데이터 추가**
   - 위에 명시된 위치에 더미 데이터 추가
   - README.md 업데이트

2. **API 연동 준비**
   - `_generateDummyResponse()` 등의 더미 로직을 실제 API 호출로 대체
   - 기존 구조 유지

3. **테스트**
   - 핫 리로드(Hot Reload) 확인
   - 다양한 화면 크기에서 테스트

---

## 📋 향후 작업 (TODO)

- [ ] 실제 서버 API 연동
- [ ] 더미 데이터 → 실데이터로 전환
- [ ] 사용자 인증 구현 (로그인/회원가입)
- [ ] 카드 추천 알고리즘 개발
- [ ] 실시간 지출 알림 기능
- [ ] 데이터 캐싱 (로컬 저장소)
- [ ] 오프라인 모드 지원
- [ ] 성능 최적화

---

## 📝 커밋 메시지 컨벤션

```
feat:   새로운 기능
fix:    버그 수정
docs:   문서 수정
style:  코드 스타일 변경 (포맷팅 등)
refactor: 코드 리팩토링
test:   테스트 추가
chore:  빌드 설정, 의존성 업데이트 등
```

---

## 👥 팀 정보

- **프로젝트**: BeneFit (개인 금융 관리 앱)
- **기간**: 2025 Winter Bootcamp
- **팀**: Team-F

---

## 📄 라이선스

이 프로젝트는 내부 개발 프로젝트입니다.

---

**마지막 업데이트**: 2026-01-26  
**현재 브랜치**: `feat/chatbot-drag-and-ui-improvements-20260123`

