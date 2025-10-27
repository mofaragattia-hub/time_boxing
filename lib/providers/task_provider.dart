import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timeboxing/models/task_model.dart';

class TaskProvider with ChangeNotifier {
  final String _boxName = 'tasksBox';
  Box<Task>? _box;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  TaskProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<Task>(_boxName);
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _box!.values.toList();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _box!.add(task);
    _loadTasks();
  }

  Future<void> updateTaskStatus(Task task, TaskStatus status) async {
    task.status = status;
    task.executedAt = DateTime.now();
    await task.save();
    _loadTasks();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
    _loadTasks();
  }

  int get completedTasksCount =>
      _tasks.where((task) => task.status == TaskStatus.completed).length;
  int get postponedTasksCount =>
      _tasks.where((task) => task.status == TaskStatus.postponed).length;
  int get pendingTasksCount =>
      _tasks.where((task) => task.status == TaskStatus.pending).length;
}
