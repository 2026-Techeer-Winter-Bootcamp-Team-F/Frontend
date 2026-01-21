import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/providers/expense_provider.dart';
import 'package:my_app/providers/card_provider.dart';
import 'package:my_app/providers/auth_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final expenseProvider = context.read<ExpenseProvider>();
    final cardProvider = context.read<CardProvider>();

    await Future.wait([
      expenseProvider.fetchAnalysis(),
      cardProvider.fetchMyCards(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BeneFit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer2<ExpenseProvider, CardProvider>(
        builder: (context, expenseProvider, cardProvider, child) {
          if (expenseProvider.isLoading || cardProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 인사말
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      final userName = auth.user?.name ?? '사용자';
                      return Text(
                        '안녕하세요, $userName님',
                        style: Theme.of(context).textTheme.titleLarge,
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '이번 달 소비 현황을 확인해보세요',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // 월간 지출 요약 카드
                  _buildSummaryCard(expenseProvider),

                  const SizedBox(height: 16),

                  // 카테고리별 지출 차트
                  _buildCategoryChart(expenseProvider),

                  const SizedBox(height: 16),

                  // 또래 비교
                  _buildPeerComparisonCard(expenseProvider),

                  const SizedBox(height: 16),

                  // 카드별 손익 현황
                  _buildCardBenefitCard(cardProvider),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(ExpenseProvider provider) {
    final totalSpent = provider.totalSpent;
    final totalBenefit = provider.totalBenefit;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${DateTime.now().month}월 지출',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '혜택 ${_formatCurrency(totalBenefit)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(totalSpent),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildMiniStat(
                  '전월 대비',
                  '-12%',
                  AppColors.success,
                  Icons.trending_down,
                ),
                const SizedBox(width: 24),
                _buildMiniStat(
                  '일평균',
                  _formatCurrency(totalSpent > 0 ? totalSpent ~/ 20 : 0),
                  AppColors.textSecondary,
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(ExpenseProvider provider) {
    final categorySpending = provider.categorySpending;
    if (categorySpending.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              Text(
                '카테고리별 지출',
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '카테고리별 지출',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: categorySpending.entries.map((entry) {
                          final index = categorySpending.keys.toList().indexOf(entry.key);
                          final percentage = (entry.value / total * 100);
                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: entry.value.toDouble(),
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 50,
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
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categorySpending.entries.map((entry) {
                      final index = categorySpending.keys.toList().indexOf(entry.key);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeerComparisonCard(ExpenseProvider provider) {
    final totalSpent = provider.totalSpent;
    final peerAverage = provider.peerAverage;
    final myRank = provider.myRank;
    final ageGroup = provider.ageGroup;
    final gender = provider.gender;

    final difference = peerAverage - totalSpent;
    final isLessThanPeer = difference > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '또래 비교',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$ageGroup $gender 평균과 비교',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildCompareItem(
                    '나의 지출',
                    _formatCurrency(totalSpent),
                    AppColors.primary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.textLight.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildCompareItem(
                    '또래 평균',
                    _formatCurrency(peerAverage),
                    AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isLessThanPeer ? AppColors.success : AppColors.warning)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isLessThanPeer ? Icons.thumb_up : Icons.info_outline,
                    color: isLessThanPeer ? AppColors.success : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isLessThanPeer
                          ? '또래보다 ${_formatCurrency(difference)} 적게 쓰고 있어요! (상위 $myRank%)'
                          : '또래보다 ${_formatCurrency(-difference)} 더 쓰고 있어요',
                      style: TextStyle(
                        fontSize: 13,
                        color: isLessThanPeer ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompareItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildCardBenefitCard(CardProvider provider) {
    final myCards = provider.myCards;

    if (myCards.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                '카드별 손익 현황',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              Text('등록된 카드가 없습니다.'),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '카드별 손익 현황',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('자세히'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '혜택 - (연회비/12)',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ...myCards.take(3).map((userCard) {
              final roi = userCard.roi.toInt();
              return _buildCardRoiItem(userCard.card.name, roi);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCardRoiItem(String name, int roi) {
    final isPositive = roi >= 0;
    final maxRoi = 15000;
    final progress = (roi.abs() / maxRoi).clamp(0.0, 1.0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}${_formatCurrency(roi)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.textLight.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(
                isPositive ? AppColors.success : AppColors.error,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
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
}
