import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/l10n/app_localizations.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/models/task_model.dart';

class TipModel {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;
  final Color color;

  TipModel({
    required this.titleKey,
    required this.descriptionKey,
    required this.icon,
    required this.color,
  });
}

class TipsInsightsScreen extends StatelessWidget {
  const TipsInsightsScreen({super.key});

  List<TipModel> _getAllTips() {
    return [
      TipModel(
        titleKey: 'tip1Title',
        descriptionKey: 'tip1Description',
        icon: Icons.timer,
        color: Colors.blue,
      ),
      TipModel(
        titleKey: 'tip2Title',
        descriptionKey: 'tip2Description',
        icon: Icons.calendar_today,
        color: Colors.purple,
      ),
      TipModel(
        titleKey: 'tip3Title',
        descriptionKey: 'tip3Description',
        icon: Icons.flag,
        color: Colors.red,
      ),
      TipModel(
        titleKey: 'tip4Title',
        descriptionKey: 'tip4Description',
        icon: Icons.access_time,
        color: Colors.orange,
      ),
      TipModel(
        titleKey: 'tip5Title',
        descriptionKey: 'tip5Description',
        icon: Icons.layers,
        color: Colors.teal,
      ),
      TipModel(
        titleKey: 'tip6Title',
        descriptionKey: 'tip6Description',
        icon: Icons.track_changes,
        color: Colors.green,
      ),
      TipModel(
        titleKey: 'tip7Title',
        descriptionKey: 'tip7Description',
        icon: Icons.notifications_off,
        color: Colors.indigo,
      ),
      TipModel(
        titleKey: 'tip8Title',
        descriptionKey: 'tip8Description',
        icon: Icons.auto_awesome,
        color: Colors.amber,
      ),
      TipModel(
        titleKey: 'tip9Title',
        descriptionKey: 'tip9Description',
        icon: Icons.trending_up,
        color: Colors.deepPurple,
      ),
      TipModel(
        titleKey: 'tip10Title',
        descriptionKey: 'tip10Description',
        icon: Icons.coffee,
        color: Colors.brown,
      ),
      TipModel(
        titleKey: 'tip11Title',
        descriptionKey: 'tip11Description',
        icon: Icons.center_focus_strong,
        color: Colors.cyan,
      ),
      TipModel(
        titleKey: 'tip12Title',
        descriptionKey: 'tip12Description',
        icon: Icons.nightlight,
        color: Colors.deepOrange,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final allTips = _getAllTips();

    // Get daily tip based on day of year
    final dayOfYear = DateTime.now()
        .difference(DateTime(DateTime.now().year, 1, 1))
        .inDays;
    final dailyTip = allTips[dayOfYear % allTips.length];

    return Scaffold(
      appBar: AppBar(title: Text(t.tipsAndInsights)),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          final tasks = provider.tasks;
          final completedTasks = tasks
              .where((t) => t.status == TaskStatus.completed)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Tip Card
                _buildDailyTipCard(context, t, dailyTip, isArabic),
                const SizedBox(height: 24),

                // Productivity Insights
                _buildSectionTitle(
                  t.productivityInsights,
                  Icons.insights,
                  Colors.purple,
                ),
                const SizedBox(height: 12),
                _buildInsightsSection(
                  context,
                  t,
                  tasks,
                  completedTasks,
                  isArabic,
                ),
                const SizedBox(height: 24),

                // All Tips
                _buildSectionTitle(
                  t.timeManagementTips,
                  Icons.lightbulb,
                  Colors.amber,
                ),
                const SizedBox(height: 12),
                ...allTips.map(
                  (tip) => _buildTipCard(context, t, tip, isArabic),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDailyTipCard(
    BuildContext context,
    AppLocalizations t,
    TipModel tip,
    bool isArabic,
  ) {
    return Card(
      elevation: 4,
      color: tip.color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: tip.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tip.icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.tipOfTheDay,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getLocalizedString(t, tip.titleKey),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: tip.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getLocalizedString(t, tip.descriptionKey),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInsightsSection(
    BuildContext context,
    AppLocalizations t,
    List<Task> tasks,
    List<Task> completedTasks,
    bool isArabic,
  ) {
    if (completedTasks.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Icon(Icons.insights, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                t.noInsightsYet,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                t.keepGoing,
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    // Calculate insights
    final completionRate = (completedTasks.length / tasks.length * 100)
        .toStringAsFixed(0);

    // Find most productive day
    final dayCount = <int, int>{};
    for (var task in completedTasks) {
      if (task.executedAt != null) {
        final day = task.executedAt!.weekday;
        dayCount[day] = (dayCount[day] ?? 0) + 1;
      }
    }

    final mostProductiveDay = dayCount.entries.isEmpty
        ? 1
        : dayCount.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    final weekdays = isArabic
        ? [
            'الإثنين',
            'الثلاثاء',
            'الأربعاء',
            'الخميس',
            'الجمعة',
            'السبت',
            'الأحد',
          ]
        : [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday',
          ];

    final dayName = weekdays[mostProductiveDay - 1];

    // Count tasks this week
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisWeekTasks = completedTasks.where((t) {
      if (t.executedAt == null) return false;
      return t.executedAt!.isAfter(weekStart);
    }).length;

    return Column(
      children: [
        if (dayCount.isNotEmpty)
          _buildInsightCard(
            t.insight1(dayName),
            Icons.calendar_today,
            Colors.blue,
          ),
        const SizedBox(height: 12),
        _buildInsightCard(
          t.insight2(completionRate),
          Icons.trending_up,
          Colors.green,
        ),
        if (thisWeekTasks > 0) ...[
          const SizedBox(height: 12),
          _buildInsightCard(
            t.insight3(thisWeekTasks),
            Icons.star,
            Colors.amber,
          ),
        ],
        const SizedBox(height: 12),
        _buildInsightCard(t.insight4, Icons.tips_and_updates, Colors.orange),
      ],
    );
  }

  Widget _buildInsightCard(String text, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(
    BuildContext context,
    AppLocalizations t,
    TipModel tip,
    bool isArabic,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: tip.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(tip.icon, color: tip.color, size: 24),
        ),
        title: Text(
          _getLocalizedString(t, tip.titleKey),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              _getLocalizedString(t, tip.descriptionKey),
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  String _getLocalizedString(AppLocalizations t, String key) {
    switch (key) {
      case 'tip1Title':
        return t.tip1Title;
      case 'tip1Description':
        return t.tip1Description;
      case 'tip2Title':
        return t.tip2Title;
      case 'tip2Description':
        return t.tip2Description;
      case 'tip3Title':
        return t.tip3Title;
      case 'tip3Description':
        return t.tip3Description;
      case 'tip4Title':
        return t.tip4Title;
      case 'tip4Description':
        return t.tip4Description;
      case 'tip5Title':
        return t.tip5Title;
      case 'tip5Description':
        return t.tip5Description;
      case 'tip6Title':
        return t.tip6Title;
      case 'tip6Description':
        return t.tip6Description;
      case 'tip7Title':
        return t.tip7Title;
      case 'tip7Description':
        return t.tip7Description;
      case 'tip8Title':
        return t.tip8Title;
      case 'tip8Description':
        return t.tip8Description;
      case 'tip9Title':
        return t.tip9Title;
      case 'tip9Description':
        return t.tip9Description;
      case 'tip10Title':
        return t.tip10Title;
      case 'tip10Description':
        return t.tip10Description;
      case 'tip11Title':
        return t.tip11Title;
      case 'tip11Description':
        return t.tip11Description;
      case 'tip12Title':
        return t.tip12Title;
      case 'tip12Description':
        return t.tip12Description;
      default:
        return '';
    }
  }
}
