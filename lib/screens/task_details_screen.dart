import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:timeboxing/providers/category_provider.dart';
import 'package:timeboxing/utils/icon_registry.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // initialize remaining seconds to full duration by default
    _remainingSeconds = widget.task.durationMinutes * 60;

    // If task has persisted timer data, resume from that
    final t = widget.task;
    if (t.isTimerRunning && t.remainingSeconds != null) {
      final start = t.timerStart ?? DateTime.now();
      final elapsed = DateTime.now().difference(start).inSeconds;
      final updated = (t.remainingSeconds! - elapsed);
      if (updated <= 0) {
        // timer finished while away
        _remainingSeconds = 0;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<TaskProvider>(
            context,
            listen: false,
          ).updateTaskStatus(t, TaskStatus.completed);
        });
      } else {
        _remainingSeconds = updated;
        _isRunning = true;
        _startLocalTimer();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.task.status == TaskStatus.completed) return;
    setState(() {
      _isRunning = true;
    });
    final provider = Provider.of<TaskProvider>(context, listen: false);
    // mark as in progress
    provider.updateTaskStatus(widget.task, TaskStatus.inProgress);

    // persist timer fields on task
    widget.task.isTimerRunning = true;
    widget.task.timerStart = DateTime.now();
    widget.task.remainingSeconds = _remainingSeconds;
    provider.saveTask(widget.task);

    _startLocalTimer();
  }

  void _startLocalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
      // persist remaining occasionally
      widget.task.remainingSeconds = _remainingSeconds;
      Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        Provider.of<TaskProvider>(
          context,
          listen: false,
        ).updateTaskStatus(widget.task, TaskStatus.completed);
        widget.task.isTimerRunning = false;
        widget.task.remainingSeconds = 0;
        widget.task.timerStart = null;
        Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });

    // persist task timer fields and set status back to pending
    widget.task.isTimerRunning = false;
    widget.task.remainingSeconds = _remainingSeconds;
    widget.task.timerStart = null;
    Provider.of<TaskProvider>(context, listen: false).saveTask(widget.task);

    Provider.of<TaskProvider>(
      context,
      listen: false,
    ).updateTaskStatus(widget.task, TaskStatus.pending);
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final task = widget.task;
    final category = Provider.of<CategoryProvider>(
      context,
    ).categories.firstWhereOrNull((c) => c.id == task.categoryId);
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تفاصيل المهمة' : 'Task Details'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Header card with title, category and actions
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              elevation: 1.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Use Wrap so the category pill and status chip wrap to the
                          // next line when the available horizontal space is small.
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),

                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      kMaterialIconMap.containsKey(
                                            category.iconCodePoint,
                                          )
                                          ? Icon(
                                              kMaterialIconMap[category
                                                  .iconCodePoint],
                                              color: category.categoryColor,
                                              size: 14,
                                            )
                                          : Text(
                                              String.fromCharCode(
                                                category.iconCodePoint,
                                              ),
                                              style: TextStyle(
                                                fontFamily: 'MaterialIcons',
                                                color: category.categoryColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                      const SizedBox(width: 6),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          color: category.categoryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Chip(
                                label: Text(
                                  _statusLabel(task.status, isArabic),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: _statusColorFor(task.status),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatDateTime(task.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () =>
                              _showActionsSheet(context, task, isArabic),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _buildDetailItem(
              context,
              icon: Icons.title,
              label: isArabic ? 'العنوان' : 'Title',
              value: task.title,
            ),
            _buildDetailItem(
              context,
              icon: Icons.description,
              label: isArabic ? 'الوصف' : 'Description',
              value: task.description,
            ),
            _buildDetailItem(
              context,
              icon: Icons.timer,
              label: isArabic ? 'المدة' : 'Duration',
              value: isArabic
                  ? '${task.durationMinutes} دقيقة'
                  : '${task.durationMinutes} minutes',
            ),
            _buildDetailItem(
              context,
              icon: Icons.info_outline,
              label: isArabic ? 'الحالة' : 'Status',
              value: _statusLabel(task.status, isArabic),
            ),
            _buildDetailItem(
              context,
              icon: Icons.calendar_today,
              label: isArabic ? 'تاريخ الإنشاء' : 'Created At',
              value: _formatDateTime(task.createdAt),
            ),
            if (task.executedAt != null)
              _buildDetailItem(
                context,
                icon: Icons.event_available,
                label: isArabic ? 'تاريخ التنفيذ' : 'Executed At',
                value: _formatDateTime(task.executedAt!),
              ),

            // Timer area: visible only when task not completed
            if (task.status != TaskStatus.completed) ...[
              const SizedBox(height: 12),
              Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 1.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isArabic ? 'المؤقت' : 'Timer',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatDuration(_remainingSeconds),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isRunning ? null : _startTimer,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(isArabic ? 'بدء' : 'Start'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _isRunning ? _stopTimer : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            icon: const Icon(Icons.stop),
                            label: Text(isArabic ? 'إيقاف' : 'Stop'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColorFor(TaskStatus status) {
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

  void _showActionsSheet(BuildContext context, Task task, bool isArabic) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(isArabic ? 'تعيين كمكتملة' : 'Mark Completed'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).updateTaskStatus(task, TaskStatus.completed);
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_arrow),
                title: Text(
                  isArabic ? 'تعيين قيد التنفيذ' : 'Mark In Progress',
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).updateTaskStatus(task, TaskStatus.inProgress);
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: Text(isArabic ? 'تأجيل' : 'Postpone'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  await Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  ).updateTaskStatus(task, TaskStatus.postponed);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  isArabic ? 'حذف' : 'Delete',
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (dctx) => AlertDialog(
                      title: Text(isArabic ? 'حذف المهمة' : 'Delete task'),
                      content: Text(
                        isArabic
                            ? 'هل أنت متأكد أنك تريد حذف هذه المهمة؟'
                            : 'Are you sure you want to delete this task?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dctx).pop(false),
                          child: Text(isArabic ? 'إلغاء' : 'Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dctx).pop(true),
                          child: Text(isArabic ? 'حذف' : 'Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    if (!mounted) return;
                    final provider = Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    );
                    final deletedTask = Task(
                      title: task.title,
                      description: task.description,
                      durationMinutes: task.durationMinutes,
                      status: task.status,
                      createdAt: task.createdAt,
                      executedAt: task.executedAt,
                    );
                    await provider.deleteTask(task);
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isArabic ? 'تم حذف المهمة' : 'Task deleted',
                        ),
                        action: SnackBarAction(
                          label: isArabic ? 'تراجع' : 'UNDO',
                          onPressed: () async {
                            await provider.addTask(deletedTask);
                          },
                        ),
                      ),
                    );
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${_formatTime(TimeOfDay.fromDateTime(dateTime))}';
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $suffix';
  }
}
