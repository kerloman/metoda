import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metoda_app/registration_screen.dart';
import 'package:metoda_app/root_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('isTeacher');
  final isTeacher = prefs.getBool('isTeacher');

  runApp(MyApp(isTeacher: isTeacher));
}

class MyApp extends StatelessWidget {
  final bool? isTeacher;

  const MyApp({super.key, required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metoda',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: isTeacher == null
          ? const RegistrationScreen()
          : RootScreen(isTeacher: isTeacher!),
    );
  }
}