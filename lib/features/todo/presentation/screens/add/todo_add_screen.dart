import 'package:flutter/material.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/todo/presentation/common/dialog/confirm_delete_dialog.dart';

class TodoAddScreen extends StatefulWidget {
  const TodoAddScreen({super.key});

  @override
  State<TodoAddScreen> createState() => _TodoAddScreenState();
}

class _TodoAddScreenState extends State<TodoAddScreen> {
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
            // onPressed: () {
            //   Navigator.pop(context);
            // },
            onTap: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmDeleteDialog(),
              );

              if (result == true) {
                print('Item deleted');
              } else {
                Navigator.pop(context);
              }
            },
            child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          ),
        ),
      ),
      body: Center(child: Text("추가")),
    );
  }
}
