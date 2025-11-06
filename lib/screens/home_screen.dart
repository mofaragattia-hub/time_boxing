import 'package:flutter/material.dart';
import 'package:timeboxing/l10n/app_localizations.dart';
import 'package:timeboxing/screens/dashboard_screen.dart';
import 'package:timeboxing/screens/tasks_screen.dart';
import 'package:timeboxing/screens/reports_screen.dart';

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
    const ReportsScreen(),
  ];
  //todo: add floating action button to add task from here also

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.appTitle, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(isArabic ? 'مرحباً' : 'Welcome', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_outlined),
                title: Text(isArabic ? 'الرئيسية' : 'Dashboard'),
                onTap: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.list_alt_outlined),
                title: Text(isArabic ? 'المهام' : 'Tasks'),
                onTap: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                  Navigator.of(context).pop();
                },
              ),
              // removed standalone Timer screen; reports are accessible via the Reports item
              const Divider(),
              ListTile(
                leading: const Icon(Icons.category),
                title: Text(isArabic ? 'التصنيفات' : 'Categories'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/categories');
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text(isArabic ? 'التقارير' : 'Reports'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/reports');
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: Text(isArabic ? 'اللغة' : 'Language'),
                onTap: () {
                  Navigator.of(context).pop();
                  widget.onToggleLanguage?.call();
                },
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(isArabic ? 'الإصدار 0.1.2' : 'Version 0.1.2', style: const TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(t.appTitle),
        actions: [
          IconButton(
            tooltip: isArabic ? 'التصنيفات' : 'Categories',
            onPressed: () => Navigator.pushNamed(context, '/categories'),
            icon: const Icon(Icons.category),
          ),
          IconButton(
            tooltip: isArabic ? 'التقارير' : 'Reports',
            onPressed: () => Navigator.pushNamed(context, '/reports'),
            icon: const Icon(Icons.bar_chart),
          ),
          IconButton(
            tooltip: isArabic ? 'English' : 'العربية',
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
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
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: isArabic ? 'التقارير' : 'ٌReports',
          ),
        ],
      ),
    );
  }
}
