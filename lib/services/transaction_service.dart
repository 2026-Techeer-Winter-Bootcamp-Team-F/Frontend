// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/home_data.dart';

class TransactionService {
  // TODO: 실제 백엔드 API 도메인으로 변경 필요
  static const String baseUrl = 'http://localhost:80/api';
  
  // 인증 토큰 (실제로는 secure storage에서 가져와야 함)
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // 1. 누적 데이터 가져오기
  Future<AccumulatedData> getAccumulatedData(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/accumulated?year=$year&month=$month'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return AccumulatedData.fromJson(json.decode(response.body));
    } else {
      throw Exception('누적 데이터 로드 실패: ${response.statusCode}');
    }
  }

  // 2. 일별 요약 데이터 가져오기
  Future<DailySummary> getDailySummary(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/daily-summary?year=$year&month=$month'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return DailySummary.fromJson(json.decode(response.body));
    } else {
      throw Exception('일별 요약 데이터 로드 실패: ${response.statusCode}');
    }
  }

  // 3. 특정 날짜의 상세 거래 내역 가져오기
  Future<List<Transaction>> getDailyTransactions(int year, int month, int day) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/daily-detail?year=$year&month=$month&day=$day'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['transactions'] as List)
          .map((e) => Transaction.fromJson(e))
          .toList();
    } else {
      throw Exception('일별 거래 내역 로드 실패: ${response.statusCode}');
    }
  }

  // 4. 주간 평균 데이터 가져오기
  Future<WeeklyData> getWeeklyAverage(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/weekly-average?year=$year&month=$month'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return WeeklyData.fromJson(json.decode(response.body));
    } else {
      throw Exception('주간 평균 데이터 로드 실패: ${response.statusCode}');
    }
  }

  // 5. 월간 평균 데이터 가져오기
  Future<MonthlyData> getMonthlyAverage(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/monthly-average?year=$year&month=$month'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return MonthlyData.fromJson(json.decode(response.body));
    } else {
      throw Exception('월간 평균 데이터 로드 실패: ${response.statusCode}');
    }
  }

  // 6. 카테고리별 요약 데이터 가져오기
  Future<List<CategoryData>> getCategorySummary(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/category-summary?year=$year&month=$month'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['categories'] as List)
          .map((e) => CategoryData.fromJson(e))
          .toList();
    } else {
      throw Exception('카테고리 요약 데이터 로드 실패: ${response.statusCode}');
    }
  }

  // 7. 지난달 비교 데이터 가져오기
  Future<MonthComparison> getMonthComparison(int year, int month) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/transactions/month-comparison?year=$year&month=$month'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return MonthComparison.fromJson(json.decode(response.body));
    } else {
      throw Exception('월간 비교 데이터 로드 실패: ${response.statusCode}');
    }
  }
}
