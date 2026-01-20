import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:my_app/config/theme.dart';

class CardAnalysisPage extends StatefulWidget {
  const CardAnalysisPage({super.key});

  @override
  State<CardAnalysisPage> createState() => _CardAnalysisPageState();
}

class _CardAnalysisPageState extends State<CardAnalysisPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 더미 데이터 - 내 카드
  final List<Map<String, dynamic>> myCards = [
    {
      'name': '삼성카드 taptap O',
      'company': '삼성카드',
      'annualFee': 15000,
      'benefitReceived': 32000,
      'maxBenefit': 50000,
      'spent': 850000,
      'color': const Color(0xFF1428A0),
    },
    {
      'name': '신한카드 Deep Dream',
      'company': '신한카드',
      'annualFee': 10000,
      'benefitReceived': 18000,
      'maxBenefit': 30000,
      'spent': 520000,
      'color': const Color(0xFF0046FF),
    },
    {
      'name': '현대카드 M',
      'company': '현대카드',
      'annualFee': 15000,
      'benefitReceived': 8000,
      'maxBenefit': 40000,
      'spent': 280000,
      'color': const Color(0xFF000000),
    },
  ];

  // 더미 데이터 - 추천 카드
  final List<Map<String, dynamic>> recommendedCards = [
    {
      'name': '토스 카드',
      'company': '토스뱅크',
      'annualFee': 0,
      'expectedBenefit': 45000,
      'mainBenefit': '모든 가맹점 0.5% 적립',
      'matchRate': 95,
      'color': const Color(0xFF0064FF),
    },
    {
      'name': '카카오뱅크 카드',
      'company': '카카오뱅크',
      'annualFee': 0,
      'expectedBenefit': 38000,
      'mainBenefit': '온라인 결제 1% 할인',
      'matchRate': 88,
      'color': const Color(0xFFFEE500),
    },
    {
      'name': '네이버페이 머니카드',
      'company': '미래에셋증권',
      'annualFee': 0,
      'expectedBenefit': 42000,
      'mainBenefit': '네이버페이 2% 적립',
      'matchRate': 85,
      'color': const Color(0xFF03C75A),
    },
    {
      'name': '우리카드 카드의정석',
      'company': '우리카드',
      'annualFee': 12000,
      'expectedBenefit': 52000,
      'mainBenefit': '외식/카페 10% 할인',
      'matchRate': 82,
      'color': const Color(0xFF0067AC),
    },
    {
      'name': 'KB국민 My WE:SH',
      'company': 'KB국민카드',
      'annualFee': 10000,
      'expectedBenefit': 48000,
      'mainBenefit': '영역 선택 최대 10%',
      'matchRate': 78,
      'color': const Color(0xFFFFB300),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카드 분석'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '내 카드'),
            Tab(text: '추천 카드'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddCardDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyCardsTab(),
          _buildRecommendedCardsTab(),
        ],
      ),
    );
  }

  Widget _buildMyCardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 총 혜택 현황
          _buildTotalBenefitCard(),

          const SizedBox(height: 16),

          // Best/Worst 카드
          _buildBestWorstCard(),

          const SizedBox(height: 16),

          // 내 카드 목록
          const Text(
            '보유 카드',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...myCards.map((card) => _buildMyCardItem(card)),
        ],
      ),
    );
  }

  Widget _buildTotalBenefitCard() {
    final totalBenefit =
        myCards.fold<int>(0, (sum, card) => sum + (card['benefitReceived'] as int));
    final totalFee =
        myCards.fold<int>(0, (sum, card) => sum + (card['annualFee'] as int));
    final monthlyFee = totalFee ~/ 12;
    final netBenefit = totalBenefit - monthlyFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              '이번 달 총 카드 혜택',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatCurrency(totalBenefit),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: netBenefit >= 0
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    netBenefit >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: netBenefit >= 0 ? AppColors.success : AppColors.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '연회비 월할(${_formatCurrency(monthlyFee)}) 제외 순이익: ${netBenefit >= 0 ? '+' : ''}${_formatCurrency(netBenefit)}',
                    style: TextStyle(
                      fontSize: 13,
                      color: netBenefit >= 0 ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w500,
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

  Widget _buildBestWorstCard() {
    final sortedCards = List<Map<String, dynamic>>.from(myCards)
      ..sort((a, b) {
        final aRoi = (a['benefitReceived'] as int) - (a['annualFee'] as int) ~/ 12;
        final bRoi = (b['benefitReceived'] as int) - (b['annualFee'] as int) ~/ 12;
        return bRoi.compareTo(aRoi);
      });

    final bestCard = sortedCards.first;
    final worstCard = sortedCards.last;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'BEST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bestCard['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${_formatCurrency(bestCard['benefitReceived'])}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'WORST',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    worstCard['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+${_formatCurrency(worstCard['benefitReceived'])}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMyCardItem(Map<String, dynamic> card) {
    final benefitRate = (card['benefitReceived'] as int) / (card['maxBenefit'] as int);
    final monthlyFee = (card['annualFee'] as int) ~/ 12;
    final roi = (card['benefitReceived'] as int) - monthlyFee;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 카드 이미지 (더미)
                Container(
                  width: 60,
                  height: 40,
                  decoration: BoxDecoration(
                    color: card['color'] as Color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.credit_card,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        card['company'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '연회비 ${_formatCurrency(card['annualFee'])}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '이번달 ${_formatCurrency(card['spent'])} 사용',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 혜택 달성률
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '혜택 달성률',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${(benefitRate * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: benefitRate,
                backgroundColor: AppColors.textLight.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(
                  benefitRate >= 0.7
                      ? AppColors.success
                      : benefitRate >= 0.4
                          ? AppColors.warning
                          : AppColors.error,
                ),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '받은 혜택: ${_formatCurrency(card['benefitReceived'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '최대: ${_formatCurrency(card['maxBenefit'])}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // ROI
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '월간 순이익',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${roi >= 0 ? '+' : ''}${_formatCurrency(roi)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: roi >= 0 ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 추천 설명
          Card(
            color: AppColors.primary.withOpacity(0.05),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI 맞춤 추천',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '최근 3개월 소비 패턴을 분석하여\n최적의 카드를 추천해드려요',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ROI 시뮬레이션
          _buildRoiSimulationCard(),

          const SizedBox(height: 20),

          // 추천 카드 Top 5
          const Text(
            '추천 카드 Top 5',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...recommendedCards.asMap().entries.map(
                (entry) => _buildRecommendedCardItem(entry.key + 1, entry.value),
              ),
        ],
      ),
    );
  }

  Widget _buildRoiSimulationCard() {
    final currentBenefit = myCards.fold<int>(
        0, (sum, card) => sum + (card['benefitReceived'] as int));
    final currentFee =
        myCards.fold<int>(0, (sum, card) => sum + (card['annualFee'] as int)) ~/
            12;
    final currentNet = currentBenefit - currentFee;

    final recommendedBenefit = recommendedCards.first['expectedBenefit'] as int;
    final recommendedFee = (recommendedCards.first['annualFee'] as int) ~/ 12;
    final recommendedNet = recommendedBenefit - recommendedFee;

    final savings = (recommendedNet - currentNet) * 12;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ROI 시뮬레이션',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '카드 교체 시 예상 절약 금액',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (recommendedNet > currentNet ? recommendedNet : currentNet)
                          .toDouble() *
                      1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              value == 0 ? '현재 카드' : '추천 카드',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: currentNet.toDouble(),
                          color: AppColors.textSecondary,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: recommendedNet.toDouble(),
                          color: AppColors.primary,
                          width: 40,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.savings,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '카드 교체 시 연간 ${_formatCurrency(savings)} 절약 가능!',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
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

  Widget _buildRecommendedCardItem(int rank, Map<String, dynamic> card) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 순위
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? AppColors.primary.withOpacity(0.1)
                    : AppColors.textLight.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // 카드 이미지
            Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                color: card['color'] as Color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),

            // 카드 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    card['mainBenefit'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '예상 혜택 ${_formatCurrency(card['expectedBenefit'])}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '매칭률 ${card['matchRate']}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 발급 버튼
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
              ),
              child: const Text(
                '상세',
                style: TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카드 추가'),
        content: const Text('카드 검색 및 추가 기능은\n추후 업데이트 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount.abs() >= 10000) {
      return '${(amount / 10000).toStringAsFixed(1)}만원';
    }
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}원';
  }
}
