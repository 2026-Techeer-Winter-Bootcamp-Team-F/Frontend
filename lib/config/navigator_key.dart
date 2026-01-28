import 'package:flutter/material.dart';

/// MaterialApp의 navigatorKey. DevicePreview 등으로 Navigator.of(context)가
/// 기대대로 동작하지 않을 때 이 key로 명시적으로 네비게이션.
final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();
