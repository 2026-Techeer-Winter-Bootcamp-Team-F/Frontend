import 'dart:math' as math;
import 'package:flutter/material.dart';

class BenefitScorePage extends StatefulWidget {
  final int score; // 0..100
  final int received;
  final int missed;

  const BenefitScorePage({
    super.key,
    this.score = 85,
    this.received = 15240,
    this.missed = 3215,
  });

  @override
  State<BenefitScorePage> createState() => _BenefitScorePageState();
}

class _BenefitScorePageState extends State<BenefitScorePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;
  bool _isBlueCardFront = false; // true면 파란 카드가 앞, false면 흰 카드가 앞
  bool _isAnimating = false; // 애니메이션 진행 중 플래그

  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeInOutCubic,
    );

    // 애니메이션 상태 감지
    _cardAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isBlueCardFront = true;
          _isAnimating = false;
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _isBlueCardFront = false;
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  void _onWhiteCardTap() {
    if (_isAnimating) return;
    // 흰 카드 탭: 파란 카드가 메인일 때만 reverse (흰 카드를 메인으로)
    if (_isBlueCardFront) {
      setState(() {
        _isAnimating = true;
      });
      _cardAnimationController.reverse();
    }
  }

  void _onBlueCardTap() {
    if (_isAnimating) return;
    // 파란 카드 탭: 흰 카드가 메인일 때만 forward (파란 카드를 메인으로)
    if (!_isBlueCardFront) {
      setState(() {
        _isAnimating = true;
      });
      _cardAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${widget.score}',
                    style: const TextStyle(
                      fontSize: 70,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                  Text(
                    '/100',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('나의 혜택 점수',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                '용진님이 사용하시는 카드 혜택의 85%를 챙기고 있어요',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      '받은 혜택',
                      widget.received,
                      accent: const Color(0xFF1560FF),
                      percentLabel: '+12%',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _statCard(
                      '놓친 혜택',
                      widget.missed,
                      accent: Colors.black,
                      isWarning: true,
                      note: '잠재 혜택',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _buildBottomCard(),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    int amount, {
    Color? accent,
    String? note,
    String? percentLabel,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatWon(amount),
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: accent ?? Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (percentLabel != null) ...[
                Icon(Icons.trending_up,
                    size: 14, color: accent ?? Colors.blue),
                const SizedBox(width: 6),
                Text(percentLabel,
                    style: TextStyle(fontSize: 12, color: accent ?? Colors.blue)),
              ] else if (isWarning) ...[
                const Icon(Icons.warning_amber_rounded,
                    size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(note ?? '잠재 혜택',
                    style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
              ] else if (note != null) ...[
                Text(note,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatWon(int value) {
    final s = value.toString();
    final out =
        s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '₩$out';
  }

  // 하단에 보여줄 큰 카드 컴포넌트 (스택된 스타일)
  Widget _buildBottomCard() {
    return AnimatedBuilder(
      animation: _cardAnimation,
      builder: (context, child) {
        final progress = _cardAnimation.value;

        return Center(
          child: SizedBox(
            width: 311,
            height: 387,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // progress < 0.5: 파란 카드(아래), 흰 카드(위)
                // progress >= 0.5: 흰 카드(아래), 파란 카드(위)
                if (progress < 0.5) ...[
                  _buildBlueCard(progress),
                  _buildWhiteCard(progress),
                ] else ...[
                  _buildWhiteCard(progress),
                  _buildBlueCard(progress),
                ],

                // ✅ (핵심 수정) "왼쪽 흰 카드 탭 영역"을 Stack의 맨 위로 올림
                // 파란 카드가 앞일 때만, 왼쪽에 살짝 보이는 흰 카드 영역을 탭하면 reverse 되도록
                if (_isBlueCardFront)
                  Positioned(
                    left: 0,
                    top: 0,
                    width: 70, // ← 흰 카드가 왼쪽에 보이게 남겨둔 폭과 비슷하게
                    height: 387,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _onWhiteCardTap,
                      child: const SizedBox.expand(),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWhiteCard(double progress) {
    final isWhiteCardTappable = !_isAnimating;

    return Positioned(
      left: progress * -245,
      top: 0,
      child: IgnorePointer(
        ignoring: !isWhiteCardTappable,
        child: GestureDetector(
          onTap: _onWhiteCardTap,
          child: Transform.scale(
            scale: 1.0 - (progress * 0.05),
            child: _buildCard(
              color: Colors.white,
              width: 285,
              height: 377,
              topOffset: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBlueCard(double progress) {
    final isBlueCardTappable = !_isAnimating;

    return Positioned(
      left: 26 - (progress * 26),
      top: 10 - (progress * 10),
      child: IgnorePointer(
        ignoring: !isBlueCardTappable,
        child: GestureDetector(
          onTap: _onBlueCardTap,
          child: Transform.scale(
            scale: 0.95 + (progress * 0.05),
            child: _buildCard(
              color: const Color(0xFF1560FF),
              width: 311,
              height: 365 + (progress * 12),
              topOffset: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color color,
    required double width,
    required double height,
    required double topOffset,
  }) {
    final isWhiteCard = color == Colors.white;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: _buildCardContent(isWhiteCard: isWhiteCard),
    );
  }

  Widget _buildCardContent({required bool isWhiteCard}) {
    final textColor = isWhiteCard ? Colors.black : Colors.white;
    final subtitleColor = isWhiteCard ? Colors.black54 : Colors.white70;
    final cardImageUrl = isWhiteCard
        ? 'https://www.shinhancard.com/pconts/images/contents/card/plate/cdCreditBOADT2.gif'
        : 'https://www.shinhancard.com/pconts/images/contents/card/plate/cdCreditBA7AQ7.gif';

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Transform.rotate(
                    angle: isWhiteCard ? 0 : math.pi,
                    child: Image.network(
                      cardImageUrl,
                      width: 160,
                      height: 101,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160,
                          height: 101,
                          color: Colors.grey[200],
                          child: const Center(
                            child: Icon(Icons.credit_card,
                                color: Colors.grey, size: 36),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isWhiteCard ? '신한은행 LG전자 The 구독케어' : '국민은행 Simple+',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: isWhiteCard ? Colors.black26 : Colors.white38,
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isWhiteCard ? '본인 5699' : '본인 6842',
                  style: TextStyle(
                    fontSize: 13,
                    color: subtitleColor,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Container(
          height: 1,
          color: isWhiteCard ? const Color(0xFFF0F0F0) : Colors.white24,
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '1월 이용금액',
                        style: TextStyle(
                          fontSize: 12,
                          color: subtitleColor,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          isWhiteCard ? '579,790원' : '121,900원',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isWhiteCard ? Colors.black26 : Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
