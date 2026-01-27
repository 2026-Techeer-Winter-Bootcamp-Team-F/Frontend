import 'package:my_app/config/api_config.dart';
import 'package:my_app/services/api_client.dart';

class CodefService {
  final ApiClient _api = ApiClient();

  /// Connected ID 생성 - ID/PW 방식 (login_type=1)
  Future<Map<String, dynamic>> createConnectedId({
    required String organization,
    required String cardId,
    required String password,
  }) async {
    final data = await _api.post(
      ApiConfig.codefConnectedIdCreate,
      body: {
        'organization': organization,
        'login_type': '1',
        'card_id': cardId,
        'password': password,
      },
    );
    return data;
  }

  /// Connected ID 생성 - 간편인증 방식 (login_type=5)
  Future<Map<String, dynamic>> createConnectedIdSimpleAuth({
    required String organization,
    required String telecom,
  }) async {
    final data = await _api.post(
      ApiConfig.codefConnectedIdCreate,
      body: {
        'organization': organization,
        'login_type': '5',
        'telecom': telecom,
      },
    );
    return data;
  }

  /// 보유 카드 목록 조회
  Future<Map<String, dynamic>> getCardList({
    required String organization,
    required String connectedId,
    String inquiryType = '0',
  }) async {
    final data = await _api.post(
      ApiConfig.codefCardList,
      body: {
        'organization': organization,
        'connected_id': connectedId,
        'inquiry_type': inquiryType,
      },
    );
    return data;
  }

  /// 카드 청구 내역 조회
  Future<Map<String, dynamic>> getCardBilling({
    required String organization,
    required String connectedId,
    String inquiryType = '0',
  }) async {
    final data = await _api.post(
      ApiConfig.codefCardBilling,
      body: {
        'organization': organization,
        'connected_id': connectedId,
        'inquiry_type': inquiryType,
      },
    );
    return data;
  }

  /// 카드 승인 내역 조회
  Future<Map<String, dynamic>> getCardApproval({
    required String organization,
    required String connectedId,
    required String startDate,
    required String endDate,
    String? cardNo,
    String? cardPassword,
  }) async {
    final body = <String, dynamic>{
      'organization': organization,
      'connected_id': connectedId,
      'start_date': startDate,
      'end_date': endDate,
    };
    if (cardNo != null) body['card_no'] = cardNo;
    if (cardPassword != null) body['card_password'] = cardPassword;

    final data = await _api.post(
      ApiConfig.codefCardApproval,
      body: body,
    );
    return data;
  }
}
