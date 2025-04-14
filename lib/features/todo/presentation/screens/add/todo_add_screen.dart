import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/todo/presentation/common/dialog/confirm_delete_dialog.dart';

class TodoAddScreen extends StatefulWidget {
  const TodoAddScreen({super.key});

  @override
  State<TodoAddScreen> createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contectController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 150,
        backgroundColor: Colors.white,
        leadingWidth: 50,
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
                  print('Item deleted');
                } else {
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
                  ),

                  TextField(
                    controller: contectController,
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
                    onSubmitted: (value) {},
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
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                AppColors.primary, // Set the button color
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
