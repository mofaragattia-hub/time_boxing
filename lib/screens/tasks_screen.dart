import 'package:flutter/material.dart';
// models imported in widgets where needed
import 'package:timeboxing/screens/add_task_screen.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timeboxing/utils/ad_helper.dart';
import 'package:timeboxing/widgets/tasks_list.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  // Banner ad is handled here; list and cards moved to widgets
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'المهام' : 'Tasks'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: isArabic ? 'إضافة مهمة' : 'Add Task',
            onPressed: () async {
              // Await navigation, then ensure context still mounted
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const AddTaskScreen()),
              );
              if (!mounted) return;
            },
          ),
        ],
      ),
      body: const TasksList(),
    );
  }
 
}
