import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todogo/core/theme/colors.dart';
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
      theme: ThemeData(
        fontFamily: 'SUITE',
        cupertinoOverrideTheme: CupertinoThemeData(
          primaryColor: AppColors.primary,
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: AppColors.textSecondary,
          selectionColor: AppColors.primaryLight,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
