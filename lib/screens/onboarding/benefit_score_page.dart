import 'package:flutter/material.dart';

class BenefitScorePage extends StatefulWidget {
  final int score; // 0..100
  final int received;
  final int missed;

  const BenefitScorePage({super.key, this.score = 85, this.received = 15240, this.missed = 3215});

  @override
  State<BenefitScorePage> createState() => _BenefitScorePageState();
}

class _BenefitScorePageState extends State<BenefitScorePage> {
  // 더미 지갑 카드 리스트 (홈 탭에 표시)
  // 카드 스택을 홈에서 제거함(디자인 요청)
  @override
  void initState() {
    super.initState();
    // 이 페이지는 이제 메인 내에서 탭 콘텐츠로 사용됩니다.
    // 외부에서 직접 푸시할 때 자동 이동이 필요하면 auth 흐름에서 MainNavigation을 푸시하세요.
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
                    style: const TextStyle(fontSize: 70, fontWeight: FontWeight.w800, color: Colors.black, height: 1.0),
                  ),
                  Text(
                    '/100',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black, height: 1.0),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text('나의 혜택 점수', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('용진님이 사용하시는 카드 혜택의 85%를 챙기고 있어요', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black54), textAlign: TextAlign.center),
              const SizedBox(height: 28),

              Row(
                children: [
                      Expanded(child: _statCard('받은 혜택', widget.received, accent: const Color(0xFF1560FF), percentLabel: '+12%')),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard('놓친 혜택', widget.missed, accent: Colors.black, isWarning: true, note: '잠재 혜택')),
                ],
              ),
              
              const Spacer(),

              // 하단 카드: 상세 카드 + 블루 백그라운드 (홈 탭에 표시)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: _buildBottomCard(),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
      // 하단 네비게이션은 이제 `MainNavigation`에서 관리합니다.
    );
  }

  Widget _statCard(String title, int amount,
      {Color? accent, String? note, String? percentLabel, bool isWarning = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.04), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black54)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(_formatWon(amount), style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: accent ?? Colors.black)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (percentLabel != null) ...[
                Icon(Icons.trending_up, size: 14, color: accent ?? Colors.blue),
                const SizedBox(width: 6),
                Text(percentLabel, style: TextStyle(fontSize: 12, color: accent ?? Colors.blue)),
              ] else if (isWarning) ...[
                Icon(Icons.warning_amber_rounded, size: 14, color: Colors.redAccent),
                const SizedBox(width: 6),
                Text(note ?? '잠재 혜택', style: const TextStyle(fontSize: 12, color: Colors.redAccent)),
              ] else if (note != null) ...[
                Text(note, style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 카드 스택 관련 UI는 더 이상 홈에 표시하지 않습니다.

  String _formatWon(int value) {
    final s = value.toString();
    final out = s.replaceAllMapped(RegExp(r"\B(?=(\d{3})+(?!\d))"), (m) => ',');
    return '₩$out';
  }

  // 하단에 보여줄 큰 카드 컴포넌트 (스택된 스타일)
  Widget _buildBottomCard() {
    return Center(
      child: SizedBox(
        width: 311, // 파란 카드의 너비 (가장 넓은 카드 기준)
        height: 387,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 파란 배경 카드 (뒤쪽) - width: 311, height: 365, 오프셋 적용
            Positioned(
              left: 26,
              top: 10,
              child: Container(
                width: 311,
                height: 365,
                decoration: BoxDecoration(
                  color: const Color(0xFF1560FF),
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
            ),

            // 흰색 카드 (앞쪽) - width: 285, height: 377
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 285,
                height: 377,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // 상단 헤더 섹션 (카드 이미지 + 제목/부제 + 꺽쇠)
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 카드 이미지
                          Container(
                            width: 88,
                            height: 56,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://www.shinhancard.com/pconts/images/contents/card/plate/cdCreditBOADT2.gif',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.credit_card, color: Colors.grey, size: 36),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // 제목 (오버플로우 방지)
                          Flexible(
                            child: Text(
                              '신한은행 LG전자 The 구독케어',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 서브타이틀
                          Text(
                            '본인 5699',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Expanded(child: SizedBox()),
                          // 상단 꺽쇠 (오른쪽 중앙)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Icon(
                              Icons.chevron_right,
                              color: Colors.black26,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 구분선 (전체 너비)
                  Container(
                    height: 1,
                    color: Color(0xFFF0F0F0),
                  ),
                  // 하단 금액 섹션
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '1월 이용금액',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
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
                                    '579,790원',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 하단 꺽쇠 (오른쪽 중앙)
                          Icon(
                            Icons.chevron_right,
                            color: Colors.black26,
                            size: 20,
                          ),
                        ],
                      ),
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
