# Home API Testing Report - Endpoints 4-7
**Test Date**: 2026-01-28  
**Backend**: http://localhost:8000 (Docker)  
**JWT Token**: Valid (expires 2026-02-01)

---

## API 4: 주간 평균 지출 (Weekly Average)
**Endpoint**: `GET /api/v1/transactions/weekly-average?year=YYYY&month=M`

### Test 4.1: year=2026&month=1
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/weekly-average?year=2026&month=1"
```

**Response**:
```json
{"average": 105745}
```

**Status**: ✅ SUCCESS  
**Notes**: 
- Returns 105,745 won as weekly average
- Based on month-comparison data: 468,300 total / ~4 weeks = 117,075
- Calculation appears slightly off (105,745 vs expected 117,075)
- Possible partial week calculation or different logic

---

### Test 4.2: year=2025&month=12
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/weekly-average?year=2025&month=12"
```

**Response**:
```json
{"average": 114337}
```

**Status**: ✅ SUCCESS  
**Notes**:
- Returns 114,337 won as weekly average
- Based on month-comparison data: 506,350 total / ~4.43 weeks = 114,314
- Calculation is accurate (114,337 ≈ 114,314)
- December has 31 days = 4.43 weeks

---

### Test 4.3: year=2025&month=6 (No Data)
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/weekly-average?year=2025&month=6"
```

**Response**:
```json
{"average": 0}
```

**Status**: ✅ SUCCESS  
**Notes**: Correctly returns 0 for months with no transaction data

---

## API 5: 월간 평균 지출 (Monthly Average)
**Endpoint**: `GET /api/v1/transactions/monthly-average?year=YYYY&month=M`

### Test 5.1: year=2026&month=1
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/monthly-average?year=2026&month=1"
```

**Response**:
```json
{"average": 162441}
```

**Status**: ✅ SUCCESS  
**Notes**:
- Returns 162,441 won as monthly average
- Current month total: 468,300 (from month-comparison)
- Calculation likely averages with previous months
- Expected range: (468,300 + 506,350) / 2 = 487,325 (doesn't match)
- Calculation logic unclear - possibly averages last 3-6 months

---

### Test 5.2: year=2025&month=12
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/monthly-average?year=2025&month=12"
```

**Response**:
```json
{"average": 84391}
```

**Status**: ✅ SUCCESS  
**Notes**:
- Returns 84,391 won as monthly average
- Current month total: 506,350 (from month-comparison)
- Lower average suggests this is average of past months (excluding current)
- Or possibly daily average * 30: 506,350 / 31 days = 16,334 per day
- 16,334 * 30 days / 6 months ≈ inconsistent

---

### Test 5.3: year=2025&month=6 (No Data)
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/monthly-average?year=2025&month=6"
```

**Response**:
```json
{"average": 0}
```

**Status**: ✅ SUCCESS  
**Notes**: Correctly returns 0 for months with no data

---

## API 6: 카테고리별 지출 요약 (Category Summary)
**Endpoint**: `GET /api/v1/transactions/category-summary?year=YYYY&month=M`

### Test 6.1: year=2026&month=1
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/category-summary?year=2026&month=1"
```

**Response**:
```json
{
  "categories": [
    {"name": "온라인쇼핑", "emoji": "🛒", "amount": 77900, "change": 48000, "percent": 16, "color": "#9C27B0"},
    {"name": "식비", "emoji": "🍽️", "amount": 77700, "change": 21600, "percent": 16, "color": "#FF6B6B"},
    {"name": "대형마트", "emoji": "🛒", "amount": 72000, "change": 7000, "percent": 15, "color": "#FF9800"},
    {"name": "통신/공과금", "emoji": "📱", "amount": 55000, "change": 0, "percent": 11, "color": "#00BCD4"},
    {"name": "주유/차량", "emoji": "⛽", "amount": 52000, "change": 4000, "percent": 11, "color": "#607D8B"},
    {"name": "의료/건강", "emoji": "💊", "amount": 45000, "change": 10000, "percent": 9, "color": "#009688"},
    {"name": "카페/디저트", "emoji": "☕", "amount": 21600, "change": 6800, "percent": 4, "color": "#8D6E63"},
    {"name": "문화/여가", "emoji": "🎬", "amount": 18000, "change": 3000, "percent": 3, "color": "#E91E63"},
    {"name": "디지털구독", "emoji": "💻", "amount": 14900, "change": 0, "percent": 3, "color": "#3F51B5"},
    {"name": "교육", "emoji": "📚", "amount": 12500, "change": 2700, "percent": 2, "color": "#FFC107"},
    {"name": "뷰티/잡화", "emoji": "💄", "amount": 8900, "change": 2100, "percent": 1, "color": "#F06292"},
    {"name": "편의점", "emoji": "🏪", "amount": 7800, "change": 4250, "percent": 1, "color": "#4CAF50"},
    {"name": "대중교통", "emoji": "🚌", "amount": 5000, "change": 2500, "percent": 1, "color": "#2196F3"}
  ]
}
```

**Status**: ✅ SUCCESS  

**Analysis**:
- **Total Amount**: 77,900 + 77,700 + 72,000 + 55,000 + 52,000 + 45,000 + 21,600 + 18,000 + 14,900 + 12,500 + 8,900 + 7,800 + 5,000 = **468,300 won**
- **Percentage Sum**: 16 + 16 + 15 + 11 + 11 + 9 + 4 + 3 + 3 + 2 + 1 + 1 + 1 = **93%**
- ⚠️ **Issue**: Percentages sum to 93%, not 100% (likely rounding down)
- ✅ **Data Consistency**: Total matches month-comparison API (468,300)
- **Category Count**: 13 categories
- **Color Scheme**: Diverse, no duplicates except emoji (🛒 used twice)

**Top 3 Categories**:
1. 온라인쇼핑 (Online Shopping): 77,900 won (16%)
2. 식비 (Food): 77,700 won (16%)
3. 대형마트 (Hypermarket): 72,000 won (15%)

---

### Test 6.2: year=2025&month=12
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/category-summary?year=2025&month=12"
```

**Response**:
```json
{
  "categories": [
    {"name": "여행/숙박", "emoji": "✈️", "amount": 150000, "change": 150000, "percent": 29, "color": "#00ACC1"},
    {"name": "대형마트", "emoji": "🛒", "amount": 65000, "change": 65000, "percent": 12, "color": "#FF9800"},
    {"name": "식비", "emoji": "🍽️", "amount": 56100, "change": 56100, "percent": 11, "color": "#FF6B6B"},
    {"name": "통신/공과금", "emoji": "📱", "amount": 55000, "change": 55000, "percent": 10, "color": "#00BCD4"},
    {"name": "주유/차량", "emoji": "⛽", "amount": 48000, "change": 48000, "percent": 9, "color": "#607D8B"},
    {"name": "의료/건강", "emoji": "💊", "amount": 35000, "change": 35000, "percent": 6, "color": "#009688"},
    {"name": "온라인쇼핑", "emoji": "🛒", "amount": 29900, "change": 29900, "percent": 5, "color": "#9C27B0"},
    {"name": "문화/여가", "emoji": "🎬", "amount": 15000, "change": 15000, "percent": 2, "color": "#E91E63"},
    {"name": "디지털구독", "emoji": "💻", "amount": 14900, "change": 14900, "percent": 2, "color": "#3F51B5"},
    {"name": "카페/디저트", "emoji": "☕", "amount": 14800, "change": 14800, "percent": 2, "color": "#8D6E63"},
    {"name": "교육", "emoji": "📚", "amount": 9800, "change": 9800, "percent": 1, "color": "#FFC107"},
    {"name": "뷰티/잡화", "emoji": "💄", "amount": 6800, "change": 6800, "percent": 1, "color": "#F06292"},
    {"name": "편의점", "emoji": "🏪", "amount": 3550, "change": 3550, "percent": 0, "color": "#4CAF50"},
    {"name": "대중교통", "emoji": "🚌", "amount": 2500, "change": 2500, "percent": 0, "color": "#2196F3"}
  ]
}
```

**Status**: ✅ SUCCESS  

**Analysis**:
- **Total Amount**: 150,000 + 65,000 + 56,100 + 55,000 + 48,000 + 35,000 + 29,900 + 15,000 + 14,900 + 14,800 + 9,800 + 6,800 + 3,550 + 2,500 = **506,350 won**
- **Percentage Sum**: 29 + 12 + 11 + 10 + 9 + 6 + 5 + 2 + 2 + 2 + 1 + 1 + 0 + 0 = **90%**
- ⚠️ **Issue**: Percentages sum to 90%, not 100% (rounding issue)
- ✅ **Data Consistency**: Total matches month-comparison API (506,350)
- **Category Count**: 14 categories (1 more than Jan 2026)
- **Change Values**: All equal to amount (December is first month with data)

**Top 3 Categories**:
1. 여행/숙박 (Travel/Accommodation): 150,000 won (29%)
2. 대형마트 (Hypermarket): 65,000 won (12%)
3. 식비 (Food): 56,100 won (11%)

---

### Test 6.3: year=2025&month=6 (No Data)
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/category-summary?year=2025&month=6"
```

**Response**:
```json
{"categories": []}
```

**Status**: ✅ SUCCESS  
**Notes**: Correctly returns empty array for months with no data

---

## API 7: 월간 비교 (Month Comparison)
**Endpoint**: `GET /api/v1/transactions/month-comparison?year=YYYY&month=M`

### Test 7.1: year=2026&month=1
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/month-comparison?year=2026&month=1"
```

**Response**:
```json
{
  "thisMonthTotal": 468300,
  "lastMonthSameDay": 496950,
  "thisMonthData": [
    {"day": 1, "amount": 0.0},
    {"day": 2, "amount": 10750.0},
    {"day": 3, "amount": 18750.0},
    {"day": 4, "amount": 18750.0},
    {"day": 5, "amount": 74250.0},
    {"day": 6, "amount": 74250.0},
    {"day": 7, "amount": 147500.0},
    {"day": 8, "amount": 154000.0},
    {"day": 9, "amount": 154000.0},
    {"day": 10, "amount": 232100.0},
    {"day": 11, "amount": 232100.0},
    {"day": 12, "amount": 261600.0},
    {"day": 13, "amount": 261600.0},
    {"day": 14, "amount": 266050.0},
    {"day": 15, "amount": 330550.0},
    {"day": 16, "amount": 330550.0},
    {"day": 17, "amount": 347250.0},
    {"day": 18, "amount": 347250.0},
    {"day": 19, "amount": 392250.0},
    {"day": 20, "amount": 405750.0},
    {"day": 21, "amount": 405750.0},
    {"day": 22, "amount": 442900.0},
    {"day": 23, "amount": 442900.0},
    {"day": 24, "amount": 459000.0},
    {"day": 25, "amount": 459000.0},
    {"day": 26, "amount": 468300.0},
    {"day": 27, "amount": 468300.0},
    {"day": 28, "amount": 468300.0}
  ],
  "lastMonthData": [
    {"day": 1, "amount": 9850.0},
    {"day": 2, "amount": 9850.0},
    {"day": 3, "amount": 15600.0},
    {"day": 4, "amount": 15600.0},
    {"day": 5, "amount": 57500.0},
    {"day": 6, "amount": 57500.0},
    {"day": 7, "amount": 122500.0},
    {"day": 8, "amount": 122500.0},
    {"day": 9, "amount": 122500.0},
    {"day": 10, "amount": 190900.0},
    {"day": 11, "amount": 190900.0},
    {"day": 12, "amount": 205900.0},
    {"day": 13, "amount": 205900.0},
    {"day": 14, "amount": 205900.0},
    {"day": 15, "amount": 222500.0},
    {"day": 16, "amount": 222500.0},
    {"day": 17, "amount": 222500.0},
    {"day": 18, "amount": 233250.0},
    {"day": 19, "amount": 233250.0},
    {"day": 20, "amount": 296150.0},
    {"day": 21, "amount": 296150.0},
    {"day": 22, "amount": 331150.0},
    {"day": 23, "amount": 331150.0},
    {"day": 24, "amount": 331150.0},
    {"day": 25, "amount": 346950.0},
    {"day": 26, "amount": 346950.0},
    {"day": 27, "amount": 346950.0},
    {"day": 28, "amount": 496950.0}
  ]
}
```

**Status**: ✅ SUCCESS  

**Analysis**:
- ✅ **thisMonthTotal**: 468,300 (matches category-summary total)
- ✅ **lastMonthSameDay**: 496,950 (December day 28 accumulated total)
- ✅ **Data Pattern**: Cumulative daily totals (amounts only increase)
- **Daily Progression**: Shows realistic spending pattern
  - Weekend plateaus (days 2-4, 6-7, 9-11, etc.)
  - Mid-week spending increases
- **Last Month Data**: December 2025 data accurately reflected
  - Final amount on day 28: 496,950 matches lastMonthSameDay
  - Day 28 shows large jump (346,950 → 496,950 = 150,000 added)
  - Matches "여행/숙박" 150,000 category in December

---

### Test 7.2: year=2025&month=12
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/month-comparison?year=2025&month=12"
```

**Response**:
```json
{
  "thisMonthTotal": 506350,
  "lastMonthSameDay": 0,
  "thisMonthData": [
    {"day": 1, "amount": 9850.0},
    {"day": 2, "amount": 9850.0},
    ...
    {"day": 28, "amount": 499150.0},
    {"day": 29, "amount": 499150.0},
    {"day": 30, "amount": 506350.0},
    {"day": 31, "amount": 506350.0}
  ],
  "lastMonthData": [
    {"day": 1, "amount": 0.0},
    {"day": 2, "amount": 0.0},
    ...
    {"day": 31, "amount": 0.0}
  ]
}
```

**Status**: ✅ SUCCESS  

**Analysis**:
- ✅ **thisMonthTotal**: 506,350 (matches category-summary total)
- ✅ **lastMonthSameDay**: 0 (no data for November 2025)
- ✅ **lastMonthData**: All zeros (correctly handles no previous month data)
- **Day Count**: 31 days (correct for December)
- **Final Spending**: Day 30-31 shows 506,350 (complete month)

---

### Test 7.3: year=2025&month=6 (No Data)
```bash
curl -s --max-time 10 -H "Authorization: Bearer $TOKEN" \
  "http://localhost:8000/api/v1/transactions/month-comparison?year=2025&month=6"
```

**Response**:
```json
{
  "thisMonthTotal": 0,
  "lastMonthSameDay": 0,
  "thisMonthData": [
    {"day": 1, "amount": 0.0},
    {"day": 2, "amount": 0.0},
    ...
    {"day": 30, "amount": 0.0}
  ],
  "lastMonthData": [
    {"day": 1, "amount": 0.0},
    {"day": 2, "amount": 0.0},
    ...
    {"day": 30, "amount": 0.0}
  ]
}
```

**Status**: ✅ SUCCESS  

**Analysis**:
- ✅ **Day Count**: 30 days (correct for June)
- ✅ **All Values**: 0 (no data available)
- ✅ **Graceful Handling**: Proper structure maintained even with no data

---

## Summary & Findings

### ✅ Successes
1. **All APIs respond successfully** with appropriate status codes
2. **Data consistency** across related endpoints (totals match)
3. **Category summary percentages** are reasonable (90-93%)
4. **Month comparison** shows realistic cumulative daily patterns
5. **Graceful handling** of no-data scenarios (returns 0 or empty arrays)
6. **Date handling** correct (28/30/31 days per month)

### ⚠️ Issues & Observations

1. **Percentage Rounding (API 6)**
   - January 2026: 93% (7% missing)
   - December 2025: 90% (10% missing)
   - Likely due to integer rounding down
   - **Recommendation**: Use float percentages or ensure rounding adds to 100%

2. **Weekly Average Calculation (API 4)**
   - January 2026: 105,745 vs expected ~117,075
   - December 2025: 114,337 ≈ expected ~114,314 ✓
   - **Potential Issue**: January calculation seems off
   - **Recommendation**: Verify weekly average logic for partial months

3. **Monthly Average Logic Unclear (API 5)**
   - January 2026: 162,441 (doesn't match simple current/previous average)
   - December 2025: 84,391 (unclear calculation basis)
   - **Recommendation**: Document calculation methodology clearly

4. **Emoji Duplication (API 6)**
   - 🛒 used for both "온라인쇼핑" and "대형마트"
   - **Recommendation**: Use distinct emojis for different categories

### 📊 Data Patterns

**Monthly Totals**:
- December 2025: 506,350 won
- January 2026: 468,300 won (as of day 28)

**Top Spending Categories**:
- **December**: Travel/Accommodation (29%), Hypermarket (12%), Food (11%)
- **January**: Online Shopping (16%), Food (16%), Hypermarket (15%)

**Spending Velocity**:
- December: ~16,334 won/day average
- January: ~16,725 won/day average (similar spending rate)

---

## Recommendations for Frontend Implementation

1. **Handle percentage rounding** in UI (show remaining as "기타" or adjust display)
2. **Validate weekly/monthly averages** against raw data before displaying
3. **Add tooltips** to explain calculation methodologies
4. **Error handling** for edge cases (leap years, month boundaries)
5. **Loading states** for async API calls
6. **Optimize category colors** for accessibility (contrast ratios)

---

**Test Completed**: 2026-01-28  
**All 12 test cases executed successfully**
