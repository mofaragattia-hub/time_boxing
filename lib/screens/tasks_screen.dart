import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/screens/add_task_screen.dart';
import 'package:timeboxing/screens/task_details_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  TaskStatus? _selectedFilter; // null => All

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'المهام' : 'Tasks'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: isArabic ? 'إضافة مهمة' : 'Add Task',
            onPressed: () async {
              // Await navigation, then ensure context still mounted
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AddTaskScreen()),
              );
              if (!mounted) return;
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    isArabic ? 'لا توجد مهام بعد' : 'No tasks yet',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isArabic ? 'اضغط زر + لإضافة أول مهمة' : 'Tap the + button to add your first task',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            );
          }

          // Apply filter
          List<Task> visibleTasks = _selectedFilter == null
              ? List<Task>.from(taskProvider.tasks)
              : taskProvider.tasks
                    .where((t) => t.status == _selectedFilter)
                    .toList();

          // Sort by createdAt descending
          visibleTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          final List<Widget> children = [];

          // Filter controls
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _buildFilterChip(label: isArabic ? 'الكل' : 'All', status: null),
                  _buildFilterChip(
                    label: isArabic ? 'قيد الانتظار' : 'Pending',
                    status: TaskStatus.pending,
                  ),
                  _buildFilterChip(
                    label: isArabic ? 'قيد التنفيذ' : 'In Progress',
                    status: TaskStatus.inProgress,
                  ),
                  _buildFilterChip(
                    label: isArabic ? 'مكتملة' : 'Completed',
                    status: TaskStatus.completed,
                  ),
                  _buildFilterChip(
                    label: isArabic ? 'مؤجلة' : 'Postponed',
                    status: TaskStatus.postponed,
                  ),
                ],
              ),
            ),
          );

          // Group by day
          DateTime? currentGroupDate;
          for (final task in visibleTasks) {
            final date = DateTime(
              task.createdAt.year,
              task.createdAt.month,
              task.createdAt.day,
            );
            if (currentGroupDate == null ||
                !_isSameDay(currentGroupDate, date)) {
              currentGroupDate = date;
              children.add(
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 8.0,
                  ),
                  child: Text(
                    _formatDayLabel(date, isArabic),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
            children.add(_buildTaskCard(context, task));
          }

          return ListView(children: children);
        },
      ),
    );
  }

  Widget _buildFilterChip({required String label, TaskStatus? status}) {
    final bool selected = _selectedFilter == status;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = status;
        });
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDayLabel(DateTime date, bool isArabic) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(date, today)) return isArabic ? 'اليوم' : 'Today';
    if (_isSameDay(date, yesterday)) return isArabic ? 'أمس' : 'Yesterday';
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(task: task),
            ),
          );
        },
        child: ListTile(
          isThreeLine: true,
          title: Text(
            task.title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            task.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _formatTimeRange(task.createdAt, task.durationMinutes),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Chip(
                      label: Text(
                        _statusLabel(task.status, isArabic),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(task.status),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  final provider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );
                  switch (value) {
                    case 'complete':
                      await provider.updateTaskStatus(task, TaskStatus.completed);
                      break;
                    case 'inprogress':
                      await provider.updateTaskStatus(
                        task,
                        TaskStatus.inProgress,
                      );
                      break;
                    case 'postpone':
                      await provider.updateTaskStatus(task, TaskStatus.postponed);
                      break;
                    case 'delete':
                      // Capture scaffold messenger and provider so we don't use context after async gaps
                      final scaffold = ScaffoldMessenger.of(context);
                      final providerLocal = provider;

                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete task'),
                          content: const Text(
                            'Are you sure you want to delete this task?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        // keep a copy for undo
                        final deletedTask = Task(
                          title: task.title,
                          description: task.description,
                          durationMinutes: task.durationMinutes,
                          status: task.status,
                          createdAt: task.createdAt,
                          executedAt: task.executedAt,
                        );
                        await providerLocal.deleteTask(task);
                        scaffold.hideCurrentSnackBar();
                        scaffold.showSnackBar(
                          SnackBar(
                            content: const Text('Task deleted'),
                            action: SnackBarAction(
                              label: 'UNDO',
                              onPressed: () async {
                                await providerLocal.addTask(deletedTask);
                              },
                            ),
                          ),
                        );
                      }
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'complete',
                    child: Text(isArabic ? 'تعيين كمكتملة' : 'Mark Completed'),
                  ),
                  PopupMenuItem(
                    value: 'inprogress',
                    child: Text(isArabic ? 'تعيين قيد التنفيذ' : 'Mark In Progress'),
                  ),
                  PopupMenuItem(value: 'postpone', child: Text(isArabic ? 'تأجيل' : 'Postpone')),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text(isArabic ? 'حذف' : 'Delete', style: const TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Colors.grey;
      case TaskStatus.inProgress:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.postponed:
        return Colors.orange;
    }
  }

  String _formatTimeRange(DateTime start, int durationMinutes) {
    final end = start.add(Duration(minutes: durationMinutes));
    String fmt(TimeOfDay t) {
      final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
      final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
      return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $suffix';
    }

    final startTod = TimeOfDay.fromDateTime(start);
    final endTod = TimeOfDay.fromDateTime(end);
    return '${fmt(startTod)} - ${fmt(endTod)}';
  }

  String _statusLabel(TaskStatus status, bool isArabic) {
    switch (status) {
      case TaskStatus.pending:
        return isArabic ? 'قيد الانتظار' : 'Pending';
      case TaskStatus.inProgress:
        return isArabic ? 'قيد التنفيذ' : 'In Progress';
      case TaskStatus.completed:
        return isArabic ? 'مكتملة' : 'Completed';
      case TaskStatus.postponed:
        return isArabic ? 'مؤجلة' : 'Postponed';
    }
  }
}
