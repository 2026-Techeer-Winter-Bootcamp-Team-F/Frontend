import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:device_preview/device_preview.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/splash/splash_page.dart';

void main() {
  // 웹에서 Google Fonts 자동 로딩 방지
  if (kIsWeb) {
    // 웹 환경에서 추가 설정이 필요한 경우 여기에 작성
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      defaultDevice: Devices.ios.iPhone16ProMax,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeneFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashPage(),

      // ★ DevicePreview 적용을 위한 최소 필수 옵션
      useInheritedMediaQuery: true,
      builder: DevicePreview.appBuilder,
    );
  }
}
