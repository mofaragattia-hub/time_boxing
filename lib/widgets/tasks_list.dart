import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/widgets/task_card.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  TaskStatus? _selectedFilter;
  final Set<Task> _selectedTasks = {};
  bool _isSelectionMode = false;

  Future<void> _confirmAndDeleteSelected(BuildContext context, TaskProvider provider, bool isArabic) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isArabic ? 'حذف المهام المحددة' : 'Delete Selected Tasks'),
        content: Text(
          isArabic 
            ? 'هل أنت متأكد من حذف ${_selectedTasks.length} مهام؟'
            : 'Are you sure you want to delete ${_selectedTasks.length} tasks?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isArabic ? 'حذف' : 'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.deleteTasks(_selectedTasks.toList());
      setState(() {
        _selectedTasks.clear();
        _isSelectionMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Consumer<TaskProvider>(builder: (context, taskProvider, child) {
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
          : taskProvider.tasks.where((t) => t.status == _selectedFilter).toList();

      // Sort by createdAt descending
      visibleTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final List<Widget> children = [];

      // Filter controls
      children.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildFilterChip(label: isArabic ? 'الكل' : 'All', status: null),
              _buildFilterChip(label: isArabic ? 'قيد الانتظار' : 'Pending', status: TaskStatus.pending),
              _buildFilterChip(label: isArabic ? 'قيد التنفيذ' : 'In Progress', status: TaskStatus.inProgress),
              _buildFilterChip(label: isArabic ? 'مكتملة' : 'Completed', status: TaskStatus.completed),
              _buildFilterChip(label: isArabic ? 'مؤجلة' : 'Postponed', status: TaskStatus.postponed),
            ],
          ),
        ),
      );

      // Group by day
      DateTime? currentGroupDate;
      for (final task in visibleTasks) {
        final date = DateTime(task.createdAt.year, task.createdAt.month, task.createdAt.day);
        if (currentGroupDate == null || !_isSameDay(currentGroupDate, date)) {
          currentGroupDate = date;
          children.add(
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Text(
                _formatDayLabel(date, isArabic),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        children.add(TaskCard(
          task: task,
          isSelected: _selectedTasks.contains(task),
          isSelectionMode: _isSelectionMode,
          onSelectionChanged: (task) {
            setState(() {
              if (_selectedTasks.contains(task)) {
                _selectedTasks.remove(task);
                if (_selectedTasks.isEmpty) {
                  _isSelectionMode = false;
                }
              } else {
                _selectedTasks.add(task);
                _isSelectionMode = true;
              }
            });
          },
        ));
      }

      return Scaffold(
        appBar: _selectedTasks.isNotEmpty ? AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              _selectedTasks.clear();
              _isSelectionMode = false;
            }),
          ),
          title: Text('${_selectedTasks.length} ${isArabic ? 'محدد' : 'selected'}'),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmAndDeleteSelected(context, taskProvider, isArabic),
            ),
          ],
        ) : null,
        body: ListView(children: children),
      );
    });
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

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _formatDayLabel(DateTime date, bool isArabic) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (_isSameDay(date, today)) return isArabic ? 'اليوم' : 'Today';
    if (_isSameDay(date, yesterday)) return isArabic ? 'أمس' : 'Yesterday';
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
