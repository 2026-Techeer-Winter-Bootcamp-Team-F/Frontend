import 'package:flutter/material.dart';
import 'package:my_app/screens/auth/phone_login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _isMoved = false;

  @override
  void initState() {
    super.initState();
    // 1.5초 후에 로고 이동 및 버튼 표시
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _isMoved = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 화면 크기를 가져와서 로고 위치 계산
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 로고 애니메이션
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            top: _isMoved ? screenHeight * 0.25 : (screenHeight / 2) - 50, // 중앙에서 상단 25% 지점으로 이동 (로고 크기 고려)
            left: 0,
            right: 0,
            child: const Center(
              child: Icon(Icons.check_circle_rounded, color: Color(0xFF2962FF), size: 100),
            ),
          ),
          
          // 버튼 애니메이션 (로고 이동 후 나타남)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            // 화면 하단에 위치하도록 설정 (전체 높이 - 버튼 영역 대략적 높이 - 하단 여백)
            top: _isMoved ? screenHeight - 200 : screenHeight, 
            left: 24,
            right: 24,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _isMoved ? 1.0 : 0.0,
              child: Column(
                children: [
                  // 로그인 버튼 (파란색)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // 전화번호 입력 화면으로 이동
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2962FF), // 로고와 동일한 파란색
                        foregroundColor: Colors.white, // 흰색 텍스트
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12), // 버튼 사이 여백
                  // 회원가입 버튼 (흰색)
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                         // 회원가입도 동일하게 전화번호 입력으로 이동 (임시)
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PhoneLoginPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // 흰색 배경
                        foregroundColor: Colors.black, // 검정 텍스트
                        elevation: 0,
                        side: const BorderSide(color: Color(0xFFE0E0E0)), // 연한 테두리 추가
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
