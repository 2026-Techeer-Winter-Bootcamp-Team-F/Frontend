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
const Color _cardBackgroundColor = Color(0xFFE8E8E8);
const Color _trackColor = Color(0xFF282828);

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
  late final String _bankDisplay;
  
  // 최근 소비 내역 더미 데이터
  static const List<Map<String, dynamic>> _recentSpendingData = [
    {'icon': Icons.shopping_cart, 'merchant': 'GS25', 'amount': 24300},
    {'icon': Icons.local_cafe, 'merchant': '스타벅스', 'amount': 32600},
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
    _bankDisplay = _bankDisplayName(widget.card.bankName);
    
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
    final offset = paddingLeft + (index + 1) * itemWidth + peekNext - pos.viewportDimension;
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
              Text(_cardTitle, style: _cardTitleStyle),
              // 제목-서브 간격: 6 → 3 (촘촘하게)
              const SizedBox(height: 3),
              Text(_maskedNumber, style: _cardNumberStyle),
              // 서브-링 간격: 6 → 4 (링을 위로 당기기)
              const SizedBox(height: 4),

              // 2. 원형 혜택 진행률 (33,000원 / 23,000원, 내가 받은 혜택 파란색, 69.7% 달성 pill)
              _buildCircularBenefitProgress(context),
              // 링-최근소비내역 간격: 18 → 8 (링 바로 아래에 오도록)
              const SizedBox(height: 8),

              // 3. 최근 소비 내역 섹션
              _buildRecentSpendingHistory(),
              const SizedBox(height: 100), // 하단 네비게이션 바 여유 공간
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
        itemBuilder: (context, i) => _MonthTabItem(
          date: _displayMonths[i],
          selected: _selectedMonthIndex == i,
          onTap: () => setState(() => _selectedMonthIndex = i),
        ),
      ),
    );
  }

  Widget _buildNewCard(BuildContext context) {
    const aspectRatio = 1.586;
    final screenW = MediaQuery.of(context).size.width;
    // 카드 크기: 0.58 → 0.50 (더 작게, 이미지처럼)
    final cardWidth = (screenW * 0.50).clamp(150.0, 190.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: cardWidth,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: _cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
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
                    opacity: 0.15,
                    child: Text(
                      'subscribe',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 22,
                        fontWeight: FontWeight.w300,
                        color: Colors.grey.shade700,
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
                      const Text(
                        'LG전자',
                        style: TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w800, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'The 구독케어',
                        style: TextStyle(fontFamily: 'Pretendard', fontSize: 9, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
                // 좌측: 화살표 아이콘 + ShinhanCard 세로
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_upward, size: 12, color: Colors.black54),
                        const SizedBox(height: 4),
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            _bankDisplay,
                            style: const TextStyle(fontFamily: 'Pretendard', fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
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
            ),
          ),
        ),
      ),
    );
  }

  String _bankDisplayName(String bankName) {
    if (bankName.contains('신한')) return 'ShinhanCard';
    return bankName.replaceAll('카드', '').trim();
  }

  String _maskedNumberFormatted() {
    final last4 = widget.card.maskedNumber.split(RegExp(r'\s+')).last;
    if (RegExp(r'^\d{4}$').hasMatch(last4)) {
      return '4221-55**-****-$last4 본인';
    }
    return '${widget.card.maskedNumber} 본인';
  }

  Widget _buildCircularBenefitProgress(BuildContext context) {
    const totalBenefit = 33000;
    const receivedBenefit = 23000;
    final percent = (receivedBenefit / totalBenefit).clamp(0.0, 1.0);
    final percentText = (percent * 100).toStringAsFixed(1);
    final screenW = MediaQuery.of(context).size.width;
    final maxFromWidth = screenW - 24;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 링 크기: scale 0.5 → 0.7 (전반적인 크기 증가)
        const scale = 0.7;
        final ringSize = (math.min(maxFromWidth, constraints.maxHeight).clamp(200.0, 400.0)) * scale;
        final stroke = (ringSize * 18 / 220).clamp(16.0 * scale, 32.0 * scale);
        // 내부 텍스트 크기 조정 (이미지 기준으로 중앙 텍스트 블록 강조)
        final fs1 = (ringSize * 10 / 220).clamp(10.0 * scale, 14.0 * scale); // "이번 달 총 혜택..."
        final fs2 = (ringSize * 12 / 220).clamp(12.0 * scale, 16.0 * scale); // "내가 받은 혜택"
        final fs3 = (ringSize * 32 / 220).clamp(32.0 * scale, 48.0 * scale); // "23,000원" - 이미지처럼 크게, 중앙에 꽉 차게
        final fs4 = (ringSize * 11 / 220).clamp(11.0 * scale, 14.0 * scale); // % 달성 pill
        final padH = (12.0 * scale).roundToDouble();
        final padV = (5.0 * scale).roundToDouble();
        // 내부 간격 조정
        final gap1 = (6.0 * scale).roundToDouble(); // "이번 달 총 혜택" - 중앙 블록 사이
        final gap2 = (10.0 * scale).roundToDouble(); // 중앙 블록 - "69.7% 달성" 사이
        
        return SizedBox(
          width: ringSize,
          height: ringSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(ringSize, ringSize),
                painter: _CircleProgressPainter(
                  percent: percent,
                  trackColor: _trackColor,
                  progressColor: _accentColor,
                  strokeWidth: stroke,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 상단 텍스트
                  Text(
                    '이번 달 총 혜택 ${_formatWon(totalBenefit)}',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: fs1,
                      color: _onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: gap1),
                  
                  // 중앙 텍스트 블록: "내가 받은 혜택" + "23,000원" 하나의 덩어리처럼
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '내가 받은 혜택',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: fs2,
                          fontWeight: FontWeight.w600,
                          color: _accentColor,
                          height: 1.0, // line-height를 1.0으로 설정하여 밀착
                        ),
                      ),
                      Text(
                        _formatWon(receivedBenefit),
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: fs3,
                          fontWeight: FontWeight.w800,
                          color: _onSurface,
                          height: 1.0, // line-height를 1.0으로 설정하여 밀착
                          letterSpacing: -0.5, // 약간의 letter spacing으로 자연스러운 느낌
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: gap2),
                  
                  // 69.7% 달성 — 파란 알약
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
                    decoration: BoxDecoration(
                      color: _accentColor,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '$percentText% 달성',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: fs4,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
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

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    return _NavItem(
      index: index,
      icon: icon,
      label: label,
      selected: _currentTabIndex == index,
      onTap: () => _navigateToTab(index),
    );
  }

  void _navigateToTab(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => MainNavigation(initialIndex: index),
      ),
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
        // 섹션 제목
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            '최근 소비 내역',
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
        ),
        
        // 항상 리스트로 표시 (스택 애니메이션 제거)
        _buildListView(),
      ],
    );
  }

  Widget _buildStackedView(double t) {
    const stackOffsetStep = 16.0;
    const initialScaleStep = 0.02;
    const initialOpacityStep = 0.05; // opacity 감소 폭 줄임 (더 선명하게)
    const maxBlur = 3.0;
    const minBackgroundOpacity = 0.85; // 배경 opacity 최소값 강제
    
    return SizedBox(
      height: 280, // 스택 높이 고정
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(_recentSpendingData.length, (index) {
          // 보간: t가 1에 가까울수록 스택 효과 감소
          final yOffset = stackOffsetStep * index * (1 - t);
          final scale = 1.0 - (initialScaleStep * index * (1 - t));
          
          // 배경 opacity: 첫 번째 카드는 1.0, 뒤로 갈수록 약간만 감소 (최소 0.85 이상)
          final baseBackgroundOpacity = index == 0 
              ? 1.0 
              : (1.0 - (initialOpacityStep * index)).clamp(minBackgroundOpacity, 1.0);
          // 스크롤 시 opacity 1.0으로 수렴, t=0일 때도 최소값 보장
          final backgroundOpacity = (baseBackgroundOpacity * (1 - t) + 1.0 * t).clamp(minBackgroundOpacity, 1.0);
          
          // blur: 첫 번째 카드는 0, 나머지는 단계적으로 (배경에만 적용)
          final baseBlur = index == 0 
              ? 0.0 
              : (maxBlur * (index - 1) / 2.0).clamp(0.0, maxBlur);
          final blur = baseBlur * (1 - t); // 스크롤 시 blur 0으로 수렴
          
          return Positioned(
            top: yOffset,
            left: 24,
            right: 24,
            child: Transform.scale(
              scale: scale.clamp(0.85, 1.0),
              alignment: Alignment.topCenter,
              // 전체 카드에 Opacity 적용하지 않고, 배경에만 opacity 적용
              child: _buildSpendingCardWithBlurredBackground(
                _recentSpendingData[index],
                index,
                blur,
                backgroundOpacity, // 배경 opacity 전달
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 배경만 blur 처리하고 텍스트/아이콘은 선명하게 유지하는 카드
  /// 배경 opacity는 전달받아 적용하고, 텍스트/아이콘은 항상 opacity 1.0
  Widget _buildSpendingCardWithBlurredBackground(
    Map<String, dynamic> data,
    int index,
    double blur,
    double backgroundOpacity,
  ) {
    final icon = data['icon'] as IconData;
    final merchant = data['merchant'] as String;
    final amount = data['amount'] as int;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          // 배경만 blur 처리 및 opacity 적용 (blur가 0이면 일반 Container)
          // ImageFiltered는 child를 blur하므로, 빈 배경 Container만 blur 처리
          if (blur > 0.3)
            Opacity(
              opacity: backgroundOpacity,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  color: const Color(0xFF2C2C2E),
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            )
          else
            Opacity(
              opacity: backgroundOpacity,
              child: Container(
                color: const Color(0xFF2C2C2E),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          // 텍스트/아이콘 콘텐츠 (blur 밖에서 렌더링, 항상 선명, opacity 1.0 고정)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(icon, color: _onSurface, size: 20),
                ),
                const SizedBox(width: 16),
                // 상점명
                Expanded(
                  child: Text(
                    merchant,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _onSurface,
                    ),
                  ),
                ),
                // 금액
                Text(
                  _formatWon(amount),
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Column(
      children: List.generate(
        _recentSpendingData.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            bottom: index < _recentSpendingData.length - 1 ? 12 : 0,
          ),
          child: _buildSpendingCard(_recentSpendingData[index], index),
        ),
      ),
    );
  }

  Widget _buildSpendingCard(Map<String, dynamic> data, int index) {
    final icon = data['icon'] as IconData;
    final merchant = data['merchant'] as String;
    final amount = data['amount'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3C),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: _onSurface, size: 20),
          ),
          const SizedBox(width: 16),
          // 상점명
          Expanded(
            child: Text(
              merchant,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _onSurface,
              ),
            ),
          ),
          // 금액
          Text(
            _formatWon(amount),
            style: TextStyle(
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

  _CircleProgressPainter({required this.percent, required this.trackColor, required this.progressColor, this.strokeWidth = 14.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // 스트로크 두께 증가: 기본값의 1.4배 (약 +40%)
    // 조절 포인트: 1.3~1.5 사이에서 조절 가능
    final baseStroke = strokeWidth * 1.4;
    final radius = math.min(size.width, size.height) / 2 - (baseStroke / 2 + 4);
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
      ..strokeWidth = baseStroke
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
        ..strokeWidth = baseStroke * 1.6 // 조절 포인트: 두께 배수 (번짐 줄임)
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7); // 조절 포인트: sigma 값 (번짐 줄임: 10→7)

      canvas.drawArc(rect, startAngle, sweep, false, outerGlowPaint);

      // 레이어 2: 중간, 중간 두께와 blur (중간 글로우)
      // 조절 포인트: strokeWidth 배수 1.2~1.4, sigma 5~8, opacity 0.3~0.4
      final middleGlowPaint = Paint()
        ..color = progressColor.withOpacity(0.3) // 조절 포인트: opacity (번짐 줄임)
        ..style = PaintingStyle.stroke
        ..strokeWidth = baseStroke * 1.25 // 조절 포인트: 두께 배수 (번짐 줄임)
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
        ..strokeWidth = baseStroke
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, sweep, false, mainProgressPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CircleProgressPainter oldDelegate) =>
      oldDelegate.percent != percent ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor ||
      oldDelegate.strokeWidth != strokeWidth;
}

/// 월 탭 아이템 위젯 (rebuild 최적화)
class _MonthTabItem extends StatelessWidget {
  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  const _MonthTabItem({
    required this.date,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            selected
                ? Text(
                    _CardDetailPageState._yearLabel(date),
                    style: const TextStyle(fontFamily: 'Pretendard', fontSize: 10, fontWeight: FontWeight.w500, color: _onSurfaceVariant),
                  )
                : const SizedBox(height: 12),
            const SizedBox(height: 1),
            Text(
              _CardDetailPageState._monthLabel(date),
              style: TextStyle(
                fontFamily: 'Pretendard',
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
  }
}

/// 네비게이션 아이템 위젯 (rebuild 최적화)
class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant;
    const iconSize = 26.0;
    const unselectedIconSize = 22.0;
    const selectedCircleSize = 36.0;
    const labelFontSize = 11.0;
    const spacing = 2.0;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected)
                Container(
                  width: selectedCircleSize,
                  height: selectedCircleSize,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Icon(icon, color: Colors.white, size: iconSize)),
                )
              else
                Icon(icon, color: color, size: unselectedIconSize),
              const SizedBox(height: spacing),
              Text(
                label,
                style: TextStyle(fontFamily: 'Pretendard', color: color, fontSize: labelFontSize, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
