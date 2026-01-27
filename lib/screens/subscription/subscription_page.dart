import 'package:flutter/material.dart';

class SubscriptionPage extends StatelessWidget {
  const SubscriptionPage({super.key});

  // 화면 시안(스크린샷) 기준 더미 데이터
  static const List<_SubscriptionSection> _sections = [
    _SubscriptionSection(
      title: 'AI & 생산성',
      items: [
        _SubscriptionCardVM(
          name: '제미나이',
          amount: 3000,
          daysLeft: 10,
          backgroundColor: Color(0xFF005FFF),
          icon: _SubscriptionIcon.gemini,
        ),
        _SubscriptionCardVM(
          name: '챗지피티',
          amount: 13000,
          daysLeft: 21,
          backgroundColor: Color(0xFFFF6B00),
          icon: _SubscriptionIcon.chatgpt,
        ),
      ],
    ),
    _SubscriptionSection(
      title: '자기계발 & 교육',
      items: [
        _SubscriptionCardVM(
          name: '챗지피티',
          amount: 13000,
          daysLeft: 21,
          backgroundColor: Color(0xFF00E676),
          icon: _SubscriptionIcon.chatgpt,
        ),
        _SubscriptionCardVM(
          name: '듀오링고',
          amount: 12500,
          daysLeft: 20,
          backgroundColor: Color(0xFFF7F8F9),
          icon: _SubscriptionIcon.duolingo,
        ),
        _SubscriptionCardVM(
          name: '말해보카',
          amount: 5000,
          daysLeft: 20,
          backgroundColor: Color(0xFFF7F8F9),
          icon: _SubscriptionIcon.malhaeboca,
        ),
      ],
    ),
    _SubscriptionSection(
      title: '쇼핑 & 라이프',
      items: [
        _SubscriptionCardVM(
          name: '네이버플러스',
          amount: 4000,
          daysLeft: 21,
          backgroundColor: Color(0xFFF7F8F9),
          icon: _SubscriptionIcon.naver,
        ),
        _SubscriptionCardVM(
          name: '쿠팡이츠',
          amount: 7500,
          daysLeft: 10,
          backgroundColor: Color(0xFF005FFF),
          icon: _SubscriptionIcon.coupangEats,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final header = _SubscriptionTopHeader();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          physics: const BouncingScrollPhysics(),
          children: [
            header,
            const SizedBox(height: 28),
            ..._sections.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: _SubscriptionSectionWidget(section: s),
                )),
          ],
        ),
      ),
    );
  }
}

/// 상단: 결제 예정 배너 + "엔터테인먼트 (OTT)" 헤더 + 넷플릭스/유튜브 카드
class _SubscriptionTopHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _UpcomingPaymentBanner(),
        const SizedBox(height: 20),
        Text(
          '회원님이 구독 중인 서비스를 확인해보세요',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '엔터테인먼트 (OTT)',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        _OttCardsRow(),
      ],
    );
  }
}

class _UpcomingPaymentBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.calendar_today, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '내일 2건의 구독 결제 예정',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '유튜브, 넷플릭스 총 31,900원',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _OttCardsRow extends StatelessWidget {
  static const _items = [
    _OttCardData(name: '넷플릭스', amount: 13000, daysLeft: 21, brand: _OttBrand.netflix),
    _OttCardData(name: '유튜브 프리미엄', amount: 20000, daysLeft: 15, brand: _OttBrand.youtube),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 210,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _OttServiceCard(data: _items[index]),
      ),
    );
  }
}

enum _OttBrand { netflix, youtube }

class _OttCardData {
  final String name;
  final int amount;
  final int daysLeft;
  final _OttBrand brand;

  const _OttCardData({
    required this.name,
    required this.amount,
    required this.daysLeft,
    required this.brand,
  });
}

class _OttServiceCard extends StatelessWidget {
  final _OttCardData data;

  const _OttServiceCard({required this.data});

  static const _cardWidth = 178.0;
  static const _radius = 26.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: _cardWidth,
      height: 210,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OttBrandIcon(brand: data.brand),
          const Spacer(),
          Text(
            '${data.name} | ${_formatAmount(data.amount)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${data.daysLeft}일',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _OttBrandIcon extends StatelessWidget {
  final _OttBrand brand;

  const _OttBrandIcon({required this.brand});

  @override
  Widget build(BuildContext context) {
    switch (brand) {
      case _OttBrand.netflix:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFF141414),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'N',
            style: TextStyle(
              color: Color(0xFFE50914),
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'sans-serif',
            ),
          ),
        );
      case _OttBrand.youtube:
        return Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFFF0000),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
        );
    }
  }
}

class _SubscriptionSection {
  final String title;
  final List<_SubscriptionCardVM> items;

  const _SubscriptionSection({required this.title, required this.items});
}

enum _SubscriptionIcon {
  gemini,
  chatgpt,
  duolingo,
  malhaeboca,
  naver,
  coupangEats,
}

class _SubscriptionCardVM {
  final String name;
  final int amount;
  final int daysLeft;
  final Color backgroundColor;
  final _SubscriptionIcon icon;

  const _SubscriptionCardVM({
    required this.name,
    required this.amount,
    required this.daysLeft,
    required this.backgroundColor,
    required this.icon,
  });
}

class _SubscriptionSectionWidget extends StatelessWidget {
  final _SubscriptionSection section;

  const _SubscriptionSectionWidget({required this.section});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: section.items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = section.items[index];
              return _SubscriptionCard(item: item);
            },
          ),
        ),
      ],
    );
  }
}

class _SubscriptionCard extends StatelessWidget {
  final _SubscriptionCardVM item;

  const _SubscriptionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    const cardWidth = 178.0;
    const radius = 26.0;
    const lightGrey = Color(0xFFF7F8F9);
    final scheme = Theme.of(context).colorScheme;
    final effectiveBg = item.backgroundColor == lightGrey ? scheme.surfaceContainerHighest : item.backgroundColor;
    final isLight = ThemeData.estimateBrightnessForColor(effectiveBg) == Brightness.light;
    final primaryText = isLight ? const Color(0xFF111827) : Colors.white;
    final secondaryText = isLight ? const Color(0xFF6B7280) : Colors.white.withOpacity(0.92);

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AppIconBadge(
            icon: item.icon,
            background: effectiveBg,
          ),
          const Spacer(),
          Text(
            '${item.name} | ${_formatAmount(item.amount)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: secondaryText,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${item.daysLeft}일',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: primaryText,
              letterSpacing: -0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _AppIconBadge extends StatelessWidget {
  final _SubscriptionIcon icon;
  final Color background;

  const _AppIconBadge({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    // 스크린샷처럼: 컬러 카드에서는 흰 원 배지, 흰 카드에서는 아이콘만(약한 투명도)
    final isLight = ThemeData.estimateBrightnessForColor(background) == Brightness.light;
    final showBadge = !isLight;

    final iconWidget = _iconFor(icon);

    if (!showBadge) {
      return Opacity(opacity: 0.95, child: iconWidget);
    }

    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: iconWidget,
    );
  }

  Widget _iconFor(_SubscriptionIcon icon) {
    // Figma/MCP가 없어서 SVG를 쓰지 않고, 현재 앱 내 아이콘으로 근사치 구성
    switch (icon) {
      case _SubscriptionIcon.gemini:
        return const Icon(Icons.auto_awesome, size: 22, color: Color(0xFF005FFF));
      case _SubscriptionIcon.chatgpt:
        return const Icon(Icons.all_inclusive, size: 22, color: Color(0xFF111827));
      case _SubscriptionIcon.duolingo:
        return const Icon(Icons.emoji_nature, size: 22, color: Color(0xFF22C55E));
      case _SubscriptionIcon.malhaeboca:
        return const Icon(Icons.face, size: 22, color: Color(0xFF7C3AED));
      case _SubscriptionIcon.naver:
        return const Icon(Icons.circle, size: 22, color: Color(0xFF22C55E));
      case _SubscriptionIcon.coupangEats:
        return const Icon(Icons.local_dining, size: 22, color: Color(0xFF005FFF));
    }
  }
}

String _formatAmount(int amount) {
  final s = amount.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return '${s.replaceAllMapped(reg, (m) => ',')}원';
}
