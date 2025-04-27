class TodoModel {
  final int userId;
  final int taskNumber;
  final String title;
  final String description;
  final String deadline;
  final bool status;

  TodoModel({
    required this.userId,
    required this.taskNumber,
    required this.title,
    required this.description,
    required this.deadline,
    required this.status,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      userId: json['userId'],
      taskNumber: json['taskNumber'],
      title: json['title'],
      description: json['description'],
      deadline: json['deadline'],
      status: json['status'],
    );
  }
}
