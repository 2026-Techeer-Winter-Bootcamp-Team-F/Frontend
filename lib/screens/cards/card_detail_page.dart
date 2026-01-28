import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/main_navigation.dart';
import 'card_analysis_page.dart';

/// 선택 탭, 진행률 강조색
const Color _accentColor = Color(0xFF005FFF);

// 색상 상수
const Color _onSurface = Colors.white;
const Color _onSurfaceVariant = Colors.white70;
const Color _backgroundColor = Color(0xFF1C1C1E);

// 스타일 상수
const TextStyle _cardTitleStyle = TextStyle(fontFamily: 'Pretendard', fontSize: 16, fontWeight: FontWeight.w800, color: _onSurface);
const TextStyle _cardNumberStyle = TextStyle(fontFamily: 'Pretendard', fontSize: 13, color: _onSurfaceVariant);

class CardDetailPage extends StatefulWidget {
  final WalletCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  static const int _currentTabIndex = 2;
  late int _selectedMonthIndex;
  late final List<DateTime> _displayMonths;
  final ScrollController _monthScrollController = ScrollController();
  final ScrollController _mainScrollController = ScrollController();
  
  // 캐싱된 값들
  late final String _cardTitle;
  late final String _maskedNumber;
  
  bool _isSpendingExpanded = true;

  // 최근 소비 내역 더미 데이터
  static const List<Map<String, dynamic>> _recentSpendingData = [
    {'icon': Icons.shopping_cart, 'merchant': 'GS25', 'amount': 24300},
    {'icon': Icons.local_cafe, 'merchant': '스타벅스', 'amount': 7500},
    {'icon': Icons.directions_bus, 'merchant': '지하철 버스', 'amount': 4500},
    {'icon': Icons.restaurant, 'merchant': '맘스터치', 'amount': 9600},
  ];

  /// 26년 1월을 기준으로, 25년 1월 ~ 26년 12월 (24개월). 진입 시 26년 1월 선택·노출.
  @override
  void initState() {
    super.initState();
    _displayMonths = _buildDisplayMonths();
    _selectedMonthIndex = 12; // 26년 1월 (0-based: 12)

    // 캐시된 값들 초기화
    _cardTitle = 'LG전자 The 구독케어 ${widget.card.bankName}';
    _maskedNumber = _maskedNumberFormatted();

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMonth(12));
  }


  @override
  void dispose() {
    _monthScrollController.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  void _scrollToMonth(int index) {
    if (!_monthScrollController.hasClients) return;
    const itemWidth = 48.0;
    const paddingLeft = 16.0;
    const peekNext = 22.0; // 26년 2월이 최우측에 살짝 보이도록
    final pos = _monthScrollController.position;
    final offset =
        paddingLeft +
        (index + 1) * itemWidth +
        peekNext -
        pos.viewportDimension;
    _monthScrollController.jumpTo(offset.clamp(0.0, pos.maxScrollExtent));
  }

  List<DateTime> _buildDisplayMonths() {
    final list = <DateTime>[];
    for (int y = 2025; y <= 2026; y++) {
      for (int m = 1; m <= 12; m++) {
        list.add(DateTime(y, m));
      }
    }
    return list;
  }

  static String _monthLabel(DateTime d) => '${d.month}월';
  static String _yearLabel(DateTime d) => '${d.year % 100}년';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: _onSurface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _mainScrollController,
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildMonthTabs(),
              const SizedBox(height: 16),

              // 1. 은색/회색 카드 (LG전자 위·The 구독케어 아래, 화살표+ShinhanCard 세로, 칩, subscribe)
              _buildNewCard(context),
              // 카드-제목 간격: 10 → 4 (촘촘하게)
              const SizedBox(height: 4),

              // 카드 아래 텍스트
              Text(
                _cardTitle,
                style: _cardTitleStyle,
              ),
              const SizedBox(height: 6),
              Text(
                _maskedNumber,
                style: _cardNumberStyle,
              ),
              SizedBox(height: (20 * 0.3).roundToDouble()),

              // 2. 원형 혜택 진행률 (33,000원 / 23,000원, 내가 받은 혜택 파란색, 69.7% 달성 pill)
              _buildCircularBenefitProgress(
                context,
                _onSurface,
                _onSurfaceVariant,
              ),
              const SizedBox(height: 18),

              // 3. 최근 소비 내역
              _buildRecentSpendingHistory(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildMonthTabs() {
    return SizedBox(
      height: 58,
      child: ListView.builder(
        controller: _monthScrollController,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _displayMonths.length,
        itemExtent: 48,
        itemBuilder: (context, i) {
          final d = _displayMonths[i];
          final selected = _selectedMonthIndex == i;
          return InkWell(
            onTap: () => setState(() => _selectedMonthIndex = i),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  selected
                      ? Text(
                          _yearLabel(d),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _onSurfaceVariant,
                          ),
                        )
                      : const SizedBox(height: 12),
                  const SizedBox(height: 1),
                  Text(
                    _monthLabel(d),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? _onSurface : _onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    height: 2,
                    width: 28,
                    decoration: BoxDecoration(
                      color: selected ? _accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewCard(BuildContext context) {
    const aspectRatio = 1.586;
    final screenW = MediaQuery.of(context).size.width;
    final cardWidth = (screenW * 0.58).clamp(165.0, 215.0);
    final baseColor = widget.card.color;
    final imagePath = widget.card.imagePath ?? _assetCardImage(widget.card.bankName);
    final rotateImage = _shouldRotateCardImage(widget.card.bankName);
    final imageScale = _cardImageScale(widget.card.bankName);
    final textColor = baseColor.computeLuminance() > 0.6
        ? const Color(0xFF1F2937)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: cardWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imagePath == null
                ? _buildCardFallback(textColor)
                : _buildCardImage(imagePath, rotateImage, imageScale, textColor),
          ),
        ),
      ),
    );
  }

  Widget _buildCardImage(
    String imagePath,
    bool rotateImage,
    double imageScale,
    Color textColor,
  ) {
    final image = imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => _buildCardFallback(textColor),
          )
        : Image.asset(
            imagePath,
            fit: BoxFit.cover,
            errorBuilder: (c, e, s) => _buildCardFallback(textColor),
          );

    if (!rotateImage) {
      if (imageScale == 1.0) return image;
      return ClipRect(
        child: Center(
          child: Transform.scale(
            scale: imageScale,
            child: image,
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: Transform.scale(
                scale: imageScale,
                child: SizedBox(
                  width: constraints.maxHeight,
                  height: constraints.maxWidth,
                  child: image,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCardFallback(Color textColor) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // 워터마크 "subscribe" (중앙, 흐릿한 회색)
        Center(
          child: Opacity(
            opacity: 0.12,
            child: Text(
              'subscribe',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: textColor,
              ),
            ),
          ),
        ),
        // 좌측 상단: LG전자(위) + The 구독케어(아래) 세로 배치
        Positioned(
          left: 12,
          top: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'LG전자',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'The 구독케어',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.85),
                ),
              ),
            ],
          ),
        ),
        // 좌측 중앙: EMV 칩
        Positioned(
          left: 12,
          bottom: 32,
          child: Container(
            width: 28,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFFD4AF37),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  String? _assetCardImage(String company) {
    if (company.contains('삼성') || company.toLowerCase().contains('samsung')) {
      return 'assets/images/samsung_select_all_card.png';
    }
    if (company.contains('신한') || company.toLowerCase().contains('shinhan')) {
      return 'assets/images/sinhan_mr_life.png';
    }
    return null;
  }

  bool _shouldRotateCardImage(String company) {
    return company.contains('삼성') || company.toLowerCase().contains('samsung');
  }

  double _cardImageScale(String company) {
    if (company.contains('삼성') || company.toLowerCase().contains('samsung')) {
      return 1.2;
    }
    return 1.0;
  }

  String _maskedNumberFormatted() {
    final last4 = widget.card.maskedNumber.split(RegExp(r'\s+')).last;
    if (RegExp(r'^\d{4}$').hasMatch(last4)) {
      return '4221-55**-****-$last4 본인';
    }
    return '${widget.card.maskedNumber} 본인';
  }

  Widget _buildCircularBenefitProgress(
    BuildContext context,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    const totalBenefit = 33000;
    const receivedBenefit = 23000;
    final percent = (receivedBenefit / totalBenefit).clamp(0.0, 1.0);
    final percentText = (percent * 100).toStringAsFixed(1);
    final screenW = MediaQuery.of(context).size.width;
    final maxFromWidth = screenW - 24;

    return LayoutBuilder(
      builder: (context, constraints) {
        const scale = 0.6; // 링 0.6배에 맞춘 내부 비율
        final ringSize =
            (math
                .min(maxFromWidth, constraints.maxHeight)
                .clamp(260.0, 500.0)) *
            scale;
        final stroke = (ringSize * 18 / 220).clamp(16.0 * scale, 32.0 * scale);
        final fs1 = (ringSize * 12 / 220).clamp(12.0 * scale, 16.0 * scale);
        final fs2 = (ringSize * 13 / 220).clamp(13.0 * scale, 17.0 * scale);
        final fs3 = (ringSize * 26 / 220).clamp(26.0 * scale, 36.0 * scale);
        final fs4 = (ringSize * 13 / 220).clamp(
          13.0 * scale,
          16.0 * scale,
        ); // % 달성 pill
        final padH = (14.0 * scale).roundToDouble();
        final padV = (6.0 * scale).roundToDouble();
        final gap1 = (6.0 * scale).roundToDouble();
        final gap2 = (12.0 * scale).roundToDouble();
        return Center(
          child: SizedBox(
            width: ringSize,
            height: ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(ringSize, ringSize),
                  painter: _CircleProgressPainter(
                    percent: percent,
                    trackColor: const Color(0xFF282828),
                    progressColor: _accentColor,
                    strokeWidth: stroke,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '이번 달 총 혜택 ${_formatWon(totalBenefit)}',
                      style: TextStyle(fontSize: fs1, color: onSurfaceVariant),
                    ),
                    SizedBox(height: gap1),
                    Text(
                      '내가 받은 혜택',
                      style: TextStyle(
                        fontSize: fs2,
                        fontWeight: FontWeight.w600,
                        color: _accentColor,
                      ),
                    ),
                    SizedBox(height: gap1),
                    Text(
                      _formatWon(receivedBenefit),
                      style: TextStyle(
                        fontSize: fs3,
                        fontWeight: FontWeight.w800,
                        color: onSurface,
                      ),
                    ),
                    SizedBox(height: gap2),
                    // 69.7% 달성 — 파란 알약
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: padH,
                        vertical: padV,
                      ),
                      decoration: BoxDecoration(
                        color: _accentColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '$percentText% 달성',
                        style: TextStyle(
                          fontSize: fs4,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      width: 440,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 74,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(index: 0, icon: Icons.home, label: '홈'),
          _buildNavItem(index: 1, icon: Icons.pie_chart_outline, label: '소비'),
          _buildNavItem(index: 2, icon: Icons.credit_card, label: '카드'),
          _buildNavItem(index: 3, icon: Icons.subscriptions, label: '구독'),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool selected = _currentTabIndex == index;
    final color = selected
        ? AppColors.primary
        : Theme.of(context).colorScheme.onSurfaceVariant;
    final iconSize = selected ? 26.0 : 22.0;
    final selectedCircleSize = 36.0;
    final labelFontSize = 11.0;
    final spacing = 2.0;

    return Expanded(
      child: InkWell(
        onTap: () => _navigateToTab(index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Container(
                  width: selectedCircleSize,
                  height: selectedCircleSize,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white, size: iconSize),
                  ),
                )
              else
                Icon(icon, color: color, size: iconSize),
              SizedBox(height: spacing),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    if (index == 0 && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainNavigation(initialIndex: index)),
      (route) => false,
    );
  }

  static String _formatWon(int value) {
    final s = value.toString();
    final out = s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '$out원';
  }

  Widget _buildRecentSpendingHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최근 소비 내역',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
              InkWell(
                onTap: () => setState(() => _isSpendingExpanded = !_isSpendingExpanded),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        _isSpendingExpanded ? '접기' : '펼치기',
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 13,
                          color: _onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isSpendingExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: _onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState:
                _isSpendingExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: _buildSpendingListView(),
            secondChild: _buildSpendingStackedView(),
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingListView() {
    return Column(
      children: _recentSpendingData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: index < _recentSpendingData.length - 1 ? 12.0 : 0),
          child: _buildSpendingCard(data),
        );
      }).toList(),
    );
  }

  Widget _buildSpendingLeading(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3C),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(icon, color: Colors.white70, size: 18),
    );
  }


  Widget _buildSpendingStackedView() {
    const peekHeight = 10.0; // 뒤 카드가 보이는 높이
    final visibleCount = math.min(3, _recentSpendingData.length);
    const cardHeight = 64.0;
    final stackHeight = cardHeight + peekHeight * (visibleCount - 1);

    // 역순으로 생성: 마지막 카드(뒤)부터 첫 번째 카드(앞)까지
    final children = <Widget>[];
    for (int i = visibleCount - 1; i >= 0; i--) {
      final distanceFromTop = i; // 0이 맨 앞, 숫자가 클수록 뒤
      final opacity = (1.0 - 0.2 * distanceFromTop).clamp(0.4, 1.0);
      final scale = (1.0 - 0.02 * distanceFromTop).clamp(0.94, 1.0);
      children.add(
        Positioned(
          top: peekHeight * distanceFromTop,
          left: 0,
          right: 0,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: _buildSpendingCard(_recentSpendingData[i]),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: stackHeight,
      child: Stack(children: children),
    );
  }

  Widget _buildSpendingCard(Map<String, dynamic> data) {
    final icon = data['icon'] as IconData;
    final merchant = data['merchant'] as String;
    final amount = data['amount'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildSpendingLeading(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              merchant,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _onSurface,
              ),
            ),
          ),
          Text(
            _formatWon(amount),
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

/// 원형 혜택 진행률 (이번 달 총 혜택 / 내가 받은 혜택)
class _CircleProgressPainter extends CustomPainter {
  final double percent;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  _CircleProgressPainter({
    required this.percent,
    required this.trackColor,
    required this.progressColor,
    this.strokeWidth = 14.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius =
        math.min(size.width, size.height) / 2 - (strokeWidth / 2 + 4);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final startAngle = 5 * math.pi / 4; // 시작 각도 유지
    final sweep = 2 * math.pi * percent.clamp(0.0, 1.0);

    // 회색 트랙 (배경 링) - 더 어둡고 은은하게
    // 트랙에 아주 약한 그라데이션 적용 (입체감)
    // 조절 포인트: opacity 0.6~0.8 사이에서 조절 가능
    final trackGradient = SweepGradient(
      startAngle: startAngle,
      endAngle: startAngle + 2 * math.pi,
      colors: [
        trackColor.withOpacity(0.75), // 바깥쪽 살짝 밝게
        trackColor.withOpacity(0.65), // 안쪽 살짝 어둡게
        trackColor.withOpacity(0.75), // 다시 밝게
      ],
    );
    final trackGradientPaint = Paint()
      ..shader = trackGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 전체 원 그리기 (트랙)
    canvas.drawCircle(center, radius, trackGradientPaint);

    // 파란 진행 arc - 3겹으로 그려서 글로우 효과 구현
    if (sweep > 0) {
      // 레이어 1: 가장 아래, 가장 두껍고 blur 강함 (외곽 글로우)
      // 조절 포인트: strokeWidth 배수 1.5~2.0, sigma 8~12, opacity 0.15~0.25
      final outerGlowPaint = Paint()
        ..color = progressColor.withOpacity(0.15) // 조절 포인트: opacity (번짐 줄임)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.6 // 조절 포인트: 두께 배수 (번짐 줄임)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7); // 조절 포인트: sigma 값 (번짐 줄임: 10→7)

      canvas.drawArc(rect, startAngle, sweep, false, outerGlowPaint);

      // 레이어 2: 중간, 중간 두께와 blur (중간 글로우)
      // 조절 포인트: strokeWidth 배수 1.2~1.4, sigma 5~8, opacity 0.3~0.4
      final middleGlowPaint = Paint()
        ..color = progressColor.withOpacity(0.3) // 조절 포인트: opacity (번짐 줄임)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 1.25 // 조절 포인트: 두께 배수 (번짐 줄임)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4); // 조절 포인트: sigma 값 (번짐 줄임: 6→4)

      canvas.drawArc(rect, startAngle, sweep, false, middleGlowPaint);

      // 레이어 3: 메인 arc - 그라데이션 적용 (깊이감)
      // SweepGradient: 바깥쪽이 살짝 더 밝고, 안쪽이 살짝 더 진한 느낌
      final progressGradient = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: [
          progressColor.withOpacity(1.0), // 바깥쪽 (시작점) - 밝게
          progressColor.withOpacity(0.85), // 중간 - 약간 어둡게
          progressColor.withOpacity(0.9), // 안쪽 (끝점) - 중간
        ],
        stops: const [0.0, 0.5, 1.0],
      );

      final mainProgressPaint = Paint()
        ..shader = progressGradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, mainProgressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
