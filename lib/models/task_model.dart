import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 1)
class Task extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  int durationMinutes;

  @HiveField(3)
  TaskStatus status;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime? executedAt;

  Task({
    required this.title,
    required this.description,
    required this.durationMinutes,
    this.status = TaskStatus.pending,
    required this.createdAt,
    this.executedAt,
  });
}

@HiveType(typeId: 2)
enum TaskStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  completed,

  @HiveField(3)
  postponed,
}
