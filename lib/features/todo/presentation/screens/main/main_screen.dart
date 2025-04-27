import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:intl/intl.dart';
import 'package:todogo/features/todo/presentation/screens/add/todo_add_screen.dart';
import 'package:todogo/features/todo/presentation/screens/calendar/calendar_screen.dart';
import 'package:todogo/features/todo/presentation/widgets/todo_item_widget.dart';
import 'package:todogo/features/todo/data/models/todo_model.dart';
import 'package:http/http.dart' as http;

class MainScreen extends StatefulWidget {
  final Map<String, dynamic> preloadedData;

  const MainScreen({required this.preloadedData, super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final List<DateTime> _dates = List.generate(365, (index) {
    return DateTime.now().add(Duration(days: index));
  });

  late Map<String, List<TodoModel>> _todoMapByDate;

  @override
  void initState() {
    super.initState();
    _todoMapByDate = widget.preloadedData.map((key, value) {
      return MapEntry(
        key,
        (value as List).map((e) => TodoModel.fromJson(e)).toList(),
      );
    });

    _tabController = TabController(length: _dates.length, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 150, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 150,
        centerTitle: false,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '투두고',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                DateFormat('EEEE, M월 d일', 'ko_KR').format(DateTime.now()),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(top: 60, right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            CalendarScreen(preloadedData: _todoMapByDate),
                  ),
                );
              },
              child: SvgPicture.asset(
                'assets/icons/calendar.svg',
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  AppColors.primary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 날짜 TabBar
          Container(
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 0.5),
              ),
            ),
            child: TabBar(
              tabAlignment: TabAlignment.start,
              controller: _tabController,
              isScrollable: true,
              tabs:
                  _dates
                      .map(
                        (date) => Tab(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getWeekday(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${date.month}/${date.day}',
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
              indicatorColor: AppColors.primary,
              indicatorWeight: 5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerHeight: 1,
              dividerColor: AppColors.background,
              labelPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(_dates.length, (index) {
                final dateKey =
                    _dates[index].toIso8601String().split('T').first;
                final todos = _todoMapByDate[dateKey] ?? [];

                if (todos.isEmpty) {
                  return Center(
                    child: Text(
                      '오늘 할 일이 없어요!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, i) {
                    final todo = todos[i];
                    return TodoItemWidget(
                      title: todo.title,
                      subtitle: todo.description,
                      isDone: todo.status,
                      deadline: todo.deadline,
                      userId: todo.userId,
                      taskId: todo.taskNumber,
                      onDelete: () async {
                        final url = Uri.parse(
                          '${dotenv.env['API_URL']}/api/users/${todo.userId}/tasks/${todo.taskNumber}',
                        );

                        try {
                          final response = await http.delete(url);

                          if (response.statusCode == 200) {
                            setState(() {
                              todos.removeAt(i);
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
                      onStatusChanged: (newStatus) {
                        setState(() {
                          todo.status = newStatus;
                        });
                      },
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _animation.value),
            child: child,
          );
        },
        child: SizedBox(
          width: 60,
          height: 60,
          child: FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              final selectedDate = _dates[_tabController.index];

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => TodoAddScreen(selectedDate: selectedDate),
                ),
              );
            },
            shape: const CircleBorder(),
            child: SvgPicture.asset(
              'assets/icons/plus.svg',
              width: 32,
              height: 32,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getWeekday(DateTime date) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }
}
