import 'package:my_app/config/api_config.dart';
import 'package:my_app/models/subscription.dart';
import 'package:my_app/services/api_client.dart';

class SubscriptionService {
  final ApiClient _api = ApiClient();

  Future<List<MySubscriptionInfo>> getSubscriptions() async {
    final data = await _api.get(ApiConfig.subscriptions);
    final result = (data['result'] as List?) ?? [];
    return result.map((item) => MySubscriptionInfo.fromJson(item)).toList();
  }
}
