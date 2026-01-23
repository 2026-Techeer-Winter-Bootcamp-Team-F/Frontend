class Expense {
  final int id;
  final String merchant;
  final int amount;
  final String category;
  final DateTime date;
  final int? cardId;
  final double? benefitAmount;

  Expense({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.category,
    required this.date,
    this.cardId,
    this.benefitAmount,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      merchant: json['merchant'] ?? json['merchant_name'] ?? '',
      amount: json['amount'] ?? json['total_amount'] ?? 0,
      category: json['category'] ?? json['category_name'] ?? '',
      date: DateTime.parse(json['date'] ?? json['transaction_date'] ?? json['created_at']),
      cardId: json['card_id'] ?? json['card'],
      benefitAmount: (json['benefit_amount'] ?? json['benefit'])?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchant': merchant,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'card_id': cardId,
      'benefit_amount': benefitAmount,
    };
  }
}

class ExpenseSummary {
  final int totalAmount;
  final Map<String, int> byCategory;
  final Map<String, int> byCard;
  final int totalBenefit;

  ExpenseSummary({
    required this.totalAmount,
    required this.byCategory,
    required this.byCard,
    required this.totalBenefit,
  });

  factory ExpenseSummary.fromJson(Map<String, dynamic> json) {
    return ExpenseSummary(
      totalAmount: json['total_amount'] ?? json['total_spent'] ?? 0,
      byCategory: Map<String, int>.from(json['by_category'] ?? json['category_breakdown'] ?? {}),
      byCard: Map<String, int>.from(json['by_card'] ?? json['card_breakdown'] ?? {}),
      totalBenefit: json['total_benefit'] ?? json['benefit_received'] ?? 0,
    );
  }
}

class CategoryExpense {
  final String category;
  final int amount;
  final double percentage;

  CategoryExpense({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  factory CategoryExpense.fromJson(Map<String, dynamic> json) {
    return CategoryExpense(
      category: json['category'] ?? json['name'] ?? '',
      amount: json['amount'] ?? json['total'] ?? 0,
      percentage: (json['percentage'] ?? json['ratio'] ?? 0).toDouble(),
    );
  }
}
