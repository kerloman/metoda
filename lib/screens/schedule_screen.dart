import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:metoda_app/main.dart';
import 'edit_schedule_screen.dart';
import 'package:clipboard/clipboard.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late List<Map<String, String>> _lessons;
  int _selectedDayIndex = 0;
  bool _isTeacher = false;

  @override
  void initState() {
    super.initState();
    _lessons = [];
    _loadLessonsFromPrefs();
    _loadRole();
    _requestNotificationPermissions();
  }
  Future<void> _requestNotificationPermissions() async {
    final iosPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'message_channel',
      'Сообщения',
      channelDescription: 'Уведомления о новых сообщениях',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      ticker: 'ticker',
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Metoda',
      'Вам пришло сообщение.',
      platformChannelSpecifics,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isTeacher = prefs.getBool('isTeacher') ?? false;
    });
  }

  Future<void> _loadLessonsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = prefs.getStringList('lessons') ?? [];
    setState(() {
      _lessons = lessonsJson.map((e) => Map<String, String>.from(jsonDecode(e))).toList();
    });
  }

  Future<void> _saveLessonsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final lessonsJson = _lessons.map((e) => jsonEncode(e)).toList();
    await prefs.setStringList('lessons', lessonsJson);
  }

  @override
  Widget build(BuildContext context) {
    final baseDate = DateTime(2025, 6, 16); // Понедельник
    final selectedDate = baseDate.add(Duration(days: _selectedDayIndex));
    final formattedDate = '${selectedDate.day} ${_monthName(selectedDate.month)} ${selectedDate.year}';

    final selectedDayName = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'][_selectedDayIndex];
    final filteredLessons = _lessons.where((lesson) => lesson['day'] == selectedDayName).toList();
    filteredLessons.sort((a, b) {
      final aNumber = int.tryParse(a['number'] ?? '') ?? 0;
      final bNumber = int.tryParse(b['number'] ?? '') ?? 0;
      return aNumber.compareTo(bNumber);
    });

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'Расписание',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        onPressed: () {
                          print('Нажали на колокольчик');

                          Future.delayed(const Duration(seconds: 5), () {
                            _showNotification();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Сверни приложение — уведомление придёт через 5 секунд')),
                          );
                        },
                      ),
                      if (_isTeacher)
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () async {
                            final newLesson = await showModalBottomSheet<Map<String, String>>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => EditScheduleScreen(),
                            );
                            if (newLesson != null) {
                              setState(() {
                                _lessons.add(newLesson);
                              });
                              await _saveLessonsToPrefs();
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
            _buildDaySelector(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isTeacher
    ? ReorderableListView.builder(
        key: ValueKey(_selectedDayIndex),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filteredLessons.length,
        onReorder: (oldIndex, newIndex) async {
          if (newIndex > oldIndex) newIndex--;

          final movedItem = filteredLessons.removeAt(oldIndex);
          filteredLessons.insert(newIndex, movedItem);

          for (int i = 0; i < filteredLessons.length; i++) {
            filteredLessons[i]['number'] = '${i + 1}';
          }

          setState(() {
            _lessons.removeWhere((l) => l['day'] == selectedDayName);
            _lessons.addAll(filteredLessons);
          });

          await _saveLessonsToPrefs();
        },
        itemBuilder: (context, index) {
  final lesson = filteredLessons[index];
  return Dismissible(
    key: ValueKey('${lesson['day']}_${lesson['number']}_${lesson['subject']}'),
    direction: DismissDirection.endToStart,
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Colors.red,
      child: const Icon(Icons.delete, color: Colors.white),
    ),
    onDismissed: (_) {
      setState(() {
        _lessons.remove(lesson);
      });
      _saveLessonsToPrefs();
    },
    child: GestureDetector(
      onTap: () {
        final text = '${lesson['number']}-я пара, ${lesson['subject']} в ${lesson['time']}, Преподаватель: ${lesson['teacher']}';
        FlutterClipboard.copy(text).then((_) {
          final overlay = Overlay.of(context);
          final overlayEntry = OverlayEntry(
            builder: (context) => Center(
              child: Material(
                color: Colors.transparent,
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Пара скопирована',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          overlay.insert(overlayEntry);
          Future.delayed(const Duration(seconds: 2), () {
            overlayEntry.remove();
          });
        });
      },
      child: _buildLessonCard(
        number: int.tryParse(lesson['number'] ?? '') ?? index + 1,
        subject: lesson['subject'] ?? '',
        time: lesson['time'] ?? '',
        teacher: lesson['teacher'] ?? '',
        onEditTap: () async {
          final newLesson = await showModalBottomSheet<Map<String, String>>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => EditScheduleScreen(existingLesson: lesson),
          );
          if (newLesson != null) {
            setState(() {
              final lessonIndex = _lessons.indexOf(lesson);
              _lessons[lessonIndex] = newLesson;
            });
            await _saveLessonsToPrefs();
          }
        },
      ),
    ),
  );
},
      )
    : ListView(
        key: ValueKey(_selectedDayIndex),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: filteredLessons.map((lesson) {
  return GestureDetector(
    onTap: () {
      final text = '${lesson['number']}-я пара, ${lesson['subject']} в ${lesson['time']}, Преподаватель: ${lesson['teacher']}';
      FlutterClipboard.copy(text).then((_) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Center(
      child: Material(
        color: Colors.transparent,
        child: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.symmetric(horizontal: 40),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1E0),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Пара скопирована',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  Future.delayed(const Duration(seconds: 2), () {
    overlayEntry.remove();
  });
});
    },
    child: _buildLessonCard(
      number: int.tryParse(lesson['number'] ?? '') ?? 1,
      subject: lesson['subject'] ?? '',
      time: lesson['time'] ?? '',
      teacher: lesson['teacher'] ?? '',
    ),
  );
}).toList(),
      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];
    return _DaySelector(
      days: days,
      selectedIndex: _selectedDayIndex,
      onDaySelected: (index) {
        setState(() {
          _selectedDayIndex = index;
        });
      },
    );
  }

  Widget _buildLessonCard({
    required int number,
    required String subject,
    required String time,
    required String teacher,
    VoidCallback? onEditTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            number.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(time),
                Text(teacher),
              ],
            ),
          ),
          _isTeacher
              ? IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: onEditTap,
                  splashRadius: 20,
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return months[month];
  }
}

class _DaySelector extends StatelessWidget {
  final List<String> days;
  final int selectedIndex;
  final Function(int) onDaySelected;

  const _DaySelector({
    required this.days,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final segmentWidth = 85.0;
    return SizedBox(
      height: 50,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: selectedIndex * segmentWidth + segmentWidth / 2 - 20,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFEFB709),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(days.length, (index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () => onDaySelected(index),
                  child: SizedBox(
                    width: segmentWidth,
                    height: 40,
                    child: Center(
                      child: Text(
                        days[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Theme.of(context).scaffoldBackgroundColor
                              : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}