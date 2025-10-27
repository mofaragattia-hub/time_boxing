import 'package:flutter/material.dart';
import 'package:timeboxing/l10n/app_localizations.dart';
import 'package:timeboxing/screens/dashboard_screen.dart';
import 'package:timeboxing/screens/tasks_screen.dart';
import 'package:timeboxing/screens/timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TasksScreen(),
    const TimerScreen(),
  ];
  //todo: add floating action button to add task from here also

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            tooltip: isArabic ? 'English' : 'العربية',
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: isArabic ? 'الرئيسية' : 'Dashboard',
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list),
            label: isArabic ? 'المهام' : 'Tasks',
          ),
          NavigationDestination(
            icon: const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: isArabic ? 'المؤقت' : 'Timer',
          ),
        ],
      ),
    );
  }
}
