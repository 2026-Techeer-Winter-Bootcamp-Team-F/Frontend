import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:device_preview/device_preview.dart';
import 'package:my_app/config/navigator_key.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/screens/splash/splash_page.dart';

/// true이면 디버그에서 DevicePreview 사용 (iPhone 프레임 + Device preview 패널)
const bool _kUseDevicePreviewInDebug = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (kReleaseMode) {
    runApp(const MyApp());
  } else if (_kUseDevicePreviewInDebug) {
    runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'BeneFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      builder: (!kReleaseMode && _kUseDevicePreviewInDebug) ? DevicePreview.appBuilder : null,
    );
  }
}
