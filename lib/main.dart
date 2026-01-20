import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_app/config/theme.dart';
import 'package:my_app/providers/auth_provider.dart';
import 'package:my_app/providers/card_provider.dart';
import 'package:my_app/providers/expense_provider.dart';
import 'package:my_app/providers/chat_provider.dart';
import 'package:my_app/screens/splash/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'BeneFit',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashPage(),
      ),
    );
  }
}
