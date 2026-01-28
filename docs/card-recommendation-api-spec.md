# 카드 추천 API 명세서 (요청)

> 작성일: 2026-01-29
> 상태: **백엔드 개발 요청**
> 우선순위: 높음

---

## 개요

### 기능 설명

사용자의 **최근 3개월 카테고리별 소비 패턴**을 분석하여, 각 카테고리에서 **최대 실익률(ROI)**을 제공하는 카드를 추천하는 API입니다.

### 비즈니스 로직

```
1. 사용자의 최근 3개월 거래 내역 조회
2. 카테고리별 월평균 지출 금액 계산
3. 상위 N개 카테고리 선정 (지출 금액 기준)
4. 각 카테고리에 대해:
   a. DB에 저장된 카드 혜택 정보 조회
   b. 해당 카테고리 혜택이 있는 카드 필터링
   c. 실익률(ROI) 계산: (예상 혜택 금액 / 연회비) × 100
   d. ROI 기준 상위 4개 카드 선정
5. 결과 반환
```

### 실익률(ROI) 계산 공식

```
월평균 지출 = 최근 3개월 해당 카테고리 지출 합계 / 3
연간 예상 지출 = 월평균 지출 × 12
예상 혜택 금액 = 연간 예상 지출 × 할인율
ROI = (예상 혜택 금액 / 연회비) × 100

* 연회비가 0원인 경우: ROI = 예상 혜택 금액 (원 단위로 표시)
```

---

## API 엔드포인트

### 카드 추천 목록 조회

| 항목         | 값                               |
| ------------ | -------------------------------- |
| **URL**      | `GET /api/v1/cards/recommendations` |
| **인증**     | JWT Bearer Token (필수)          |
| **파라미터** | 없음 (인증된 사용자 기준)        |

### curl 예시

```bash
curl "http://localhost:8000/api/v1/cards/recommendations" \
  -H "Authorization: Bearer <TOKEN>"
```

### 요청 헤더

```
Authorization: Bearer <ACCESS_TOKEN>
Content-Type: application/json
```

---

## 응답 형식

### 성공 응답 (200 OK)

```json
{
  "generated_at": "2026-01-29T14:30:00",
  "analysis_period": {
    "start": "2025-11-01",
    "end": "2026-01-31"
  },
  "categories": [
    {
      "category_name": "택시",
      "emoji": "🚕",
      "color": "#FFC107",
      "monthly_average": 27133,
      "total_spent": 81400,
      "recommended_cards": [
        {
          "card_id": 101,
          "card_name": "LIKIT FUN+",
          "card_company": "신한카드",
          "card_image_url": "https://example.com/cards/likit-fun.png",
          "annual_fee": 15000,
          "roi_percent": 210,
          "estimated_annual_benefit": 31500,
          "main_benefits": [
            "스타벅스 최대 60%, 영화 50% 할인",
            "대중교통, 통신비 10%, 배달의민족 5% 할인"
          ],
          "category_benefits": [
            {
              "category": "커피",
              "description": "스타벅스 최대 60% 할인",
              "discount_rate": 60
            },
            {
              "category": "문화",
              "description": "롯데시네마, CGV 50% 할인",
              "discount_rate": 50
            },
            {
              "category": "교통",
              "description": "대중교통 10% 할인",
              "discount_rate": 10
            },
            {
              "category": "통신",
              "description": "통신비 10% 할인",
              "discount_rate": 10
            },
            {
              "category": "외식",
              "description": "배달의민족, 요기요 5% 할인",
              "discount_rate": 5
            }
          ]
        },
        {
          "card_id": 102,
          "card_name": "탄탄대로 티타늄카드",
          "card_company": "BC카드",
          "card_image_url": "https://example.com/cards/bc-titanium.png",
          "annual_fee": 20000,
          "roi_percent": 110,
          "estimated_annual_benefit": 22000,
          "main_benefits": [
            "택시·대리운전 최대 15% 할인",
            "주유 10%, 음식 배달 7% 할인"
          ],
          "category_benefits": [
            {
              "category": "택시",
              "description": "카카오T, 티맵 최대 15% 할인",
              "discount_rate": 15
            },
            {
              "category": "주유",
              "description": "주유 결제 10% 할인",
              "discount_rate": 10
            }
          ]
        }
      ]
    },
    {
      "category_name": "교통",
      "emoji": "🚌",
      "color": "#2196F3",
      "monthly_average": 7816,
      "total_spent": 23450,
      "recommended_cards": [
        {
          "card_id": 103,
          "card_name": "현대카드 M",
          "card_company": "현대카드",
          "card_image_url": "https://example.com/cards/hyundai-m.png",
          "annual_fee": 20000,
          "roi_percent": 130,
          "estimated_annual_benefit": 26000,
          "main_benefits": [
            "대중교통 20%, 주유 15% 할인",
            "통신비 10%, 영화 50% 할인"
          ],
          "category_benefits": [
            {
              "category": "교통",
              "description": "대중교통 20% 할인",
              "discount_rate": 20
            },
            {
              "category": "주유",
              "description": "주유 15% 할인",
              "discount_rate": 15
            }
          ]
        }
      ]
    }
  ]
}
```

### 데이터 없음 응답 (200 OK)

거래 내역이 없는 경우:

```json
{
  "generated_at": "2026-01-29T14:30:00",
  "analysis_period": {
    "start": "2025-11-01",
    "end": "2026-01-31"
  },
  "categories": [],
  "message": "최근 3개월간 거래 내역이 없습니다."
}
```

### 에러 응답

#### 401 Unauthorized

```json
{
  "message": "조회 실패",
  "error_code": "AUTH_REQUIRED",
  "reason": "로그인이 필요하거나 만료되었습니다."
}
```

#### 500 Internal Server Error

```json
{
  "message": "카드 추천 생성 실패",
  "error_code": "RECOMMENDATION_ERROR",
  "reason": "서버 내부 오류가 발생했습니다."
}
```

---

## 타입 정의

### TypeScript

```typescript
interface CardRecommendationResponse {
  generated_at: string; // ISO 8601 형식
  analysis_period: {
    start: string; // "YYYY-MM-DD"
    end: string;   // "YYYY-MM-DD"
  };
  categories: CategoryRecommendation[];
  message?: string; // 데이터 없을 때 메시지
}

interface CategoryRecommendation {
  category_name: string;      // 카테고리 한글명
  emoji: string;              // 이모지
  color: string;              // HEX 색상 코드
  monthly_average: number;    // 월평균 지출 (원)
  total_spent: number;        // 3개월 총 지출 (원)
  recommended_cards: RecommendedCard[];
}

interface RecommendedCard {
  card_id: number;                    // 카드 고유 ID
  card_name: string;                  // 카드 이름
  card_company: string;               // 카드사
  card_image_url: string;             // 카드 이미지 URL
  annual_fee: number;                 // 연회비 (원)
  roi_percent: number;                // 실익률 (%)
  estimated_annual_benefit: number;   // 연간 예상 혜택 금액 (원)
  main_benefits: string[];            // 주요 혜택 요약 (1-2줄)
  category_benefits: CategoryBenefit[];
}

interface CategoryBenefit {
  category: string;       // 혜택 적용 카테고리
  description: string;    // 혜택 설명
  discount_rate: number;  // 할인율 (%)
}
```

### Dart (Flutter)

```dart
class CardRecommendationResponse {
  final String generatedAt;
  final AnalysisPeriod analysisPeriod;
  final List<CategoryRecommendation> categories;
  final String? message;

  CardRecommendationResponse.fromJson(Map<String, dynamic> json)
      : generatedAt = json['generated_at'],
        analysisPeriod = AnalysisPeriod.fromJson(json['analysis_period']),
        categories = (json['categories'] as List)
            .map((c) => CategoryRecommendation.fromJson(c))
            .toList(),
        message = json['message'];
}

class AnalysisPeriod {
  final String start;
  final String end;

  AnalysisPeriod.fromJson(Map<String, dynamic> json)
      : start = json['start'],
        end = json['end'];
}

class CategoryRecommendation {
  final String categoryName;
  final String emoji;
  final String color;
  final int monthlyAverage;
  final int totalSpent;
  final List<RecommendedCard> recommendedCards;

  CategoryRecommendation.fromJson(Map<String, dynamic> json)
      : categoryName = json['category_name'],
        emoji = json['emoji'],
        color = json['color'],
        monthlyAverage = json['monthly_average'],
        totalSpent = json['total_spent'],
        recommendedCards = (json['recommended_cards'] as List)
            .map((c) => RecommendedCard.fromJson(c))
            .toList();
}

class RecommendedCard {
  final int cardId;
  final String cardName;
  final String cardCompany;
  final String cardImageUrl;
  final int annualFee;
  final int roiPercent;
  final int estimatedAnnualBenefit;
  final List<String> mainBenefits;
  final List<CategoryBenefit> categoryBenefits;

  RecommendedCard.fromJson(Map<String, dynamic> json)
      : cardId = json['card_id'],
        cardName = json['card_name'],
        cardCompany = json['card_company'],
        cardImageUrl = json['card_image_url'],
        annualFee = json['annual_fee'],
        roiPercent = json['roi_percent'],
        estimatedAnnualBenefit = json['estimated_annual_benefit'],
        mainBenefits = List<String>.from(json['main_benefits']),
        categoryBenefits = (json['category_benefits'] as List)
            .map((b) => CategoryBenefit.fromJson(b))
            .toList();
}

class CategoryBenefit {
  final String category;
  final String description;
  final int discountRate;

  CategoryBenefit.fromJson(Map<String, dynamic> json)
      : category = json['category'],
        description = json['description'],
        discountRate = json['discount_rate'];
}
```

---

## 필요한 DB 테이블 (참고)

### 카드 정보 테이블 (cards)

```sql
CREATE TABLE cards (
  card_id INT PRIMARY KEY AUTO_INCREMENT,
  card_name VARCHAR(100) NOT NULL,
  card_company VARCHAR(50) NOT NULL,
  card_image_url VARCHAR(500),
  annual_fee INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### 카드 혜택 테이블 (card_benefits)

```sql
CREATE TABLE card_benefits (
  benefit_id INT PRIMARY KEY AUTO_INCREMENT,
  card_id INT NOT NULL,
  category VARCHAR(50) NOT NULL,        -- 혜택 적용 카테고리
  description VARCHAR(200) NOT NULL,    -- 혜택 설명
  discount_rate DECIMAL(5,2) NOT NULL,  -- 할인율 (%)
  max_discount INT,                     -- 월 최대 할인 한도 (원, nullable)
  min_spend INT,                        -- 전월 실적 조건 (원, nullable)
  FOREIGN KEY (card_id) REFERENCES cards(card_id)
);
```

### 카드-카테고리 매핑

기존 거래 카테고리와 카드 혜택 카테고리 매핑:

| 거래 카테고리   | 카드 혜택 카테고리 |
| --------------- | ------------------ |
| 식비            | 외식, 배달         |
| 카페/디저트     | 커피, 카페         |
| 대중교통        | 교통               |
| 주유/차량       | 주유, 자동차       |
| 온라인쇼핑      | 쇼핑, 온라인       |
| 대형마트        | 마트, 쇼핑         |
| 통신/공과금     | 통신               |
| 문화/여가       | 문화, 영화         |
| 의료/건강       | 의료, 병원         |
| 교육            | 교육               |

---

## 프론트엔드 연동 계획

### 현재 상태

`card_analysis_page.dart`에서 `_recommendations` 데이터가 **하드코딩**되어 있음.

### 연동 후 변경 사항

1. `CardService`에 `getRecommendations()` 메서드 추가
2. `card_analysis_page.dart`에서 API 호출로 대체
3. 모델 클래스 추가 (`lib/models/card_recommendation.dart`)

### 예상 코드 변경

```dart
// lib/services/card_service.dart
Future<CardRecommendationResponse> getRecommendations() async {
  final data = await _api.get('/api/v1/cards/recommendations');
  return CardRecommendationResponse.fromJson(data);
}
```

---

## 추가 고려 사항

### 1. 카테고리 개수 제한

- 상위 3~5개 카테고리만 추천 (UI 공간 고려)
- 월평균 지출이 10,000원 미만인 카테고리는 제외 가능

### 2. 추천 카드 개수 제한

- 카테고리당 최대 4개 카드 추천
- ROI 기준 내림차순 정렬

### 3. 캐싱

- 추천 결과는 자주 변경되지 않으므로 1일 캐싱 권장
- `generated_at` 필드로 캐시 유효성 확인

### 4. 성능

- 3개월 거래 내역 조회 + 카드 혜택 조회 + ROI 계산
- 예상 응답 시간: 500ms ~ 1초
- 필요시 비동기 처리 또는 배치 계산 고려

### 5. 향후 확장

- 사용자 맞춤 필터 (연회비 상한, 특정 카드사 선호 등)
- 현재 보유 카드와의 중복 제외 옵션
- 실적 조건 충족 여부 계산

---

## 우선순위 및 일정 제안

| 단계 | 작업 내용 | 우선순위 |
| ---- | --------- | -------- |
| 1    | 카드 정보 DB 테이블 설계 및 생성 | 높음 |
| 2    | 카드 혜택 DB 테이블 설계 및 생성 | 높음 |
| 3    | 샘플 카드 데이터 시딩 (10~20개) | 높음 |
| 4    | 추천 API 엔드포인트 구현 | 높음 |
| 5    | ROI 계산 로직 구현 | 높음 |
| 6    | 프론트엔드 연동 | 중간 |
| 7    | 캐싱 및 성능 최적화 | 낮음 |

---

**문의사항이 있으면 프론트엔드 팀에 연락해주세요.**

**최종 업데이트**: 2026-01-29
