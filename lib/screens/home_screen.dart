import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final news = [
      {
        'image': 'assets/images/news/news1.jpg',
        'title': 'Выставка в павильоне «Атом» на ВДНХ',
        'date': '07.12.2023',
        'description': 'В четверг группа ИС-31 побывала в удивительном Павильоне «Атом» на ВДНХ. Это было путешествие в мир науки, инноваций и невероятных открытий. Первым остановочным пунктом был зал, посвященный истории открытия атома и первым шагам в разработке атомной энергии.'
      },
      {
        'image': 'assets/images/news/news2.jpg',
        'title': 'КВН «Знатоки информатики»',
        'date': '07.04.2023',
        'description': 'В рамках декады специальности 09.02.07 «Информационные системы и программирование» в техникуме 7 апреля прошел КВН «Знатоки информатики». Соревновались команда первого курса ИС-11 и второго курса ИС-21.'
      },
      {
        'image': 'assets/images/news/news3.jpg',
        'title': 'Дорога в мир IT – профессий',
        'date': '05.04.2023',
        'description': '5 апреля состоялось внеклассное мероприятие – цель которого, познакомиться с теми профессиями, которые скрываются под общим названием «Программист», где ведущую роль играют программисты профессионалы.'
      },
    ];

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/logo/mkt.jpg',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Московский Кооперативный Техникум\nим. Альтшуля, г. Мытищи',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Последние новости',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onBackground,
              ),
            ),
            const SizedBox(height: 16),
            ...news.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        item['image']!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['date']!,
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['description']!,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}