class CardRecommendationResponse {
  final String generatedAt;
  final AnalysisPeriod analysisPeriod;
  final List<CategoryRecommendation> categories;

  CardRecommendationResponse({
    required this.generatedAt,
    required this.analysisPeriod,
    required this.categories,
  });

  factory CardRecommendationResponse.fromJson(Map<String, dynamic> json) {
    return CardRecommendationResponse(
      generatedAt: json['generated_at'] ?? '',
      analysisPeriod: AnalysisPeriod.fromJson(json['analysis_period'] ?? {}),
      categories: (json['categories'] as List?)
              ?.map((c) => CategoryRecommendation.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class AnalysisPeriod {
  final String start;
  final String end;

  AnalysisPeriod({
    required this.start,
    required this.end,
  });

  factory AnalysisPeriod.fromJson(Map<String, dynamic> json) {
    return AnalysisPeriod(
      start: json['start'] ?? '',
      end: json['end'] ?? '',
    );
  }
}

class CategoryRecommendation {
  final String categoryName;
  final String emoji;
  final String color;
  final int monthlyAverage;
  final int totalSpent;
  final List<RecommendedCard> recommendedCards;

  CategoryRecommendation({
    required this.categoryName,
    required this.emoji,
    required this.color,
    required this.monthlyAverage,
    required this.totalSpent,
    required this.recommendedCards,
  });

  factory CategoryRecommendation.fromJson(Map<String, dynamic> json) {
    return CategoryRecommendation(
      categoryName: json['category_name'] ?? '',
      emoji: json['emoji'] ?? '',
      color: json['color'] ?? '#000000',
      monthlyAverage: (json['monthly_average'] ?? 0).toInt(),
      totalSpent: (json['total_spent'] ?? 0).toInt(),
      recommendedCards: (json['recommended_cards'] as List?)
              ?.map((c) => RecommendedCard.fromJson(c))
              .toList() ??
          [],
    );
  }
}

class RecommendedCard {
  final int cardId;
  final String cardName;
  final String cardCompany;
  final String cardImageUrl;
  final int annualFee;
  final int roiPercent;
  final List<CardCategoryBenefit> categoryBenefits;

  RecommendedCard({
    required this.cardId,
    required this.cardName,
    required this.cardCompany,
    required this.cardImageUrl,
    required this.annualFee,
    required this.roiPercent,
    required this.categoryBenefits,
  });

  factory RecommendedCard.fromJson(Map<String, dynamic> json) {
    return RecommendedCard(
      cardId: json['card_id'] ?? 0,
      cardName: json['card_name'] ?? '',
      cardCompany: json['card_company'] ?? '',
      cardImageUrl: json['card_image_url'] ?? '',
      annualFee: (json['annual_fee'] ?? 0).toInt(),
      roiPercent: (json['roi_percent'] ?? 0).toInt(),
      categoryBenefits: (json['category_benefits'] as List?)
              ?.map((b) => CardCategoryBenefit.fromJson(b))
              .toList() ??
          [],
    );
  }

  /// 주요 혜택을 요약 문자열 리스트로 반환
  List<String> get mainBenefitLines {
    if (categoryBenefits.isEmpty) return [];
    // 최대 2줄로 요약
    final lines = <String>[];
    for (var i = 0; i < categoryBenefits.length && lines.length < 2; i++) {
      lines.add(categoryBenefits[i].description);
    }
    return lines;
  }
}

class CardCategoryBenefit {
  final String category;
  final String description;
  final double discountRate;

  CardCategoryBenefit({
    required this.category,
    required this.description,
    required this.discountRate,
  });

  factory CardCategoryBenefit.fromJson(Map<String, dynamic> json) {
    return CardCategoryBenefit(
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      discountRate: (json['discount_rate'] ?? 0).toDouble(),
    );
  }
}
