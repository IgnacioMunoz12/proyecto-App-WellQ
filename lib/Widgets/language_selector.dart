import 'package:flutter/material.dart';
import '../main.dart'; // usa localeNotifier, setAppLanguage, useSystemLanguage

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, currentLocale, _) {
        final selected = currentLocale?.languageCode ?? 'system';

        return Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                ListTile(
                  title: const Text(
                    'Language / Idioma',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    switch (selected) {
                      'es' => 'Español',
                      'en' => 'English',
                      _ => 'Follow system / Seguir sistema',
                    },
                  ),
                ),
                const Divider(height: 0),

                // Seguir idioma del sistema
                RadioListTile<String>(
                  value: 'system',
                  groupValue: selected,
                  title: const Text('Follow system / Seguir sistema'),
                  onChanged: (_) async {
                    await useSystemLanguage();
                    _ok(context);
                  },
                ),

                // Español
                RadioListTile<String>(
                  value: 'es',
                  groupValue: selected,
                  title: const Text('Español'),
                  onChanged: (_) async {
                    await setAppLanguage('es');
                    _ok(context);
                  },
                ),

                // English
                RadioListTile<String>(
                  value: 'en',
                  groupValue: selected,
                  title: const Text('English'),
                  onChanged: (_) async {
                    await setAppLanguage('en');
                    _ok(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _ok(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Language updated / Idioma actualizado')),
    );
  }
}
