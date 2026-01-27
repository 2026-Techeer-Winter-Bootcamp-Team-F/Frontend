class User {
  final int userId;
  final String phone;
  final String name;
  final String email;
  final String birthDate;
  final String? ageGroup;
  final bool? gender;
  final String createdAt;
  final List<UserCardInfo> cards;

  User({
    required this.userId,
    required this.phone,
    required this.name,
    required this.email,
    required this.birthDate,
    this.ageGroup,
    this.gender,
    required this.createdAt,
    this.cards = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      phone: json['phone'],
      name: json['name'],
      email: json['email'],
      birthDate: json['birth_date'] ?? '',
      ageGroup: json['age_group'],
      gender: json['gender'],
      createdAt: json['created_at'] ?? '',
      cards: (json['cards'] as List?)
              ?.map((c) => UserCardInfo.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class UserCardInfo {
  final int userCardId;
  final int cardId;
  final String cardName;
  final String company;
  final String cardImageUrl;
  final String cardNumber;
  final String registeredAt;

  UserCardInfo({
    required this.userCardId,
    required this.cardId,
    required this.cardName,
    required this.company,
    required this.cardImageUrl,
    required this.cardNumber,
    required this.registeredAt,
  });

  factory UserCardInfo.fromJson(Map<String, dynamic> json) {
    return UserCardInfo(
      userCardId: json['user_card_id'],
      cardId: json['card_id'],
      cardName: json['card_name'] ?? '',
      company: json['company'] ?? '',
      cardImageUrl: json['card_image_url'] ?? '',
      cardNumber: json['card_number'] ?? '',
      registeredAt: json['registered_at'] ?? '',
    );
  }
}
