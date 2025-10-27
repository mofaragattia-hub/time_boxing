import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/utils/ad_helper.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/services/notification_service.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  AddTaskScreenState createState() => AddTaskScreenState();
}

class AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    _startTime = now;
    _endTime = TimeOfDay(
      hour: (now.hour + 0) % 24,
      minute: (now.minute + 30) % 60,
    );
    _loadInterstitialAd();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (err) {
          _interstitialAd = null;
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Title',
                            prefixIcon: Icon(Icons.title),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _title = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            prefixIcon: Icon(Icons.description),
                            filled: true,
                          ),
                          maxLines: 3,
                          onSaved: (value) {
                            _description = value ?? '';
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: _selectedDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2101),
                                  );
                                  if (picked != null &&
                                      picked != _selectedDate) {
                                    if (!mounted) return;
                                    setState(() {
                                      _selectedDate = picked;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(
                                  '${_selectedDate.toLocal()}'.split(' ')[0],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: _startTime ?? TimeOfDay.now(),
                                  );
                                  if (picked != null) {
                                    if (!mounted) return;
                                    setState(() => _startTime = picked);
                                  }
                                },
                                icon: const Icon(Icons.play_circle_fill),
                                label: Text(
                                  _startTime == null
                                      ? 'Pick start time'
                                      : 'Start: ${_startTime!.format(context)}',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime:
                                        _endTime ??
                                        (_startTime ?? TimeOfDay.now()),
                                  );
                                  if (picked != null) {
                                    if (!mounted) return;
                                    setState(() => _endTime = picked);
                                  }
                                },
                                icon: const Icon(Icons.stop_circle),
                                label: Text(
                                  _endTime == null
                                      ? 'Pick end time'
                                      : 'End: ${_endTime!.format(context)}',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final info = _startTime == null || _endTime == null
                                ? 'No time selected'
                                : _formatDurationLabel(context);
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                info,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              if (!_validateTimes(context)) return;
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                final startDateTime = _mergeDateAndTime(
                                  _selectedDate,
                                  _startTime!,
                                );
                                final endDateTime = _mergeDateAndTime(
                                  _selectedDate,
                                  _endTime!,
                                );
                                final durationMinutes = endDateTime
                                    .difference(startDateTime)
                                    .inMinutes;

                                final task = Task(
                                  title: _title,
                                  description: _description,
                                  durationMinutes: durationMinutes,
                                  createdAt: startDateTime,
                                );
                                await Provider.of<TaskProvider>(
                                  context,
                                  listen: false,
                                ).addTask(task);

                                if (_interstitialAd != null) {
                                  _interstitialAd!.show();
                                }

                                // Only schedule notification if start time is in the future
                                if (startDateTime.isAfter(DateTime.now())) {
                                  await NotificationService()
                                      .scheduleNotification(
                                        scheduledDateTime: startDateTime,
                                        title: 'Task reminder',
                                        body: _title,
                                        notificationId: startDateTime
                                            .millisecondsSinceEpoch
                                            .remainder(100000),
                                      );
                                } else {
                                  // Show warning for past times
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Start time is in the past - no notification scheduled'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }

                                if (!mounted) return;

                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.add_task),
                            label: const Text('Add Task'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _validateTimes(BuildContext context) {
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end times')),
      );
      return false;
    }
    final start = _mergeDateAndTime(_selectedDate, _startTime!);
    final end = _mergeDateAndTime(_selectedDate, _endTime!);
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return false;
    }
    return true;
  }

  DateTime _mergeDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  String _formatDurationLabel(BuildContext context) {
    if (_startTime == null || _endTime == null) return '';
    final start = _mergeDateAndTime(_selectedDate, _startTime!);
    final end = _mergeDateAndTime(_selectedDate, _endTime!);
    final minutes = end.difference(start).inMinutes;
    return 'From ${_startTime!.format(context)} to ${_endTime!.format(context)} • $minutes min';
  }
}
