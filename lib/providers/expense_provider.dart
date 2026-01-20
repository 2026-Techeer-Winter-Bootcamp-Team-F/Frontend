import 'package:flutter/foundation.dart';
import 'package:my_app/models/expense.dart';
import 'package:my_app/models/subscription.dart';
import 'package:my_app/services/api_service.dart';

class ExpenseProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  Map<String, dynamic>? _analysis;
  List<Expense> _expenses = [];
  List<Subscription> _subscriptions = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedMonth = '';

  Map<String, dynamic>? get analysis => _analysis;
  List<Expense> get expenses => _expenses;
  List<Subscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedMonth => _selectedMonth;

  // 분석 데이터에서 추출하는 편의 getter들
  int get totalSpent => _analysis?['total_spent'] ?? 0;
  int get totalBenefit => _analysis?['total_benefit'] ?? 0;
  Map<String, int> get categorySpending {
    final data = _analysis?['by_category'];
    if (data == null) return {};
    return Map<String, int>.from(data);
  }

  int get peerAverage => _analysis?['peer_average'] ?? 0;
  int get myRank => _analysis?['my_rank'] ?? 0;
  String get ageGroup => _analysis?['age_group'] ?? '';
  String get gender => _analysis?['gender'] ?? '';

  // 현재 월 형식 (YYYY-MM)
  String get currentMonth {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  // 소비 분석 조회
  Future<void> fetchAnalysis({String? month}) async {
    _selectedMonth = month ?? currentMonth;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _analysis = await _api.getExpenseAnalysis(_selectedMonth);
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '소비 분석을 불러오는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 월간 지출 내역 조회
  Future<void> fetchExpenses({String? month}) async {
    _selectedMonth = month ?? currentMonth;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getMonthlyExpenses(_selectedMonth);
      _expenses = response.map((json) => Expense.fromJson(json)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '지출 내역을 불러오는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 구독 목록 조회
  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _api.getSubscriptions();
      _subscriptions = response.map((json) => Subscription.fromJson(json)).toList();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = '구독 목록을 불러오는데 실패했습니다.';
    }

    _isLoading = false;
    notifyListeners();
  }

  // 구독 삭제
  Future<bool> deleteSubscription(int id) async {
    try {
      await _api.deleteSubscription(id);
      _subscriptions.removeWhere((sub) => sub.id == id);
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = '구독 삭제에 실패했습니다.';
      notifyListeners();
      return false;
    }
  }

  // 모든 데이터 로드
  Future<void> loadAll({String? month}) async {
    await Future.wait([
      fetchAnalysis(month: month),
      fetchExpenses(month: month),
      fetchSubscriptions(),
    ]);
  }

  // 카테고리별 상세 (API에서 제공하는 경우)
  Map<String, Map<String, int>> get categoryDetails {
    return Map<String, Map<String, int>>.from(
      _analysis?['category_details'] ?? {},
    );
  }

  // 에러 초기화
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
