import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:device_preview/device_preview.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/splash/splash_page.dart';

void main() {
  runApp(
    kReleaseMode
        ? const MyApp()
        : DevicePreview(
            enabled: true,
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
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      builder: kReleaseMode ? null : DevicePreview.appBuilder,
    );
  }
}
