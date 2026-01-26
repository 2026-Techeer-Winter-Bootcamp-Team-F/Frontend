import 'package:flutter/material.dart';
import 'wallet_card.dart';

class CardAnalysisPage extends StatelessWidget {
  static final List<WalletCard> _cards = [];
  const CardAnalysisPage({super.key});

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
                // 카드 뭉치를 가로선 위에 배치
                Padding(
                  padding: const EdgeInsets.only(bottom: 8), // 가로선과 간격 최소화
                  child: Center(
                    child: SizedBox(
                      width: 370,
                      height: 600,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // 카드 높이 210, 40% 겹침: 126씩 증가
                          // 신한카드(맨 위)
                          Positioned(
                            left: 0,
                            top: 0,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/mywallet_shinhan_card.jpeg',
                                    width: 350,
                                    height: 210,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      '신한 5699',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Toss카드
                          Positioned(
                            left: 0,
                            top: 126,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/mywallet_toss_card.png',
                                    width: 350,
                                    height: 210,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      '토스 5289',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // BC카드
                          Positioned(
                            left: 0,
                            top: 252,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/recommend_bc.jpg',
                                    width: 350,
                                    height: 210,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      '비씨 7892',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // 국민카드
                          Positioned(
                            left: 0,
                            top: 378,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.asset(
                                    'assets/images/mywallet_kookmin_card.png',
                                    width: 350,
                                    height: 210,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  top: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Text(
                                      '국민 2095',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                const SizedBox(height: 24),
                // 가로선 Divider 추가
                Divider(thickness: 1, height: 24, color: Color(0xFFE0E0E0)),
                const Text(
                  '이 카드는 어때요?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                const Text(
                  '3개월 동안의 가장 많이 쓴 카테고리 소비 평균에 따른 실익률을 분석했어요.',
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  maxLines: 1,
                ),
                const SizedBox(height: 18),
                // Recommendation sections
                Column(
                  children: _recommendations
                      .map(
                        (section) =>
                            _buildRecommendationSection(context, section),
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
      'category': '택시',
      'total': 27133,
      'items': [
        {
          'image': 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png',
          'title': '현대카드',
          'subtitle': '연회비: 20만 원',
          'percent': '112%',
        },
        {
          'image': 'assets/images/recommend_bc.jpg',
          'title': 'BC카드',
          'subtitle': '연회비: 20만 원',
          'percent': '123%',
        },
        {
          'image':
              'https://image.lottecard.co.kr/UploadFiles/ecenterPath/cdInfo/ecenterCdInfoP11881-A11881_nm1.png',
          'title': '롯데카드',
          'subtitle': '연회비: 20만 원',
          'percent': '145%',
        },
        {
          'image': 'assets/images/recommend_life.jpeg',
          'title': 'Mr.Life',
          'subtitle': '연회비: 20만 원',
          'percent': '178%',
        },
      ],
    },
    {
      'category': '교통',
      'total': 7816,
      'items': [
        {
          'image': 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png',
          'title': '현대카드',
          'subtitle': '연회비: 20만 원',
          'percent': '115%',
        },
        {
          'image': 'assets/images/recommend_bc.jpg',
          'title': 'BC카드',
          'subtitle': '연회비: 20만 원',
          'percent': '134%',
        },
        {
          'image':
              'https://image.lottecard.co.kr/UploadFiles/ecenterPath/cdInfo/ecenterCdInfoP11881-A11881_nm1.png',
          'title': '롯데카드',
          'subtitle': '연회비: 20만 원',
          'percent': '142%',
        },
        {
          'image': 'assets/images/recommend_life.jpeg',
          'title': 'Mr.Life',
          'subtitle': '연회비: 20만 원',
          'percent': '151%',
        },
      ],
    },
    {
      'category': '마트',
      'total': 4500,
      'items': [
        {
          'image': 'https://img.hyundaicard.com/img/com/card/card_AMGLE2.png',
          'title': '현대카드',
          'subtitle': '연회비: 20만 원',
          'percent': '121%',
        },
        {
          'image': 'assets/images/recommend_bc.jpg',
          'title': 'BC카드',
          'subtitle': '연회비: 20만 원',
          'percent': '137%',
        },
        {
          'image':
              'https://image.lottecard.co.kr/UploadFiles/ecenterPath/cdInfo/ecenterCdInfoP11881-A11881_nm1.png',
          'title': '롯데카드',
          'subtitle': '연회비: 20만 원',
          'percent': '153%',
        },
        {
          'image': 'assets/images/recommend_life.jpeg',
          'title': 'Mr.Life',
          'subtitle': '연회비: 20만 원',
          'percent': '164%',
        },
      ],
    },
  ];

  Widget _buildRecommendationSection(
    BuildContext context,
    Map<String, dynamic> section,
  ) {
    final items = section['items'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              section['category'] ?? '',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '총 ${_formatWon(section['total'] ?? 0)} 썼어요',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: items
              .map(
                (it) => SizedBox(
                  width: MediaQuery.of(context).size.width / 2 - 32,
                  child: _SquareRecommendationCard(
                    data: it as Map<String, dynamic>,
                  ),
                ),
              )
              .toList(),
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
}

class _SquareRecommendationCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _SquareRecommendationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              data['image'] as String,
              width: 103,
              height: 65,
              fit: BoxFit.contain,
              errorBuilder: (c, e, s) => Container(
                color: Colors.grey.shade200,
                width: 103,
                height: 65,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.error_outline,
                      size: 32,
                      color: Colors.redAccent,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '이미지 오류',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${data['title']} | ${data['subtitle']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2F3A45),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 10),
          Text(
            data['percent'] as String,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.black87,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }
}
