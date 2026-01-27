import 'package:flutter/material.dart';
import 'package:my_app/models/card.dart';
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

  final List<WalletCard> _cards = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final cardService = CardService();
      final cards = await cardService.getMyCards();
      if (!mounted) return;
      setState(() {
        _cards
          ..clear()
          ..addAll(cards.map(_toWalletCard));
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '카드 정보를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Title intentionally left blank per UI request
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wallet stack (full width inside padding)
                SizedBox(
                  width: double.infinity,
                  height: _walletSectionHeight(context),
                  child: _buildWalletContent(context),
                ),

                const SizedBox(height: 28),

                // Header text like the screenshot (left-aligned)
                Text(
                  '이 카드는 어때요?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                ),
                const SizedBox(height: 6),
                Text(
                  '3개월 동안의 가장 많이 쓴 카테고리 소비 평균에 따른 실익률을 분석했어요.',
                  style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 18),

                // Recommendation sections
                Column(
                  children: _recommendations.map((section) => _buildRecommendationSection(context, section)).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWalletContent(BuildContext context) {
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
    if (_cards.isEmpty) {
      return const Center(
        child: Text(
          '등록된 카드가 없습니다.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }
    if (_cards.length == 1) {
      return Center(
        child: _buildSingleCard(context, _cards.first),
      );
    }
    return _buildWalletStack(context);
  }

  double _walletSectionHeight(BuildContext context) {
    final availableWidth =
        MediaQuery.of(context).size.width - 40 - 12; // padding + card margin
    final cardHeight = availableWidth > 0
        ? availableWidth / _cardAspectRatio
        : 200.0;
    if (_isLoading || _error != null || _cards.isEmpty) {
      return cardHeight.clamp(200.0, 320.0);
    }

    final step = _stackOffsetStep();
    final stackedHeight = cardHeight + step * (_cards.length - 1);
    return stackedHeight.clamp(220.0, 520.0);
  }

  Widget _buildSingleCard(BuildContext context, WalletCard card) {
    return SizedBox(
      width: double.infinity,
      child: _buildCard(context, card, true),
    );
  }

  Widget _buildWalletStack(BuildContext context) {
    final step = _stackOffsetStep();
    return Stack(
      clipBehavior: Clip.none,
      children: List.generate(_cards.length, (i) {
        final card = _cards[i];
        final offset = i * step; // tighten overlap so more cards are visible
        const scale = 1.0;
        return Positioned(
          top: offset,
          left: 0,
          right: 0,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.topCenter,
            child: _buildCard(context, card, i == _cards.length - 1),
          ),
        );
      }),
    );
  }

  double _stackOffsetStep() {
    if (_cards.length <= 2) {
      return 28;
    }
    if (_cards.length == 3) {
      return 34;
    }
    return 40;
  }

  WalletCard _toWalletCard(MyCardInfo info) {
    final last4 = _extractLast4(info.cardNumber);
    return WalletCard(
      color: _companyColor(info.company),
      label: '${_shortCompanyName(info.company)} $last4',
      bankName: info.company,
      maskedNumber: '**** $last4',
      imagePath: info.cardImageUrl.isNotEmpty ? info.cardImageUrl : null,
    );
  }

  String _extractLast4(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 4) {
      return '****';
    }
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

  // Sample recommendation data: category, totalSpent, recommended cards
  static final List<Map<String, dynamic>> _recommendations = [
    {
      'category': '택시',
      'total': 27133,
      'items': [
        {
          'image': 'assets/images/mywallet_shinhan_card.jpeg',
          'title': 'LIKIT FUN+',
          'subtitle': '연회비: 1만 5천 원',
          'percent': '210%',
          'mainBenefitLines': [
            '스타벅스 최대 60%, 영화 50% 할인',
            '대중교통, 통신비 10%, 배달의민족 5% 할인',
          ],
          'benefits': [
            {'category': '커피', 'desc': '스타벅스 최대 60% 할인'},
            {'category': '문화', 'desc': '롯데시네마, CGV 50% 할인'},
            {'category': '교통', 'desc': '대중교통 10% 할인'},
            {'category': '통신', 'desc': '통신비 10% 할인'},
            {'category': '외식', 'desc': '배달의민족, 요기요 5% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_toss_card.png',
          'title': 'BC카드',
          'subtitle': '연회비: 20만 원',
          'percent': '110%',
          'mainBenefitLines': [
            '택시·대리운전 최대 15% 할인',
            '주유 10%, 음식 배달 7% 할인',
          ],
          'benefits': [
            {'category': '택시', 'desc': '카카오T, 티맵 최대 15% 할인'},
            {'category': '주유', 'desc': '주유 결제 10% 할인'},
            {'category': '교통', 'desc': '대중교통 7% 할인'},
            {'category': '외식', 'desc': '배달앱 7% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_bc_card.png',
          'title': '롯데카드',
          'subtitle': '연회비: 20만 원',
          'percent': '230%',
          'mainBenefitLines': [
            '택시 20%, 쇼핑 5% 할인',
            '영화·콘서트 30% 할인',
          ],
          'benefits': [
            {'category': '택시', 'desc': '택시 결제 20% 할인'},
            {'category': '쇼핑', 'desc': '백화점·대형마트 5% 할인'},
            {'category': '문화', 'desc': '영화, 공연 30% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_kookmin_card.png',
          'title': 'Mr.Life',
          'subtitle': '연회비: 20만 원',
          'percent': '190%',
          'mainBenefitLines': [
            '생활비·통신 10% 할인',
            '카페·외식 5~10% 할인',
          ],
          'benefits': [
            {'category': '통신', 'desc': '통신요금 10% 할인'},
            {'category': '커피', 'desc': '카페 10% 할인'},
            {'category': '외식', 'desc': '배달·외식 5% 할인'},
          ],
        },
      ],
    },
    {
      'category': '교통',
      'total': 7816,
      'items': [
        {
          'image': 'assets/images/mywallet_shinhan_card.jpeg',
          'title': '현대카드',
          'subtitle': '연회비: 20만 원',
          'percent': 'ROI',
          'mainBenefitLines': [
            '대중교통 20%, 주유 15% 할인',
            '통신비 10%, 영화 50% 할인',
          ],
          'benefits': [
            {'category': '교통', 'desc': '대중교통 20% 할인'},
            {'category': '주유', 'desc': '주유 15% 할인'},
            {'category': '통신', 'desc': '통신요금 10% 할인'},
            {'category': '문화', 'desc': '영화 50% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_toss_card.png',
          'title': 'BC카드',
          'subtitle': '연회비: 20만 원',
          'percent': '110%',
          'mainBenefitLines': [
            '택시·대리운전 최대 15% 할인',
            '주유 10%, 음식 배달 7% 할인',
          ],
          'benefits': [
            {'category': '택시', 'desc': '카카오T, 티맵 최대 15% 할인'},
            {'category': '주유', 'desc': '주유 결제 10% 할인'},
            {'category': '교통', 'desc': '대중교통 7% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_bc_card.png',
          'title': '롯데카드',
          'subtitle': '연회비: 20만 원',
          'percent': '95%',
          'mainBenefitLines': [
            '택시 20%, 쇼핑 5% 할인',
            '영화·콘서트 30% 할인',
          ],
          'benefits': [
            {'category': '교통', 'desc': '택시 20% 할인'},
            {'category': '쇼핑', 'desc': '백화점·마트 5% 할인'},
            {'category': '문화', 'desc': '영화, 공연 30% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_kookmin_card.png',
          'title': '신한카드',
          'subtitle': '연회비: 20만 원',
          'percent': '130%',
          'mainBenefitLines': [
            '대중교통 15%, 주유 10% 할인',
            '편의점·카페 5% 할인',
          ],
          'benefits': [
            {'category': '교통', 'desc': '대중교통 15% 할인'},
            {'category': '주유', 'desc': '주유 10% 할인'},
            {'category': '편의점', 'desc': '편의점 5% 할인'},
            {'category': '커피', 'desc': '카페 5% 할인'},
          ],
        },
      ],
    },
    {
      'category': '마트',
      'total': 4500,
      'items': [
        {
          'image': 'assets/images/mywallet_toss_card.png',
          'title': '이마트카드',
          'subtitle': '연회비: 10만 원',
          'percent': '150%',
          'mainBenefitLines': [
            '이마트·트레이더스 5% 할인',
            '주유 10%, 교통 5% 할인',
          ],
          'benefits': [
            {'category': '마트', 'desc': '이마트·트레이더스 5% 할인'},
            {'category': '주유', 'desc': '이마트 주유 10% 할인'},
            {'category': '교통', 'desc': '대중교통 5% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_bc_card.png',
          'title': '롯데마트카드',
          'subtitle': '연회비: 12만 원',
          'percent': '140%',
          'mainBenefitLines': [
            '롯데마트 5%, 영화 30% 할인',
            '주유·주차 10% 할인',
          ],
          'benefits': [
            {'category': '마트', 'desc': '롯데마트 5% 할인'},
            {'category': '문화', 'desc': '롯데시네마 30% 할인'},
            {'category': '주유', 'desc': '주유 10% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_kookmin_card.png',
          'title': '홈플러스카드',
          'subtitle': '연회비: 8만 원',
          'percent': '125%',
          'mainBenefitLines': [
            '홈플러스 5%, 주유 7% 할인',
            '생활서비스 10% 할인',
          ],
          'benefits': [
            {'category': '마트', 'desc': '홈플러스 5% 할인'},
            {'category': '주유', 'desc': '주유 7% 할인'},
            {'category': '생활', 'desc': '세탁·이사 10% 할인'},
          ],
        },
        {
          'image': 'assets/images/mywallet_shinhan_card.jpeg',
          'title': '쿠팡카드',
          'subtitle': '연회비: 0원',
          'percent': '115%',
          'mainBenefitLines': [
            '쿠팡 5% 할인, 로켓배송 추가 혜택',
            '주유 7%, 대중교통 5% 할인',
          ],
          'benefits': [
            {'category': '쇼핑', 'desc': '쿠팡 5% 할인'},
            {'category': '주유', 'desc': '주유 7% 할인'},
            {'category': '교통', 'desc': '대중교통 5% 할인'},
          ],
        },
      ],
    },
  ];

  Widget _buildRecommendationSection(BuildContext context, Map<String, dynamic> section) {
    final items = section['items'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(section['category'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
            Text('총 ${_formatWon(section['total'] as int)} 썼어요', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.15,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items.map((it) => _RecommendationCard(data: it as Map<String, dynamic>)).toList(),
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  String _formatWon(int value) {
    final s = value.toString();
    final out = s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '$out원';
  }

  Widget _buildCard(BuildContext context, WalletCard card, bool isBottom) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CardDetailPage(card: card))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: AspectRatio(
          aspectRatio: _cardAspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: card.color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6)),
              ],
            ),
            child: Stack(
              children: [
          Positioned(
            left: 20,
            top: 20,
            child: Container(
              width: 48,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // optional badge on top-right
          Positioned(
            right: 18,
            top: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(card.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
          ),
          Positioned(
            left: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.bankName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87)),
                const SizedBox(height: 6),
                Text(card.maskedNumber, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),
          if (!isBottom)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Colors.white.withOpacity(0.0), Colors.white.withOpacity(0.02)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
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
}

class WalletCard {
  final Color color;
  final String label;
  final String bankName;
  final String maskedNumber;
  final String? imagePath;

  const WalletCard({this.imagePath, required this.color, required this.label, this.bankName = '카드', this.maskedNumber = ''});
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecommendationCard({required this.data});

  void _openDetail(BuildContext context) {
    final main = (data['mainBenefitLines'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
    final ben = (data['benefits'] as List?)?.map((e) {
      final m = e as Map;
      return <String, String>{
        'category': (m['category'] ?? '').toString(),
        'desc': (m['desc'] ?? '').toString(),
      };
    }).toList() ?? <Map<String, String>>[];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendedCardDetailPage(
          imagePath: data['image'] as String,
          cardName: data['title'] as String,
          subtitle: data['subtitle'] as String,
          mainBenefitLines: main,
          benefits: ben,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 80,
              width: double.infinity,
              child: Image.asset(
                data['image'] as String,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(Icons.credit_card, size: 28, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['title'] as String,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  data['subtitle'] as String,
                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data['percent'] as String,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Theme.of(context).colorScheme.onSurface),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    ));
  }
}

