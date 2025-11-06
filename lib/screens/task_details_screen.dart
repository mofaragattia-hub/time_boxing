import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    // if task completed, timer stays hidden; if inProgress user can start/stop
    if (widget.task.status == TaskStatus.inProgress) {
      // leave as default; no persisted remaining in current model
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
    // mark as in progress
    Provider.of<TaskProvider>(context, listen: false)
        .updateTaskStatus(widget.task, TaskStatus.inProgress);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
      });
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
        });
        // complete task
        Provider.of<TaskProvider>(context, listen: false)
            .updateTaskStatus(widget.task, TaskStatus.completed);
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    // optionally leave task as inProgress, or set back to pending — we'll leave as pending
    Provider.of<TaskProvider>(context, listen: false)
        .updateTaskStatus(widget.task, TaskStatus.pending);
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isArabic ? 'المؤقت' : 'Timer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _formatDuration(_remainingSeconds),
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
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
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
