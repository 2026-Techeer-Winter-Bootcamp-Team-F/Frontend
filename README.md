# BeneFit Frontend

Flutter 기반의 개인 금융 관리 애플리케이션입니다.

## 프로젝트 구조

### 주요 화면
1. 홈 - 지출 분석 및 일일 캘린더
2. 소비 - 카드별/카테고리별 지출 분석
3. 카드 - 보유 카드 관리 및 혜택 분석
4. 구독 - 구독 서비스 관리
5. 채팅 - AI 챗봇 상담

## 더미 데이터 위치

### 1. **홈 페이지** (`lib/screens/home/home_page.dart`)
- **일일 지출 데이터**: `_dummyDailyExpenses` (Map<int, int>)
  - 각 날짜별 총 지출액
  - Lines: 38-60
  
- **일일 거래 상세**: `_dummyTransactions` (Map<int, List<_TransactionItem>>)
  - 각 날짜별 거래 내역 (상품명, 금액, 카테고리 등)
  - 현재 21일 거래만 포함
  - Lines: 66-95

### 2. **채팅 페이지** (`lib/screens/chat/chat_page.dart`)
- **추천 질문**: `_suggestedQuestions` (List<String>)
  - 사용자에게 제시되는 샘플 질문 목록
  - Lines: 18-22
  
- **더미 응답**: `_generateDummyResponse()` 메서드
  - 질문별 자동 응답 생성 (API 연동 전 임시)
  - 커피/카드/분석/연회비 관련 질문별 샘플 응답
  - Lines: 84-116

### 3. **채봇 시트** (`lib/screens/main_navigation.dart`)
- **대화 목록**: `_allConversations` (List<_Conversation>)
  - 채봇과의 과거 대화 목록
  - Lines: 213-217

## 최근 변경사항 (UI 개선)

### ChatbotSheet (모달) UI
- ✅ 헤더: 로고(원형) + 타이틀 + 닫기 버튼 추가
- ✅ 메시지 카드: 말풍선 꼬리(Tail) 추가
- ✅ 배경색: 밝은 회색(#F8F8FB)으로 변경
- ✅ 로고 텍스트 크기: 11 → 15pt (더 크고 꽉 찬 느낌)
- ✅ 타이틀 굵기: w800 → w600 (더 가벼운 느낌)
- ✅ 본문 간격: 12 → 1 (매우 촘촘함)

### ChatPage UI
- ✅ 헤더: 뒤로가기 + 로고 + 닫기 버튼으로 재설계
- ✅ 메시지 아바타: 봇 아이콘 → BeneFit 로고로 변경
- ✅ 사용자 메시지: 우측에 사용자 아이콘 추가
- ✅ 추천 질문: 파란색(#1560FF) 포인트 컬러로 통일

### 하단 네비게이션 바
- ✅ 로고와 글씨 간격: 4.0 → 2.0 (더 촘촘함)

### 색상 시스템
- ✅ Primary Color: #4F46E5 → #1560FF (파란색으로 통일)

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 앱 실행
flutter run
```

## 사용 기술

- **Framework**: Flutter 3.x
- **Language**: Dart
- **State Management**: StatefulWidget
- **UI Components**: Material Design 3
- **Font**: Pretendard

## 향후 작업

- [ ] 실제 API 데이터 연동
- [ ] 더미 데이터 → 서버 데이터로 변경
- [ ] 로그인/회원가입 구현
- [ ] 카드 추천 알고리즘 개발
- [ ] 실시간 알림 기능
