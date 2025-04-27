import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/auth/presentation/screens/login_screen.dart';
import 'package:todogo/features/todo/presentation/screens/main/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Map<String, dynamic> _loadedData = {};

  @override
  void initState() {
    super.initState();
    _checkUuidAndLoadData();
  }

  Future<void> _checkUuidAndLoadData() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('uuid');

    if (uuid != null) {
      await _loadTodosFromApi(uuid);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainScreen(preloadedData: _loadedData),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  Future<void> _loadTodosFromApi(String uuid) async {
    final url = Uri.parse(
      'http://todogo-env.eba-n7q4attf.ap-northeast-2.elasticbeanstalk.com/api/tasks/user/$uuid',
    );
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final Map<String, List<dynamic>> groupedData = {};

        for (final item in data) {
          final dateKey = item['deadline'].split('T').first;
          groupedData.putIfAbsent(dateKey, () => []).add(item);
        }

        setState(() {
          _loadedData = groupedData;
        });
      } else {
        print('Failed to load todos: ${response.body}');
      }
    } catch (e) {
      print('Error loading todos from API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          const SizedBox(height: 80),
          const Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 100,
                  ),
                  Text(
                    '투두고',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '하루 일정을 간단히 관리하세요!',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Text(
            '경북소프트웨어마이스터고등학교',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
