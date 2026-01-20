import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/providers/expense_provider.dart';
import 'package:my_app/models/expense.dart';

class ExpenseAnalysisPage extends StatefulWidget {
  const ExpenseAnalysisPage({super.key});

  @override
  State<ExpenseAnalysisPage> createState() => _ExpenseAnalysisPageState();
}

class _ExpenseAnalysisPageState extends State<ExpenseAnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _chartKey = GlobalKey();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final expenseProvider = context.read<ExpenseProvider>();
    await expenseProvider.loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지출 분석'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '카테고리별'),
            Tab(text: '최근 내역'),
          ],
        ),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, expenseProvider, child) {
          if (expenseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryTab(expenseProvider),
              _buildRecentTab(expenseProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryTab(ExpenseProvider provider) {
    final categorySpending = provider.categorySpending;
    final categoryDetails = provider.categoryDetails;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildMainCategoryChart(categorySpending),
            const SizedBox(height: 16),
            if (_selectedCategory != null && categoryDetails.containsKey(_selectedCategory))
              _buildSubCategoryCard(categoryDetails[_selectedCategory]!),
            const SizedBox(height: 16),
            _buildCategoryList(categorySpending),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCategoryChart(Map<String, int> categorySpending) {
    if (categorySpending.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              Text(
                '이번 달 카테고리별 지출',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 20),
              Text('지출 데이터가 없습니다.'),
            ],
          ),
        ),
      );
    }

    final total = categorySpending.values.reduce((a, b) => a + b);
    final colors = AppColors.chartColors;

    return Container(
      key: _chartKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                '이번 달 카테고리별 지출',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '총 ${_formatCurrency(total)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        if (response?.touchedSection != null) {
                          final index = response!.touchedSection!.touchedSectionIndex;
                          if (index >= 0) {
                            setState(() {
                              _selectedCategory = categorySpending.keys.toList()[index];
                            });
                          }
                        }
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 50,
                    sections: categorySpending.entries.map((entry) {
                      final index = categorySpending.keys.toList().indexOf(entry.key);
                      final categoryTotal = entry.value;
                      final percentage = (categoryTotal / total * 100);
                      final isSelected = _selectedCategory == entry.key;

                      return PieChartSectionData(
                        color: colors[index % colors.length],
                        value: categoryTotal.toDouble(),
                        title: '${percentage.toStringAsFixed(0)}%',
                        radius: isSelected ? 60 : 50,
                        titleStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubCategoryCard(Map<String, int> subCategories) {
    final categoryTotal = subCategories.values.reduce((a, b) => a + b);
    final categoryIndex = context
        .read<ExpenseProvider>()
        .categorySpending
        .keys
        .toList()
        .indexOf(_selectedCategory!);
    final color = AppColors.chartColors[categoryIndex % AppColors.chartColors.length];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_selectedCategory 상세',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatCurrency(categoryTotal),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...subCategories.entries.map((entry) {
              final percentage = entry.value / categoryTotal;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key),
                        Text(
                          _formatCurrency(entry.value),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage,
                        backgroundColor: AppColors.textLight.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(color.withOpacity(0.7)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryList(Map<String, int> categorySpending) {
    final colors = AppColors.chartColors;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리 목록',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...categorySpending.entries.map((entry) {
              final index = categorySpending.keys.toList().indexOf(entry.key);
              final total = entry.value;
              final isSelected = _selectedCategory == entry.key;

              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedCategory = _selectedCategory == entry.key ? null : entry.key;
                  });
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToChart();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors[index % colors.length].withOpacity(0.1)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors[index % colors.length].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _getCategoryIcon(entry.key),
                          color: colors[index % colors.length],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatCurrency(total),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isSelected
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_right,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTab(ExpenseProvider provider) {
    final expenses = provider.expenses;

    if (expenses.isEmpty) {
      return const Center(
        child: Text('지출 내역이 없습니다.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: expenses.length,
        itemBuilder: (context, index) {
          final expense = expenses[index];
          return _buildExpenseItem(expense);
        },
      ),
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          expense.merchant,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${expense.category} | ${_formatDate(expense.date)}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: Text(
          '-${_formatCurrency(expense.amount)}',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ),
    );
  }

  void _scrollToChart() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '식비':
        return Icons.restaurant;
      case '교통':
        return Icons.directions_car;
      case '쇼핑':
        return Icons.shopping_bag;
      case '생활':
        return Icons.home;
      default:
        return Icons.more_horiz;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  String _formatCurrency(int amount) {
    if (amount >= 10000) {
      final man = amount ~/ 10000;
      final remainder = amount % 10000;
      if (remainder == 0) {
        return '${man}만원';
      }
      return '${man}만 ${remainder}원';
    }
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}원';
  }
}
