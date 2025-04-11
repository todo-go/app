import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todogo/features/todo/presentation/screens/splash/splash_screen.dart';

void main() async {
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SUITE'),
      home: const SplashScreen(),
    );
  }
}
