import 'package:flutter/material.dart';
import 'package:my_app/screens/login/signup_complete_page.dart';
import 'package:my_app/services/codef_service.dart';

class CardLoginPage extends StatefulWidget {
  final String name;
  final String bankName;
  final String organization;

  const CardLoginPage({
    super.key,
    required this.name,
    required this.bankName,
    required this.organization,
  });

  @override
  State<CardLoginPage> createState() => _CardLoginPageState();
}

class _CardLoginPageState extends State<CardLoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _cardNoController = TextEditingController();
  final TextEditingController _cardPwController = TextEditingController();
  bool _obscurePw = true;
  bool _obscureCardPw = true;
  bool _isLoading = false;

  final CodefService _codefService = CodefService();

  bool get _canSubmit =>
      _idController.text.trim().isNotEmpty &&
      _pwController.text.isNotEmpty &&
      _cardNoController.text.trim().isNotEmpty &&
      _cardPwController.text.length == 2;

  Future<void> _onConnect() async {
    if (!_canSubmit || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // 1. Connected ID 생성
      final connectedResult = await _codefService.createConnectedId(
        organization: widget.organization,
        cardId: _idController.text.trim(),
        password: _pwController.text,
      );
      final connectedId = connectedResult['connected_id'] as String;

      // 2. 카드 목록 조회/저장
      await _codefService.getCardList(
        organization: widget.organization,
        connectedId: connectedId,
      );

      // 3. 청구 내역 조회/저장
      await _codefService.getCardBilling(
        organization: widget.organization,
        connectedId: connectedId,
      );

      // 4. 승인 내역 조회/저장
      final now = DateTime.now();
      final startDate = '${now.year}${now.month.toString().padLeft(2, '0')}01';
      final endDate = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';

      await _codefService.getCardApproval(
        organization: widget.organization,
        connectedId: connectedId,
        startDate: startDate,
        endDate: endDate,
        cardNo: _cardNoController.text.trim(),
        cardPassword: _cardPwController.text,
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SignupCompletePage(name: widget.name),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카드사 연결 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _cardNoController.dispose();
    _cardPwController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.bankName} 로그인 정보를\n입력해주세요.',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                '카드사 홈페이지 아이디와 비밀번호를 입력해주세요.',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),

              // 아이디
              const Text('아이디', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: _idController,
                decoration: InputDecoration(
                  hintText: '카드사 아이디',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // 비밀번호
              const Text('비밀번호', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: _pwController,
                obscureText: _obscurePw,
                decoration: InputDecoration(
                  hintText: '카드사 비밀번호',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePw ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePw = !_obscurePw),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // 카드 번호
              const Text('카드 번호', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              TextField(
                controller: _cardNoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: '카드 번호 (숫자만 입력)',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: theme.primaryColor, width: 2),
                  ),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // 카드 비밀번호 앞 2자리
              const Text('카드 비밀번호', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _cardPwController,
                      obscureText: _obscureCardPw,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      decoration: InputDecoration(
                        counterText: '',
                        hintText: '••',
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: theme.primaryColor, width: 2),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureCardPw ? Icons.visibility_off : Icons.visibility, size: 18),
                          onPressed: () => setState(() => _obscureCardPw = !_obscureCardPw),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: List.generate(2, (_) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(width: 8),
                  Text('앞 2자리만 입력', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_canSubmit && !_isLoading) ? _onConnect : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(56),
                    backgroundColor: const Color(0xFF1787FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('연결하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
