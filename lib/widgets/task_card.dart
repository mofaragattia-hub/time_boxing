import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/providers/category_provider.dart';
import 'package:timeboxing/screens/task_details_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<Task>? onSelectionChanged;

  const TaskCard({
    super.key,
    required this.task,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      elevation: 2.0,
      color: isSelected ? Colors.blue : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (isSelectionMode) {
            onSelectionChanged?.call(task);
          } else {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TaskDetailsScreen(task: task),
            ));
          }
        },
        onLongPress: isSelectionMode ? null : () => onSelectionChanged?.call(task),
        child: Consumer<CategoryProvider>(
          builder: (context, categoryProvider, child) {
            final category = task.categoryId != null
                ? categoryProvider.categories
                    .firstWhereOrNull((c) => c.id == task.categoryId)
                : null;

            // Custom nicer card layout
            final planned = task.durationMinutes.toDouble();
            final actual = (task.executedAt != null)
                ? task.executedAt!.difference(task.createdAt).inMinutes.toDouble()
                : 0.0;
            final progress = (planned > 0) ? (actual / planned).clamp(0.0, 1.0) : 0.0;

            return Container(
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // colored strip
                  Container(
                    width: 6,
                    height: 100,
                    decoration: BoxDecoration(
                      color: category?.categoryColor ?? _getStatusColor(task.status),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // main content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              if (category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: category.categoryColor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(category.categoryIcon, color: category.categoryColor, size: 14),
                                      const SizedBox(width: 6),
                                      Text(category.name, style: TextStyle(color: category.categoryColor, fontSize: 12)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.black87),
                          ),
                          const SizedBox(height: 10),
                          // progress bar
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 8,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        progress >= 1.0 ? Colors.green : Colors.blue),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${actual.toInt()}m',
                                style: const TextStyle(fontSize: 12, color: Colors.black54),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // trailing actions
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTimeRange(task.createdAt, task.durationMinutes),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        Chip(
                          label: Text(
                            _statusLabel(task.status, isArabic),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          backgroundColor: _getStatusColor(task.status),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        PopupMenuButton<String>(
                      onSelected: (value) async {
                        final provider =
                            Provider.of<TaskProvider>(context, listen: false);
                        switch (value) {
                          case 'complete':
                            await provider.updateTaskStatus(
                                task, TaskStatus.completed);
                            break;
                          case 'inprogress':
                            await provider.updateTaskStatus(
                                task, TaskStatus.inProgress);
                            break;
                          case 'postpone':
                            await provider.updateTaskStatus(
                                task, TaskStatus.postponed);
                            break;
                          case 'delete':
                            final scaffold = ScaffoldMessenger.of(context);
                            final providerLocal = provider;

                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Delete task'),
                                content: const Text(
                                    'Are you sure you want to delete this task?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
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
              ],
              ),
            );
          },
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
