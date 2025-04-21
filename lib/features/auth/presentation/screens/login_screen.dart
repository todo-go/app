import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/auth/data/auth_service.dart';
import 'package:todogo/features/auth/presentation/screens/privacy_policy_screen.dart';
import 'package:todogo/features/todo/presentation/screens/main/main_screen.dart';

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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
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
      _version = '${packageInfo.version}'; // Get the version from pubspec.yaml
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 200),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: AppColors.primary,
                      size: 100,
                    ),
                    Text(
                      '투두고',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    Text(
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
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: '닉네임',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1, color: AppColors.primary),
                  ),
                  fillColor: Colors.white,
                  counterText: '',
                ),
                maxLength: 10,
                cursorColor: AppColors.primary,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                style: TextStyle(fontSize: 14),
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '전화번호 (예: 01012341234)',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: AppColors.textSecondary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(width: 1, color: AppColors.primary),
                  ),
                  fillColor: Colors.white,
                  counterText: '',
                ),
                maxLength: 11,
                cursorColor: AppColors.primary,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.zero, // Remove padding
                    child: Checkbox(
                      activeColor: AppColors.primary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(
                        horizontal: VisualDensity.minimumDensity,
                        vertical: VisualDensity.minimumDensity,
                      ),
                      value: true, // You can manage this state with a variable
                      onChanged: (bool? value) {
                        // Handle checkbox state change
                      },
                    ),
                  ),
                  SizedBox(width: 5),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '개인정보 수집 및 이용에 동의합니다. ',
                            style: TextStyle(color: Colors.black),
                          ),
                          TextSpan(
                            text: '보기',
                            style: TextStyle(
                              color: Colors.black,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer:
                                TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => PrivacyPolicyScreen(
                                              url:
                                                  'https://melon-hammer-751.notion.site/1d924e64ed2c809c9fb9dee53dfca45b',
                                            ),
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _registerAndNavigate();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary, // Set the button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
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
                    style: TextStyle(
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
