import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/screens/add_task_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'لوحة التحكم' : 'Dashboard'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStatCard(
                    context,
                    isArabic ? 'مكتملة' : 'Completed',
                    taskProvider.completedTasksCount,
                    Colors.green,
                    Icons.check_circle,
                  ),
                  _buildStatCard(
                    context,
                    isArabic ? 'قيد التنفيذ' : 'In Progress',
                    taskProvider.tasks
                        .where((t) => t.status == TaskStatus.inProgress)
                        .length,
                    Colors.blue,
                    Icons.play_circle,
                  ),
                  _buildStatCard(
                    context,
                    isArabic ? 'مؤجلة' : 'Postponed',
                    taskProvider.postponedTasksCount,
                    Colors.orange,
                    Icons.pause_circle,
                  ),
                  _buildStatCard(
                    context,
                    isArabic ? 'قيد الانتظار' : 'Pending',
                    taskProvider.pendingTasksCount,
                    Colors.grey,
                    Icons.pending,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildWeeklyChart(context, taskProvider, isArabic),
            ],
          ),
        ),
      ),
      
      floatingActionButton: SizedBox(
        height: 48, // حجم الزر
        width: 48,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddTaskScreen()),
            );
          },
          backgroundColor: Colors.green, // اللون الأخضر
          elevation: 4,
          shape: const CircleBorder(), // يضمن الشكل الدائري
          child: const Icon(
            Icons.add,
            size: 24, // حجم الأيقونة جوه الزر
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    int count,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color, color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, TaskProvider taskProvider, bool isArabic) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      return d;
    });

    // Count tasks by day based on createdAt
    final Map<String, int> dayToCount = {};
    for (final d in days) {
      final key = _fmtDateKey(d);
      dayToCount[key] = 0;
    }
    for (final t in taskProvider.tasks) {
      final k = _fmtDateKey(
        DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day),
      );
      if (dayToCount.containsKey(k)) {
        dayToCount[k] = (dayToCount[k] ?? 0) + 1;
      }
    }

    final counts = days.map((d) => dayToCount[_fmtDateKey(d)] ?? 0).toList();
    final maxCount = counts.isEmpty
        ? 0
        : counts.reduce((a, b) => a > b ? a : b);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArabic ? 'هذا الأسبوع' : 'This Week',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 160,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < days.length; i++) ...[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Bar
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 16,
                                height: _barHeight(counts[i], maxCount, 120),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF64B5F6),
                                      Color(0xFF1976D2),
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _weekdayLabel(days[i]),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${counts[i]}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i < days.length - 1) const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _barHeight(int count, int maxCount, double maxHeight) {
    if (maxCount <= 0) return 2; // minimal stub when no data
    final ratio = count / maxCount;
    final h = ratio * maxHeight;
    return h < 2 ? 2 : h;
  }

  String _fmtDateKey(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  String _weekdayLabel(DateTime d) {
    switch (d.weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }
}
