import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/analysis/category_detail_page.dart';
import 'package:my_app/models/transaction_models.dart';
import 'package:my_app/services/transaction_service.dart';
import 'package:my_app/utils/api_exception.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // 카드 스택 위젯

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 현재 선택된 월
  DateTime selectedMonth = DateTime.now();
  
  // 상단 스크롤 페이지 인덱스 (누적/일간/주간/월간)
  int topPageIndex = 0;
  
  // 하단 스크롤 페이지 인덱스 (카테고리/지난달 비교)
  int bottomPageIndex = 0;
  final PageController bottomPageController = PageController();
  
  // 도넛 차트 선택된 카테고리 인덱스
  int selectedCategoryIndex = 0;
  
  // 일간 캘린더 관련
  DateTime? selectedDate;
  
  // API 서비스
  final TransactionService _transactionService = TransactionService();

  // 로딩/에러 상태
  bool _isLoading = true;
  String? _error;
  bool _isDailyDetailLoading = false;

  // API 데이터 (로딩 전 null)
  MonthComparison? _monthComparison;
  DailySummary? _dailySummary;
  WeeklyAverage? _weeklyAverageData;
  MonthlyAverage? _monthlyAverageData;
  List<CategorySummaryItem>? _categoryList;
  AccumulatedData? _accumulatedData;
  DailyDetail? _selectedDayDetail;

  // 주간/월간 바 차트용 파생 데이터
  List<MapEntry<String, int>> _weeklyBarData = [];
  List<MapEntry<String, int>> _monthlyBarData = [];

  // 편의 getter (기존 위젯 호환)
  int get thisMonthTotal => _monthComparison?.thisMonthTotal ?? 0;
  int get lastMonthSameDay => _monthComparison?.lastMonthSameDay ?? 0;
  int get weeklyAverage => _weeklyAverageData?.average ?? 0;
  int get monthlyAverage => _monthlyAverageData?.average ?? 0;

  Map<int, int> get dailyExpenses {
    if (_dailySummary == null) return {};
    return _dailySummary!.expenses.map((day, amount) => MapEntry(day, -amount));
  }

  List<double> get thisMonthDailyData {
    if (_monthComparison == null) return [];
    return _monthComparison!.thisMonthData
        .map((d) => d.amount)
        .toList();
  }

  List<double> get lastMonthDailyData {
    if (_monthComparison == null) return [];
    return _monthComparison!.lastMonthData
        .map((d) => d.amount)
        .toList();
  }

  Map<String, Map<String, dynamic>> get categoryData {
    if (_categoryList == null || _categoryList!.isEmpty) return {};
    return {
      for (final cat in _categoryList!)
        cat.name: {
          'amount': cat.amount,
          'change': cat.change,
          'percent': cat.percent,
          'icon': cat.emoji,
          'color': cat.colorValue,
        }
    };
  }

  int get _currentDay {
    final now = DateTime.now();
    if (selectedMonth.year == now.year && selectedMonth.month == now.month) {
      return now.day;
    }
    return DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day;
  }

  String get _prevMonthLabel {
    final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
    return '${prev.month}월';
  }

  List<TransactionItem> _getTransactionsForDate(int day) {
    return _selectedDayDetail?.transactions ?? [];
  }

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      selectedCategoryIndex = 0;
    });

    try {
      final year = selectedMonth.year;
      final month = selectedMonth.month;

      final results = await Future.wait([
        _transactionService.getMonthComparison(year, month),
        _transactionService.getDailySummary(year, month),
        _transactionService.getWeeklyAverage(year, month),
        _transactionService.getMonthlyAverage(year, month),
        _transactionService.getCategorySummary(year, month),
        _transactionService.getAccumulated(year, month),
      ]);

      if (!mounted) return;

      setState(() {
        _monthComparison = results[0] as MonthComparison;
        _dailySummary = results[1] as DailySummary;
        _weeklyAverageData = results[2] as WeeklyAverage;
        _monthlyAverageData = results[3] as MonthlyAverage;
        _categoryList = results[4] as List<CategorySummaryItem>;
        _accumulatedData = results[5] as AccumulatedData;
        _selectedDayDetail = null;
        _isLoading = false;

        _deriveWeeklyBarData();
        _deriveMonthlyBarData();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e is UnauthorizedException
            ? '로그인이 필요합니다'
            : '데이터를 불러올 수 없습니다';
      });
    }
  }

  Future<void> _fetchDailyDetail(int day) async {
    setState(() {
      _isDailyDetailLoading = true;
      _selectedDayDetail = null;
    });

    try {
      final detail = await _transactionService.getDailyDetail(
        selectedMonth.year, selectedMonth.month, day,
      );
      if (!mounted) return;
      setState(() {
        _selectedDayDetail = detail;
        _isDailyDetailLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDailyDetailLoading = false;
      });
    }
  }

  void _deriveWeeklyBarData() {
    if (_dailySummary == null) {
      _weeklyBarData = [];
      return;
    }
    final year = selectedMonth.year;
    final month = selectedMonth.month;
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDay = DateTime(year, month, 1);

    final List<MapEntry<String, int>> bars = [];
    int weekStart = 1;
    // Align to Monday-based weeks
    int firstWeekEnd = 7 - (firstDay.weekday - 1);
    if (firstWeekEnd <= 0) firstWeekEnd += 7;

    int end = firstWeekEnd;
    while (weekStart <= daysInMonth) {
      if (end > daysInMonth) end = daysInMonth;
      int weekTotal = 0;
      for (int d = weekStart; d <= end; d++) {
        weekTotal += _dailySummary!.expenses[d] ?? 0;
      }
      final label = '${month.toString().padLeft(2, '0')}.${weekStart.toString().padLeft(2, '0')}';
      bars.add(MapEntry(label, weekTotal));
      weekStart = end + 1;
      end = weekStart + 6;
    }
    _weeklyBarData = bars;
  }

  void _deriveMonthlyBarData() {
    // Use accumulated totals from current + comparison data
    final List<MapEntry<String, int>> bars = [];

    // Add current month
    final currLabel = '${selectedMonth.year % 100}.${selectedMonth.month.toString().padLeft(2, '0')}';
    bars.add(MapEntry(currLabel, _accumulatedData?.total ?? 0));

    // Add previous month from comparison
    final prev = DateTime(selectedMonth.year, selectedMonth.month - 1);
    final prevLabel = '${prev.year % 100}.${prev.month.toString().padLeft(2, '0')}';
    final lastMonthTotal = _monthComparison?.lastMonthData.isNotEmpty == true
        ? _monthComparison!.lastMonthData.last.amount.toInt()
        : 0;
    bars.insert(0, MapEntry(prevLabel, lastMonthTotal));

    _monthlyBarData = bars;
  }

  IconData _categoryIcon(String category) {
    const map = {
      'food': Icons.restaurant,
      'cafe': Icons.coffee,
      'transport': Icons.directions_bus,
      'shopping': Icons.shopping_bag,
      'money': Icons.phone_android,
      'github': Icons.computer,
    };
    return map[category] ?? Icons.receipt_long;
  }

  Color _categoryColor(String category) {
    const map = {
      'food': Color(0xFFFF6B6B),
      'cafe': Color(0xFF8D6E63),
      'transport': Color(0xFF2196F3),
      'shopping': Color(0xFF4CAF50),
      'money': Color(0xFF00BCD4),
      'github': Color(0xFF3F51B5),
    };
    return map[category] ?? const Color(0xFF757575);
  }

  @override
  void dispose() {
    bottomPageController.dispose();
    super.dispose();
  }

  // (카드 스택은 홈 탭으로 이동됨)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 상단 월 선택 헤더
            _buildMonthHeader(),
            
            // 스크롤 가능한 컨텐츠
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_error!, style: const TextStyle(color: Colors.red)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _fetchAllData,
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            children: [
                              const SizedBox(height: 16),

                              const SizedBox(height: 16),

                              // 상단 섹션 (누적/주간/월간)
                              _buildTopSection(),

                              const SizedBox(height: 32),

                              // 이번달/지난달 비교 탭
                              _buildTabButtons(),

                              const SizedBox(height: 16),

                              // 하단 섹션 (카테고리/지난달 비교)
                              _buildBottomSection(),
                              const SizedBox(height: 80), // 하단 네비게이션 바 공간
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  

  // 상단 월 선택 헤더
  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                );
                selectedDate = null;
              });
              _fetchAllData();
            },
          ),
          Text(
            '${selectedMonth.year % 100}년 ${selectedMonth.month}월',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                );
                selectedDate = null;
              });
              _fetchAllData();
            },
          ),
        ],
      ),
    );
  }

  // 상단 섹션 (누적/일간/주간/월간 탭 전환)
  Widget _buildTopSection() {
    return Column(
      children: [
        // 페이지 인디케이터
        Center(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(100),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIndicator('누적', 0),
                  _buildIndicator('일간', 1),
                  _buildIndicator('주간', 2),
                  _buildIndicator('월간', 3),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 현재 선택된 탭에 해당하는 뷰 표시
        _buildCurrentTopView(),
      ],
    );
  }

  Widget _buildCurrentTopView() {
    switch (topPageIndex) {
      case 0:
        return _buildAccumulatedView();
      case 1:
        return _buildDailyView();
      case 2:
        return _buildWeeklyView();
      case 3:
        return _buildMonthlyView();
      default:
        return _buildAccumulatedView();
    }
  }

  Widget _buildIndicator(String label, int index) {
    final isSelected = topPageIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          topPageIndex = index;
        });
      },
      child: Container(
        height: 47.6,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  // 일간 뷰 (캘린더)
  Widget _buildDailyView() {
    final firstDay = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final lastDay = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday % 7;
    final totalCells = firstWeekday + daysInMonth;
    final rows = (totalCells / 7).ceil();
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 요일 헤더
          Row(
            children: ['일', '월', '화', '수', '목', '금', '토'].map((day) {
              return Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 13,
                      color: day == '일' ? Colors.red : (day == '토' ? Colors.blue : Theme.of(context).colorScheme.onSurfaceVariant),
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          
          const SizedBox(height: 12),
          
          // 날짜 그리드
          ...List.generate(rows, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: List.generate(7, (dayIndex) {
                  final cellIndex = weekIndex * 7 + dayIndex;
                  final dayNumber = cellIndex - firstWeekday + 1;
                  
                  if (cellIndex < firstWeekday || dayNumber > daysInMonth) {
                    return Expanded(child: Container());
                  }
                  
                  final expense = dailyExpenses[dayNumber];
                  final isSelected = selectedDate?.day == dayNumber && 
                                    selectedDate?.month == selectedMonth.month &&
                                    selectedDate?.year == selectedMonth.year;
                  final isToday = DateTime.now().day == dayNumber && 
                                  DateTime.now().month == selectedMonth.month &&
                                  DateTime.now().year == selectedMonth.year;
                  
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final isSameDate = selectedDate?.day == dayNumber && 
                            selectedDate?.month == selectedMonth.month &&
                            selectedDate?.year == selectedMonth.year;
                        
                        if (isSameDate) {
                          setState(() {
                            selectedDate = null;
                          });
                        } else {
                          setState(() {
                            selectedDate = DateTime(selectedMonth.year, selectedMonth.month, dayNumber);
                          });
                          _fetchDailyDetail(dayNumber);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              dayNumber.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? Colors.blue : Theme.of(context).colorScheme.onSurface,
                                fontFamily: 'Pretendard',
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (expense != null && expense < 0)
                              Text(
                                _formatShortCurrency(expense),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
                              )
                            else if (expense != null && expense > 0)
                              Text(
                                '+${_formatShortCurrency(expense)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Pretendard',
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
          
          const SizedBox(height: 20),
          
          // 선택된 날짜의 거래 내역
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: selectedDate != null && 
                selectedDate!.month == selectedMonth.month &&
                selectedDate!.year == selectedMonth.year
              ? _buildDailyTransactions()
              : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // 선택된 날짜의 거래 내역
  Widget _buildDailyTransactions() {
    if (selectedDate == null) return const SizedBox.shrink();

    if (_isDailyDetailLoading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final transactions = _getTransactionsForDate(selectedDate!.day);
    final totalExpense = dailyExpenses[selectedDate!.day] ?? 0;
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayName = weekdays[selectedDate!.weekday - 1];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 날짜 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDate!.day}일 ($weekdayName)',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              _formatCurrencyFull(totalExpense),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: totalExpense < 0 ? Theme.of(context).colorScheme.onSurface : AppColors.primary,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        if (transactions.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                '거래 내역이 없습니다',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontFamily: 'Pretendard',
                ),
              ),
            ),
          )
        else
          ...transactions.asMap().entries.map((entry) {
            final index = entry.key;
            final tx = entry.value;

            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 250 + index * 80),
              tween: Tween<double>(begin: 0, end: 1),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 16 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: _categoryColor(tx.category).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_categoryIcon(tx.category), color: _categoryColor(tx.category), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pretendard',
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tx.category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontFamily: 'Pretendard',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatCurrencyFull(tx.amount),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: 'Pretendard',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  String _formatShortCurrency(int amount) {
    if (amount.abs() >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만';
    }
    return '${(amount / 1000).toStringAsFixed(0)}천';
  }

  // 누적 소비 금액 뷰
  Widget _buildAccumulatedView() {
    final difference = lastMonthSameDay - thisMonthTotal;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 텍스트 정보
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '지난달 같은 기간보다\n'),
                  TextSpan(
                    text: _formatCurrency(difference.abs()),
                    style: TextStyle(
                      color: difference >= 0 ? AppColors.primary : const Color(0xFFFF5252),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  TextSpan(text: difference >= 0 ? ' 덜 썼어요' : ' 더 썼어요'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 차트 영역
          Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: LineChartPainter(
                thisMonthData: thisMonthDailyData,
                lastMonthData: lastMonthDailyData,
                currentDay: _currentDay,
                labelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                selectedMonth: selectedMonth,
                totalDays: DateTime(selectedMonth.year, selectedMonth.month + 1, 0).day,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 월별 데이터
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _buildMonthData('${selectedMonth.month}월 ${_currentDay}일까지', thisMonthTotal, AppColors.primary, isCurrent: true),
                const SizedBox(height: 8),
                _buildMonthData('$_prevMonthLabel ${_currentDay}일까지', lastMonthSameDay, const Color(0xFFB3D9FF), isCurrent: false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthData(String label, int amount, Color color, {required bool isCurrent}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        Text(
          _formatCurrencyFull(amount),
          style: TextStyle(
            fontSize: 16,
            fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            color: Theme.of(context).colorScheme.onSurface,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  // 주간 평균 뷰
  Widget _buildWeeklyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 텍스트 정보
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '일주일 평균\n'),
                  TextSpan(
                    text: _formatCurrency(weeklyAverage),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const TextSpan(text: ' 정도 썼어요'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 차트 영역
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _weeklyBarData.isEmpty
                  ? [const Center(child: Text('데이터 없음'))]
                  : _weeklyBarData.asMap().entries.map((entry) {
                      final rawMax = _weeklyBarData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                      final maxAmount = rawMax > 0 ? rawMax : 1;
                      return _buildBarChart(
                        entry.value.key,
                        entry.value.value,
                        maxAmount > 0 ? maxAmount : 1,
                        isToday: entry.key == _weeklyBarData.length - 1,
                      );
                    }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '지난 4주 평균  ${_formatCurrencyFull(weeklyAverage)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(String label, int amount, int maxAmount, {bool isToday = false}) {
    final height = amount > 0 ? (amount / maxAmount * 120) : 2;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (amount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(amount / 10000).toStringAsFixed(0)}만',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        Container(
          width: 40,
          height: height.toDouble(),
            decoration: BoxDecoration(
            color: isToday ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  // 월간 평균 뷰
  Widget _buildMonthlyView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 텍스트 정보
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '월 평균\n'),
                  TextSpan(
                    text: _formatCurrency(monthlyAverage),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const TextSpan(text: ' 정도 썼어요'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 차트 영역
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _monthlyBarData.isEmpty
                  ? [const Center(child: Text('데이터 없음'))]
                  : _monthlyBarData.asMap().entries.map((entry) {
                      final rawMax = _monthlyBarData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
                      final maxAmount = rawMax > 0 ? rawMax : 1;
                      return _buildMonthlyBar(
                        entry.value.key,
                        entry.value.value,
                        maxAmount > 0 ? maxAmount : 1,
                        isCurrentMonth: entry.key == _monthlyBarData.length - 1,
                      );
                    }).toList(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '지난 4개월 평균  ${_formatCurrencyFull(monthlyAverage)}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBar(String label, int amount, int maxAmount, {bool isCurrentMonth = false}) {
    final height = maxAmount > 0 ? (amount / maxAmount * 120) : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (amount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${(amount / 10000).toStringAsFixed(0)}만',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: isCurrentMonth ? AppColors.primary : Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Pretendard',
          ),
        ),
      ],
    );
  }

  // 이번달/지난달 비교 탭 버튼
  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomTab('이번달', 0),
              _buildBottomTab('지난달 비교', 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomTab(String label, int index) {
    final isSelected = bottomPageIndex == index;
    return GestureDetector(
      onTap: () {
        bottomPageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        height: 47.6,
        constraints: const BoxConstraints(minWidth: 137),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurfaceVariant,
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  // 하단 섹션 (카테고리/지난달 비교)
  Widget _buildBottomSection() {
    return SizedBox(
      height: 700,
      child: PageView(
        controller: bottomPageController,
        onPageChanged: (index) {
          setState(() {
            bottomPageIndex = index;
          });
        },
        children: [
          SingleChildScrollView(child: _buildCategoryView()),
          SingleChildScrollView(child: _buildComparisonView()),
        ],
      ),
    );
  }

  // 소비 카테고리 뷰
  Widget _buildCategoryView() {
    if (categoryData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text('카테고리 데이터 없음')),
      );
    }

    final safeIndex = selectedCategoryIndex < categoryData.length ? selectedCategoryIndex : 0;
    final selectedEntry = categoryData.entries.toList()[safeIndex];

    // 상단 문구는 항상 최대 금액 카테고리로 표시
    final maxAmountCategory = categoryData.entries.reduce((a, b) =>
      (a.value['amount'] as int) > (b.value['amount'] as int) ? a : b
    ).key;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 메시지
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  TextSpan(
                    text: maxAmountCategory,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const TextSpan(text: '에\n가장 많이 썼어요'),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 도넛 차트
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent && pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                          setState(() {
                            final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                            if (touchedIndex >= 0 && touchedIndex < categoryData.length) {
                              selectedCategoryIndex = touchedIndex;
                            }
                          });
                        }
                      },
                    ),
                    sections: categoryData.entries.toList().asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value.value;
                      final isSelected = index == safeIndex;

                      return PieChartSectionData(
                        color: data['color'] as Color,
                        value: (data['percent'] as int).toDouble(),
                        title: '',
                        radius: isSelected ? 35 : 30,
                      );
                    }).toList(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedEntry.value['icon'] as String,
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${selectedEntry.value['percent']}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendard',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        selectedEntry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 카테고리 목록
          ...categoryData.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return _buildCategoryItem(
              data.value['icon'] as String,
              data.key,
              data.value['percent'] as int,
              data.value['amount'] as int,
              data.value['change'] as int,
              data.value['color'] as Color,
              isSelected: index == safeIndex,
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
            );
          }),
          
          const SizedBox(height: 16),
          
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailPage(initialMonth: selectedMonth),
                ),
              );
            },
            child: Text('더보기 >', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    String icon,
    String name,
    int percent,
    int amount,
    int change,
    Color color, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    final isPositive = change > 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha(13) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
                decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: isSelected ? Border.all(color: color, width: 2) : null,
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          fontFamily: 'Pretendard',
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrencyFull(amount),
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isPositive ? '+' : ''}${_formatCurrencyFull(change)}',
                style: TextStyle(
                fontSize: 12,
                color: isPositive ? const Color(0xFFFF5252) : AppColors.primary,
                fontWeight: FontWeight.w500,
                fontFamily: 'Pretendard',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 지난달 비교 뷰
  Widget _buildComparisonView() {
    final topCategoryName = categoryData.isNotEmpty
        ? categoryData.entries.first.key
        : '전체';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 메시지
          Align(
            alignment: Alignment.centerLeft,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '지난달 이맘때 대비\n'),
                  TextSpan(
                    text: '$topCategoryName 지출이 줄었어요',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 카테고리별 막대 그래프 (상위 5개)
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: categoryData.entries.take(5).map((entry) {
                final percent = entry.value['percent'] as int;
                final change = entry.value['change'] as int;
                final lastMonthPercent = percent + (change / 10000).round();

                return Expanded(
                  child: _buildComparisonBar(
                    entry.key,
                    lastMonthPercent,
                    percent,
                    entry.value['color'] as Color,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 상세 정보
          Column(
            children: [
              _buildComparisonDetail('${selectedMonth.month}월 ${_currentDay}일까지', '', _formatCurrencyFull(thisMonthTotal), isThisMonth: true),
              const SizedBox(height: 8),
              _buildComparisonDetail('$_prevMonthLabel ${_currentDay}일까지', '', _formatCurrencyFull(lastMonthSameDay)),
              const SizedBox(height: 8),
              _buildComparisonDetail('증감', '', _formatCurrencyFull(thisMonthTotal - lastMonthSameDay), isChange: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(String label, int lastMonth, int thisMonth, Color color) {
    final maxHeight = 150.0;
    final lastMonthHeight = (lastMonth / 60 * maxHeight).clamp(10.0, maxHeight);
    final thisMonthHeight = (thisMonth / 60 * maxHeight).clamp(10.0, maxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 16,
              height: lastMonthHeight,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 16,
              height: thisMonthHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 28,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonDetail(String label, String percent, String amount, {bool isChange = false, bool isThisMonth = false}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isChange ? Colors.transparent : (isThisMonth ? AppColors.primary : Theme.of(context).colorScheme.outlineVariant),
            shape: BoxShape.circle,
            border: isChange ? Border.all(color: Theme.of(context).colorScheme.outlineVariant, width: 1) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        Text(
          percent,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 100,
          child: Text(
            amount,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isChange && amount.startsWith('-') ? AppColors.primary : Theme.of(context).colorScheme.onSurface,
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  String _formatCurrency(int amount) {
    if (amount.abs() >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만원';
    }
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}원';
  }

  

  String _formatCurrencyFull(int amount) {
    final formatted = amount.abs().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
    return '${amount < 0 ? '-' : ''}$formatted원';
  }
}

// 간단한 라인 차트 페인터
class LineChartPainter extends CustomPainter {
  final List<double> thisMonthData;
  final List<double> lastMonthData;
  final int currentDay;
  final Color labelColor;
  final DateTime selectedMonth;
  final int totalDays;

  LineChartPainter({
    required this.thisMonthData,
    required this.lastMonthData,
    required this.currentDay,
    required this.labelColor,
    required this.selectedMonth,
    required this.totalDays,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (thisMonthData.isEmpty && lastMonthData.isEmpty) return;

    // 최대값 계산 (스케일링을 위해)
    double maxValue = 1.0;
    final allData = [...thisMonthData, ...lastMonthData];
    if (allData.isNotEmpty) {
      final computed = allData.reduce((a, b) => a > b ? a : b);
      if (computed > 0) maxValue = computed;
    }
    final padding = 10.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;

    // 지난달 그래프 그리기 (연한 파란색, 전체 기간)
    _drawMonthLine(
      canvas,
      lastMonthData,
      maxValue,
      chartWidth,
      chartHeight,
      padding,
      const Color(0xFFB3D9FF).withOpacity(0.5),
      const Color(0xFFE3F2FD).withOpacity(0.3),
      lastMonthData.length,
      false,
    );

    // 이번달 그래프 그리기 (파란색, 현재 날짜까지만)
    _drawMonthLine(
      canvas,
      thisMonthData,
      maxValue,
      chartWidth,
      chartHeight,
      padding,
      AppColors.primary,
      AppColors.primary.withOpacity(0.15),
      currentDay,
      true,
    );

    // 날짜 레이블 그리기
    _drawLabels(canvas, size, chartWidth, padding, labelColor);
  }

  void _drawMonthLine(
    Canvas canvas,
    List<double> data,
    double maxValue,
    double chartWidth,
    double chartHeight,
    double padding,
    Color lineColor,
    Color fillColor,
    int dataLength,
    bool isCurrentMonth,
  ) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 3.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          fillColor.withOpacity(0.6),
          fillColor.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, padding, chartWidth, chartHeight));

    final path = Path();
    final fillPath = Path();

    // 데이터 포인트 계산
    final pointsToUse = data.take(dataLength).toList();
    if (pointsToUse.isEmpty) return;

    // x축 간격 계산 (최대 31일 기준)
    final xStep = chartWidth / 31;

    // 첫 번째 포인트
    final firstX = padding;
    final firstY = padding + chartHeight - (pointsToUse[0] / maxValue * chartHeight);

    path.moveTo(firstX, firstY);
    fillPath.moveTo(firstX, padding + chartHeight);
    fillPath.lineTo(firstX, firstY);

    // 나머지 포인트들 - 부드러운 곡선으로 연결
    for (int i = 1; i < pointsToUse.length; i++) {
      final x = padding + (i * xStep);
      final y = padding + chartHeight - (pointsToUse[i] / maxValue * chartHeight);

      if (i == 1) {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        // 베지어 곡선으로 부드럽게 연결
        final prevX = padding + ((i - 1) * xStep);
        final prevY = padding + chartHeight - (pointsToUse[i - 1] / maxValue * chartHeight);
        
        final controlX = (prevX + x) / 2;
        
        path.quadraticBezierTo(controlX, prevY, x, y);
        fillPath.quadraticBezierTo(controlX, prevY, x, y);
      }
    }

    // Fill path 완성
    final lastX = padding + ((pointsToUse.length - 1) * xStep);
    fillPath.lineTo(lastX, padding + chartHeight);
    fillPath.close();

    // 그리기
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // 마지막 점 표시 (이번달 데이터인 경우에만, 네온 글로우 효과 추가)
    if (isCurrentMonth) {
      final lastPointX = padding + ((pointsToUse.length - 1) * xStep);
      final lastPointY = padding + chartHeight - (pointsToUse.last / maxValue * chartHeight);

      // 네온 글로우 효과 (여러 겹의 원으로 구현)
      final glowPaint1 = Paint()
        ..color = AppColors.primary.withOpacity(0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      final glowPaint2 = Paint()
        ..color = AppColors.primary.withOpacity(0.25)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      final glowPaint3 = Paint()
        ..color = AppColors.primary.withOpacity(0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      // 가장 큰 글로우
      canvas.drawCircle(Offset(lastPointX, lastPointY), 12, glowPaint1);
      canvas.drawCircle(Offset(lastPointX, lastPointY), 9, glowPaint2);
      canvas.drawCircle(Offset(lastPointX, lastPointY), 6, glowPaint3);

      // 흰색 테두리
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      // 중심 원
      final circlePaint = Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastPointX, lastPointY), 6, borderPaint);
      canvas.drawCircle(Offset(lastPointX, lastPointY), 4, circlePaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double chartWidth, double padding, Color labelColor) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final labelStyle = TextStyle(
      color: labelColor,
      fontSize: 11,
      fontFamily: 'Pretendard',
    );

    // 날짜 레이블 (1일, 현재 날짜, 말일)
    final labels = [
      {'text': '${selectedMonth.month}.1', 'position': 0.0},
      {'text': '${selectedMonth.month}.${currentDay}', 'position': (currentDay - 1) / (totalDays - 1)},
      {'text': '${selectedMonth.month}.$totalDays', 'position': 1.0},
    ];

    for (final label in labels) {
      textPainter.text = TextSpan(
        text: label['text'] as String,
        style: labelStyle,
      );
      textPainter.layout();

      final x = padding + (chartWidth * (label['position'] as double)) - textPainter.width / 2;
      final y = size.height - 10;

      textPainter.paint(canvas, Offset(x, y));
    }
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.thisMonthData != thisMonthData ||
        oldDelegate.lastMonthData != lastMonthData ||
        oldDelegate.currentDay != currentDay ||
        oldDelegate.labelColor != labelColor ||
        oldDelegate.selectedMonth != selectedMonth ||
        oldDelegate.totalDays != totalDays;
  }
}
