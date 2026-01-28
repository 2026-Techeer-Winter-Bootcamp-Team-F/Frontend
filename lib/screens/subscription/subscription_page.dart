import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:my_app/models/subscription.dart';
import 'package:my_app/services/subscription_service.dart';

class SubscriptionPage extends StatefulWidget {
  const SubscriptionPage({super.key});

  @override
  State<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends State<SubscriptionPage> {
  final List<MySubscriptionInfo> _items = [];
  final Map<String, int> _sectionIndex = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
  }

  Future<void> _loadSubscriptions() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final service = SubscriptionService();
      final data = await service.getSubscriptions();
      if (!mounted) return;
      setState(() {
        _items
          ..clear()
          ..addAll(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '구독 정보를 불러올 수 없습니다.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
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
                _error ?? '구독 정보를 불러올 수 없습니다.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadSubscriptions,
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      );
    }

    final sections = _buildSections();
    if (sections.isEmpty) {
      return const Center(
        child: Text(
          '등록된 구독이 없습니다.',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildOttBanner(context),
        const SizedBox(height: 20),
        ...sections.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: _SubscriptionSectionWidget(
                section: s,
                currentIndex: (_sectionIndex[s.title] ?? 0).clamp(0, s.items.length - 1),
                onPrev: s.items.length <= 1
                    ? null
                    : () => _goPrevSection(s.title, s.items.length - 1),
                onNext: s.items.length <= 1
                    ? null
                    : () => _goNextSection(s.title, s.items.length - 1),
              ),
            )),
      ],
    );
  }

  Widget _buildOttBanner(BuildContext context) {
    final ottItems = _items.where((item) => item.categoryName == '디지털구독').toList();
    if (ottItems.isEmpty) {
      return const SizedBox.shrink();
    }
    ottItems.sort((a, b) => a.dDay.compareTo(b.dDay));
    final topItems = ottItems.take(2).toList();
    final total = topItems.fold<int>(0, (sum, item) => sum + item.monthlyFee);
    final title = _ottTitle(topItems);
    final subtitle = '${topItems.map((e) => e.serviceName).join(', ')} 총 ${_formatAmount(total)}';

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
            child: const Icon(Icons.live_tv, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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

  String _ottTitle(List<MySubscriptionInfo> items) {
    if (items.isEmpty) return 'OTT 구독이 없습니다';
    final next = items.first.dDay;
    if (next <= 0) return '오늘 OTT 결제 예정';
    if (next == 1) return '내일 OTT 결제 예정';
    return '$next일 후 OTT 결제 예정';
  }

  List<_SubscriptionSection> _buildSections() {
    final grouped = <String, List<MySubscriptionInfo>>{};
    for (final item in _items) {
      final section = _mapCategoryToSection(item.categoryName);
      grouped.putIfAbsent(section, () => []).add(item);
    }

    return grouped.entries
        .where((entry) => entry.value.isNotEmpty)
        .map(
          (entry) => _SubscriptionSection(
            title: entry.key,
            items: entry.value
                .map(
                  (item) => _SubscriptionCardVM(
                    name: item.serviceName,
                    amount: item.monthlyFee,
                    daysLeft: item.dDay,
                    backgroundColor: _cardColorForService(item.serviceName),
                    icon: _iconForService(item.serviceName),
                  ),
                )
                .toList(),
          ),
        )
        .toList();
  }

  String _mapCategoryToSection(String categoryName) {
    return categoryName;
  }

  Color _cardColorForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('youtube')) return const Color(0xFFFF3B30);
    if (lower.contains('netflix')) return const Color(0xFF1F1F1F);
    if (lower.contains('coupang') || lower.contains('쿠팡')) return const Color(0xFF005FFF);
    if (lower.contains('naver') || lower.contains('네이버')) return const Color(0xFF00C73C);
    if (lower.contains('spotify')) return const Color(0xFF1DB954);
    if (lower.contains('chatgpt')) return const Color(0xFF111111);
    if (lower.contains('claude')) return const Color(0xFFECECEC);
    return const Color(0xFFF7F8F9);
  }

  _SubscriptionIcon _iconForService(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('youtube')) return _SubscriptionIcon.youtube;
    if (lower.contains('netflix')) return _SubscriptionIcon.netflix;
    if (lower.contains('coupang') || lower.contains('쿠팡')) return _SubscriptionIcon.coupangEats;
    if (lower.contains('naver') || lower.contains('네이버')) return _SubscriptionIcon.naver;
    if (lower.contains('spotify')) return _SubscriptionIcon.spotify;
    if (lower.contains('chatgpt')) return _SubscriptionIcon.chatgpt;
    if (lower.contains('claude')) return _SubscriptionIcon.gemini;
    return _SubscriptionIcon.defaultIcon;
  }

  void _goPrevSection(String title, int maxIndex) {
    final current = _sectionIndex[title] ?? 0;
    if (current <= 0) return;
    setState(() {
      _sectionIndex[title] = current - 1;
    });
  }

  void _goNextSection(String title, int maxIndex) {
    final current = _sectionIndex[title] ?? 0;
    if (current >= maxIndex) return;
    setState(() {
      _sectionIndex[title] = current + 1;
    });
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
  spotify,
  netflix,
  youtube,
  defaultIcon,
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
  final int currentIndex;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _SubscriptionSectionWidget({
    required this.section,
    required this.currentIndex,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = currentIndex.clamp(0, section.items.length - 1);
    final visibleCount = math.min(3, section.items.length - safeIndex);
    final visible = List<int>.generate(visibleCount, (i) => safeIndex + i);
    const stackWidth = 240.0;
    const stackHeight = 180.0;
    const stackOffset = 22.0;
    const scaleStep = 0.045;

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
          height: 180,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NavArrowButton(
                  icon: Icons.chevron_left,
                  onPressed: safeIndex == 0 ? null : onPrev,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: stackWidth,
                  height: stackHeight,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0.06, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(position: slide, child: child),
                      );
                    },
                    child: Stack(
                      key: ValueKey<int>(safeIndex),
                      clipBehavior: Clip.none,
                      children: [
                        for (final idx in visible.reversed)
                          Positioned(
                            left: (idx - safeIndex) * stackOffset,
                            child: Transform.scale(
                              scale: 1 - (idx - safeIndex) * scaleStep,
                              alignment: Alignment.topLeft,
                              child: Opacity(
                                opacity: 1 - (idx - safeIndex) * 0.06,
                                child: _SubscriptionCard(item: section.items[idx]),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _NavArrowButton(
                  icon: Icons.chevron_right,
                  onPressed: safeIndex == section.items.length - 1 ? null : onNext,
                ),
              ],
            ),
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
    const radius = 22.0;
    const lightGrey = Color(0xFFF7F8F9);
    final scheme = Theme.of(context).colorScheme;
    final effectiveBg = item.backgroundColor == lightGrey ? scheme.surfaceContainerHighest : item.backgroundColor;
    final isLight = ThemeData.estimateBrightnessForColor(effectiveBg) == Brightness.light;
    final primaryText = isLight ? const Color(0xFF111827) : Colors.white;
    final secondaryText = isLight ? const Color(0xFF6B7280) : Colors.white.withOpacity(0.92);

    return Container(
      width: 220,
      height: 180,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: BorderRadius.circular(radius),
      ),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
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
              fontSize: 24,
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

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _NavArrowButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 28,
        color: onPressed == null
            ? Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.4)
            : Theme.of(context).colorScheme.onSurfaceVariant,
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
      case _SubscriptionIcon.spotify:
        return const Icon(Icons.music_note, size: 22, color: Color(0xFF1DB954));
      case _SubscriptionIcon.netflix:
        return const Text('N', style: TextStyle(color: Color(0xFFE50914), fontWeight: FontWeight.w900));
      case _SubscriptionIcon.youtube:
        return const Icon(Icons.play_arrow, size: 22, color: Color(0xFFFF0000));
      case _SubscriptionIcon.defaultIcon:
        return const Icon(Icons.subscriptions, size: 22, color: Color(0xFF64748B));
    }
  }
}

String _formatAmount(int amount) {
  final s = amount.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return '${s.replaceAllMapped(reg, (m) => ',')}원';
}
