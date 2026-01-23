import 'package:flutter/foundation.dart';
import 'package:my_app/models/card.dart';
import 'package:my_app/services/api_service.dart';

class CardProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  List<UserCard> _myCards = [];
  List<CreditCard> _recommendedCards = [];
  Map<String, dynamic>? _benefitAnalysis;
  bool _isLoading = false;
  String? _errorMessage;

  List<UserCard> get myCards => _myCards;
  List<CreditCard> get recommendedCards => _recommendedCards;
  Map<String, dynamic>? get benefitAnalysis => _benefitAnalysis;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 내 카드 목록 조회
  Future<void> fetchMyCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getMyCards();
      _myCards = response.map((json) => UserCard.fromJson(json)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '카드 목록을 불러오는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 추천 카드 목록 조회
  Future<void> fetchRecommendedCards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getRecommendedCards();
      _recommendedCards = response.map((json) => CreditCard.fromJson(json)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '추천 카드를 불러오는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 혜택 분석 조회
  Future<void> fetchBenefitAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _benefitAnalysis = await _api.getBenefitAnalysis();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '혜택 분석을 불러오는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 모든 카드 데이터 로드
  Future<void> loadAll() async {
    await Future.wait([
      fetchMyCards(),
      fetchRecommendedCards(),
      fetchBenefitAnalysis(),
    ]);
  }

  // 총 혜택 계산
  int get totalBenefitReceived {
    return _myCards.fold(0, (sum, card) => sum + card.totalBenefitReceived.toInt());
  }

  // 총 연회비 (월할)
  int get totalMonthlyFee {
    return _myCards.fold(0, (sum, card) => sum + (card.card.annualFee ~/ 12));
  }

  // 순이익
  int get netBenefit => totalBenefitReceived - totalMonthlyFee;

  // 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
