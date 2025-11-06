import 'dart:async';
import 'package:flutter/foundation.dart';
import 'dart:io' as io show Platform;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Task? _selectedTask;
  int _remainingSeconds = 0;
  bool _isTimerRunning = false;
  Timer? _localTimer;
  StreamSubscription<dynamic>? _serviceSubscription;

  @override
  void initState() {
    super.initState();
    _attachServiceListener();
  }

  void _attachServiceListener() {
    // Attach once; cancel old if any
    _serviceSubscription?.cancel();
    _serviceSubscription = FlutterBackgroundService().on('updateTimer').listen((
      event,
    ) {
      if (!mounted || event == null) return;
      final nextRemaining = event['remainingSeconds'] as int;
      final isFinished = event['isFinished'] as bool? ?? false;
      setState(() {
        _remainingSeconds = nextRemaining;
        if (_remainingSeconds <= 0) {
          _isTimerRunning = false;
          _remainingSeconds = 0;
        }
      });
      if ((nextRemaining <= 0 || isFinished) && _selectedTask != null) {
        Provider.of<TaskProvider>(
          context,
          listen: false,
        ).updateTaskStatus(_selectedTask!, TaskStatus.completed);
      }
    });
  }

  @override
  void dispose() {
    _localTimer?.cancel();
    _serviceSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startTimer() async {
    if (_selectedTask == null) return;

    setState(() {
      _remainingSeconds = _selectedTask!.durationMinutes * 60;
      _isTimerRunning = true;
    });

    // Use background service on Android/iOS only; otherwise fallback to local timer
    final isMobile = !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);
    if (isMobile) {
      // Ensure service is running, then invoke timer
      final service = FlutterBackgroundService();
      bool running = await service.isRunning();
      if (!running) {
        await service.startService();
        // small delay to give onStart time to attach listeners
        await Future.delayed(const Duration(milliseconds: 300));
      }
      // Re-attach listener in case service restarted
      if (!mounted) return; // guard context and state after awaits
      _attachServiceListener();
      service.invoke('startTimer', {
        'duration': _remainingSeconds,
        'title': _selectedTask!.title,
      });
      // Locally reflect initial value immediately as UX pre-tick
      setState(() {});
    } else {
      _startLocalTimer();
    }

    // Mark task as in progress when starting
    if (!mounted) return; // Guard against using context across async gaps
    if (_selectedTask != null) {
      Provider.of<TaskProvider>(
        context,
        listen: false,
      ).updateTaskStatus(_selectedTask!, TaskStatus.inProgress);
    }
  }

  void _startLocalTimer() {
    _localTimer?.cancel();
    _localTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        }
        if (_remainingSeconds <= 0) {
          _isTimerRunning = false;
          timer.cancel();
        }
      });
      if (_remainingSeconds <= 0 && _selectedTask != null) {
        Provider.of<TaskProvider>(
          context,
          listen: false,
        ).updateTaskStatus(_selectedTask!, TaskStatus.completed);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final tasks = Provider.of<TaskProvider>(
      context,
    ).tasks.where((t) => t.status == TaskStatus.pending).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'المؤقت' : 'Timer'),
        centerTitle: true,
        elevation: 1,
        actions: [
          if (_isTimerRunning)
            IconButton(
              icon: const Icon(Icons.stop_circle),
              tooltip: isArabic ? 'إيقاف' : 'Stop',
              onPressed: _handleStop,
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isTimerRunning)
                    DropdownButtonFormField<Task>(
                      decoration: InputDecoration(
                        labelText: isArabic ? 'اختر مهمة' : 'Select Task',
                        prefixIcon: const Icon(Icons.list),
                        filled: true,
                      ),
                        initialValue: _selectedTask,
                        items: tasks.map((task) {
                          return DropdownMenuItem<Task>(
                            value: task,
                            child: Text(task.title),
                          );
                        }).toList(),
                        onChanged: (task) {
                          setState(() {
                            _selectedTask = task;
                          });
                        },
                      ),
                    const SizedBox(height: 24),
                    Text(
                      _formatDuration(_remainingSeconds),
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: !_isTimerRunning
                            ? (_selectedTask != null ? _startTimer : null)
                            : _handleStop,
                        icon: Icon(
                          _isTimerRunning ? Icons.stop : Icons.play_arrow,
                        ),
                        label: Text(
                          _isTimerRunning
                              ? (isArabic ? 'إيقاف المؤقت' : 'Stop Timer')
                              : (isArabic ? 'بدء المؤقت' : 'Start Timer'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleStop() {
    // Stop background service if on mobile; otherwise cancel local timer
    final isMobile = !kIsWeb && (io.Platform.isAndroid || io.Platform.isIOS);
    if (isMobile) {
      FlutterBackgroundService().invoke('stopSelf');
    }
    _localTimer?.cancel();
    setState(() {
      _isTimerRunning = false;
      _remainingSeconds = 0;
    });
  }

  String _formatDuration(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }
}
