import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  // 더미 데이터
  final List<Map<String, dynamic>> subscriptions = [
    {
      'id': 1,
      'name': '넷플릭스',
      'amount': 17000,
      'cycle': '월',
      'category': '영상',
      'status': 'active',
      'utilityScore': 4.5,
      'icon': Icons.play_circle_fill,
      'color': const Color(0xFFE50914),
      'lastUsed': '2일 전',
    },
    {
      'id': 2,
      'name': '유튜브 프리미엄',
      'amount': 14900,
      'cycle': '월',
      'category': '영상',
      'status': 'active',
      'utilityScore': 5.0,
      'icon': Icons.smart_display,
      'color': const Color(0xFFFF0000),
      'lastUsed': '오늘',
    },
    {
      'id': 3,
      'name': '스포티파이',
      'amount': 10900,
      'cycle': '월',
      'category': '음악',
      'status': 'active',
      'utilityScore': 3.8,
      'icon': Icons.music_note,
      'color': const Color(0xFF1DB954),
      'lastUsed': '3일 전',
    },
    {
      'id': 4,
      'name': '네이버 플러스',
      'amount': 4900,
      'cycle': '월',
      'category': '쇼핑',
      'status': 'active',
      'utilityScore': 2.5,
      'icon': Icons.shopping_bag,
      'color': const Color(0xFF03C75A),
      'lastUsed': '1주 전',
    },
    {
      'id': 5,
      'name': '밀리의 서재',
      'amount': 9900,
      'cycle': '월',
      'category': '도서',
      'status': 'active',
      'utilityScore': 1.5,
      'icon': Icons.book,
      'color': const Color(0xFFFFD700),
      'lastUsed': '3주 전',
    },
    {
      'id': 6,
      'name': '애플 뮤직',
      'amount': 10900,
      'cycle': '월',
      'category': '음악',
      'status': 'canceled',
      'utilityScore': 0,
      'icon': Icons.apple,
      'color': const Color(0xFF000000),
      'lastUsed': '-',
    },
  ];

  String _selectedFilter = '전체';

  List<Map<String, dynamic>> get filteredSubscriptions {
    if (_selectedFilter == '전체') {
      return subscriptions.where((s) => s['status'] == 'active').toList();
    } else if (_selectedFilter == '해지됨') {
      // 해지된 구독만 필터링
      return subscriptions.where((s) => s['status'] == 'canceled').toList();
    } else if (_selectedFilter == '해지 권장') {
      // 활성 상태이면서 유용성 점수가 3.0 미만인 구독만 필터링
      return subscriptions
        .where((s) =>
          s['status'] == 'active' &&
          // utilityScore가 int/double 둘 다 올 수 있어 num으로 받아 안전 변환
          (s['utilityScore'] as num).toDouble() < 3.0)
        .toList();
    }
    return subscriptions;
  }

  int get totalMonthlyAmount {
    return subscriptions
        .where((s) => s['status'] == 'active')
        .fold<int>(0, (sum, s) => sum + (s['amount'] as int));
  }

  int get activeCount {
    return subscriptions.where((s) => s['status'] == 'active').length;
  }

  int get lowUtilityCount {
    return subscriptions
        .where((s) =>
        s['status'] == 'active' &&
        // utilityScore가 int/double 둘 다 올 수 있어 num으로 받아 안전 변환
        (s['utilityScore'] as num).toDouble() < 3.0)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSubscriptionDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 총 구독료 요약
            _buildSummaryCard(),

            const SizedBox(height: 16),

            // 해지 권장 알림 (전체 탭일 때만 표시 - 다른 탭에서는 이미 필터링된 목록을 보고 있으므로 불필요)
            if (lowUtilityCount > 0 && _selectedFilter == '전체') _buildLowUtilityAlert(),

            const SizedBox(height: 16),

            // 필터
            _buildFilterChips(),

            const SizedBox(height: 16),

            // 구독 목록
            ...filteredSubscriptions.map((sub) => _buildSubscriptionItem(sub)),

            if (filteredSubscriptions.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '구독 서비스가 없습니다',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '월간 구독료',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(totalMonthlyAmount),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$activeCount',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const Text(
                        '구독 중',
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMiniStat(
                    '연간 예상',
                    _formatCurrency(totalMonthlyAmount * 12),
                    Icons.calendar_today,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMiniStat(
                    '지난달 대비',
                    '+4,900원',
                    Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowUtilityAlert() {
    return Card(
      color: AppColors.warning.withValues(alpha: 0.1),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '해지 권장 구독이 있어요',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '유용성이 낮은 $lowUtilityCount개 서비스를 확인해보세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.warning.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() => _selectedFilter = '해지 권장');
              },
              child: const Text('보기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['전체', '해지 권장', '해지됨'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
              },
              selectedColor: AppColors.primary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubscriptionItem(Map<String, dynamic> subscription) {
    final isActive = subscription['status'] == 'active';
    // utilityScore를 안전하게 double로 변환 (int일 수도 있고 double일 수도 있음)
    final utilityScore = (subscription['utilityScore'] as num).toDouble();
    final isLowUtility = isActive && utilityScore < 3.0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (subscription['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subscription['icon'] as IconData,
                    color: subscription['color'] as Color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            subscription['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isActive
                                  ? AppColors.textPrimary
                                  : AppColors.textLight,
                            ),
                          ),
                          if (!isActive) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.textLight.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '해지됨',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                          if (isLowUtility) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '해지 권장',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${subscription['category']} | 마지막 사용: ${subscription['lastUsed']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // 금액
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${_formatCurrency(subscription['amount'])}/${subscription['cycle']}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textLight,
                      ),
                    ),
                    if (isActive) ...[
                      const SizedBox(height: 4),
                      _buildUtilityStars(utilityScore),
                    ],
                  ],
                ),
              ],
            ),

            // 해지 버튼 (활성 상태일 때만)
            if (isActive) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '유용성 점수: ${utilityScore.toStringAsFixed(1)}/5.0',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  if (isLowUtility)
                    TextButton.icon(
                      onPressed: () => _showCancelDialog(subscription),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('해지하기'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    )
                  else
                    TextButton(
                      onPressed: () {},
                      child: const Text('관리'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUtilityStars(double score) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < score.floor()) {
          return const Icon(Icons.star, size: 14, color: AppColors.warning);
        } else if (index < score) {
          return const Icon(Icons.star_half, size: 14, color: AppColors.warning);
        } else {
          return Icon(Icons.star_border,
              size: 14, color: AppColors.textLight.withValues(alpha: 0.5));
        }
      }),
    );
  }

  void _showAddSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 추가'),
        content: const Text('구독 서비스 추가 기능은\n추후 업데이트 예정입니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(Map<String, dynamic> subscription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('구독 해지'),
        content: Text(
          '${subscription['name']} 구독을 해지하시겠습니까?\n\n월 ${_formatCurrency(subscription['amount'])}을 절약할 수 있습니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                subscription['status'] = 'canceled';
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${subscription['name']} 구독이 해지되었습니다.'),
                  action: SnackBarAction(
                    label: '실행 취소',
                    onPressed: () {
                      setState(() {
                        subscription['status'] = 'active';
                      });
                    },
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('해지'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int amount) {
    return '${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}원';
  }
}
