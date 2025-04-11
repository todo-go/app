class TodoModel {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final bool isCompleted;

  TodoModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.isCompleted,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      date: json['date'],
      isCompleted: json['isCompleted'],
    );
  }
}
