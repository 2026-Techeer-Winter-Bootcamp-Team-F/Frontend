enum SubscriptionStatus { active, canceled }

class Subscription {
  final int id;
  final String name;
  final int amount;
  final String cycle;
  final SubscriptionStatus status;
  final double? utilityScore;
  final String? category;
  final DateTime? nextPaymentDate;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.status,
    this.utilityScore,
    this.category,
    this.nextPaymentDate,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // status 필드 처리
    SubscriptionStatus parseStatus(dynamic value) {
      if (value == null) return SubscriptionStatus.active;
      final str = value.toString().toLowerCase();
      if (str == 'active' || str == 'true' || str == '1') {
        return SubscriptionStatus.active;
      }
      return SubscriptionStatus.canceled;
    }

    return Subscription(
      id: json['id'],
      name: json['name'] ?? json['service_name'] ?? '',
      amount: json['amount'] ?? json['monthly_amount'] ?? json['price'] ?? 0,
      cycle: json['cycle'] ?? json['billing_cycle'] ?? 'monthly',
      status: parseStatus(json['status'] ?? json['is_active']),
      utilityScore: (json['utility_score'] ?? json['score'])?.toDouble(),
      category: json['category'] ?? json['service_category'],
      nextPaymentDate: json['next_payment_date'] != null
          ? DateTime.parse(json['next_payment_date'])
          : json['next_billing_date'] != null
              ? DateTime.parse(json['next_billing_date'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'cycle': cycle,
      'status': status == SubscriptionStatus.active ? 'active' : 'canceled',
      'utility_score': utilityScore,
      'category': category,
      'next_payment_date': nextPaymentDate?.toIso8601String(),
    };
  }

  bool get isLowUtility => utilityScore != null && utilityScore! < 3.0;

  // 월간 비용 계산
  int get monthlyAmount {
    switch (cycle.toLowerCase()) {
      case 'yearly':
      case 'annual':
        return amount ~/ 12;
      case 'weekly':
        return amount * 4;
      default: // monthly
        return amount;
    }
  }
}
