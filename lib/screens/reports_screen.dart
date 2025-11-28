import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/models/task_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(title: Text(isArabic ? 'التقارير' : 'Reports')),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;
          final completedTasks = tasks
              .where((t) => t.status == TaskStatus.completed)
              .toList();
          final pendingTasks = tasks
              .where((t) => t.status == TaskStatus.pending)
              .toList();
          final inProgressTasks = tasks
              .where((t) => t.status == TaskStatus.inProgress)
              .toList();

          // Calculate statistics
          final totalPlannedMinutes = tasks.fold<int>(
            0,
            (sum, t) => sum + t.durationMinutes,
          );
          final totalCompletedMinutes = completedTasks.fold<int>(
            0,
            (sum, t) => sum + t.durationMinutes,
          );
          final completionRate = tasks.isEmpty
              ? 0.0
              : (completedTasks.length / tasks.length * 100);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                _buildSummaryCards(
                  context,
                  isArabic,
                  tasks.length,
                  completedTasks.length,
                  pendingTasks.length,
                  inProgressTasks.length,
                  completionRate,
                ),
                const SizedBox(height: 24),

                // Task Status Distribution
                _buildSectionTitle(
                  isArabic ? 'توزيع حالة المهام' : 'Task Status Distribution',
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildStatusPieChart(
                  context,
                  completedTasks.length,
                  pendingTasks.length,
                  inProgressTasks.length,
                  isArabic,
                ),
                const SizedBox(height: 24),

                // Productivity Over Time (Last 7 Days)
                _buildSectionTitle(
                  isArabic
                      ? 'الإنتاجية (آخر 7 أيام)'
                      : 'Productivity (Last 7 Days)',
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildProductivityChart(completedTasks, isArabic),
                const SizedBox(height: 24),

                // Time Statistics
                _buildSectionTitle(
                  isArabic ? 'إحصائيات الوقت' : 'Time Statistics',
                  isArabic,
                ),
                const SizedBox(height: 12),
                _buildTimeStatistics(
                  context,
                  isArabic,
                  totalPlannedMinutes,
                  totalCompletedMinutes,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(
    BuildContext context,
    bool isArabic,
    int totalTasks,
    int completedTasks,
    int pendingTasks,
    int inProgressTasks,
    double completionRate,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                isArabic ? 'إجمالي المهام' : 'Total Tasks',
                totalTasks.toString(),
                Icons.task_alt,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                isArabic ? 'مكتملة' : 'Completed',
                completedTasks.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                isArabic ? 'قيد التنفيذ' : 'In Progress',
                inProgressTasks.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                isArabic ? 'معلقة' : 'Pending',
                pendingTasks.toString(),
                Icons.schedule,
                Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          context,
          isArabic ? 'معدل الإنجاز' : 'Completion Rate',
          '${completionRate.toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.purple,
          fullWidth: true,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isArabic) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildStatusPieChart(
    BuildContext context,
    int completed,
    int pending,
    int inProgress,
    bool isArabic,
  ) {
    final total = completed + pending + inProgress;
    if (total == 0) {
      return Card(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            isArabic ? 'لا توجد مهام' : 'No tasks yet',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    sections: [
                      if (completed > 0)
                        PieChartSectionData(
                          value: completed.toDouble(),
                          title: '$completed',
                          color: Colors.green,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (inProgress > 0)
                        PieChartSectionData(
                          value: inProgress.toDouble(),
                          title: '$inProgress',
                          color: Colors.orange,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      if (pending > 0)
                        PieChartSectionData(
                          value: pending.toDouble(),
                          title: '$pending',
                          color: Colors.grey,
                          radius: 60,
                          titleStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                    ],
                    sectionsSpace: 2,
                    centerSpaceRadius: 40,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (completed > 0)
                      _buildLegendItem(
                        isArabic ? 'مكتملة' : 'Completed',
                        Colors.green,
                      ),
                    if (inProgress > 0)
                      _buildLegendItem(
                        isArabic ? 'قيد التنفيذ' : 'In Progress',
                        Colors.orange,
                      ),
                    if (pending > 0)
                      _buildLegendItem(
                        isArabic ? 'معلقة' : 'Pending',
                        Colors.grey,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildProductivityChart(List<Task> completedTasks, bool isArabic) {
    final now = DateTime.now();
    final last7Days = List.generate(7, (i) {
      final day = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      final tasksOnDay = completedTasks.where((t) {
        final executed = t.executedAt;
        if (executed == null) return false;
        return executed.year == day.year &&
            executed.month == day.month &&
            executed.day == day.day;
      }).length;
      return {'day': day, 'count': tasksOnDay};
    });

    final maxCount = last7Days.fold<int>(0, (max, day) {
      final count = day['count'] as int;
      return count > max ? count : max;
    });

    if (maxCount == 0) {
      return Card(
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Text(
            isArabic
                ? 'لا توجد مهام مكتملة في آخر 7 أيام'
                : 'No completed tasks in the last 7 days',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= last7Days.length)
                        return const SizedBox();
                      final day = last7Days[idx]['day'] as DateTime;
                      final weekday = [
                        'Sun',
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                      ][day.weekday % 7];
                      final weekdayAr = [
                        'الأحد',
                        'الإثنين',
                        'الثلاثاء',
                        'الأربعاء',
                        'الخميس',
                        'الجمعة',
                        'السبت',
                      ][day.weekday % 7];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          isArabic ? weekdayAr : weekday,
                          style: const TextStyle(fontSize: 10),
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: last7Days.asMap().entries.map((entry) {
                    return FlSpot(
                      entry.key.toDouble(),
                      (entry.value['count'] as int).toDouble(),
                    );
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: Colors.blue,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.blue.withOpacity(0.1),
                  ),
                ),
              ],
              minY: 0,
              maxY: (maxCount + 1).toDouble(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeStatistics(
    BuildContext context,
    bool isArabic,
    int totalPlannedMinutes,
    int totalCompletedMinutes,
  ) {
    final plannedHours = (totalPlannedMinutes / 60).toStringAsFixed(1);
    final completedHours = (totalCompletedMinutes / 60).toStringAsFixed(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTimeRow(
              isArabic ? 'إجمالي الوقت المخطط' : 'Total Planned Time',
              '$plannedHours ${isArabic ? 'ساعة' : 'hours'}',
              Icons.schedule,
              Colors.blue,
            ),
            const Divider(height: 24),
            _buildTimeRow(
              isArabic ? 'إجمالي الوقت المكتمل' : 'Total Completed Time',
              '$completedHours ${isArabic ? 'ساعة' : 'hours'}',
              Icons.check_circle,
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
