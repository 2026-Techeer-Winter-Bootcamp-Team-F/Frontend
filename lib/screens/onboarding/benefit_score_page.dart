import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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
              const SizedBox(height: 40),
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
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // 받은 혜택
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.blue[400],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '받은 혜택',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₩12,500',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          // 구분선
          Container(
            width: 1,
            height: 40,
            color: isDark ? Colors.grey[700] : Colors.grey[300],
          ),
          // 놓친 혜택
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: subTextColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '놓친 혜택',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₩2,100',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
          // 정보 아이콘
          GestureDetector(
            onTap: () {
              // 정보 표시
            },
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.grey[600]! : Colors.grey[400]!,
                ),
              ),
              child: Icon(
                Icons.info_outline,
                size: 16,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
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

class _CardWalletSectionState extends State<CardWalletSection> {
  int _currentIndex = 0;
  bool _isGridView = false; // 그리드 뷰 토글
  
  final List<Map<String, dynamic>> _cards = [
    {
      "id": 1,
      "name": "KB KOOKMIN",
      "sub": "청춘대로 | 톡톡",
      "bgColor": const Color(0xFF6B7A8F), // 파란-회색 계열
      "accentColor": Colors.white,
      "textColor": Colors.white,
      "chipColor": const Color(0xFFC0C0C0), // 은색 칩
    },
    {
      "id": 2,
      "name": "BC CARD",
      "sub": "VALID THRU",
      "bgColor": const Color(0xFFE8E8E8), // 회색 계열
      "accentColor": const Color(0xFFDC143C), // 빨간색 BC 로고
      "textColor": const Color(0xFF333333),
      "chipColor": const Color(0xFFC0C0C0),
    },
    {
      "id": 3,
      "name": "ShinhanCard",
      "sub": "Deep Making",
      "bgColor": const Color(0xFF8B4C9F), // 보라색 계열
      "accentColor": Colors.white,
      "textColor": Colors.white,
      "chipColor": const Color(0xFFFFD700), // 금색 칩
    },
    {
      "id": 4,
      "name": "KEB Hana Card",
      "sub": "toss",
      "bgColor": const Color(0xFF4A90E2), // 파란색 계열
      "accentColor": Colors.white,
      "textColor": Colors.white,
      "chipColor": const Color(0xFFC0C0C0),
    },
  ];

  void _goToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

  void _goToNext() {
    if (_currentIndex < _cards.length - 1) {
      setState(() {
        _currentIndex++;
      });
    }
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
                  const SizedBox(width: 12),
                  // 인디케이터 dots (스택 뷰일 때만 표시)
                  if (!_isGridView)
                    ...List.generate(
                      _cards.length,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                          });
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
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 그리드 뷰 또는 스택 뷰
        Expanded(
          child: _isGridView ? _buildGridView() : _buildStackView(),
        ),
      ],
    );
  }

  // 스택 뷰 (겹쳐진 카드)
  Widget _buildStackView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final cardWidth = screenWidth - 80;
        final fullCardHeight = cardWidth * 1.4; // 카드 높이 비율 조정
        final visibleHeight = constraints.maxHeight + 20; // 더 많이 보이도록
        
        return GestureDetector(
          onTapUp: (details) {
            final tapX = details.localPosition.dx;
            if (tapX < screenWidth / 3) {
              _goToPrevious();
            } else {
              _goToNext();
            }
          },
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                _goToPrevious();
              } else if (details.primaryVelocity! < 0) {
                _goToNext();
              }
            }
          },
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (int i = _cards.length - 1; i >= 0; i--)
                  if (i != _currentIndex)
                    Positioned(
                      left: 24 + (i - _currentIndex).abs() * 8.0,
                      top: 0,
                      child: Transform.translate(
                        offset: Offset(
                          i > _currentIndex ? (i - _currentIndex) * 12.0 : 0,
                          0,
                        ),
                        child: Opacity(
                          opacity: i > _currentIndex ? 0.7 : 0.0,
                          child: SizedBox(
                            width: cardWidth,
                            height: visibleHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: OverflowBox(
                                alignment: Alignment.topCenter,
                                maxHeight: fullCardHeight,
                                child: _buildVerticalCreditCard(
                                  context,
                                  _cards[i],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ),
              Positioned(
                left: 24,
                top: 0,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    key: ValueKey<int>(_currentIndex),
                    width: cardWidth,
                    height: visibleHeight,
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
                ),
              ),
              ],
            ),
          ),
        );
      },
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
    Map<String, dynamic> card,
  ) {
    final bgColor = card['bgColor'] as Color? ?? Colors.grey[300]!;
    final textColor = card['textColor'] as Color? ?? Colors.white;
    final chipColor = card['chipColor'] as Color? ?? const Color(0xFFC0C0C0);
    final name = card['name'] as String? ?? 'CARD';
    final sub = card['sub'] as String? ?? '';

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
              '**** **** **** ****',
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
    Map<String, dynamic> card, {
    Key? key,
  }) {
    final bgColor = card['bgColor'] as Color? ?? Colors.grey[300]!;
    final accentColor = card['accentColor'] as Color? ?? Colors.blue;
    final textColor = card['textColor'] as Color? ?? Colors.white;
    final chipColor = card['chipColor'] as Color? ?? const Color(0xFFC0C0C0);
    final name = card['name'] as String? ?? 'CARD';
    final sub = card['sub'] as String? ?? '';

    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 80; // 스택 뷰와 동일
    // 세로 카드 비율 조정
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
              '**** **** **** ****',
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
            if (name.contains('BC'))
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

  Widget _buildCreditCard(
    BuildContext context,
    Map<String, dynamic> card,
    bool isTop, {
    Key? key,
  }) {
    // 카드 색상 정보 가져오기
    final bgColor = card['bgColor'] as Color? ?? Colors.grey[300]!;
    final accentColor = card['accentColor'] as Color? ?? Colors.blue;
    final textColor = card['textColor'] as Color? ?? Colors.white;
    final chipColor = card['chipColor'] as Color? ?? const Color(0xFFC0C0C0);
    final name = card['name'] as String? ?? 'CARD';
    final sub = card['sub'] as String? ?? '';
    
    // 사용 가능한 높이의 약 1/3로 제한 (하단 네비게이션 바 고려)
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight * 0.3;
    final cardHeight = math.min(availableHeight, 240.0);
    
    // 카드 비율 계산 (일반적인 카드 비율은 85.60mm x 53.98mm, 약 1.585:1)
    final cardWidth = MediaQuery.of(context).size.width - 48; // 좌우 패딩 제외
    final aspectRatio = 1.585; // 카드 비율
    final calculatedHeight = cardWidth / aspectRatio;
    final finalHeight = math.min(cardHeight, calculatedHeight);

    return Container(
      key: key,
      height: finalHeight,
      width: cardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgColor,
            bgColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // 카드 내용
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 상단: 카드 이름과 칩
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (sub.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              sub,
                              style: TextStyle(
                                color: textColor.withOpacity(0.8),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // EMV 칩
                    Container(
                      width: 48,
                      height: 36,
                      decoration: BoxDecoration(
                        color: chipColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: chipColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: CustomPaint(
                        painter: ChipPatternPainter(chipColor),
                      ),
                    ),
                  ],
                ),
                // 하단: 카드 번호 (선택적)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "**** **** ****",
                      style: TextStyle(
                        color: textColor.withOpacity(0.6),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 2,
                      ),
                    ),
                    if (card['id'] == 2) // BC 카드인 경우
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            "BC",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
