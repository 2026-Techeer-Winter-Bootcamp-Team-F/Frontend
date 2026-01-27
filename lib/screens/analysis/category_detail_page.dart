import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/models/transaction_models.dart';
import 'package:my_app/services/transaction_service.dart';
import 'package:my_app/screens/analysis/category_transaction_page.dart';

class CategoryDetailPage extends StatefulWidget {
  final DateTime? initialMonth;

  const CategoryDetailPage({super.key, this.initialMonth});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  final TransactionService _service = TransactionService();

  late DateTime selectedMonth;
  String selectedFilter = '전체';
  int selectedCategoryIndex = 0;

  bool _isLoading = true;
  String? _error;

  // API data
  List<CategorySummaryItem> _categoryList = [];
  int _totalSpending = 0;
  int _lastMonthDifference = 0;

  // Convenience getters
  List<Map<String, dynamic>> get categoryData {
    return _categoryList.map((cat) => {
      'name': cat.name,
      'icon': cat.emoji,
      'amount': cat.amount,
      'change': cat.change,
      'percent': cat.percent,
      'color': cat.colorValue,
    }).toList();
  }

  List<String> get categoryFilters {
    final filters = ['전체'];
    final sorted = List<Map<String, dynamic>>.from(categoryData)
      ..sort((a, b) => (b['amount'] as int).compareTo(a['amount'] as int));
    filters.addAll(sorted.map((d) => d['name'] as String));
    return filters;
  }

  @override
  void initState() {
    super.initState();
    selectedMonth = widget.initialMonth ?? DateTime.now();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      selectedCategoryIndex = 0;
    });

    try {
      final year = selectedMonth.year;
      final month = selectedMonth.month;

      final results = await Future.wait([
        _service.getCategorySummary(year, month),
        _service.getAccumulated(year, month),
        _service.getMonthComparison(year, month),
      ]);

      final categories = results[0] as List<CategorySummaryItem>;
      final accumulated = results[1] as AccumulatedData;
      final comparison = results[2] as MonthComparison;

      setState(() {
        _categoryList = categories;
        _totalSpending = accumulated.total;
        _lastMonthDifference = comparison.thisMonthTotal - comparison.lastMonthSameDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 나이 대비 비교 데이터 (API 없음, 하드코딩 유지)
  final List<Map<String, dynamic>> ageComparisonData = [
    {
      'name': '쇼핑',
      'icon': '🏛️',
      'difference': 950000,
      'isHigher': true,
    },
    {
      'name': '식비',
      'icon': '🍽️',
      'difference': 200000,
      'isHigher': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '카테고리별 지출',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildMonthSelector(),
            const SizedBox(height: 16),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.only(top: 100),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Center(child: Text('데이터를 불러올 수 없습니다')),
              )
            else ...[
              _buildCategoryFilters(),
              const SizedBox(height: 24),
              _buildSpendingSection(),
              const SizedBox(height: 32),
              _buildAgeComparisonSection(),
              const SizedBox(height: 24),
              _buildCardAnalysisBanner(),
              const SizedBox(height: 100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
              });
              _fetchData();
            },
          ),
          Text(
            '${selectedMonth.month}월',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              setState(() {
                selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
              });
              _fetchData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categoryFilters.length,
        itemBuilder: (context, index) {
          final filter = categoryFilters[index];
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (filter != '전체' && selected) {
                  final categoryIndex = categoryData.indexWhere(
                    (data) => data['name'] == filter,
                  );
                  if (categoryIndex != -1) {
                    final selectedData = categoryData[categoryIndex];
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryTransactionPage(
                          categoryName: selectedData['name'] as String,
                          categoryIcon: selectedData['icon'] as String,
                          amount: selectedData['amount'] as int,
                          change: selectedData['change'] as int,
                          percent: selectedData['percent'] as int,
                          color: selectedData['color'] as Color,
                        ),
                      ),
                    );
                  }
                } else {
                  setState(() {
                    selectedFilter = filter;
                  });
                }
              },
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
              side: BorderSide(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpendingSection() {
    if (categoryData.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('카테고리 데이터가 없습니다')),
      );
    }

    if (selectedCategoryIndex >= categoryData.length) {
      selectedCategoryIndex = 0;
    }
    final selectedCategory = categoryData[selectedCategoryIndex];

    final diffAbs = _lastMonthDifference.abs();
    final diffLabel = _lastMonthDifference <= 0 ? '덜 썼어요' : '더 썼어요';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Text(
            _formatCurrencyFull(_totalSpending),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              children: [
                const TextSpan(text: '지난달 같은 기간보다 '),
                TextSpan(
                  text: _formatCurrencyFull(diffAbs),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' $diffLabel'),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 도넛 차트
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent &&
                            pieTouchResponse != null &&
                            pieTouchResponse.touchedSection != null) {
                          final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          if (touchedIndex >= 0 && touchedIndex < categoryData.length) {
                            setState(() {
                              selectedCategoryIndex = touchedIndex;
                            });
                          }
                        }
                      },
                    ),
                    sections: categoryData.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final isSelected = index == selectedCategoryIndex;

                      return PieChartSectionData(
                        color: data['color'] as Color,
                        value: (data['percent'] as int).toDouble(),
                        title: '',
                        radius: isSelected ? 44 : 38,
                      );
                    }).toList(),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        selectedCategory['icon'] as String,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${selectedCategory['percent']}%',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        selectedCategory['name'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          ...categoryData.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            return _buildCategoryItem(
              data['icon'] as String,
              data['name'] as String,
              data['percent'] as int,
              data['amount'] as int,
              data['change'] as int,
              data['color'] as Color,
              isSelected: index == selectedCategoryIndex,
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
            );
          }),
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
    final changeText = change == 0
        ? '지난달과 같아요'
        : '${change > 0 ? '+' : ''}${_formatCurrencyFull(change)}';
    final changeColor = change == 0
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (change > 0 ? const Color(0xFFFF5252) : AppColors.primary);

    return GestureDetector(
      onTap: () {
        if (onTap != null) onTap();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryTransactionPage(
              categoryName: name,
              categoryIcon: icon,
              amount: amount,
              change: change,
              percent: percent,
              color: color,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.surface : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: color, width: 2) : null,
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.12) : color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: isSelected ? Border.all(color: color, width: 1.5) : null,
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
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    changeText,
                    style: TextStyle(
                      fontSize: 12,
                      color: changeColor,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _formatCurrencyFull(amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeComparisonSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '김용진 님은',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            '20대 평균보다',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  ageComparisonData[0]['icon'] as String,
                  ageComparisonData[0]['name'] as String,
                  ageComparisonData[0]['difference'] as int,
                  ageComparisonData[0]['isHigher'] as bool,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard(
                  ageComparisonData[1]['icon'] as String,
                  ageComparisonData[1]['name'] as String,
                  ageComparisonData[1]['difference'] as int,
                  ageComparisonData[1]['isHigher'] as bool,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(
      String icon, String name, int difference, bool isHigher) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${(difference / 10000).toStringAsFixed(0)}만원',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isHigher ? const Color(0xFFFF5252) : const Color(0xFF2196F3),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                isHigher ? '높아요' : '낮아요',
                style: TextStyle(
                  fontSize: 14,
                  color: isHigher ? const Color(0xFFFF5252) : const Color(0xFF2196F3),
                ),
              ),
            ],
          ),
          Icon(
            isHigher ? Icons.arrow_upward : Icons.arrow_downward,
            color: isHigher ? const Color(0xFFFF5252) : const Color(0xFF2196F3),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildCardAnalysisBanner() {
    final topCategory = categoryData.isNotEmpty ? categoryData.first : null;
    final bannerText = topCategory != null
        ? '${topCategory['name']}에 ${_formatCurrencyFull(topCategory['amount'] as int)} 지출하셨네요!'
        : '지출 내역을 확인해보세요!';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF5252).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.credit_card,
              color: Color(0xFFFF5252),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  bannerText,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '카드를 분석해봤어요!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  String _formatCurrencyFull(int amount) {
    final formatted = amount.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
    return '${amount < 0 ? '-' : ''}$formatted원';
  }
}
