import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/main_navigation.dart';
import 'card_analysis_page.dart';

/// 선택 탭, 진행률 강조색
const Color _accentColor = Color(0xFF005FFF);

class CardDetailPage extends StatefulWidget {
  final WalletCard card;

  const CardDetailPage({super.key, required this.card});

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage> {
  static const int _currentTabIndex = 2;
  late int _selectedMonthIndex;
  List<DateTime> _displayMonths = [];
  final ScrollController _monthScrollController = ScrollController();

  /// 26년 1월을 기준으로, 25년 1월 ~ 26년 12월 (24개월). 진입 시 26년 1월 선택·노출.
  @override
  void initState() {
    super.initState();
    _buildDisplayMonths();
    _selectedMonthIndex = 12; // 26년 1월 (0-based: 12)
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToMonth(12));
  }

  @override
  void dispose() {
    _monthScrollController.dispose();
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

  void _buildDisplayMonths() {
    final list = <DateTime>[];
    for (int y = 2025; y <= 2026; y++) {
      for (int m = 1; m <= 12; m++) {
        list.add(DateTime(y, m));
      }
    }
    _displayMonths = list;
  }

  String _monthLabel(DateTime d) => '${d.month}월';
  String _yearLabel(DateTime d) => '${d.year % 100}년';

  @override
  Widget build(BuildContext context) {
    final onSurface = Colors.white;
    final onSurfaceVariant = Colors.white70;

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: onSurface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildMonthTabs(onSurface, onSurfaceVariant),
            const SizedBox(height: 16),

            // 1. 은색/회색 카드 (LG전자 위·The 구독케어 아래, 화살표+ShinhanCard 세로, 칩, subscribe)
            _buildNewCard(context),
            const SizedBox(height: 10),

            // 카드 아래 텍스트
            Text(
              _cardTitle(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _maskedNumberFormatted(),
              style: TextStyle(fontSize: 13, color: onSurfaceVariant),
            ),
            SizedBox(height: (20 * 0.3).roundToDouble()),

            // 2. 원형 혜택 진행률 (33,000원 / 23,000원, 내가 받은 혜택 파란색, 69.7% 달성 pill)
            Expanded(
              child: _buildCircularBenefitProgress(
                context,
                onSurface,
                onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildMonthTabs(Color onSurface, Color onSurfaceVariant) {
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
                            color: onSurfaceVariant,
                          ),
                        )
                      : const SizedBox(height: 12),
                  const SizedBox(height: 1),
                  Text(
                    _monthLabel(d),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected ? onSurface : onSurfaceVariant,
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
    final textColor = baseColor.computeLuminance() > 0.6
        ? const Color(0xFF1F2937)
        : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: cardWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: baseColor.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
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
                // 좌측: 화살표 아이콘 + ShinhanCard 세로
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
            ),
          ),
        ),
      ),
    );
  }

  String _cardTitle() {
    return 'LG전자 The 구독케어 ${widget.card.bankName}';
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
    final stroke = strokeWidth;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 배경 링 (다크 그레이/블랙)
    final bgPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    // 진행 링 (파란색) — 좌하에서 시계방향으로 우상 쪽
    final fgPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);
    final sweep = 2 * math.pi * percent.clamp(0.0, 1.0);
    canvas.drawArc(rect, 5 * math.pi / 4, sweep, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}
