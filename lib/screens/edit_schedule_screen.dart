import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class EditScheduleScreen extends StatefulWidget {
  final Map<String, String>? existingLesson;

  EditScheduleScreen({super.key, this.existingLesson});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _selectedDay;
  String? _selectedNumber;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _teacherController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.existingLesson != null) {
      _selectedDay = widget.existingLesson!['day'];
      _selectedNumber = widget.existingLesson!['number'];
      _subjectController.text = widget.existingLesson!['subject'] ?? '';
      _teacherController.text = widget.existingLesson!['teacher'] ?? '';

      final time = widget.existingLesson!['time'] ?? '';
      final parts = time.split('—').map((e) => e.trim()).toList();
      if (parts.length == 2) {
        final start = parts[0];
        final end = parts[1];
        _startTime = _parseTimeOfDay(start);
        _endTime = _parseTimeOfDay(end);
      }
    }
  }

  TimeOfDay? _parseTimeOfDay(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: controller,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Отменить',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD600),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () {
                        // Проверка на заполненность всех полей
                        if (_selectedDay == null ||
                            _selectedNumber == null ||
                            _subjectController.text.trim().isEmpty ||
                            _startTime == null ||
                            _endTime == null ||
                            _teacherController.text.trim().isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFFFF8E1),
                              title: Text(
                                'Ошибка',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              content: Text(
                                'Вы заполнили не все поля',
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: const Text('ОК'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: const Color(0xFFFFD600),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                          return;
                        }
                        final timeRange = [
                          _startTime != null ? _startTime!.format(context) : '',
                          _endTime != null ? _endTime!.format(context) : ''
                        ].join(' — ');

                        final newLesson = {
                          'day': _selectedDay ?? '',
                          'number': _selectedNumber ?? '',
                          'subject': _subjectController.text,
                          'time': timeRange,
                          'teacher': _teacherController.text,
                        };
                        Navigator.of(context).pop(newLesson);
                      },
                      child: const Text('Сохранить'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDropdownField('День недели', ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'], _selectedDay, (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                }, context: context),
                const SizedBox(height: 12),
                _buildDropdownField('Пара №', ['1', '2', '3', '4'], _selectedNumber, (value) {
                  setState(() {
                    _selectedNumber = value;
                  });
                }, context: context),
                const SizedBox(height: 12),
                _buildTextField('Предмет', 'Введите название предмета', _subjectController, context: context),
                const SizedBox(height: 12),
                _buildTimePickerRow(context),
                const SizedBox(height: 12),
                _buildTextField('Преподаватель ФИО', 'Например: Конаков Кирилл Сергеевич', _teacherController, context: context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdownField(
    String label,
    List<String> items,
    String? selectedValue,
    void Function(String?) onChanged, {
    required BuildContext context,
  }) {
    if (Platform.isIOS) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (_) {
                  int initialIndex = selectedValue != null ? items.indexOf(selectedValue) : 0;
                  return Container(
                    height: 250,
                    color: Theme.of(context).cardColor,
                    child: CupertinoPicker(
                      backgroundColor: Theme.of(context).cardColor,
                      itemExtent: 32,
                      scrollController: FixedExtentScrollController(initialItem: initialIndex),
                      onSelectedItemChanged: (index) {
                        onChanged(items[index]);
                      },
                      children: items.map((item) {
                        return Center(
                          child: Text(
                            item,
                            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                selectedValue ?? 'Выберите',
                style: TextStyle(
                  color: selectedValue != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: _fieldDecoration(context: context),
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            dropdownColor: Theme.of(context).cardColor,
            style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          ),
        ],
      );
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {required BuildContext context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
          decoration: _fieldDecoration(hintText: hint, context: context),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hintText, required BuildContext? context}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: context != null ? Theme.of(context).hintColor : Colors.grey),
      filled: true,
      fillColor: context != null ? Theme.of(context).cardColor : Colors.white,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildTimePickerRow(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Время',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (Platform.isIOS) {
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (_) {
                        return Container(
                          height: 250,
                          color: Theme.of(context).cardColor,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            initialDateTime: DateTime.now(),
                            onDateTimeChanged: (DateTime newTime) {
                              setState(() {
                                _startTime = TimeOfDay.fromDateTime(newTime);
                              });
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).brightness == Brightness.dark
                              ? ThemeData.dark().copyWith(
                                  timePickerTheme: const TimePickerThemeData(
                                    backgroundColor: Color(0xFF2C2C2C),
                                    hourMinuteTextColor: Colors.white,
                                    hourMinuteColor: Color(0xFFFFD600),
                                    dialHandColor: Color(0xFFFFD600),
                                    dialBackgroundColor: Color(0xFF424242),
                                    entryModeIconColor: Colors.white,
                                  ),
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFFFFD600),
                                    onPrimary: Colors.black,
                                    surface: Color(0xFF2C2C2C),
                                    onSurface: Colors.white,
                                  ),
                                )
                              : ThemeData.light().copyWith(
                                  timePickerTheme: const TimePickerThemeData(
                                    backgroundColor: Color(0xFFFFF8E1),
                                    hourMinuteTextColor: Colors.black,
                                    hourMinuteColor: Color(0xFFFFD600),
                                    dialHandColor: Color(0xFFFFD600),
                                    dialBackgroundColor: Color(0xFFFFECB3),
                                    entryModeIconColor: Colors.black,
                                  ),
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFFFD600),
                                    onPrimary: Colors.black,
                                    surface: Color(0xFFFFF8E1),
                                    onSurface: Colors.black,
                                  ),
                                ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _startTime = picked;
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _startTime != null ? _startTime!.format(context) : 'Укажите начало',
                    style: TextStyle(
                      color: _startTime != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text('—'),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (Platform.isIOS) {
                    await showCupertinoModalPopup(
                      context: context,
                      builder: (_) {
                        return Container(
                          height: 250,
                          color: Theme.of(context).cardColor,
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.time,
                            use24hFormat: true,
                            initialDateTime: DateTime.now(),
                            onDateTimeChanged: (DateTime newTime) {
                              setState(() {
                                _endTime = TimeOfDay.fromDateTime(newTime);
                              });
                            },
                          ),
                        );
                      },
                    );
                  } else {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).brightness == Brightness.dark
                              ? ThemeData.dark().copyWith(
                                  timePickerTheme: const TimePickerThemeData(
                                    backgroundColor: Color(0xFF2C2C2C),
                                    hourMinuteTextColor: Colors.white,
                                    hourMinuteColor: Color(0xFFFFD600),
                                    dialHandColor: Color(0xFFFFD600),
                                    dialBackgroundColor: Color(0xFF424242),
                                    entryModeIconColor: Colors.white,
                                  ),
                                  colorScheme: const ColorScheme.dark(
                                    primary: Color(0xFFFFD600),
                                    onPrimary: Colors.black,
                                    surface: Color(0xFF2C2C2C),
                                    onSurface: Colors.white,
                                  ),
                                )
                              : ThemeData.light().copyWith(
                                  timePickerTheme: const TimePickerThemeData(
                                    backgroundColor: Color(0xFFFFF8E1),
                                    hourMinuteTextColor: Colors.black,
                                    hourMinuteColor: Color(0xFFFFD600),
                                    dialHandColor: Color(0xFFFFD600),
                                    dialBackgroundColor: Color(0xFFFFECB3),
                                    entryModeIconColor: Colors.black,
                                  ),
                                  colorScheme: const ColorScheme.light(
                                    primary: Color(0xFFFFD600),
                                    onPrimary: Colors.black,
                                    surface: Color(0xFFFFF8E1),
                                    onSurface: Colors.black,
                                  ),
                                ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _endTime = picked;
                      });
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _endTime != null ? _endTime!.format(context) : 'Укажите конец',
                    style: TextStyle(
                      color: _endTime != null ? Theme.of(context).textTheme.bodyLarge?.color : Theme.of(context).hintColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}