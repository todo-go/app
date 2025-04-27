import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/todo/presentation/screens/add/todo_add_screen.dart';
import 'package:todogo/features/todo/data/models/todo_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:todogo/features/todo/presentation/widgets/todo_item_widget.dart';

class CalendarScreen extends StatefulWidget {
  final Map<String, List<TodoModel>> preloadedData;
  const CalendarScreen({required this.preloadedData, super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<String, List<TodoModel>> _todoMapByDate = {};

  @override
  void initState() {
    super.initState();
    _todoMapByDate = widget.preloadedData;
    _loadTodosFromApi();
  }

  Future<void> _loadTodosFromApi() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('uuid');
    if (uuid == null) return;

    final url = Uri.parse('${dotenv.env['API_URL']}/api/tasks/user/$uuid');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final todos = data.map((e) => TodoModel.fromJson(e)).toList();

        setState(() {
          _todoMapByDate.clear();
          for (final todo in todos) {
            final dateKey = todo.deadline.split('T').first;
            _todoMapByDate.putIfAbsent(dateKey, () => []).add(todo);
          }
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
    final dateKey = _selectedDay.toIso8601String().split('T').first;
    final todos = _todoMapByDate[dateKey] ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leadingWidth: 50,
        toolbarHeight: 100,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TodoAddScreen(selectedDate: _selectedDay),
                ),
              );
            },
            child: SvgPicture.asset(
              'assets/icons/file-edit.svg',
              colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
              width: 24,
              height: 24,
            ),
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              locale: 'ko_KR',
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              eventLoader: (day) {
                final dateKey = day.toIso8601String().split('T').first;
                return _todoMapByDate[dateKey] ?? [];
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: TextStyle(color: Colors.red),
                markerDecoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(formatButtonVisible: false),
            ),
          ),
          Expanded(
            child:
                todos.isEmpty
                    ? Center(
                      child: Text(
                        '선택한 날짜에 할 일이 없습니다.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                    : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return TodoItemWidget(
                          title: todo.title,
                          subtitle: todo.description,
                          isDone: todo.status,
                          onDelete: () async {
                            final url = Uri.parse(
                              '${dotenv.env['API_URL']}/api/users/${todo.userId}/tasks/${todo.taskNumber}',
                            );

                            try {
                              final response = await http.delete(url);

                              if (response.statusCode == 200) {
                                setState(() {
                                  todos.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${todo.title}가 삭제되었습니다.'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('삭제 실패: ${response.body}'),
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('삭제 중 오류 발생: $e')),
                              );
                            }
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
