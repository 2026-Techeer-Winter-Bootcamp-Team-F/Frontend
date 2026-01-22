import 'package:flutter/material.dart';
import 'package:my_app/screens/cards/card_detail_page.dart';

class CardAnalysisPage extends StatelessWidget {
  const CardAnalysisPage({super.key});

  static final List<WalletCard> _cards = [
    WalletCard(
      imagePath: 'assets/cards/card1.png',
      color: Color(0xFFECECEC),
      label: '신한 5699',
      bankName: '신한카드',
      maskedNumber: '**** 5699',
    ),
    WalletCard(
      imagePath: 'assets/cards/card2.png',
      color: Color(0xFFEFF66A),
      label: '토스 5289',
      bankName: '토스뱅크',
      maskedNumber: '**** 5289',
    ),
    WalletCard(
      imagePath: 'assets/cards/card3.png',
      color: Color(0xFFF2F2F4),
      label: '비씨 7892',
      bankName: '비씨카드',
      maskedNumber: '**** 7892',
    ),
    WalletCard(
      imagePath: 'assets/cards/card4.png',
      color: Color(0xFFBFCFE6),
      label: '국민 2095',
      bankName: 'KB국민카드',
      maskedNumber: '**** 2095',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        centerTitle: true,
        title: const Text(
          '내 지갑',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
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
                  height: 750,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(_cards.length, (i) {
                      final card = _cards[i];
                      // Keep all visible cards the same scale/size.
                      final offset = i * 130.0; // Reduce overlap
                      final scale = 1.0;
                      return Positioned(
                        top: offset,
                        left: 0,
                        right: 0,
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment.topCenter,
                          child: _buildCard(
                            context,
                            card,
                            i == _cards.length - 1,
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 16),
                Divider(thickness: 1, height: 24, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 10),
                // Header text like the screenshot (left-aligned)
                const Text(
                  '이 카드는 어때요?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  '3개월 동안의 가장 많이 쓴 카테고리 소비 평균에 따른 실익률을 분석했어요.',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 18),

                // Recommendation sections
                Column(
                  children: _recommendations
                      .map(
                        (section) => _buildRecommendationSection(context, section),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Sample recommendation data: category, totalSpent, recommended cards
  static final List<Map<String, dynamic>> _recommendations = [
    {
      'category': '교통',
      'total': 7816,
      'items': [
        {
          'image': 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png',
          'title': '현대카드',
          'subtitle': '연회비: 20만 원',
          'percent': '120%',
        },
        {
          'image': 'assets/cards/card2.png',
          'title': 'BC카드',
          'subtitle': '연회비: 20만 원',
          'percent': '128%',
        },
      ],
    },
    {
      'category': '택시',
      'total': 27133,
      'items': [
        {
          'image': 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png',
          'title': '현대카드 택시',
          'subtitle': '연회비: 20만 원',
          'percent': '112%',
        },
        {
          'image': 'https://www.bccard.com/images/individual/card/renew/list/card_104239.png',
          'title': 'BC카드 택시',
          'subtitle': '연회비: 20만 원',
          'percent': '130%',
        },
        {
          'image': 'https://image.lottecard.co.kr/UploadFiles/ecenterPath/cdInfo/ecenterCdInfoP11881-A11881_nm1.png',
          'title': '롯데카드 택시',
          'subtitle': '연회비: 20만 원',
          'percent': '210%',
        },
        {
          'image': 'https://img.cdn.nicebizinfo.com/mi/2020/07/20/20200720155313_1.jpg',
          'title': 'Mr.Life',
          'subtitle': '연회비: 20만 원',
          'percent': '175%',
        },
      ],
    },
    {
      'category': '마트',
      'total': 4500,
      'items': [
        {
          'image': 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png',
          'title': '현대카드 마트',
          'subtitle': '연회비: 20만 원',
          'percent': '120%',
        },
        {
          'image': 'https://www.bccard.com/images/individual/card/renew/list/card_104239.png',
          'title': 'BC카드 마트',
          'subtitle': '연회비: 20만 원',
          'percent': '125%',
        },
        {
          'image': 'https://image.lottecard.co.kr/UploadFiles/ecenterPath/cdInfo/ecenterCdInfoP11881-A11881_nm1.png',
          'title': '롯데카드 마트',
          'subtitle': '연회비: 20만 원',
          'percent': '210%',
        },
        {
          'image': 'https://img.cdn.nicebizinfo.com/mi/2020/07/20/20200720155313_1.jpg',
          'title': 'Mr.Life',
          'subtitle': '연회비: 20만 원',
          'percent': '170%',
        },
      ],
    },
  ];

  Widget _buildRecommendationSection(BuildContext context, Map<String, dynamic> section) {
    final items = section['items'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section['category'] ?? '',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '총 사용 금액: ${_formatWon(section['total'] ?? 0)}',
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        ...items.map((it) => _RecommendationCard(data: it as Map<String, dynamic>)).toList(),
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
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CardDetailPage(card: card)),
      ),
      child: Container(
        width: 317,
        height: 210,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: card.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 현대카드 이미지 좌측 정렬, 103x65
            if (card.imagePath == 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png')
              Positioned(
                left: 20,
                top: 30,
                child: Image.network(
                  card.imagePath!,
                  width: 103,
                  height: 65,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey.shade200,
                    width: 103,
                    height: 65,
                    child: const Icon(
                      Icons.credit_card,
                      size: 28,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
            // optional badge on top-right
            Positioned(
              right: 18,
              top: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(16),
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
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.bankName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    card.maskedNumber,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            if (!isBottom)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.0),
                        Colors.white.withOpacity(0.02),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
          ],
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

  const WalletCard({
    this.imagePath,
    required this.color,
    required this.label,
    this.bankName = '카드',
    this.maskedNumber = '',
  });
}

class _RecommendationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecommendationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 80,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.network(
                  data['image'] as String,
                  width: 103,
                  height: 65,
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => Container(
                    color: Colors.grey.shade200,
                    width: 103,
                    height: 65,
                    child: const Icon(
                      Icons.credit_card,
                      size: 28,
                      color: Colors.black26,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${data['title'] as String} | ${data['subtitle'] as String}',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2F3A45),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data['percent'] as String,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
