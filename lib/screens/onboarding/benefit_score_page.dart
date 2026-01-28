import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/user.dart';
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
              {"text": prompt}
            ]
          }
        ]
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
              const SizedBox(height: 32),
              const SpendingReportSection(),
              const SizedBox(height: 8),
              const BenefitSummarySection(),
              const SizedBox(height: 40),
              // 카드 섹션 (2/3만 보이게)
              const Expanded(child: CardWalletSection()),
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
                          color: isDark ? const Color(0xFF3A3A3C) : Colors.grey[400]!,
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
                    _buildCategoryRow(
                      "Food",
                      "45%",
                      Colors.blue[600]!,
                      isDark,
                    ),
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
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
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
        )
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
            math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi)) *
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
            math.sin((i / size.width * 2 * math.pi) +
                    (animationValue * 2 * math.pi) +
                    2) * // Phase shift
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
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                      child: Icon(Icons.info_outline, size: 16, color: iconColor),
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

// --- 3. Card Wallet (카드 지갑) ---
class CardWalletSection extends StatefulWidget {
  const CardWalletSection({super.key});

  @override
  State<CardWalletSection> createState() => _CardWalletSectionState();
}

class _CardWalletSectionState extends State<CardWalletSection>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isGridView = false;
  List<UserCardInfo> _cards = [];
  bool _isLoading = true;
  String? _error;

  // 스와이프 애니메이션을 위한 컨트롤러
  late AnimationController _animationController;
  double _dragOffset = 0.0; // 현재 드래그 오프셋 (픽셀)
  double _dragVelocity = 0.0; // 드래그 속도

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadCards();
  }

  @override
  void dispose() {
    _animationController.dispose();
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

  // 부드러운 스프링 효과 애니메이션 실행
  void _runSpringAnimation(double targetOffset) {
    final startOffset = _dragOffset;
    
    // Tween 기반 애니메이션 (부드러운 감속)
    final Animation<double> animation = Tween<double>(
      begin: startOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _animationController,
      // 더 부드러운 커브 사용
      curve: Curves.easeOutExpo,
    ));

    void listener() {
      if (!mounted) return;
      setState(() {
        _dragOffset = animation.value;
      });
    }

    void statusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _animationController.removeListener(listener);
        _animationController.removeStatusListener(statusListener);
        if (!mounted) return;
        setState(() {
          _dragOffset = 0.0;
        });
      }
    }

    _animationController.removeStatusListener(statusListener);
    _animationController.removeListener(listener);
    _animationController.addListener(listener);
    _animationController.addStatusListener(statusListener);
    
    // 애니메이션 실행 (더 긴 duration으로 부드럽게)
    _animationController.reset();
    _animationController.duration = const Duration(milliseconds: 600);
    _animationController.forward();
  }

  // 드래그 종료 시 다음/이전 카드로 스냅
  void _onDragEnd(double velocity, double cardWidth) {
    _dragVelocity = velocity;
    final threshold = cardWidth * 0.25; // 25% 이상 드래그하면 다음 카드로

    if (_dragOffset < -threshold || velocity < -500) {
      // 오른쪽에서 왼쪽으로 스와이프 → 다음 카드
      if (_currentIndex < _cards.length - 1) {
        setState(() {
          _currentIndex++;
        });
        _runSpringAnimation(0);
      } else {
        // 마지막 카드면 원래 위치로
        _runSpringAnimation(0);
      }
    } else if (_dragOffset > threshold || velocity > 500) {
      // 왼쪽에서 오른쪽으로 스와이프 → 이전 카드
      if (_currentIndex > 0) {
        setState(() {
          _currentIndex--;
        });
        _runSpringAnimation(0);
      } else {
        // 첫 번째 카드면 원래 위치로
        _runSpringAnimation(0);
      }
    } else {
      // 임계값 미달 → 원래 위치로 복귀
      _runSpringAnimation(0);
    }
  }

  // 인디케이터 탭 시 해당 인덱스로 스무스하게 이동
  void _animateToIndex(int targetIndex) {
    if (targetIndex == _currentIndex) return;
    
    setState(() {
      _currentIndex = targetIndex;
      _dragOffset = 0;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "My Wallet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  // 그리드/스택 뷰 토글 버튼
                  if (_cards.isNotEmpty && !_isLoading)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isGridView = !_isGridView;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isGridView
                              ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _isGridView ? Icons.view_agenda : Icons.grid_view_rounded,
                          size: 16,
                          color: _isGridView
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[400],
                        ),
                      ),
                    ),
                  if (_cards.isNotEmpty && !_isLoading) ...[
                    const SizedBox(width: 12),
                    // 인디케이터 dots (스택 뷰일 때만 표시)
                    if (!_isGridView)
                      ...List.generate(
                        _cards.length,
                        (index) => GestureDetector(
                          onTap: () {
                            // 해당 인덱스로 스무스하게 이동
                            _animateToIndex(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(left: 4),
                            width: _currentIndex == index ? 20 : 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _currentIndex == index
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey[600],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(child: _buildContent()),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingState();
    }
    if (_error != null) {
      return _buildErrorState();
    }
    if (_cards.isEmpty) {
      return _buildEmptyState();
    }
    return _isGridView ? _buildGridView() : _buildStackView();
  }

  _CardVisualStyle _cardVisualStyle(UserCardInfo card) {
    final bgColor = _companyBaseColor(card.company);
    final textColor =
        bgColor.computeLuminance() > 0.6 ? Colors.black87 : Colors.white;
    final accentColor =
        card.company.contains('BC') || card.cardName.contains('BC')
            ? const Color(0xFFDC143C)
            : Colors.white;
    return _CardVisualStyle(
      bgColor: bgColor,
      accentColor: accentColor,
      textColor: textColor,
      chipColor: const Color(0xFFC0C0C0),
    );
  }

  Color _companyBaseColor(String company) {
    final normalized = company.toLowerCase();
    if (normalized.contains('kb') || normalized.contains('국민')) {
      return const Color(0xFFB8860B);
    }
    if (normalized.contains('신한') || normalized.contains('shinhan')) {
      return const Color(0xFF8B4C9F);
    }
    if (normalized.contains('하나') || normalized.contains('hana')) {
      return const Color(0xFF4A90E2);
    }
    if (normalized.contains('bc')) {
      return const Color(0xFFE8E8E8);
    }
    return const Color(0xFFB0B0B0);
  }

  String _maskCardNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) {
      return '**** **** **** ****';
    }
    final last4 = digits.substring(digits.length - 4);
    return '**** **** **** $last4';
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error ?? '카드 정보를 불러올 수 없습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _loadCards,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '등록된 카드가 없습니다.',
        style: TextStyle(fontSize: 14),
      ),
    );
  }

  // 스택 뷰 (겹쳐진 카드 + 스프링 물리 애니메이션)
  Widget _buildStackView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const bottomReserve = 8.0;
        final availableHeight = (constraints.maxHeight - bottomReserve).clamp(0.0, double.infinity);
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth - 80;
        final fullCardHeight = cardWidth * 1.4;
        final visibleHeight = math.min(availableHeight, fullCardHeight);

        // 드래그 진행률 (-1 ~ 1 사이, -1은 완전히 왼쪽, 1은 완전히 오른쪽)
        final dragProgress = (_dragOffset / cardWidth).clamp(-1.0, 1.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: availableHeight,
              child: GestureDetector(
                onHorizontalDragStart: (_) {
                  _animationController.stop();
                },
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dragOffset += details.delta.dx;
                    // 첫 번째/마지막 카드에서 저항감 추가
                    if ((_currentIndex == 0 && _dragOffset > 0) ||
                        (_currentIndex == _cards.length - 1 && _dragOffset < 0)) {
                      _dragOffset *= 0.3; // 저항감
                    }
                  });
                },
                onHorizontalDragEnd: (details) {
                  _onDragEnd(details.primaryVelocity ?? 0, cardWidth);
                },
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // 뒤에 있는 카드들 (최대 2장만 표시)
                    for (int i = math.min(_currentIndex + 2, _cards.length - 1);
                        i > _currentIndex;
                        i--)
                      _buildStackedCard(
                        context: context,
                        index: i,
                        cardWidth: cardWidth,
                        visibleHeight: visibleHeight,
                        fullCardHeight: fullCardHeight,
                        dragProgress: dragProgress,
                        stackPosition: i - _currentIndex,
                      ),
                    
                    // 이전 카드 (왼쪽으로 스와이프 시 보임)
                    if (_currentIndex > 0 && dragProgress > 0)
                      _buildPreviousCard(
                        context: context,
                        cardWidth: cardWidth,
                        visibleHeight: visibleHeight,
                        fullCardHeight: fullCardHeight,
                        dragProgress: dragProgress,
                      ),
                    
                    // 현재 카드 (가장 앞)
                    _buildCurrentCard(
                      context: context,
                      cardWidth: cardWidth,
                      visibleHeight: visibleHeight,
                      fullCardHeight: fullCardHeight,
                      dragProgress: dragProgress,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: bottomReserve),
          ],
        );
      },
    );
  }

  // 현재 카드 (가장 앞에 있는 카드)
  Widget _buildCurrentCard({
    required BuildContext context,
    required double cardWidth,
    required double visibleHeight,
    required double fullCardHeight,
    required double dragProgress,
  }) {
    // 드래그에 따른 X 이동
    final translateX = _dragOffset;
    // 드래그에 따른 회전 (최대 15도)
    final rotation = dragProgress * 0.15;
    // 드래그 시 약간 위로 올라가는 효과
    final translateY = -dragProgress.abs() * 20;

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // 원근감
        ..translate(translateX, translateY)
        ..rotateZ(rotation),
      child: Container(
        width: cardWidth,
        height: visibleHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: fullCardHeight,
            child: _buildVerticalCreditCard(
              context,
              _cards[_currentIndex],
            ),
          ),
        ),
      ),
    );
  }

  // 뒤에 겹쳐진 카드들
  Widget _buildStackedCard({
    required BuildContext context,
    required int index,
    required double cardWidth,
    required double visibleHeight,
    required double fullCardHeight,
    required double dragProgress,
    required int stackPosition,
  }) {
    // 스택 위치에 따른 오프셋 (오른쪽으로 살짝씩 밀림)
    final baseOffsetX = stackPosition * 15.0;
    // 스택 위치에 따른 스케일 (뒤로 갈수록 작아짐)
    final baseScale = 1.0 - (stackPosition * 0.05);
    // 스택 위치에 따른 투명도
    final baseOpacity = 1.0 - (stackPosition * 0.2);
    
    // 드래그 시 다음 카드가 앞으로 나오는 효과
    final dragEffect = (-dragProgress).clamp(0.0, 1.0);
    final scale = baseScale + (dragEffect * 0.05 * (stackPosition == 1 ? 1 : 0.5));
    final offsetX = baseOffsetX - (dragEffect * baseOffsetX * (stackPosition == 1 ? 1 : 0.5));
    final opacity = (baseOpacity + (dragEffect * 0.2)).clamp(0.0, 1.0);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(offsetX, 0.0)
        ..scale(scale),
      child: Opacity(
        opacity: opacity,
        child: Container(
          width: cardWidth,
          height: visibleHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: fullCardHeight,
              child: _buildVerticalCreditCard(
                context,
                _cards[index],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 이전 카드 (왼쪽에서 나타남)
  Widget _buildPreviousCard({
    required BuildContext context,
    required double cardWidth,
    required double visibleHeight,
    required double fullCardHeight,
    required double dragProgress,
  }) {
    // 오른쪽으로 드래그할 때만 보임
    final appearProgress = dragProgress.clamp(0.0, 1.0);
    // 왼쪽에서 들어오는 효과
    final translateX = -cardWidth * (1 - appearProgress * 0.8);
    // 들어오면서 스케일 증가
    final scale = 0.9 + (appearProgress * 0.1);
    // 회전 효과
    final rotation = -0.15 * (1 - appearProgress);

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..translate(translateX, 0.0)
        ..scale(scale)
        ..rotateZ(rotation),
      child: Opacity(
        opacity: appearProgress,
        child: Container(
          width: cardWidth,
          height: visibleHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: OverflowBox(
              alignment: Alignment.topCenter,
              maxHeight: fullCardHeight,
              child: _buildVerticalCreditCard(
                context,
                _cards[_currentIndex - 1],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 그리드 뷰 (전체 카드 목록)
  Widget _buildGridView() {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        ),
        cacheExtent: 500, // 미리 렌더링할 영역
        itemCount: _cards.length,
        itemBuilder: (context, index) {
          final card = _cards[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                _currentIndex = index;
                _isGridView = false;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildHorizontalCreditCard(context, card),
            ),
          );
        },
      ),
    );
  }

  // 가로 카드 (그리드 뷰용)
  Widget _buildHorizontalCreditCard(
    BuildContext context,
    UserCardInfo card,
  ) {
    final style = _cardVisualStyle(card);
    final bgColor = style.bgColor;
    final textColor = style.textColor;
    final chipColor = style.chipColor;
    final name = card.cardName;
    final sub = card.company;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            Color.lerp(bgColor, Colors.black, 0.15) ?? bgColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                // EMV 칩
                Container(
                  width: 40,
                  height: 30,
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: CustomPaint(
                    painter: ChipPatternPainter(chipColor),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _maskCardNumber(card.cardNumber),
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                letterSpacing: 2,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'VALID THRU',
                  style: TextStyle(
                    color: textColor.withOpacity(0.6),
                    fontSize: 8,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '12/28',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 세로 카드 (스택 뷰용)
  Widget _buildVerticalCreditCard(
    BuildContext context,
    UserCardInfo card, {
    Key? key,
  }) {
    final style = _cardVisualStyle(card);
    final bgColor = style.bgColor;
    final accentColor = style.accentColor;
    final textColor = style.textColor;
    final chipColor = style.chipColor;
    final name = card.cardName;
    final sub = card.company;

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 80; // 스택 뷰와 동일
    final cardHeight = cardWidth * 1.4;

    return Container(
      key: key,
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            Color.lerp(bgColor, Colors.black, 0.15) ?? bgColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카드 이름
            Text(
              name,
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(
                color: textColor.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const Spacer(),
            // EMV 칩 (세로 방향)
            Container(
              width: 40,
              height: 48,
              decoration: BoxDecoration(
                color: chipColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: CustomPaint(
                painter: ChipPatternPainter(chipColor),
              ),
            ),
            const SizedBox(height: 16),
            // 카드 번호
            Text(
              _maskCardNumber(card.cardNumber),
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            // 유효기간
            Row(
              children: [
                Text(
                  'VALID\nTHRU',
                  style: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 7,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '12/28',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // BC 카드 로고 (해당하는 경우)
            if (card.company.contains('BC') || card.cardName.contains('BC'))
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'BC',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
}

class _CardVisualStyle {
  final Color bgColor;
  final Color accentColor;
  final Color textColor;
  final Color chipColor;

  const _CardVisualStyle({
    required this.bgColor,
    required this.accentColor,
    required this.textColor,
    required this.chipColor,
  });
}

// EMV 칩 패턴을 그리는 CustomPainter
class ChipPatternPainter extends CustomPainter {
  final Color chipColor;

  ChipPatternPainter(this.chipColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = chipColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // 칩 내부 패턴 그리기
    final rectWidth = size.width * 0.15;
    final rectHeight = size.height * 0.2;
    final spacing = size.width * 0.1;

    for (double x = spacing; x < size.width - spacing; x += rectWidth + spacing * 0.5) {
      for (double y = spacing; y < size.height - spacing; y += rectHeight + spacing * 0.5) {
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
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey[200]!,
          ),
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
    final color = isActive ? Theme.of(context).colorScheme.primary : Colors.grey;
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
