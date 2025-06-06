import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:metoda_app/screens/schedule_screen.dart';
import 'package:metoda_app/screens/messages_screen.dart';
import 'package:metoda_app/screens/profile_screen.dart';
import 'package:metoda_app/screens/home_screen.dart';

class RootScreen extends StatefulWidget {
  final bool isTeacher;

  const RootScreen({super.key, required this.isTeacher});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          activeColor: Color(0xFFEFB709),
          inactiveColor: CupertinoColors.systemGrey,
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.calendar), label: 'Расписание'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble), label: 'Сообщения'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.person), label: 'Профиль'),
          ],
        ),
        tabBuilder: (context, index) {
          final screens = [
            const HomeScreen(),
            const ScheduleScreen(),
            const MessagesScreen(),
            const ProfileScreen(),
          ];
          return CupertinoTabView(builder: (context) => screens[index]);
        },
      );
    } else {
      return Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            const HomeScreen(),
            const ScheduleScreen(),
            const MessagesScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Color(0xFFEFB709),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Главная'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Расписание'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Сообщения'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
          ],
        ),
      );
    }
  }
}