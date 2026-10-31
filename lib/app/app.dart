import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';
import '../features/notes/presentation/screens/notes_screen.dart';

/// Root widget that applies and persists the user's theme choice.
class PocketNotesApp extends StatefulWidget {
  const PocketNotesApp({
    super.key,
    required this.initialIsDark,
    required this.preferences,
  });

  /// Theme preference loaded before [runApp] is called.
  final bool initialIsDark;

  /// Shared async preferences used to persist theme changes.
  final SharedPreferencesAsync preferences;

  @override
  State<PocketNotesApp> createState() => _PocketNotesAppState();
}

class _PocketNotesAppState extends State<PocketNotesApp> {
  late bool _isDark = widget.initialIsDark;

  /// Saves the new choice, then rebuilds the app with the selected theme.
  Future<void> _toggleTheme() async {
    final isDark = !_isDark;
    await widget.preferences.setBool('isDark', isDark);
    if (!mounted) return;

    setState(() {
      _isDark = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Notes',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: NotesScreen(isDark: _isDark, onToggleTheme: _toggleTheme),
    );
  }
}
