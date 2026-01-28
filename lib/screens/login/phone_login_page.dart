import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/screens/login/login_password_page.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  bool get _canProceed {
    final digits = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
      return RegExp(r'^\d{10,11}$').hasMatch(digits);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _next() {
    if (!_canProceed) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoginPasswordPage(phone: _phoneController.text.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const darkBg = Color(0xFF1E1E1E);
    const darkerBg = Color(0xFF121212);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: darkBg,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: darkerBg,
        appBar: AppBar(
          backgroundColor: darkBg,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '전화번호를 입력해주세요.',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 18),
                const Text('전화번호', style: TextStyle(fontSize: 12, color: Color(0xFFB0B0B0))),
                const SizedBox(height: 6),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  autofocus: true,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                  onSubmitted: (_) => _next(),
                  decoration: InputDecoration(
                    hintText: '01012345678',
                    hintStyle: const TextStyle(color: Color(0xFF6B6B6B)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF4A4A4A))),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: theme.primaryColor, width: 2)),
                    suffixIcon: _phoneController.text.isEmpty
                        ? null
                        : IconButton(
                            icon: Container(
                              decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF3A3A3A)),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.clear, size: 18, color: Color(0xFFB0B0B0)),
                            ),
                            onPressed: () => setState(() => _phoneController.clear()),
                          ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canProceed ? _next : null,
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                  child: const Text('확인'),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}