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
      appBar: AppBar(
        title: Text(isArabic ? 'التقارير' : 'Reports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Consumer<TaskProvider>(
          builder: (context, provider, child) {
            final tasks = provider.tasks;

            // Prepare data for charts
            final completedTasks = tasks.where((t) => t.status == TaskStatus.completed).toList();

            // Bar chart data: planned vs actual minutes per task (show up to 8 tasks)
            final List<Task> recent = tasks.toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
            final displayTasks = recent.take(8).toList();

            // Productivity per day (last 7 days): sum of actual minutes of completed tasks per day
            final now = DateTime.now();
            final last7 = List.generate(7, (i) {
              final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
              final total = completedTasks
                  .where((t) {
                    final executed = t.executedAt;
                    if (executed == null) return false;
                    return executed.year == day.year && executed.month == day.month && executed.day == day.day;
                  })
                  .fold<int>(0, (prev, t) {
                    final executed = t.executedAt!;
                    final actualMinutes = executed.difference(t.createdAt).inMinutes;
                    return prev + (actualMinutes > 0 ? actualMinutes : t.durationMinutes);
                  });
              return {'day': day, 'minutes': total};
            }).reversed.toList(); // chronological

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? 'الوقت المستغرق في كل مهمة' : 'Time spent per task',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 240,
                    child: _buildTasksBarChart(displayTasks),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    isArabic ? 'الإنتاجية خلال آخر 7 أيام' : 'Productivity (last 7 days)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: _buildProductivityLineChart(last7),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    isArabic ? 'الوقت المتوقع مقابل الوقت الفعلي (المهام المكتملة)' : 'Planned vs Actual (completed tasks)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: _buildPlannedVsActual(displayTasks.where((t) => t.status == TaskStatus.completed).toList()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTasksBarChart(List<Task> tasks) {
    if (tasks.isEmpty) return const Center(child: Text('No tasks'));
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < tasks.length; i++) {
      final t = tasks[i];
      final planned = t.durationMinutes.toDouble();
      final actual = (t.executedAt != null) ? t.executedAt!.difference(t.createdAt).inMinutes.toDouble() : 0.0;
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: planned, color: Colors.blue, width: 8),
            BarChartRodData(toY: actual, color: Colors.green, width: 8),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: bars,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
              final idx = value.toInt();
              if (idx < 0 || idx >= tasks.length) return const SizedBox();
              final label = tasks[idx].title;
              return SideTitleWidget(axisSide: meta.axisSide, child: Text(label, style: const TextStyle(fontSize: 10)));
            }),
          ),
        ),
        gridData: FlGridData(show: false),
      ),
    );
  }

  Widget _buildProductivityLineChart(List<Map> last7) {
    if (last7.isEmpty) return const Center(child: Text('No data'));

    final spots = <FlSpot>[];
    for (var i = 0; i < last7.length; i++) {
      final minutes = (last7[i]['minutes'] as int).toDouble();
      spots.add(FlSpot(i.toDouble(), minutes));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
            final idx = v.toInt();
            if (idx < 0 || idx >= last7.length) return const SizedBox();
            final day = last7[idx]['day'] as DateTime;
            final label = '${day.month}/${day.day}';
            return SideTitleWidget(axisSide: meta.axisSide, child: Text(label, style: const TextStyle(fontSize: 10)));
          })),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        lineBarsData: [
          LineChartBarData(spots: spots, isCurved: true, color: Colors.blue, barWidth: 3, dotData: FlDotData(show: true)),
        ],
      ),
    );
  }

  Widget _buildPlannedVsActual(List<Task> completedTasks) {
    if (completedTasks.isEmpty) return const Center(child: Text('No completed tasks'));

    final bars = <BarChartGroupData>[];
    for (var i = 0; i < completedTasks.length; i++) {
      final t = completedTasks[i];
      final planned = t.durationMinutes.toDouble();
      final actual = t.executedAt != null ? t.executedAt!.difference(t.createdAt).inMinutes.toDouble() : planned;
      bars.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(toY: planned, color: Colors.orange, width: 8),
          BarChartRodData(toY: actual, color: Colors.green, width: 8),
        ],
      ));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: bars,
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= completedTasks.length) return const SizedBox();
            final label = completedTasks[idx].title;
            return SideTitleWidget(axisSide: meta.axisSide, child: Text(label, style: const TextStyle(fontSize: 10)));
          })),
        ),
        gridData: FlGridData(show: false),
      ),
    );
  }
}
