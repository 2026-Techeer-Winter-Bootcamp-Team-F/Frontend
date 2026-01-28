import 'package:flutter/material.dart';
import 'package:my_app/config/navigator_key.dart';
import 'package:my_app/screens/main_navigation.dart';

class SignupCompletePage extends StatefulWidget {
  final String name;
  const SignupCompletePage({super.key, required this.name});

  @override
  State<SignupCompletePage> createState() => _SignupCompletePageState();
}

class _SignupCompletePageState extends State<SignupCompletePage> {
  @override
  void initState() {
    super.initState();
    // 2초 후 메인 화면으로 이동 (DevicePreview 사용 시 Navigator.of(context)가
    // 동작하지 않을 수 있어 appNavigatorKey 사용)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      appNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => MainNavigation(name: widget.name)),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayName = widget.name;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 120, 24, 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(child: Image.asset('assets/images/logo.png', width: 200, height: 200)),
              const SizedBox(height: 0),
              Text(
                '로그인 완료!',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.brightness == Brightness.dark
                      ? Colors.white
                      : const Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 12),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: displayName,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    TextSpan(
                      text: '님,\n',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                    TextSpan(
                      text: '환영합니다!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.brightness == Brightness.dark
                            ? Colors.white
                            : const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
