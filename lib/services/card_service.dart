import 'package:my_app/config/api_config.dart';
import 'package:my_app/models/card.dart';
import 'package:my_app/models/card_recommendation.dart';
import 'package:my_app/services/api_client.dart';

class CardService {
  final ApiClient _api = ApiClient();

  Future<List<MyCardInfo>> getMyCards() async {
    final data = await _api.get(ApiConfig.cards);
    final cards = (data['cards'] as List?) ?? [];
    return cards.map((c) => MyCardInfo.fromJson(c)).toList();
  }

  Future<CardRecommendationResponse> getRecommendations() async {
    final data = await _api.get(ApiConfig.cardRecommendations);
    return CardRecommendationResponse.fromJson(data);
  }
}
