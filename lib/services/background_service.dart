import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:timeboxing/services/notification_service.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: false,
      autoStart: false,
      // Provide a notification channel and initial notification required for
      // foreground services on newer Android versions. This prevents crashes
      // when the OS expects a foreground notification for the service.
      notificationChannelId: 'timeboxing_service_channel',
      initialNotificationTitle: 'Timeboxing Service',
      initialNotificationContent: 'Timer service is running',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopSelf').listen((event) {
    service.stopSelf();
  });

  service.on('startTimer').listen((event) {
    final duration = event!['duration'] as int;
    final title = event['title'] as String;
    // Cancel any existing timer by keeping a static reference inside the closure scope
    _activeTimer?.cancel();
    int remainingSeconds = duration;

    // Immediately emit the initial value so UI updates instantly
    service.invoke('updateTimer', {'remainingSeconds': remainingSeconds});

    _activeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        remainingSeconds--;
        service.invoke('updateTimer', {'remainingSeconds': remainingSeconds});
      } else {
        timer.cancel();
        _activeTimer = null;
        service.invoke('updateTimer', {'remainingSeconds': 0, 'isFinished': true});
        final notificationService = NotificationService();
        notificationService.showNotification(
          'Time\'s up for $title!',
          'Did you complete it?',
          DateTime.now().millisecondsSinceEpoch.remainder(100000),
        );
        service.stopSelf();
      }
    });
  });
}

// Keep a module-level reference to cancel previous timers when new ones start
Timer? _activeTimer;
