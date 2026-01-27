import 'dart:ui';

/// 1. 월별 누적 데이터
class AccumulatedData {
  final int total;
  final List<DailyAccumulated> dailyData;

  AccumulatedData({required this.total, required this.dailyData});

  factory AccumulatedData.fromJson(Map<String, dynamic> json) {
    return AccumulatedData(
      total: (json['total'] as num).toInt(),
      dailyData: (json['dailyData'] as List)
          .map((e) => DailyAccumulated.fromJson(e))
          .toList(),
    );
  }
}

/// 2. 일별 누적 항목 (accumulated, month-comparison에서 공유)
class DailyAccumulated {
  final int day;
  final double amount; // API returns float

  DailyAccumulated({required this.day, required this.amount});

  factory DailyAccumulated.fromJson(Map<String, dynamic> json) {
    return DailyAccumulated(
      day: (json['day'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

/// 3. 일별 지출 요약 (캘린더용, 키가 문자열)
class DailySummary {
  final Map<int, int> expenses;

  DailySummary({required this.expenses});

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    final raw = json['expenses'] as Map<String, dynamic>;
    return DailySummary(
      expenses: raw.map((key, value) =>
          MapEntry(int.parse(key), (value as num).toInt())),
    );
  }
}

/// 4. 일별 거래 상세
class DailyDetail {
  final List<TransactionItem> transactions;

  DailyDetail({required this.transactions});

  factory DailyDetail.fromJson(Map<String, dynamic> json) {
    return DailyDetail(
      transactions: (json['transactions'] as List)
          .map((e) => TransactionItem.fromJson(e))
          .toList(),
    );
  }
}

/// 5. 개별 거래 항목
class TransactionItem {
  final String name;
  final String category;
  final int amount;
  final String currency;

  TransactionItem({
    required this.name,
    required this.category,
    required this.amount,
    required this.currency,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      name: json['name'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toInt(),
      currency: json['currency'] as String? ?? 'KRW',
    );
  }
}

/// 6. 주간 평균
class WeeklyAverage {
  final int average;

  WeeklyAverage({required this.average});

  factory WeeklyAverage.fromJson(Map<String, dynamic> json) {
    return WeeklyAverage(average: (json['average'] as num).toInt());
  }
}

/// 7. 월간 평균
class MonthlyAverage {
  final int average;

  MonthlyAverage({required this.average});

  factory MonthlyAverage.fromJson(Map<String, dynamic> json) {
    return MonthlyAverage(average: (json['average'] as num).toInt());
  }
}

/// 8. 카테고리별 지출 항목
class CategorySummaryItem {
  final String name;
  final String emoji;
  final int amount;
  final int change;
  final int percent;
  final String color; // hex string like "#FF6B6B"

  CategorySummaryItem({
    required this.name,
    required this.emoji,
    required this.amount,
    required this.change,
    required this.percent,
    required this.color,
  });

  factory CategorySummaryItem.fromJson(Map<String, dynamic> json) {
    return CategorySummaryItem(
      name: json['name'] as String,
      emoji: json['emoji'] as String,
      amount: (json['amount'] as num).toInt(),
      change: (json['change'] as num).toInt(),
      percent: (json['percent'] as num).toInt(),
      color: json['color'] as String,
    );
  }

  /// Parse hex color string to Flutter Color
  Color get colorValue {
    final hex = color.replaceFirst('#', '');
    return Color(int.parse(hex, radix: 16) + 0xFF000000);
  }
}

/// 9. 카테고리별 거래 상세
class CategoryDetail {
  final String categoryName;
  final String emoji;
  final String color;
  final int totalAmount;
  final int transactionCount;
  final List<CategoryTransaction> transactions;

  CategoryDetail({
    required this.categoryName,
    required this.emoji,
    required this.color,
    required this.totalAmount,
    required this.transactionCount,
    required this.transactions,
  });

  factory CategoryDetail.fromJson(Map<String, dynamic> json) {
    return CategoryDetail(
      categoryName: json['category_name'] as String,
      emoji: json['emoji'] as String,
      color: json['color'] as String,
      totalAmount: (json['total_amount'] as num).toInt(),
      transactionCount: (json['transaction_count'] as num).toInt(),
      transactions: (json['transactions'] as List)
          .map((e) => CategoryTransaction.fromJson(e))
          .toList(),
    );
  }
}

/// 10. 카테고리 개별 거래
class CategoryTransaction {
  final int expenseId;
  final String merchantName;
  final int amount;
  final DateTime spentAt;
  final String cardName;

  CategoryTransaction({
    required this.expenseId,
    required this.merchantName,
    required this.amount,
    required this.spentAt,
    required this.cardName,
  });

  factory CategoryTransaction.fromJson(Map<String, dynamic> json) {
    return CategoryTransaction(
      expenseId: (json['expense_id'] as num).toInt(),
      merchantName: json['merchant_name'] as String,
      amount: (json['amount'] as num).toInt(),
      spentAt: DateTime.parse(json['spent_at'] as String),
      cardName: json['card_name'] as String,
    );
  }
}

/// 11. 월간 비교
class MonthComparison {
  final int thisMonthTotal;
  final int lastMonthSameDay;
  final List<DailyAccumulated> thisMonthData;
  final List<DailyAccumulated> lastMonthData;

  MonthComparison({
    required this.thisMonthTotal,
    required this.lastMonthSameDay,
    required this.thisMonthData,
    required this.lastMonthData,
  });

  factory MonthComparison.fromJson(Map<String, dynamic> json) {
    return MonthComparison(
      thisMonthTotal: (json['thisMonthTotal'] as num).toInt(),
      lastMonthSameDay: (json['lastMonthSameDay'] as num).toInt(),
      thisMonthData: (json['thisMonthData'] as List)
          .map((e) => DailyAccumulated.fromJson(e))
          .toList(),
      lastMonthData: (json['lastMonthData'] as List)
          .map((e) => DailyAccumulated.fromJson(e))
          .toList(),
    );
  }
}
