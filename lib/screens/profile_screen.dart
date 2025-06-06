import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:metoda_app/registration_screen.dart';
import 'package:metoda_app/main.dart';
import 'package:metoda_app/root_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Future<void> _updateRole(bool isTeacher) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTeacher', isTeacher);
    setState(() => _isTeacher = isTeacher);
    navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(builder: (_) => RootScreen(isTeacher: isTeacher)),
    );
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    final isTeacher = prefs.getBool('isTeacher') ?? false;
    final lessons = prefs.getStringList('lessons') ?? [];
    await prefs.clear();
    await prefs.setBool('isTeacher', isTeacher);
    await prefs.setStringList('lessons', lessons);
    navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RegistrationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final accent = const Color(0xFFEFB709);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(
                'Профиль',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _roleButton(true, accent),
                        const SizedBox(width: 12),
                        _roleButton(false, accent),
                      ],
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Выйти из аккаунта'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(bool isTeacher, Color accent) {
    final selected = _isTeacher == isTeacher;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _updateRole(isTeacher),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? accent : Colors.transparent,
          foregroundColor: selected ? Colors.black : accent,
          side: BorderSide(color: accent),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(isTeacher ? 'Преподаватель' : 'Студент'),
      ),
    );
  }
}