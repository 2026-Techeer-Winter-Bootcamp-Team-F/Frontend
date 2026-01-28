import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:my_app/models/card.dart';
import 'package:my_app/models/card_recommendation.dart';
import 'package:my_app/screens/cards/card_detail_page.dart';
import 'package:my_app/screens/cards/recommended_card_detail_page.dart';
import 'package:my_app/services/card_service.dart';

class CardAnalysisPage extends StatefulWidget {
  const CardAnalysisPage({super.key});

  @override
  State<CardAnalysisPage> createState() => _CardAnalysisPageState();
}

class _CardAnalysisPageState extends State<CardAnalysisPage> {
  static const double _cardAspectRatio = 1.586; // 85.60mm x 53.98mm

  // 샘플 카드 이미지 (assets)
  static const List<String> _sampleCardImages = [
    'assets/images/samsung_select_all_card.png',
    'assets/images/sinhan_mr_life.png',
  ];

  final CardService _cardService = CardService();

  // 내 카드 목록
  final List<WalletCard> _cards = [];
  bool _isLoadingCards = true;
  String? _cardsError;

  // 추천 카드 목록
  List<CategoryRecommendation> _recommendations = [];
  bool _isLoadingRecommendations = true;
  String? _recommendationsError;

  final ScrollController _scrollController = ScrollController();
  final CarouselSliderController _carouselController = CarouselSliderController();
  int _currentCardIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCards(),
      _loadRecommendations(),
    ]);
  }

  Future<void> _loadCards() async {
    try {
      setState(() {
        _isLoadingCards = true;
        _cardsError = null;
      });
      final cards = await _cardService.getMyCards();
      if (!mounted) return;
      setState(() {
        _cards
          ..clear()
          ..addAll(cards.asMap().entries.map((e) => _toWalletCardWithIndex(e.value, e.key)));
        _isLoadingCards = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cardsError = '카드 정보를 불러올 수 없습니다.';
        _isLoadingCards = false;
      });
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoadingRecommendations = true;
        _recommendationsError = null;
      });
      final response = await _cardService.getRecommendations();
      if (!mounted) return;
      setState(() {
        _recommendations = response.categories;
        _isLoadingRecommendations = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _recommendationsError = '추천 카드를 불러올 수 없습니다.';
        _isLoadingRecommendations = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet swiper (패딩 없이 전체 너비)
              SizedBox(
                width: double.infinity,
                height: _walletSectionHeight(context),
                child: _buildWalletContent(context),
              ),

              const SizedBox(height: 28),

              // 이하 컨텐츠는 패딩 적용
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header text
                    Text(
                      '이 카드는 어때요?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '3개월 간 카테고리 별 소비 기준 카드 실익률 분석을 제공합니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Recommendation sections
                    _buildRecommendationsContent(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecommendationsContent(BuildContext context) {
    if (_isLoadingRecommendations) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_recommendationsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _recommendationsError!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadRecommendations,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    if (_recommendations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            '추천 카드가 없습니다.\n최근 3개월간 거래 내역이 필요합니다.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    return Column(
      children: _recommendations
          .map((category) => _buildRecommendationSection(context, category))
          .toList(),
    );
  }

  Widget _buildWalletContent(BuildContext context) {
    if (_isLoadingCards) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_cardsError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _cardsError ?? '카드 정보를 불러올 수 없습니다.',
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
    if (_cards.isEmpty) {
      return const Center(
        child: Text(
          '등록된 카드가 없습니다.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    return _buildCardSwiper(context);
  }

  Widget _buildCardSwiper(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 60;
    final cardHeight = cardWidth / _cardAspectRatio;

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _carouselController,
          itemCount: _cards.length,
          options: CarouselOptions(
            height: cardHeight + 16,
            viewportFraction: 0.85,
            enlargeCenterPage: true,
            enlargeFactor: 0.2,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() => _currentCardIndex = index);
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final card = _cards[index];
            return _buildSwipeCard(context, card, index);
          },
        ),
        const SizedBox(height: 16),
        // 페이지 인디케이터
        if (_cards.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_cards.length, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentCardIndex == index ? 20 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentCardIndex == index
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
      ],
    );
  }

  Widget _buildSwipeCard(BuildContext context, WalletCard card, int index) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: AspectRatio(
          aspectRatio: _cardAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 카드 이미지
                  if (card.imagePath != null)
                    Image.asset(
                      card.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: card.color,
                      ),
                    )
                  else
                    Container(color: card.color),
                  // 오버레이 정보
                  Positioned(
                    right: 16,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        card.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.bankName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          card.maskedNumber,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            shadows: [
                              Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _walletSectionHeight(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 60;
    final cardHeight = cardWidth > 0 ? cardWidth / _cardAspectRatio : 200.0;
    // PageView 높이 + 인디케이터 영역
    final indicatorHeight = _cards.length > 1 ? 32.0 : 0.0;
    return cardHeight + indicatorHeight + 32;
  }

  WalletCard _toWalletCardWithIndex(MyCardInfo info, int index) {
    final last4 = _extractLast4(info.cardNumber);
    // 샘플 이미지 순환 적용
    final sampleImage = _sampleCardImages[index % _sampleCardImages.length];
    return WalletCard(
      color: _companyColor(info.company),
      label: '${_shortCompanyName(info.company)} $last4',
      bankName: info.company,
      maskedNumber: '**** $last4',
      imagePath: sampleImage,
    );
  }

  String _extractLast4(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) return '****';
    return digits.substring(digits.length - 4);
  }

  Color _companyColor(String company) {
    final normalized = company.toLowerCase();
    if (normalized.contains('신한')) return const Color(0xFFECECEC);
    if (normalized.contains('토스')) return const Color(0xFFEFF66A);
    if (normalized.contains('bc') || normalized.contains('비씨')) {
      return const Color(0xFFF2F2F4);
    }
    if (normalized.contains('국민') || normalized.contains('kb')) {
      return const Color(0xFFBFCFE6);
    }
    if (normalized.contains('하나')) return const Color(0xFF4A90E2);
    return const Color(0xFFE0E0E0);
  }

  String _shortCompanyName(String company) {
    if (company.contains('신한')) return '신한';
    if (company.contains('토스')) return '토스';
    if (company.contains('비씨') || company.contains('BC')) return '비씨';
    if (company.contains('국민') || company.contains('KB')) return '국민';
    if (company.contains('하나')) return '하나';
    return company.replaceAll('카드', '');
  }

  Widget _buildRecommendationSection(BuildContext context, CategoryRecommendation category) {
    // 연회비 없는 카드 (왼쪽)와 연회비 있는 카드 (오른쪽) 분리
    final freeCards = category.recommendedCards.where((c) => c.annualFee == 0).toList();
    final paidCards = category.recommendedCards.where((c) => c.annualFee > 0).toList();

    // 각각 첫 번째 카드만 선택
    final RecommendedCard? freeCard = freeCards.isNotEmpty ? freeCards.first : null;
    final RecommendedCard? paidCard = paidCards.isNotEmpty ? paidCards.first : null;

    // 표시할 카드가 없으면 섹션 숨김
    if (freeCard == null && paidCard == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  category.categoryName,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Text(
              '월평균 ${_formatWon(category.monthlyAverage)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // 왼쪽: 연회비 무료 카드
            Expanded(
              child: freeCard != null
                  ? _RecommendationCard(card: freeCard, showAnnualFee: false)
                  : _buildEmptyCard(context, '연회비 무료 카드 없음'),
            ),
            const SizedBox(width: 12),
            // 오른쪽: 연회비 유료 카드
            Expanded(
              child: paidCard != null
                  ? _RecommendationCard(card: paidCard, showAnnualFee: true)
                  : _buildEmptyCard(context, '연회비 유료 카드 없음'),
            ),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  Widget _buildEmptyCard(BuildContext context, String message) {
    return AspectRatio(
      aspectRatio: 0.95,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Text(
            message,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  String _formatWon(int value) {
    final s = value.toString();
    final out = s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '$out원';
  }
}

class WalletCard {
  final Color color;
  final String label;
  final String bankName;
  final String maskedNumber;
  final String? imagePath;

  const WalletCard({
    this.imagePath,
    required this.color,
    required this.label,
    this.bankName = '카드',
    this.maskedNumber = '',
  });
}

class _RecommendationCard extends StatelessWidget {
  static const double _cardAspectRatio = 1.586;

  final RecommendedCard card;
  final bool showAnnualFee;
  const _RecommendationCard({required this.card, this.showAnnualFee = false});

  void _openDetail(BuildContext context) {
    final mainBenefits = card.mainBenefitLines;
    final benefits = card.categoryBenefits
        .map((b) => <String, String>{
              'category': b.category,
              'desc': b.description,
            })
        .toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendedCardDetailPage(
          imagePath: card.cardImageUrl,
          cardName: card.cardName,
          subtitle: card.annualFee == 0
              ? '연회비: 무료'
              : '연회비: ${_formatFee(card.annualFee)}',
          mainBenefitLines: mainBenefits,
          benefits: benefits,
        ),
      ),
    );
  }

  String _formatFee(int fee) {
    if (fee >= 10000) {
      final man = fee ~/ 10000;
      final remainder = fee % 10000;
      if (remainder == 0) {
        return '$man만원';
      }
      return '$man만 ${remainder.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',')}원';
    }
    return '${fee.toString().replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',')}원';
  }

  @override
  Widget build(BuildContext context) {
    // ROI 텍스트: 연회비 무료면 금액, 유료면 퍼센트
    final roiText = card.annualFee == 0
        ? '${_formatNumber(card.roiPercent)}원'
        : '${card.roiPercent.toStringAsFixed(card.roiPercent % 1 == 0 ? 0 : 1)}%';

    // 연회비 텍스트: 만원 단위
    final feeText = card.annualFee == 0
        ? '연회비 없음'
        : '연회비 ${_formatFeeInMan(card.annualFee)}';

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 0.95,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카드 이미지
              AspectRatio(
                aspectRatio: _cardAspectRatio,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: card.cardImageUrl.isNotEmpty
                      ? Image.network(
                          card.cardImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                ),
              ),
              const SizedBox(height: 6),
              // 카드 이름
              Text(
                card.cardName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // 카드사 + 연회비 (한 줄)
              Row(
                children: [
                  Flexible(
                    child: Text(
                      card.cardCompany,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    ' · ',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    feeText,
                    style: TextStyle(
                      fontSize: 10,
                      color: card.annualFee == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: card.annualFee == 0 ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // ROI
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    card.annualFee == 0 ? '예상 혜택' : 'ROI',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    roiText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
  }

  String _formatFeeInMan(int fee) {
    final man = fee / 10000;
    if (man == man.toInt()) {
      return '${man.toInt()}만원';
    }
    return '${man}만원';
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.credit_card,
        size: 28,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
