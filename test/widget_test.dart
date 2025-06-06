import 'package:flutter/material.dart';
// import 'package:metoda_app/models.dart';

class ScheduleScreen extends StatefulWidget {
  final bool isTeacher;

  const ScheduleScreen({Key? key, required this.isTeacher}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDay = 1;
  int selectedCourse = 1;

  final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт'];
  final courses = ['1 курс', '2 курс', '3 курс', '4 курс'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Расписание',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: 'SF Pro',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Row(
              children: [
                _dayChip(selectedDay),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: selectedCourse,
                  items: courses
                      .asMap()
                      .entries
                      .map(
                        (e) => DropdownMenuItem<int>(
                          value: e.key + 1,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedCourse = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '1 сентября, Понедельник',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF3F4F58),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _lessonCard(1, 'Математика', '08:30 - 09:15', 'Иванов И.И.'),
                  const SizedBox(height: 12),
                  _lessonCard(2, 'Физика', '09:25 - 10:10', 'Петров П.П.'),
                  const SizedBox(height: 12),
                  _lessonCard(3, 'История', '10:20 - 11:05', 'Сидоров С.С.'),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayChip(int dayIndex) {
    final isSelected = dayIndex == selectedDay;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = dayIndex;
        });
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFB709) : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    offset: const Offset(0, 4),
                    blurRadius: 4,
                  )
                ]
              : null,
          border: isSelected ? null : Border.all(color: Colors.grey),
        ),
        alignment: Alignment.center,
        child: Text(
          days[dayIndex - 1],
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _lessonCard(int number, String subject, String time, String teacher) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '$number',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      teacher,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.edit,
              size: 20,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
