import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';

/// "이 카드는 어때요?" 추천 카드 클릭 시 표시되는 상세 페이지.
/// 상단: 카드 실물 이미지, 하단: 카드명, 주요 혜택, 상세 혜택 목록, 카드 신청하기 버튼.
class RecommendedCardDetailPage extends StatelessWidget {
  final String imagePath;
  final String cardName;
  final String subtitle;
  final List<String> mainBenefitLines;
  final List<Map<String, String>> benefits;

  const RecommendedCardDetailPage({
    super.key,
    required this.imagePath,
    required this.cardName,
    required this.subtitle,
    this.mainBenefitLines = const [],
    this.benefits = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final effectiveMain = mainBenefitLines.isNotEmpty
        ? mainBenefitLines
        : [subtitle];
    final effectiveBenefits = benefits.isNotEmpty
        ? benefits
        : [{'category': '혜택', 'desc': subtitle}];

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카드 실물 이미지 (상단) — 0.6배 (132×209, 기존 220×348)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 132,
                    height: 209,
                    child: imagePath.startsWith('http')
                        ? Image.network(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.credit_card,
                                size: 38,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          )
                        : Image.asset(
                            imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              color: scheme.surfaceContainerHighest,
                              child: Icon(
                                Icons.credit_card,
                                size: 38,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 카드 이름
              Text(
                cardName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // 주요 혜택
              Text(
                '주요 혜택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              ...effectiveMain.map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    line,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 상세 혜택 목록 (구분선)
              ...effectiveBenefits.asMap().entries.map((e) {
                final idx = e.key;
                final b = e.value;
                final cat = b['category'] ?? '';
                final desc = b['desc'] ?? '';
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (idx > 0)
                      Divider(
                        height: 24,
                        thickness: 1,
                        color: scheme.outlineVariant.withOpacity(0.6),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: scheme.onSurface,
                            ),
                            softWrap: false,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              desc,
                              style: TextStyle(
                                fontSize: 14,
                                color: scheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 32),

              // 카드 신청하기 버튼 (스크롤 안에 포함)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('카드 신청 페이지로 이동합니다.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                    shadowColor: Colors.black.withOpacity(0.2),
                  ),
                  child: const Text(
                    '카드 신청하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
