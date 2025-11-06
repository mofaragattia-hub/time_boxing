import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/models/category_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/providers/category_provider.dart';
import 'package:timeboxing/screens/splash_screen.dart';
import 'package:timeboxing/screens/categories_screen.dart';
import 'package:timeboxing/screens/reports_screen.dart';
import 'package:timeboxing/services/background_service.dart';
import 'package:timeboxing/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(TaskStatusAdapter());
  Hive.registerAdapter(TaskCategoryAdapter());
  await NotificationService().init();
  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'en' ? const Locale('ar') : const Locale('en');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TaskProvider()),
        ChangeNotifierProvider(create: (context) => CategoryProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          primaryColor: const Color(0xFF007AFF),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 4.0,
            shadowColor: Colors.black,
          ),
        ),
        routes: {
          '/categories': (context) => const CategoriesScreen(),
          '/reports': (context) => const ReportsScreen(),
        },
        home: SplashScreen(onToggleLanguage: _toggleLanguage),
      ),
    );
  }
}
