import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/utils/ad_helper.dart';
import 'package:timeboxing/models/task_model.dart';
import 'package:timeboxing/providers/task_provider.dart';
import 'package:timeboxing/services/notification_service.dart';
import 'package:timeboxing/providers/category_provider.dart';
import 'package:timeboxing/utils/icon_registry.dart';

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
  String? _selectedCategoryId;

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
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(isAr ? 'إضافة مهمة' : 'Add Task'),
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
                          decoration: InputDecoration(
                            labelText: isAr ? 'العنوان' : 'Title',
                            prefixIcon: const Icon(Icons.title),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return isAr
                                  ? 'يرجى إدخال عنوان'
                                  : 'Please enter a title';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _title = value!;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: isAr ? 'الوصف' : 'Description',
                            prefixIcon: Icon(Icons.description),
                            filled: true,
                          ),
                          maxLines: 3,
                          onSaved: (value) {
                            _description = value ?? '';
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer<CategoryProvider>(
                          builder: (context, categoryProvider, child) {
                            return DropdownButtonFormField<String>(
                              initialValue: _selectedCategoryId,
                              decoration: InputDecoration(
                                labelText: isAr ? 'التصنيف' : 'Category',
                                prefixIcon: _selectedCategoryId != null
                                    ? Builder(
                                        builder: (ctx) {
                                          final selected = categoryProvider
                                              .categories
                                              .firstWhere(
                                                (c) =>
                                                    c.id == _selectedCategoryId,
                                              );
                                          return kMaterialIconMap.containsKey(
                                                selected.iconCodePoint,
                                              )
                                              ? Icon(
                                                  kMaterialIconMap[selected
                                                      .iconCodePoint],
                                                  color: selected.categoryColor,
                                                )
                                              : Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 8.0,
                                                        right: 8.0,
                                                      ),
                                                  child: Text(
                                                    String.fromCharCode(
                                                      selected.iconCodePoint,
                                                    ),
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'MaterialIcons',
                                                      color: selected
                                                          .categoryColor,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                );
                                        },
                                      )
                                    : const Icon(Icons.category),
                                filled: true,
                              ),
                              items: [
                                DropdownMenuItem<String>(
                                  value: null,
                                  child: Text(
                                    isAr ? 'بدون تصنيف' : 'No Category',
                                  ),
                                ),
                                ...categoryProvider.categories.map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category.id,
                                    child: Row(
                                      children: [
                                        kMaterialIconMap.containsKey(
                                              category.iconCodePoint,
                                            )
                                            ? Icon(
                                                kMaterialIconMap[category
                                                    .iconCodePoint],
                                                color: category.categoryColor,
                                              )
                                            : Text(
                                                String.fromCharCode(
                                                  category.iconCodePoint,
                                                ),
                                                style: TextStyle(
                                                  fontFamily: 'MaterialIcons',
                                                  color: category.categoryColor,
                                                  fontSize: 18,
                                                ),
                                              ),
                                        const SizedBox(width: 8),
                                        Text(category.name),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            );
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
                                      ? (isAr
                                            ? 'اختر وقت البدء'
                                            : 'Pick start time')
                                      : (isAr
                                            ? 'البدء: ${_startTime!.format(context)}'
                                            : 'Start: ${_startTime!.format(context)}'),
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
                                      ? (isAr
                                            ? 'اختر وقت الانتهاء'
                                            : 'Pick end time')
                                      : (isAr
                                            ? 'الانتهاء: ${_endTime!.format(context)}'
                                            : 'End: ${_endTime!.format(context)}'),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Builder(
                          builder: (context) {
                            final info = _startTime == null || _endTime == null
                                ? (isAr
                                      ? 'لم يتم اختيار وقت'
                                      : 'No time selected')
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
                              if (!mounted) return;
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
                                  categoryId: _selectedCategoryId,
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
                                        title: isAr
                                            ? 'تذكير بالمهمة'
                                            : 'Task reminder',
                                        body: _title,
                                        notificationId: startDateTime
                                            .millisecondsSinceEpoch
                                            .remainder(100000),
                                      );
                                } else {
                                  if (!context.mounted) return;
                                  // Show warning for past times
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isAr
                                            ? 'وقت البدء في الماضي - لن يتم جدولة إشعار'
                                            : 'Start time is in the past - no notification scheduled',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }

                                if (!context.mounted) return;

                                Navigator.of(context).pop();
                              }
                            },
                            icon: const Icon(Icons.add_task),
                            label: Text(isAr ? 'إضافة مهمة' : 'Add Task'),
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
    if (!mounted) return false;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    if (_startTime == null || _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'يرجى اختيار وقتي البدء والانتهاء'
                : 'Please select start and end times',
          ),
        ),
      );
      return false;
    }
    final start = _mergeDateAndTime(_selectedDate, _startTime!);
    final end = _mergeDateAndTime(_selectedDate, _endTime!);
    if (!end.isAfter(start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isAr
                ? 'يجب أن يكون وقت الانتهاء بعد وقت البدء'
                : 'End time must be after start time',
          ),
        ),
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
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';
    final start = _mergeDateAndTime(_selectedDate, _startTime!);
    final end = _mergeDateAndTime(_selectedDate, _endTime!);
    final minutes = end.difference(start).inMinutes;
    return isAr
        ? 'من ${_startTime!.format(context)} إلى ${_endTime!.format(context)} • $minutes دقيقة'
        : 'From ${_startTime!.format(context)} to ${_endTime!.format(context)} • $minutes min';
  }
}
