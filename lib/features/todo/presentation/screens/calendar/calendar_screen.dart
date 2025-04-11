import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/todo/presentation/widgets/todo_item_widget.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:todogo/features/todo/data/models/todo_model.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

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
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    try {
      final String jsonStr = await rootBundle.loadString(
        'assets/json/todos_sample.json',
      );
      final List<dynamic> data = json.decode(jsonStr);
      final todos = data.map((e) => TodoModel.fromJson(e)).toList();

      // Group todos by date
      setState(() {
        for (final todo in todos) {
          _todoMapByDate.putIfAbsent(todo.date, () => []).add(todo);
        }
      });
    } catch (e) {
      // Handle error
      print('Error loading todos: $e');
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
        ),
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
                  _focusedDay = focusedDay; // update focusedDay as well
                });
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
              ),
              headerStyle: HeaderStyle(formatButtonVisible: false),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child:
                  todos.isEmpty
                      ? Center(child: Text('해당 날자에는 할 일이 없어요!'))
                      : ListView.builder(
                        itemCount: todos.length,
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return TodoItemWidget(
                            title: todo.title,
                            subtitle: todo.subtitle,
                            isDone: todo.isCompleted,
                          );
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
