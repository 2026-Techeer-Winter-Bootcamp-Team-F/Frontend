import 'package:flutter/material.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/home/home_page.dart';
import 'package:my_app/screens/onboarding/benefit_score_page.dart';
// '소비' 탭은 기존 `HomePage`로 이동했으므로 ExpenseAnalysisPage import는 더 이상 필요하지 않습니다.
import 'package:my_app/screens/cards/card_analysis_page.dart';
import 'package:my_app/screens/subscription/subscription_page.dart';
import 'package:my_app/screens/chat/chat_page.dart';
import 'package:my_app/services/chat_service.dart';

class MainNavigation extends StatefulWidget {
  final String name;
  final int initialIndex;
  const MainNavigation({super.key, this.name = '', this.initialIndex = 0});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _Conversation {
  final int id;
  final String sessionId;
  final String title;
  final String lastMessage;
  final String time;

  const _Conversation({required this.id, required this.sessionId, required this.title, required this.lastMessage, required this.time});
}

// 말풍선 CustomPainter
class ChatBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    
    // 둥근 말풍선 그리기
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height * 0.75),
      Radius.circular(size.width * 0.5), // 더 둥근 모서리
    );
    path.addRRect(rect);
    
    // 말풍선 꼬리 (아래쪽 작은 삼각형)
    final tailWidth = size.width * 0.2;
    final tailStartX = size.width * 0.2;
    
    path.moveTo(tailStartX, size.height * 0.75);
    path.lineTo(tailStartX - tailWidth * 0.3, size.height);
    path.lineTo(tailStartX + tailWidth, size.height * 0.75);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class ChatbotFloating extends StatefulWidget {
  final VoidCallback? onTap;

  const ChatbotFloating({super.key, this.onTap});

  @override
  State<ChatbotFloating> createState() => _ChatbotFloatingState();
}

class _ChatbotFloatingState extends State<ChatbotFloating> {
  double _xPosition = 0;
  double _yPosition = 0;
  bool _isInitialized = false;
  bool _isHidden = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final screenSize = MediaQuery.of(context).size;
      _xPosition = screenSize.width - 72; // 오른쪽 여백 16 + 위젯 크기 56
      _yPosition = screenSize.height - 150; // 하단바 위
      _isInitialized = true;
    }
  }

  void _onDragEnd(DragEndDetails details) {
    final screenSize = MediaQuery.of(context).size;
    final widgetSize = 56.0;
    final threshold = 20.0; // 모서리 근처 감지 거리
    final hideOffset = 42.0; // 숨김 시 튀어나오는 크기

    setState(() {
      // 왼쪽 가장자리 근처인지 확인
      if (_xPosition < threshold) {
        _xPosition = -hideOffset;
        _isHidden = true;
      }
      // 오른쪽 가장자리 근처인지 확인
      else if (_xPosition > screenSize.width - widgetSize - threshold) {
        _xPosition = screenSize.width - (widgetSize - hideOffset);
        _isHidden = true;
      }
      // 위쪽 가장자리 근처인지 확인
      else if (_yPosition < threshold) {
        _yPosition = -hideOffset;
        _isHidden = true;
      }
      // 아래쪽 가장자리 근처인지 확인
      else if (_yPosition > screenSize.height - widgetSize - threshold) {
        _yPosition = screenSize.height - (widgetSize - hideOffset);
        _isHidden = true;
      } else {
        _isHidden = false;
      }

      // 화면 경계 내로 제한 (완전히 숨기지 않을 때)
      if (!_isHidden) {
        _xPosition = _xPosition.clamp(0.0, screenSize.width - widgetSize);
        _yPosition = _yPosition.clamp(0.0, screenSize.height - widgetSize);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: _xPosition,
      top: _yPosition,
      child: GestureDetector(
        onTap: () {
          // 숨겨진 상태면 먼저 보이게 함
          if (_isHidden) {
            final screenSize = MediaQuery.of(context).size;
            final widgetSize = 56.0;
            setState(() {
              // 가장 가까운 안전한 위치로 복귀
              if (_xPosition < 0) {
                _xPosition = 16;
              } else if (_xPosition > screenSize.width - widgetSize) {
                _xPosition = screenSize.width - widgetSize - 16;
              }
              if (_yPosition < 0) {
                _yPosition = 16;
              } else if (_yPosition > screenSize.height - widgetSize) {
                _yPosition = screenSize.height - widgetSize - 16;
              }
              _isHidden = false;
            });
          } else {
            widget.onTap?.call();
          }
        },
        onPanUpdate: (details) {
          setState(() {
            _xPosition += details.delta.dx;
            _yPosition += details.delta.dy;
            _isHidden = false;
          });
        },
        onPanEnd: _onDragEnd,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.14), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 말풍선 모양
              CustomPaint(
                size: const Size(32, 32),
                painter: ChatBubblePainter(),
              ),
              // 물음표
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
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


class ChatbotSheet extends StatefulWidget {
  const ChatbotSheet({super.key});

  @override
  State<ChatbotSheet> createState() => _ChatbotSheetState();
}

class _ChatbotSheetState extends State<ChatbotSheet> {
  int _selectedIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  final ChatService _chatService = ChatService();
  List<_Conversation> _allConversations = [];
  bool _isLoading = true;
  bool _isCreatingRoom = false;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    // 목데이터 사용 (API 연동 주석처리)
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    final mockConversations = [
      _Conversation(
        id: 0,
        sessionId: 'mock_session_1',
        title: '이번 달 커피값 얼마나 썼어?',
        lastMessage: '이번 달 커피 관련 소비를 분석해봤어요! 총 지출: 47,500원...',
        time: '2시간 전',
      ),
      _Conversation(
        id: 1,
        sessionId: 'mock_session_2',
        title: '카드 추천해줘',
        lastMessage: '고객님의 소비 패턴을 분석해서 추천드릴게요! 신한카드 Deep Dream...',
        time: '1일 전',
      ),
      _Conversation(
        id: 2,
        sessionId: 'mock_session_3',
        title: '내 소비 패턴 분석해줘',
        lastMessage: '고객님의 이번 달 소비 패턴이에요! 식비: 324,000원 (32%)...',
        time: '3일 전',
      ),
      _Conversation(
        id: 3,
        sessionId: 'mock_session_4',
        title: '연회비 아까운 카드 있어?',
        lastMessage: '연회비 대비 혜택을 분석해봤어요! BC카드는 해지를 고려해보세요...',
        time: '1주 전',
      ),
    ];

    setState(() {
      _allConversations = mockConversations;
      _isLoading = false;
    });

    /* 기존 API 연동 코드
    try {
      final sessions = await _chatService.getSavedSessions();
      if (!mounted) return;

      final conversations = <_Conversation>[];
      for (int i = 0; i < sessions.length; i++) {
        final s = sessions[i];
        final updatedAt = DateTime.parse(s['updated_at'] as String);
        conversations.add(_Conversation(
          id: i,
          sessionId: s['session_id'] as String,
          title: s['title'] as String,
          lastMessage: s['last_message'] as String? ?? '',
          time: _formatTime(updatedAt),
        ));
      }

      setState(() {
        _allConversations = conversations.reversed.toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
    */
  }

  Future<void> _createRoomAndNavigate() async {
    if (_isCreatingRoom) return;
    setState(() => _isCreatingRoom = true);

    // 목데이터 사용 (API 연동 주석처리)
    await Future.delayed(const Duration(milliseconds: 200));
    final sessionId = 'mock_session_${DateTime.now().millisecondsSinceEpoch}';

    if (!mounted) return;
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatPage(sessionId: sessionId)),
    );

    /* 기존 API 연동 코드
    try {
      final result = await _chatService.makeRoom();
      final sessionId = result['session_id'] as String;

      if (!mounted) return;
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ChatPage(sessionId: sessionId)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isCreatingRoom = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('채팅방 생성에 실패했습니다.')),
      );
    }
    */
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inHours < 1) return '${diff.inMinutes}분 전';
    if (diff.inDays < 1) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}주 전';
    return '${(diff.inDays / 30).floor()}달 전';
  }

  List<_Conversation> get _filteredConversations {
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) return _allConversations;
    return _allConversations.where((c) => c.title.contains(q) || c.lastMessage.contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.86;

    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).viewInsets.top),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  // Header: logo + title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Logo: white circle with "BeneFit" text in blue
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              'BeneFit',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Title
                        Expanded(
                          child: Text(
                            'BeneFit',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Content area
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: [
                        // Home screen
                        SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Message card with speech bubble tail
                              Stack(
                                children: [
                                  // Main card
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.06),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '카드 혜택부터 비교까지 무엇이든 물어보세요.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context).colorScheme.onSurface,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 1),
                                        Text(
                                          '실제 데이터 기반으로 맞춤형 카드를 추천해드려요.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Theme.of(context).colorScheme.onSurface,
                                            height: 1.4,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: _isCreatingRoom ? null : _createRoomAndNavigate,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.primary,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(26),
                                              ),
                                              padding: const EdgeInsets.symmetric(vertical: 16),
                                              elevation: 0,
                                            ),
                                            child: _isCreatingRoom
                                                ? const SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                                  )
                                                : const Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '질문하기',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Icon(Icons.send, color: Colors.white, size: 18),
                                                    ],
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Speech bubble tail (left side, top)
                                  Positioned(
                                    left: 20,
                                    top: -6,
                                    child: CustomPaint(
                                      painter: _BubbleTailPainter(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                                      size: const Size(16, 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              const SizedBox(height: 200),
                            ],
                          ),
                        ),
                        // Conversation screen
                        Column(
                          children: [
                            // 검색창
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                              child: TextField(
                                controller: _searchCtrl,
                                decoration: InputDecoration(
                                  hintText: '채팅 검색',
                                  prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  filled: true,
                                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : _filteredConversations.isEmpty
                                      ? Center(
                                          child: Text(
                                            '아직 대화 기록이 없어요.\n새 질문을 시작해보세요!',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                                              fontSize: 14,
                                            ),
                                          ),
                                        )
                                      : ListView.builder(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          itemCount: _filteredConversations.length,
                                          itemBuilder: (context, idx) {
                                            final c = _filteredConversations[idx];
                                            return Padding(
                                              padding: const EdgeInsets.only(bottom: 12),
                                              child: InkWell(
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(builder: (_) => ChatPage(sessionId: c.sessionId, isNewChat: false)),
                                                  );
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(12),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      CircleAvatar(radius: 20, backgroundColor: Colors.white, child: Icon(Icons.smart_toy, color: Colors.blue)),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(c.title, style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.onSurface)),
                                                            const SizedBox(height: 6),
                                                            Text(c.lastMessage, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 13)),
                                                          ],
                                                        ),
                                                      ),
                                                      Text(c.time, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                            ),
                            // 새 문의하기 버튼
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                              child: Center(
                                child: ElevatedButton(
                                  onPressed: _isCreatingRoom ? null : _createRoomAndNavigate,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                                  ),
                                  child: _isCreatingRoom
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('새 질문하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                            SizedBox(width: 8),
                                            Icon(Icons.send, color: Colors.white, size: 18),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Bottom tab bar
                  const Divider(height: 1),
                  SizedBox(
                    height: 68,
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedIndex = 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.home, color: _selectedIndex == 0 ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
                                const SizedBox(height: 6),
                                Text('홈', style: TextStyle(color: _selectedIndex == 0 ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedIndex = 1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble, color: _selectedIndex == 1 ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant, size: 22),
                                const SizedBox(height: 6),
                                Text('대화', style: TextStyle(color: _selectedIndex == 1 ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Close button (top right, Positioned)
              Positioned(
                top: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE8E8E8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
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


class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  late final List<Widget> _pages = [
    BenefitScorePage(name: widget.name),
    const HomePage(),
    const CardAnalysisPage(),
    const SubscriptionPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, _pages.length - 1);
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final bool selected = _currentIndex == index;
    final color = selected ? AppColors.primary : Theme.of(context).colorScheme.onSurfaceVariant;

    // Use larger icon when selected for emphasis
    final iconSize = selected ? 26.0 : 22.0;
    final selectedCircleSize = 36.0;
    final labelFontSize = 11.0;
    final spacing = 2.0;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: spacing),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // selected 상태는 파란 원 배경에 흰 아이콘
              if (selected)
                Container(
                  width: selectedCircleSize,
                  height: selectedCircleSize,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Icon(icon, color: Colors.white, size: iconSize)),
                )
              else
                Icon(icon, color: color, size: iconSize),
              SizedBox(height: spacing),
              Text(label, style: TextStyle(color: color, fontSize: labelFontSize, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Floating chatbot widget visible across all main pages
          ChatbotFloating(onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const ChatbotSheet(),
            );
          }),
        ],
      ),
      bottomNavigationBar: Container(
        width: 440,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        height: 74,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildNavItem(index: 0, icon: Icons.home, label: '홈'),
            _buildNavItem(index: 1, icon: Icons.pie_chart_outline, label: '소비'),
            _buildNavItem(index: 2, icon: Icons.credit_card, label: '카드'),
            _buildNavItem(index: 3, icon: Icons.subscriptions, label: '구독'),
          ],
        ),
      ),
    );
  }
}

// Custom painter for speech bubble tail
class _BubbleTailPainter extends CustomPainter {
  const _BubbleTailPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw triangle pointing up to the left
    final path = Path();
    path.moveTo(0, 0); // Top left
    path.lineTo(size.width, size.height); // Bottom right
    path.lineTo(size.width - 4, 0); // Top right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_BubbleTailPainter oldDelegate) => false;
}