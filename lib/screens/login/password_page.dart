import 'package:flutter/material.dart';
import 'package:my_app/screens/bank/bank_selection_page.dart';

class PasswordPage extends StatefulWidget {
  final String phone;
  final String name;
  const PasswordPage({super.key, required this.phone, required this.name});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _obscurePw = true;
  bool _obscureConfirm = true;
  String? _pwError;
  String? _confirmError;
  int _step = 0; // 0: 비밀번호 입력, 1: 재확인 입력

  final RegExp _pwRule = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');

  @override
  void dispose() {
    _pwController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _validatePw(String v) {
    if (v.isEmpty) {
      _pwError = null;
    } else {
      _pwError = _pwRule.hasMatch(v) ? null : '영문, 숫자, 특수문자 조합 (최소 8자)';
    }
    if (_step == 1) _validateConfirm(_confirmController.text);
    setState(() {});
  }

  void _validateConfirm(String v) {
    if (v.isEmpty) {
      _confirmError = null;
    } else if (!_pwRule.hasMatch(v)) {
      _confirmError = '영문, 숫자, 특수문자 조합 (최소 8자)';
    } else if (v != _pwController.text) {
      _confirmError = '입력한 비밀번호와 일치하지 않습니다.';
    } else {
      _confirmError = null;
    }
    setState(() {});
  }

  bool get _canProceedStep0 {
    return _pwController.text.isNotEmpty && _pwError == null && _pwRule.hasMatch(_pwController.text);
  }

  bool get _canProceedStep1 {
    return _confirmController.text.isNotEmpty && _confirmError == null && _pwRule.hasMatch(_confirmController.text) && _confirmController.text == _pwController.text;
  }

  void _onNext() {
    if (!_canProceedStep0) return;
    setState(() {
      _step = 1;
      _confirmController.clear();
      _obscureConfirm = true;
      _confirmError = null;
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _onComplete() {
    if (!_canProceedStep1) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BankSelectionPage(name: widget.name)),
    );
  }

  InputDecoration _buildDecoration({
    required ThemeData theme,
    String? hint,
    String? error,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      helperText: null,
      errorText: error,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor, width: 2)),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '최소 8자리 이상\n비밀번호를 입력해주세요.',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),

              if (_step == 0) ...[
                const Text('비밀번호', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _pwController,
                  obscureText: _obscurePw,
                  onChanged: _validatePw,
                  decoration: _buildDecoration(
                    theme: theme,
                    hint: '영문, 숫자, 특수문자 조합',
                    error: _pwError,
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_pwController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _pwController.clear()),
                          ),
                        IconButton(
                          icon: Icon(_obscurePw ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscurePw = !_obscurePw),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceedStep0 ? _onNext : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ],

              if (_step == 1) ...[
                const Text('비밀번호 재확인', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  onChanged: _validateConfirm,
                  decoration: _buildDecoration(
                    theme: theme,
                    hint: '영문, 숫자, 특수문자 조합',
                    error: _confirmError,
                    suffix: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_confirmController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _confirmController.clear()),
                          ),
                        IconButton(
                          icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('비밀번호', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 6),
                TextField(
                  controller: TextEditingController(text: _pwController.text),
                  obscureText: true,
                  enabled: false,
                  decoration: _buildDecoration(theme: theme, hint: '', error: null),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canProceedStep1 ? _onComplete : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('확인'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}