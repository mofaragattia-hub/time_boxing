// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Timeboxing';

  @override
  String get hello => 'Hello!';

  @override
  String get welcome => 'Welcome to Timeboxing';

  @override
  String get deleteSelectedTasks => 'Delete Selected Tasks';

  @override
  String deleteTasksConfirmation(Object count) {
    return 'Are you sure you want to delete $count tasks?';
  }

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get tipsAndInsights => 'Tips & Insights';

  @override
  String get dailyTip => 'Daily Tip';

  @override
  String get productivityInsights => 'Productivity Insights';

  @override
  String get timeManagementTips => 'Time Management Tips';

  @override
  String get learningResources => 'Learning Resources';

  @override
  String get tipOfTheDay => 'Tip of the Day';

  @override
  String get viewAllTips => 'View All Tips';

  @override
  String get noInsightsYet => 'Complete more tasks to see insights!';

  @override
  String get keepGoing => 'Keep going! You\'re doing great.';

  @override
  String get tip1Title => 'The Two-Minute Rule';

  @override
  String get tip1Description =>
      'If a task takes less than two minutes, do it immediately. This prevents small tasks from piling up.';

  @override
  String get tip2Title => 'Time Blocking';

  @override
  String get tip2Description =>
      'Dedicate specific time blocks to different tasks. This helps maintain focus and reduces context switching.';

  @override
  String get tip3Title => 'Eat the Frog';

  @override
  String get tip3Description =>
      'Start your day with the most challenging task. Once it\'s done, everything else feels easier.';

  @override
  String get tip4Title => 'Pomodoro Technique';

  @override
  String get tip4Description =>
      'Work in 25-minute focused sessions followed by 5-minute breaks. This maintains high productivity.';

  @override
  String get tip5Title => 'Batch Similar Tasks';

  @override
  String get tip5Description =>
      'Group similar tasks together and complete them in one session to improve efficiency.';

  @override
  String get tip6Title => 'Set Clear Goals';

  @override
  String get tip6Description =>
      'Define specific, measurable goals for each task. Clarity leads to better execution.';

  @override
  String get tip7Title => 'Eliminate Distractions';

  @override
  String get tip7Description =>
      'Turn off notifications and create a focused work environment during task execution.';

  @override
  String get tip8Title => 'Review and Reflect';

  @override
  String get tip8Description =>
      'Spend 10 minutes at the end of each day reviewing what you accomplished and planning tomorrow.';

  @override
  String get tip9Title => 'The 80/20 Rule';

  @override
  String get tip9Description =>
      'Focus on the 20% of tasks that will generate 80% of your results. Prioritize wisely.';

  @override
  String get tip10Title => 'Take Regular Breaks';

  @override
  String get tip10Description =>
      'Short breaks improve focus and prevent burnout. Your brain needs rest to perform optimally.';

  @override
  String get tip11Title => 'Single-Tasking';

  @override
  String get tip11Description =>
      'Focus on one task at a time. Multitasking reduces quality and increases completion time.';

  @override
  String get tip12Title => 'Plan Tomorrow Today';

  @override
  String get tip12Description =>
      'Spend 5 minutes before bed planning tomorrow\'s tasks. You\'ll wake up with clarity and purpose.';

  @override
  String insight1(Object day) {
    return 'You\'re most productive on $day. Schedule important tasks on this day!';
  }

  @override
  String insight2(Object rate) {
    return 'Your average task completion rate is $rate%. Keep up the good work!';
  }

  @override
  String insight3(Object count) {
    return 'You\'ve completed $count tasks this week. That\'s impressive!';
  }

  @override
  String get insight4 =>
      'Try breaking larger tasks into smaller chunks for better completion rates.';

  @override
  String insight5(Object duration) {
    return 'You work best in $duration-minute sessions. Use this to your advantage!';
  }
}
