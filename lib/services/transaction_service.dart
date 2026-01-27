import 'package:my_app/config/api_config.dart';
import 'package:my_app/models/transaction_models.dart';
import 'package:my_app/services/api_client.dart';

class TransactionService {
  final ApiClient _api = ApiClient();

  Map<String, String> _monthParams(int year, int month) => {
        'year': year.toString(),
        'month': month.toString(),
      };

  /// 월별 누적 데이터
  Future<AccumulatedData> getAccumulated(int year, int month) async {
    final data = await _api.get(
      ApiConfig.transactionsAccumulated,
      queryParams: _monthParams(year, month),
    );
    return AccumulatedData.fromJson(data);
  }

  /// 일별 지출 요약
  Future<DailySummary> getDailySummary(int year, int month) async {
    final data = await _api.get(
      ApiConfig.transactionsDailySummary,
      queryParams: _monthParams(year, month),
    );
    return DailySummary.fromJson(data);
  }

  /// 일별 거래 상세
  Future<DailyDetail> getDailyDetail(int year, int month, int day) async {
    final params = _monthParams(year, month);
    params['day'] = day.toString();
    final data = await _api.get(
      ApiConfig.transactionsDailyDetail,
      queryParams: params,
    );
    return DailyDetail.fromJson(data);
  }

  /// 주간 평균 지출
  Future<WeeklyAverage> getWeeklyAverage(int year, int month) async {
    final data = await _api.get(
      ApiConfig.transactionsWeeklyAverage,
      queryParams: _monthParams(year, month),
    );
    return WeeklyAverage.fromJson(data);
  }

  /// 월간 평균 지출
  Future<MonthlyAverage> getMonthlyAverage(int year, int month) async {
    final data = await _api.get(
      ApiConfig.transactionsMonthlyAverage,
      queryParams: _monthParams(year, month),
    );
    return MonthlyAverage.fromJson(data);
  }

  /// 카테고리별 지출 요약
  Future<List<CategorySummaryItem>> getCategorySummary(int year, int month) async {
    final data = await _api.get(
      ApiConfig.transactionsCategorySummary,
      queryParams: _monthParams(year, month),
    );
    return (data['categories'] as List)
        .map((e) => CategorySummaryItem.fromJson(e))
        .toList();
  }

  /// 월간 비교
  Future<MonthComparison> getMonthComparison(int year, int month) async {
    final data = await _api.get(
      ApiConfig.transactionsMonthComparison,
      queryParams: _monthParams(year, month),
    );
    return MonthComparison.fromJson(data);
  }
}
