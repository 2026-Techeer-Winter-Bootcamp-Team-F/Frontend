enum SubscriptionStatus { active, canceled }

class Subscription {
  final int id;
  final String name;
  final int amount;
  final String cycle;
  final SubscriptionStatus status;
  final double? utilityScore;
  final String? category;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.status,
    this.utilityScore,
    this.category,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      cycle: json['cycle'],
      status: json['status'] == 'active'
          ? SubscriptionStatus.active
          : SubscriptionStatus.canceled,
      utilityScore: json['utility_score']?.toDouble(),
      category: json['category'],
    );
  }

  bool get isLowUtility => utilityScore != null && utilityScore! < 3.0;
}

class MySubscriptionInfo {
  final int subsId;
  final String serviceName;
  final int monthlyFee;
  final String nextBilling;
  final int dDay;
  final String status;
  final String statusKor;
  final String categoryName;

  MySubscriptionInfo({
    required this.subsId,
    required this.serviceName,
    required this.monthlyFee,
    required this.nextBilling,
    required this.dDay,
    required this.status,
    required this.statusKor,
    required this.categoryName,
  });

  factory MySubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return MySubscriptionInfo(
      subsId: json['subs_id'] ?? 0,
      serviceName: json['service_name'] ?? '',
      monthlyFee: json['monthly_fee'] ?? 0,
      nextBilling: json['next_billing'] ?? '',
      dDay: json['d_day'] ?? 0,
      status: json['status'] ?? '',
      statusKor: json['status_kor'] ?? '',
      categoryName: json['category_name'] ?? '',
    );
  }

  bool get isActive => status.toUpperCase() == 'ACTIVE';
}
