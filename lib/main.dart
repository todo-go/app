import 'package:flutter/material.dart';
import 'package:todogo/features/todo/presentation/screens/main/main_screen.dart';
import 'package:todogo/features/todo/presentation/screens/splash/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'SUITE'),
      home: const MainScreen(),
    );
  }
}
