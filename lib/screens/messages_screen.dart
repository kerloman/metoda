import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metoda_app/screens/chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isTeacher = false;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    _isTeacher = prefs.getBool('isTeacher') ?? false;
    _isLoaded = true;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    // final textTheme = Theme.of(context).textTheme;

    if (Platform.isIOS) {
      return Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Сообщения',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      onTap: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            fullscreenDialog: true, // это важно
                            builder: (_) => ChatScreen(
                              userName: _isTeacher
                                  ? 'Конаков Кирилл Сергеевич'
                                  : 'Поляков Михаил Владимирович',
                              isTeacher: _isTeacher,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _isTeacher
                            ? const AssetImage('assets/images/users/user1.jpeg')
                            : null,
                        child: !_isTeacher ? const Icon(Icons.person, color: Colors.amber) : null,
                      ),
                      title: Text(
                        _isTeacher ? 'Конаков Кирилл Сергеевич' : 'Поляков Михаил Владимирович',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _isTeacher ? 'Здравствуйте!' : 'Привет всем! Кого не видел)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Text('9:05', style: TextStyle(color: Colors.grey)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Сообщения',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(
                        CupertinoPageRoute(
                          fullscreenDialog: true, // Важно
                          builder: (_) => ChatScreen(
                            userName: _isTeacher
                                ? 'Конаков Кирилл Сергеевич'
                                : 'Поляков Михаил Владимирович',
                            isTeacher: _isTeacher,
                          ),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: _isTeacher
                          ? const AssetImage('assets/images/users/user1.jpeg')
                          : null,
                      child: !_isTeacher ? const Icon(Icons.person, color: Colors.amber) : null,
                    ),
                    title: Text(
                      _isTeacher ? 'Конаков Кирилл Сергеевич' : 'Поляков Михаил Владимирович',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      _isTeacher ? 'Здравствуйте!' : 'Привет всем! Кого не видел)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Text('9:05', style: TextStyle(color: Colors.grey)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}