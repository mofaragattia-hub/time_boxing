import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timeboxing/utils/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:timeboxing/l10n/app_localizations.dart';
import 'package:timeboxing/screens/dashboard_screen.dart';
import 'package:timeboxing/screens/tasks_screen.dart';
import 'package:timeboxing/screens/reports_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_update/in_app_update.dart';

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
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {});
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();
    _checkForUpdate();
  }

  Future<void> _checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
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
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? 'مرحباً' : 'Welcome',
                      style: const TextStyle(color: Colors.white70),
                    ),
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
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(isArabic ? 'نصائح وإرشادات' : 'Tips & Insights'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, '/tips');
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: Text(isArabic ? 'مشاركة التطبيق' : 'Share App'),
                onTap: () {
                  Navigator.of(context).pop();
                  // ignore: deprecated_member_use
                  Share.share(
                    isArabic
                        ? 'جرب هذا التطبيق الرائع لإدارة الوقت: https://play.google.com/store/apps/details?id=com.mofarag.timeboxing'
                        : 'Check out this amazing time management app: https://play.google.com/store/apps/details?id=com.mofarag.timeboxing',
                  );
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
                child: Text(
                  isArabic ? 'الإصدار 0.1.4' : 'Version 0.1.4',
                  style: const TextStyle(color: Colors.black54),
                ),
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
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          NavigationBar(
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: _currentIndex,
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
          if (_bannerAd != null)
            Container(
              alignment: Alignment.center,
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
    );
  }
}
