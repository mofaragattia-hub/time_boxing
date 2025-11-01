import 'package:flutter/material.dart';
import 'package:timeboxing/models/task_model.dart';

class TaskDetailsScreen extends StatelessWidget {
  final Task task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
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
