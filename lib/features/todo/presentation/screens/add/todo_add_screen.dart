import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/todo/presentation/common/dialog/confirm_delete_dialog.dart';

class TodoAddScreen extends StatefulWidget {
  final DateTime selectedDate;

  const TodoAddScreen({Key? key, required this.selectedDate}) : super(key: key);

  @override
  _TodoAddScreenState createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contectController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(titleFocusNode);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contectController.dispose();
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _addTodo() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');
    if (userId == null) return;

    final url = Uri.parse('${dotenv.env['API_URL']}/api/tasks');
    final body = {
      "title": titleController.text,
      "description": contectController.text,
      "deadline": widget.selectedDate.toIso8601String(),
      "status": false,
      "userId": int.parse(userId),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('추가 실패: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('추가 중 오류 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'yyyy년 MM월 dd일',
    ).format(widget.selectedDate);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Colors.white,
        leadingWidth: 50,
        title: Text(formattedDate, style: TextStyle(fontSize: 18)),
        leading: Padding(
          padding: EdgeInsets.only(top: 60),
          child: GestureDetector(
            onTap: () async {
              if (titleController.text.isNotEmpty ||
                  contectController.text.isNotEmpty) {
                final result = await showDialog<bool>(
                  context: context,
                  builder: (context) => const ConfirmDeleteDialog(),
                );

                if (result == true) {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    style: TextStyle(fontSize: 24),
                    decoration: InputDecoration(
                      hintText: '제목을 작성하세요',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    maxLength: 10,
                    cursorColor: AppColors.textSecondary,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (value) {
                      FocusScope.of(context).requestFocus(contentFocusNode);
                    },
                  ),
                  TextField(
                    controller: contectController,
                    focusNode: contentFocusNode,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: '내용을 작성하세요',
                      hintStyle: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    maxLength: 50,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 150),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _addTodo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "일정 추가하기",
                            style: TextStyle(
                              color: AppColors.background,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 80,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
