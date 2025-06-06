import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String userName;
  final bool isTeacher;

  const ChatScreen({
    super.key,
    required this.userName,
    required this.isTeacher,
  });

  @override
  Widget build(BuildContext context) {
    final messages = isTeacher
        ? [
            {'fromMe': true, 'text': 'Привет всем! Кого не видел)', 'time': '9:05'},
            {'fromMe': false, 'text': 'Здравствуйте!', 'time': '9:06'},
          ]
        : [
            {'fromMe': false, 'text': 'Привет всем! Кого не видел)', 'time': '9:05'},
            {'fromMe': true, 'text': 'Здравствуйте!', 'time': '9:06'},
          ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Text(userName),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['fromMe'] as bool;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.amber.shade600 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['text'] as String,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              message['time'] as String,
                              style: TextStyle(
                                fontSize: 10,
                                color: isMe ? Colors.white70 : Colors.grey.shade600,
                              ),
                              textAlign: TextAlign.right,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 8,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Сообщение',
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        // отправка
                      },
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