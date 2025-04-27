import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/auth/data/auth_service.dart';
import 'package:todogo/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:todogo/features/todo/presentation/screens/main/main_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _version = '';

  void _registerAndNavigate() async {
    try {
      await _authService.registerUser(
        _phoneController.text,
        _nameController.text,
      );

      final prefs = await SharedPreferences.getInstance();
      final uuid = prefs.getString('uuid');

      if (uuid != null) {
        final preloadedData = await _loadTodosFromApi(uuid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(preloadedData: preloadedData),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사용자 정보를 불러올 수 없습니다.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  Future<Map<String, dynamic>> _loadTodosFromApi(String uuid) async {
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

        return groupedData;
      } else {
        print('Failed to load todos: ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error loading todos from API: $e');
      return {};
    }
  }

  @override
  void initState() {
    super.initState();
    _getVersion();
  }

  Future<void> _getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = '${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 200),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 100,
                    ),
                    const Text(
                      '투두고',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      '하루 일정을 간단히 관리하세요!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '닉네임',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 1,
                      color: AppColors.primary,
                    ),
                  ),
                  fillColor: Colors.white,
                  counterText: '',
                ),
                maxLength: 10,
                cursorColor: AppColors.primary,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                style: const TextStyle(fontSize: 14),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '전화번호 (예: 01012341234)',
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: const BorderSide(
                      width: 1,
                      color: AppColors.primary,
                    ),
                  ),
                  fillColor: Colors.white,
                  counterText: '',
                ),
                maxLength: 11,
                cursorColor: AppColors.primary,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _registerAndNavigate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "투두고 시작하기!",
                    style: TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 5),
              Row(
                children: [
                  Text(
                    "ver. $_version",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
