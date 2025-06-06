import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFEFB709),
  scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  fontFamily: 'SF Pro',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF3F4F58)),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFEFB709),
  scaffoldBackgroundColor: const Color(0xFF121212),
  fontFamily: 'SF Pro',
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
  ),
);