import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
// 'package:my_app/config/theme.dart'은 현재 이 파일에서 사용되지 않아 제거했습니다.
import 'package:my_app/screens/analysis/category_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  // 카드 스택 위젯

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 현재 선택된 월
  DateTime selectedMonth = DateTime.now();
  
  // 상단 스크롤 페이지 인덱스 (누적/주간/월간)
  int topPageIndex = 0;
  final PageController topPageController = PageController();
  
  // 하단 스크롤 페이지 인덱스 (카테고리/지난달 비교)
  int bottomPageIndex = 0;
  final PageController bottomPageController = PageController();
  
  // 도넛 차트 선택된 카테고리 인덱스
  int selectedCategoryIndex = 0;
  
  // 일간 캘린더 관련
  DateTime? selectedDate;
  
  // 더미 데이터
  final int thisMonthTotal = 646137; // 1월 19일까지
  final int lastMonthSameDay = 1014051; // 12월 19일까지
  final int weeklyAverage = 200000;
  final int monthlyAverage = 880000;
  
  final Map<int, int> _dummyDailyExpenses = {
    1: -118620,
    2: -75745,
    3: -57402,
    4: -53151,
    5: 133100,
    6: -87071,
    7: -25497,
    8: -22500,
    9: -20400,
    10: -37050,
    11: -5900,
    12: -26520,
    13: -13340,
    14: 7907,
    15: -13340,
    16: -14000,
    17: -14000,
    18: -35000,
    19: 183400,
    20: -13123,
    21: 9481,
    22: -11900,
  };
  
  Map<int, int> get dailyExpenses => _dummyDailyExpenses;

  // 일간 거래 더미 데이터 (UI 데모용)
  final Map<int, List<_TransactionItem>> _dummyTransactions = {
    21: [
      _TransactionItem(
        name: '취소 | 기차표 | 토스뱅크 화이트돌핀 해외결제',
        subtitle: '-10 USD',
        amount: -16727,
        icon: Icons.credit_card,
        color: const Color(0xFF1E1E23),
      ),
      _TransactionItem(
        name: '쇼핑내역 → 내 KB국민계좌',
        amount: 9481,
        icon: Icons.shopping_bag,
        color: const Color(0xFF1560FF),
      ),
      _TransactionItem(
        name: '네이버페이 충전 | 토스뱅크 → 네이버페이 머니',
        amount: -10000,
        icon: Icons.account_balance_wallet,
        color: const Color(0xFF1560FF),
      ),
      _TransactionItem(
        name: 'ABLY',
        amount: -11900,
        icon: Icons.local_mall,
        color: const Color(0xFFE91E63),
      ),
    ],
  };

  List<_TransactionItem> _getTransactionsForDate(int day) {
    return _dummyTransactions[day] ?? [];
  }
  
  final Map<String, Map<String, dynamic>> categoryData = {
    '쇼핑': {'amount': 317918, 'change': -235312, 'percent': 49, 'icon': '🛍️', 'color': Color(0xFF1560FF)},
    '이체': {'amount': 142562, 'change': -146449, 'percent': 22, 'icon': '🏦', 'color': Color(0xFF2196F3)},
    '생활': {'amount': 83351, 'change': 37551, 'percent': 13, 'icon': '🏠', 'color': Color(0xFFFF9800)},
    '식비': {'amount': 48812, 'change': -15388, 'percent': 8, 'icon': '🍴', 'color': Color(0xFFFFEB3B)},
    '카페·간식': {'amount': 21000, 'change': 21000, 'percent': 3, 'icon': '☕', 'color': Color(0xFF00BFA5)},
  };
  
  // 일별 누적 데이터 생성 (1월 19일까지)
  List<double> get thisMonthDailyData {
    return [
      0, 15000, 35000, 58000, 85000, 120000, 145000, // 1-7일
      180000, 215000, 245000, 280000, 320000, 365000, 395000, // 8-14일
      435000, 485000, 535000, 580000, 646137, // 15-19일
    ];
  }
  
  // 지난달 일별 누적 데이터 (12월 31일까지)
  List<double> get lastMonthDailyData {
    return [
      0, 25000, 55000, 95000, 145000, 195000, 240000, // 1-7일
      295000, 350000, 410000, 475000, 540000, 610000, 675000, // 8-14일
      735000, 795000, 860000, 920000, 1014051, 1070000, 1125000, // 15-21일
      1180000, 1235000, 1285000, 1340000, 1395000, 1445000, 1495000, // 22-28일
      1545000, 1595000, 1660000, // 29-31일
    ];
  }

  @override
  void dispose() {
    topPageController.dispose();
    bottomPageController.dispose();
    super.dispose();
  }

  // (카드 스택은 홈 탭으로 이동됨)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 월 선택 헤더
            _buildMonthHeader(),
            
            // 스크롤 가능한 컨텐츠
            Expanded(
              child: SingleChildScrollView(
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
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month - 1,
                );
              });
            },
          ),
          Text(
            '${selectedMonth.month}월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              fontFamily: 'Pretendard',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(
                  selectedMonth.year,
                  selectedMonth.month + 1,
                );
              });
            },
          ),
        ],
      ),
    );
  }

  // 상단 섹션 (누적/주간/월간 스크롤)
  Widget _buildTopSection() {
    return Column(
      children: [
        // 페이지 인디케이터
        Center(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(100),
            ),
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
        const SizedBox(height: 16),
        
        // 스크롤 가능한 페이지
        SizedBox(
          height: topPageIndex == 1
              ? null
              : (topPageIndex == 0 ? 360 : 320),
          child: topPageIndex == 1
            ? _buildDailyView()
            : SizedBox(
                height: 320,
                child: PageView(
                  controller: topPageController,
                  onPageChanged: (pageIndex) {
                    setState(() {
                      if (pageIndex == 0) {
                        topPageIndex = 0;
                      } else if (pageIndex == 1) {
                        topPageIndex = 2;
                      } else if (pageIndex == 2) {
                        topPageIndex = 3;
                      }
                    });
                  },
                  children: [
                    _buildAccumulatedView(),
                    _buildWeeklyView(),
                    _buildMonthlyView(),
                  ],
                ),
              ),
        ),
      ],
    );
  }

  Widget _buildIndicator(String label, int index) {
    final isSelected = topPageIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          topPageIndex = index;
        });
        if (index != 1 && topPageController.hasClients) {
          int pageIndex;
          if (index == 0) {
            pageIndex = 0;
          } else if (index == 2) {
            pageIndex = 1;
          } else {
            pageIndex = 2;
          }
          topPageController.animateToPage(
            pageIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        height: 47.6,
        padding: const EdgeInsets.symmetric(horizontal: 34),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF1E1E23) : const Color(0xFFBBBBBB),
            fontFamily: 'Pretendard',
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentTab(String label, int index) {
    final isSelected = topPageIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            topPageIndex = index;
          });
          topPageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1E1E23).withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? const Color(0xFF1E1E23) : const Color(0xFF999999),
              fontFamily: 'Pretendard',
            ),
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
                      color: day == '일' ? Colors.red : (day == '토' ? Colors.blue : Colors.grey[700]),
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
                                color: isToday ? Colors.blue : const Color(0xFF1E1E23),
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
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Pretendard',
              ),
            ),
            Text(
              _formatCurrencyFull(totalExpense),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: totalExpense < 0 ? const Color(0xFF1E1E23) : const Color(0xFF1560FF),
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
                  color: Colors.grey[500],
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
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
                        color: tx.color.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(tx.icon, color: tx.color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tx.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Pretendard',
                              color: Color(0xFF1E1E23),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (tx.subtitle != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              tx.subtitle!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontFamily: 'Pretendard',
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatCurrencyFull(tx.amount),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: tx.amount < 0 ? const Color(0xFF1E1E23) : const Color(0xFF1560FF),
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
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E23),
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '지난달 같은 기간보다\n'),
                  TextSpan(
                    text: _formatCurrency(difference),
                    style: const TextStyle(
                      color: Color(0xFF1560FF),
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Pretendard',
                    ),
                  ),
                  const TextSpan(text: ' 덜 썼어요'),
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
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: CustomPaint(
              size: const Size(double.infinity, 150),
              painter: LineChartPainter(
                thisMonthData: thisMonthDailyData,
                lastMonthData: lastMonthDailyData,
                currentDay: 19, // 1월 19일까지 데이터
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 월별 데이터
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                _buildMonthData('1월 19일까지', thisMonthTotal, const Color(0xFF1560FF), isCurrent: true),
                const SizedBox(height: 8),
                _buildMonthData('12월 19일까지', lastMonthSameDay, const Color(0xFFB3D9FF), isCurrent: false),
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
              color: Colors.grey[700],
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
            color: const Color(0xFF1E1E23),
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
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E23),
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '일주일 평균\n'),
                  TextSpan(
                    text: _formatCurrency(weeklyAverage),
                    style: const TextStyle(
                      color: Color(0xFF1560FF),
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
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildBarChart('28일', 280000, 380000),
                _buildBarChart('01.04', 380000, 380000),
                _buildBarChart('01.11', 260000, 380000),
                _buildBarChart('01.18', 90000, 380000),
                _buildBarChart('0', 0, 380000, isToday: true),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '지난 4주 평균  ${_formatCurrencyFull(weeklyAverage)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
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
                color: Colors.grey[600],
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        Container(
          width: 40,
          height: height.toDouble(),
            decoration: BoxDecoration(
            color: isToday ? const Color(0xFF1560FF) : const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
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
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E23),
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '월 평균\n'),
                  TextSpan(
                    text: _formatCurrency(monthlyAverage),
                    style: const TextStyle(
                      color: Color(0xFF1560FF),
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
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMonthlyBar('25.09', 140000, 1700000),
                _buildMonthlyBar('25.10', 540000, 1700000),
                _buildMonthlyBar('25.11', 1700000, 1700000),
                _buildMonthlyBar('25.12', 1400000, 1700000),
                _buildMonthlyBar('26.01', 660000, 1700000, isCurrentMonth: true),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          Text(
            '지난 4개월 평균  ${_formatCurrencyFull(754776)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Pretendard',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBar(String label, int amount, int maxAmount, {bool isCurrentMonth = false}) {
    final height = (amount / maxAmount * 120);
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
                color: Colors.grey[600],
                fontFamily: 'Pretendard',
              ),
            ),
          ),
        Container(
          width: 40,
          height: height,
          decoration: BoxDecoration(
            color: isCurrentMonth ? const Color(0xFF1560FF) : const Color(0xFFEAF3FF),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
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
            color: const Color(0xFFF5F5F5),
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
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? const Color(0xFF1E1E23) : const Color(0xFFBBBBBB),
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
    final selectedEntry = categoryData.entries.toList()[selectedCategoryIndex];
    
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
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E23),
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  TextSpan(
                    text: maxAmountCategory,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1560FF),
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
                      final isSelected = index == selectedCategoryIndex;
                      
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
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Pretendard',
                        ),
                      ),
                      Text(
                        selectedEntry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
              isSelected: index == selectedCategoryIndex,
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
                  builder: (context) => const CategoryDetailPage(),
                ),
              );
            },
            child: const Text('더보기 >'),
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
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
                      color: Colors.grey[600],
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
                color: isPositive ? const Color(0xFFFF5252) : const Color(0xFF1560FF),
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
    final topCategory = categoryData.entries.first;
    
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
                style: const TextStyle(
                  fontSize: 20,
                  color: Color(0xFF1E1E23),
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Pretendard',
                ),
                children: [
                  const TextSpan(text: '지난달 이맘때 대비\n'),
                  TextSpan(
                    text: '${topCategory.key} 지출이 줄었어요',
                    style: const TextStyle(
                      color: Color(0xFF1560FF),
                      fontFamily: 'Pretendard',
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 카테고리별 막대 그래프
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: categoryData.entries.map((entry) {
                final percent = entry.value['percent'] as int;
                final change = entry.value['change'] as int;
                final lastMonthPercent = percent + (change / 10000).round();
                
                return _buildComparisonBar(
                  entry.key,
                  lastMonthPercent,
                  percent,
                  entry.value['color'] as Color,
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 상세 정보
          Column(
            children: [
              _buildComparisonDetail('1월 19일까지', '49%', _formatCurrencyFull(317918)),
              const SizedBox(height: 8),
              _buildComparisonDetail('12월 19일까지', '55%', _formatCurrencyFull(553230)),
              const SizedBox(height: 8),
              _buildComparisonDetail('증감', '-6%', _formatCurrencyFull(-235312), isChange: true),
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
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 16,
              height: lastMonthHeight,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
          width: 40,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
              fontFamily: 'Pretendard',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonDetail(String label, String percent, String amount, {bool isChange = false}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isChange ? Colors.transparent : (label.contains('1월') ? Color(0xFF1560FF) : Colors.grey),
            shape: BoxShape.circle,
            border: isChange ? Border.all(color: Colors.grey, width: 1) : null,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontFamily: 'Pretendard',
            ),
          ),
        ),
        Text(
          percent,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Pretendard',
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
              color: isChange && amount.startsWith('-') ? const Color(0xFF1560FF) : const Color(0xFF1E1E23),
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

class _TransactionItem {
  final String name;
  final int amount;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const _TransactionItem({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}

// 간단한 라인 차트 페인터
class LineChartPainter extends CustomPainter {
  final List<double> thisMonthData;
  final List<double> lastMonthData;
  final int currentDay;

  LineChartPainter({
    required this.thisMonthData,
    required this.lastMonthData,
    required this.currentDay,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 최대값 계산 (스케일링을 위해)
    final maxValue = lastMonthData.reduce((a, b) => a > b ? a : b);
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
      const Color(0xFF1560FF),
      const Color(0xFF1560FF).withOpacity(0.15),
      currentDay,
      true,
    );

    // 날짜 레이블 그리기
    _drawLabels(canvas, size, chartWidth, padding);
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
        ..color = const Color(0xFF1560FF).withOpacity(0.15)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      final glowPaint2 = Paint()
        ..color = const Color(0xFF1560FF).withOpacity(0.25)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      final glowPaint3 = Paint()
        ..color = const Color(0xFF1560FF).withOpacity(0.4)
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
        ..color = const Color(0xFF1560FF)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(lastPointX, lastPointY), 6, borderPaint);
      canvas.drawCircle(Offset(lastPointX, lastPointY), 4, circlePaint);
    }
  }

  void _drawLabels(Canvas canvas, Size size, double chartWidth, double padding) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final labelStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 11,
      fontFamily: 'Pretendard',
    );

    // 날짜 레이블 (1일, 중간, 31일)
    final labels = [
      {'text': '1.1', 'position': 0.0},
      {'text': '1.19', 'position': 18 / 31}, // 현재 날짜
      {'text': '1.31', 'position': 1.0},
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
        oldDelegate.currentDay != currentDay;
  }
}
