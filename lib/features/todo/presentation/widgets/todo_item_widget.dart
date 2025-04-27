import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:todogo/core/theme/colors.dart';

class TodoItemWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;
  final String deadline;
  final int userId;
  final int taskId;
  final VoidCallback onDelete;
  final ValueChanged<bool> onStatusChanged;

  const TodoItemWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isDone,
    required this.deadline,
    required this.userId,
    required this.taskId,
    required this.onDelete,
    required this.onStatusChanged,
  }) : super(key: key);

  Future<void> _updateStatus(BuildContext context, bool newStatus) async {
    final url = Uri.parse(
      '${dotenv.env['API_URL']}/api/users/$userId/tasks/$taskId',
    );

    final body = {
      "title": title,
      "description": subtitle,
      "deadline": deadline,
      "status": newStatus,
      "userId": userId,
    };

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        onStatusChanged(newStatus);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('상태 업데이트 실패: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('상태 업데이트 중 오류 발생: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        onDelete();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Checkbox(
              value: isDone,
              onChanged: (value) {
                if (value != null) {
                  _updateStatus(context, value);
                }
              },
              activeColor: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDone ? Colors.grey : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
