import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todogo/core/theme/colors.dart';
import 'package:todogo/features/todo/presentation/common/dialog/confirm_delete_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _dates.length, vsync: this);

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 150, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
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
        toolbarHeight: 150,
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 60),
          child: const Column(
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
                '화요일, 4월 8일',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(top: 60, right: 16),
            child: Icon(Icons.calendar_month, color: AppColors.primary),
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
                horizontal: 24,
                vertical: 5,
              ),
            ),
          ),

          // 할 일 리스트
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(
                _dates.length,
                (index) => ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: [
                    buildTodoItem(
                      title: '운동하러가기',
                      subtitle: '헬스장 마감 전에 가기',
                      isDone: true,
                    ),
                    buildTodoItem(
                      title: '아침 산책하기',
                      subtitle: '가볍게 걷고 기분 전환하기',
                      isDone: true,
                    ),
                    buildTodoItem(
                      title: '책 한 챕터 읽기',
                      subtitle: '어제 읽던 부분부터 이어서',
                    ),
                    buildTodoItem(
                      title: '카페 가서 작업하기',
                      subtitle: '집중할 수 있는 음악 플레이리스트 틀기',
                    ),
                    buildTodoItem(
                      title: '친구에게 연락하기',
                      subtitle: '너무 오랜만이라 어색할 수도...',
                    ),
                    buildTodoItem(
                      title: '자기 전 명상 10분',
                      subtitle: '하루를 정리하고 마음을 가라앉히기',
                    ),
                    buildTodoItem(title: '냉장고 정리하기', subtitle: '유통기한 지난 거 버리기'),
                  ],
                ),
              ),
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
            onPressed: () async {
              final result = await showDialog<bool>(
                context: context,
                builder: (context) => const ConfirmDeleteDialog(),
              );

              if (result == true) {
                // Handle the delete action
                print('Item deleted');
              }
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

  Widget buildTodoItem({
    required String title,
    required String subtitle,
    bool isDone = false,
  }) {
    return Container(
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
            onChanged: (_) {},
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
          const SizedBox(width: 8),
          Icon(Icons.delete, color: Colors.black87),
        ],
      ),
    );
  }
}
