import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/user.dart';
import 'package:my_app/screens/cards/card_analysis_page.dart';
import 'package:my_app/screens/cards/card_detail_page.dart';
import 'package:my_app/services/user_service.dart';

// --- Gemini API 설정 ---
const String _apiKey = ""; // 여기에 API 키를 입력하세요

Future<String> callGeminiAPI(String prompt) async {
  if (_apiKey.isEmpty) return "API 키가 설정되지 않았습니다.";

  const String url =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-09-2025:generateContent";

  try {
    final response = await http.post(
      Uri.parse("$url?key=$_apiKey"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates']?[0]['content']?['parts']?[0]['text'] ??
          "분석 결과를 가져올 수 없습니다.";
    } else {
      return "오류 발생: ${response.statusCode}";
    }
  } catch (e) {
    return "네트워크 오류가 발생했습니다.";
  }
}

class BenefitScorePage extends StatefulWidget {
  final String name;
  const BenefitScorePage({super.key, this.name = ''});

  @override
  State<BenefitScorePage> createState() => _BenefitScorePageState();
}

class _BenefitScorePageState extends State<BenefitScorePage> {
  bool _isDarkMode = true;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode
          ? ThemeData(
              brightness: Brightness.dark,
              fontFamily: 'Pretendard',
              scaffoldBackgroundColor: Colors.black,
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF2563EB),
                secondary: Color(0xFF3B82F6),
                surface: Color(0xFF1C1C1E),
                onSurface: Colors.white,
              ),
              useMaterial3: true,
            )
          : ThemeData(
              brightness: Brightness.light,
              fontFamily: 'Pretendard',
              scaffoldBackgroundColor: const Color(0xFFF8F9FA),
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF2563EB),
                secondary: Color(0xFF3B82F6),
                surface: Colors.white,
                onSurface: Color(0xFF1E293B),
              ),
              useMaterial3: true,
            ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              if (widget.name.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${widget.name}님',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const SpendingReportSection(),
              const SizedBox(height: 16),
              const BenefitSummarySection(),
              const SizedBox(height: 52),
              // 카드 섹션
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 8),
                  child: CardWalletSection(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 1. Spending Report (지출 리포트) ---
class SpendingReportSection extends StatefulWidget {
  const SpendingReportSection({super.key});

  @override
  State<SpendingReportSection> createState() => _SpendingReportSectionState();
}

class _SpendingReportSectionState extends State<SpendingReportSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Content
          Row(
            children: [
              // Wave Chart
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 배경 원
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : Colors.grey[200],
                      ),
                    ),
                    // Wave Animation (클리핑된 원)
                    SizedBox(
                      width: 150,
                      height: 150,
                      child: ClipOval(
                        child: AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: WavePainter(
                                _controller.value,
                                primaryColor,
                                0.63, // 63%
                              ),
                              size: const Size(150, 150),
                            );
                          },
                        ),
                      ),
                    ),
                    // 테두리 원
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF3A3A3C)
                              : Colors.grey[400]!,
                          width: 3,
                        ),
                      ),
                    ),
                    // 텍스트 (가장 위에)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "TARGET",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "63%",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              // Categories
              Expanded(
                child: Column(
                  children: [
                    _buildCategoryRow("Food", "45%", Colors.blue[600]!, isDark),
                    const SizedBox(height: 16),
                    _buildCategoryRow(
                      "Shopping",
                      "30%",
                      Colors.indigo[400]!,
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(
    String label,
    String percent,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
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
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            Text(
              percent,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.grey[200],
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: double.parse(percent.replaceAll('%', '')) / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Wave Painter for the water effect
class WavePainter extends CustomPainter {
  final double animationValue;
  final Color color;
  final double percentage;

  WavePainter(this.animationValue, this.color, this.percentage);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    final y = size.height * (1 - percentage);
    path.moveTo(0, y);

    // Sine wave calculation
    for (double i = 0.0; i <= size.width; i++) {
      path.lineTo(
        i,
        y +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi),
                ) *
                5,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // Second lighter wave
    final paint2 = Paint()..color = color.withOpacity(0.5);
    final path2 = Path();
    path2.moveTo(0, y);
    for (double i = 0.0; i <= size.width; i++) {
      path2.lineTo(
        i,
        y +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi) +
                      2,
                ) * // Phase shift
                5,
      );
    }
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// --- 2. Benefit Summary (혜택 요약) ---
class BenefitSummarySection extends StatelessWidget {
  const BenefitSummarySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor = isDark ? Colors.grey[500]! : Colors.grey[600]!;
    final iconColor = isDark ? Colors.grey[600]! : Colors.grey[500]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 받은 혜택 (세로 파란 바 + 라벨/금액)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '받은 혜택',
                        style: TextStyle(color: labelColor, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₩15,400',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF60A5FA),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 선물 상자 아이콘 (가운데)
          Icon(Icons.card_giftcard, size: 24, color: iconColor),
          const SizedBox(width: 16),
          // 놓친 혜택 (세로 회색 바 + 라벨/금액)
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 3,
                  height: 24,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: labelColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '놓친 혜택',
                        style: TextStyle(color: labelColor, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₩12,500',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 우측 겹치는 정보 아이콘 두 개
          SizedBox(
            width: 36,
            height: 36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: iconColor),
                    ),
                    child: Icon(Icons.info_outline, size: 16, color: iconColor),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Opacity(
                    opacity: 0.7,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: iconColor),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        size: 16,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Card Wallet (카드 지갑) - Tinder 스타일 ---
class CardWalletSection extends StatefulWidget {
  const CardWalletSection({super.key});

  @override
  State<CardWalletSection> createState() => _CardWalletSectionState();
}

class _CardWalletSectionState extends State<CardWalletSection> {
  int _currentIndex = 0;
  List<UserCardInfo> _cards = [];
  bool _isLoading = true;
  String? _error;
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final userService = UserService();
      final user = await userService.getProfile();
      if (!mounted) return;
      setState(() {
        _cards = user.cards;
        _isLoading = false;
        if (_currentIndex >= _cards.length) {
          _currentIndex = 0;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '카드 정보를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (currentIndex != null) {
      setState(() {
        _currentIndex = currentIndex;
      });
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 헤더
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "My Wallet",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // 카드 영역
        _buildContent(),
        // 하단 인디케이터
        if (_cards.isNotEmpty && !_isLoading) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _cards.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentIndex == index ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[700],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: _loadCards, child: const Text('다시 시도')),
            ],
          ),
        ),
      );
    }
    if (_cards.isEmpty) {
      return const Center(child: Text('등록된 카드가 없습니다.'));
    }
    return _buildCardSwiper();
  }

  // Dribbble 스타일 카드 스와이퍼
  Widget _buildCardSwiper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // BC 카드 비율 기준 (ISO 7810 ID-1: 85.6mm × 53.98mm = 1.586)
          final cardWidth = constraints.maxWidth;
          final cardHeight = cardWidth / 1.586;

          return SizedBox(
            height: cardHeight + 50, // 스택 공간
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: _cards.length,
              numberOfCardsDisplayed: math.min(3, _cards.length),
              backCardOffset: const Offset(0, 24), // 뒤 카드 상승 폭 완화
              padding: EdgeInsets.zero, // 카드 비율 유지
              scale: 0.95, // 뒤→앞 전환 확대 폭 완화
              onSwipe: _onSwipe,
              duration: const Duration(milliseconds: 240), // 부드러운 전환
              threshold: 50,
              maxAngle: 35, // angle.gif 스타일: 회전 효과
              allowedSwipeDirection: const AllowedSwipeDirection.symmetric(
                horizontal: true,
                vertical: false,
              ),
              cardBuilder:
                  (
                    context,
                    index,
                    horizontalOffsetPercentage,
                    verticalOffsetPercentage,
                  ) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: _buildCreditCard(
                          context,
                          _cards[index],
                          horizontalOffsetPercentage.toDouble(),
                        ),
                      ),
                    );
                  },
            ),
          );
        },
      ),
    );
  }

  WalletCard _toWalletCard(UserCardInfo card) {
    final style = _getCardStyle(card.company);
    final assetImage = _assetCardImage(card.company);
    return WalletCard(
      color: style.baseColor,
      label: card.cardName,
      bankName: card.company,
      maskedNumber: card.cardNumber,
      imagePath: assetImage ?? (card.cardImageUrl.isNotEmpty ? card.cardImageUrl : null),
    );
  }

  // 심플한 카드 디자인 (CardSwiper 기본 애니메이션 활용)
  Widget _buildCreditCard(
    BuildContext context,
    UserCardInfo card,
    double horizontalOffset,
  ) {
    final style = _getCardStyle(card.company);
    final imagePath =
        _assetCardImage(card.company) ?? (card.cardImageUrl.isNotEmpty ? card.cardImageUrl : null);
    final rotateImage = _shouldRotateCardImage(card.company);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder<void>(
            transitionDuration: const Duration(milliseconds: 320),
            reverseTransitionDuration: const Duration(milliseconds: 260),
            pageBuilder: (context, animation, secondaryAnimation) {
              return CardDetailPage(card: _toWalletCard(card));
            },
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.02, 0.04),
                    end: Offset.zero,
                  ).animate(curved);
                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: style.gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: style.baseColor.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: imagePath == null
              ? _buildFallbackCard(style, card)
              : _buildImageCard(imagePath, style, card, rotateImage),
        ),
      ),
    );
  }

  Widget _buildImageCard(
    String imagePath,
    _CardStyle style,
    UserCardInfo card,
    bool rotateImage,
  ) {
    if (imagePath.startsWith('http')) {
      final image = Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _buildFallbackCard(style, card),
      );
      return _wrapCardImage(image, rotateImage);
    }
    final image = Image.asset(
      imagePath,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => _buildFallbackCard(style, card),
    );
    return _wrapCardImage(image, rotateImage);
  }

  Widget _wrapCardImage(Widget image, bool rotateImage) {
    if (!rotateImage) return image;
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Transform.rotate(
              angle: -math.pi / 2,
              child: SizedBox(
                width: constraints.maxHeight,
                height: constraints.maxWidth,
                child: image,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackCard(_CardStyle style, UserCardInfo card) {
    return Stack(
      children: [
        // 워터마크 텍스트
        Center(
          child: Text(
            'subscribe',
            style: TextStyle(
              color: style.textColor.withOpacity(0.08),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        // 카드 내용
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.company,
                style: TextStyle(
                  color: style.textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card.cardName,
                style: TextStyle(
                  color: style.textColor.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              _buildRealisticChip(),
              const SizedBox(height: 6),
            ],
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

  _CardStyle _getCardStyle(String company) {
    final normalized = company.toLowerCase();

    Color baseColor = const Color(0xFF4A5568);
    if (normalized.contains('kb') || normalized.contains('국민')) {
      baseColor = const Color(0xFF6B7C93);
    } else if (normalized.contains('토스') || normalized.contains('toss')) {
      baseColor = const Color(0xFF146CFF);
    } else if (normalized.contains('신한') || normalized.contains('shinhan')) {
      baseColor = const Color(0xFF0D4EFF);
    } else if (normalized.contains('하나') || normalized.contains('hana')) {
      baseColor = const Color(0xFF008773);
    } else if (normalized.contains('삼성') || normalized.contains('samsung')) {
      baseColor = const Color(0xFF1B2A6B);
    } else if (normalized.contains('현대') || normalized.contains('hyundai')) {
      baseColor = const Color(0xFF173A6B);
    } else if (normalized.contains('bc')) {
      baseColor = const Color(0xFFE11D48);
    } else if (normalized.contains('롯데') || normalized.contains('lotte')) {
      baseColor = const Color(0xFFE60012);
    } else if (normalized.contains('우리') || normalized.contains('woori')) {
      baseColor = const Color(0xFF0B63B6);
    } else if (normalized.contains('농협') || normalized.contains('nh')) {
      baseColor = const Color(0xFF0B8F5B);
    } else if (normalized.contains('카카오') || normalized.contains('kakao')) {
      baseColor = const Color(0xFFFEE500);
    }

    final textColor = baseColor.computeLuminance() > 0.6
        ? const Color(0xFF1F2937)
        : Colors.white;

    return _CardStyle(
      baseColor: baseColor,
      textColor: textColor,
      gradientColors: [
        baseColor,
        Color.lerp(baseColor, Colors.black, 0.18) ?? baseColor,
      ],
    );
  }

  // 리얼리스틱 EMV 칩
  Widget _buildRealisticChip() {
    return Container(
      width: 50,
      height: 38,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF2F2F2),
            Color(0xFFD9D9D9),
            Color(0xFFBFBFBF),
            Color(0xFFD9D9D9),
            Color(0xFFF2F2F2),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
        border: Border.all(color: const Color(0xFFB0B0B0), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 2,
            offset: const Offset(1, 1),
          ),
        ],
      ),
      child: CustomPaint(painter: _RealisticChipPainter()),
    );
  }
}

class _CardStyle {
  final Color baseColor;
  final Color textColor;
  final List<Color> gradientColors;

  const _CardStyle({
    required this.baseColor,
    required this.textColor,
    required this.gradientColors,
  });
}

// 리얼리스틱 EMV 칩 패턴
class _RealisticChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B7355)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final fillPaint = Paint()
      ..color = const Color(0xFFBFAF8F).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 중앙 사각형
    final centerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.5),
        width: size.width * 0.35,
        height: size.height * 0.45,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(centerRect, fillPaint);
    canvas.drawRRect(centerRect, paint);

    // 좌측 연결부
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.2);
      canvas.drawLine(
        Offset(size.width * 0.08, y),
        Offset(size.width * 0.32, y),
        paint,
      );
    }

    // 우측 연결부
    for (int i = 0; i < 4; i++) {
      final y = size.height * (0.2 + i * 0.2);
      canvas.drawLine(
        Offset(size.width * 0.68, y),
        Offset(size.width * 0.92, y),
        paint,
      );
    }

    // 상단 연결부
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.08),
      Offset(size.width * 0.5, size.height * 0.27),
      paint,
    );

    // 하단 연결부
    canvas.drawLine(
      Offset(size.width * 0.5, size.height * 0.73),
      Offset(size.width * 0.5, size.height * 0.92),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// EMV 칩 패턴을 그리는 CustomPainter (기본)
class ChipPatternPainter extends CustomPainter {
  final Color chipColor;

  ChipPatternPainter(this.chipColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chipColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final rectWidth = size.width * 0.15;
    final rectHeight = size.height * 0.2;
    final spacing = size.width * 0.1;

    for (
      double x = spacing;
      x < size.width - spacing;
      x += rectWidth + spacing * 0.5
    ) {
      for (
        double y = spacing;
        y < size.height - spacing;
        y += rectHeight + spacing * 0.5
      ) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, rectWidth, rectHeight),
            const Radius.circular(2),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 심플한 EMV 칩 디자인
class SimpleChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFFB8A070)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 수직선 (왼쪽)
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.35, size.height * 0.85),
      linePaint,
    );

    // 수직선 (오른쪽)
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.15),
      Offset(size.width * 0.65, size.height * 0.85),
      linePaint,
    );

    // 수평선 (상단)
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.35),
      Offset(size.width * 0.85, size.height * 0.35),
      linePaint,
    );

    // 수평선 (하단)
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.65),
      Offset(size.width * 0.85, size.height * 0.65),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- Bottom Navigation ---
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 32),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF000000).withOpacity(0.9)
            : Colors.white.withOpacity(0.95),
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_filled, "Home", true),
          _buildNavItem(context, Icons.credit_card, "Cards", false),
          _buildNavItem(context, Icons.play_circle_outline, "Subs", false),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
  ) {
    final color = isActive
        ? Theme.of(context).colorScheme.primary
        : Colors.grey;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
