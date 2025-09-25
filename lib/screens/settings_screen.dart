import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // para acceder a themeModeNotifier

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', ThemeMode.values.indexOf(mode));
    themeModeNotifier.value = mode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ValueListenableBuilder<ThemeMode>(
          valueListenable: themeModeNotifier,
          builder: (context, mode, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Theme",
                    style:
                    TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButton<ThemeMode>(
                  value: mode,
                  onChanged: (ThemeMode? newMode) {
                    if (newMode != null) _saveTheme(newMode);
                  },
                  items: ThemeMode.values.map((ThemeMode mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(mode.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
