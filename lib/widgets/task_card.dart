import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/category_provider.dart';
import 'package:timeboxing/screens/task_details_screen.dart';
import 'package:timeboxing/utils/icon_registry.dart';

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
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final category = categoryProvider.categories.firstWhereOrNull((c) => c.id == task.categoryId);
    final isArabic = false;

    final progress = task.status == TaskStatus.completed ? 1.0 : 0.0;
    final actual = task.durationMinutes.toDouble();

    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onSelectionChanged?.call(task);
          return;
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task)));
      },
      onLongPress: () {
        onSelectionChanged?.call(task);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            // colored strip
            Container(
              width: 6,
              height: 96,
              decoration: BoxDecoration(
                color: _getStatusColor(task.status),
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
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.title,
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                ),
                                                if (category != null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          // Prefer const IconData from registry so the glyph is
                                                          // preserved during tree-shaking; fall back to a
                                                          // Text glyph if the codepoint isn't registered.
                                                          kMaterialIconMap.containsKey(category.icon)
                                                              ? Icon(kMaterialIconMap[category.icon], color: category.categoryColor, size: 14)
                                                              : Text(
                                                                  String.fromCharCode(category.icon),
                                                                  style: TextStyle(
                                                                    fontFamily: 'MaterialIcons',
                                                                    color: category.categoryColor,
                                                                    fontSize: 14,
                                                                  ),
                                                                ),
                                                          const SizedBox(width: 6),
                                                          Text(category.name, style: TextStyle(color: category.categoryColor, fontSize: 12)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),                    const SizedBox(height: 6),
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
                              valueColor: AlwaysStoppedAnimation<Color>(progress >= 1.0 ? Colors.green : Colors.blue),
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
            // trailing actions (time and status only) — detailed actions moved to Task Details
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
                ],
              ),
            ),
          ],
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
