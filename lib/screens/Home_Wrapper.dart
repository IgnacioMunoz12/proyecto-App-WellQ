// lib/screens/home_wrapper.dart
import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';
import '../main.dart'; // Para acceder a HomeHeader
/*
class HomeWrapper extends StatefulWidget {
  const HomeWrapper({Key? key}) : super(key: key);

  @override
  State<HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<HomeWrapper> {
  int _currentIndex = 0;

  // Lista de pantallas - IMPORTANTE: quitar appBar de cada una
  final List<Widget> _screens = [
    const DashboardScreen(), // Sin AppBar y sin BottomNav
    const AnalyticsScreen(),  // Contenido sin AppBar
    const CalendarScreen(),   // Contenido sin AppBar
    const CommitScreen(),     // Contenido sin AppBar
    const SettingsScreen(),   // Contenido sin AppBar
  ];

  // Títulos dinámicos para el AppBar
  final List<String> _titles = [
    'WellQ', // Dashboard mantiene el título original
    'Analytics',
    'Calendar',
    'Commit',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar persistente con título dinámico
      appBar: _currentIndex == 0
          ? const HomeHeader() // Dashboard usa su header personalizado
          : AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: Row(
          children: [
            _LogoDiamond(size: 22),
            const SizedBox(width: 8),
            Text(
              _titles[_currentIndex],
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        actions: [
          // Streak counter (solo en Dashboard)
          if (_currentIndex == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded,
                      size: 16, color: Color(0xFFF9A825)),
                  SizedBox(width: 6),
                  Text(
                    '15-day streak',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 10),

          // Theme toggle
          _IconPill(
            icon: Icons.wb_sunny_rounded,
            onTap: () {
              final platformBrightness = WidgetsBinding.instance
                  .platformDispatcher.platformBrightness;
              final current = themeModeNotifier.value;
              final effectiveIsDark = current == ThemeMode.dark ||
                  (current == ThemeMode.system &&
                      platformBrightness == Brightness.dark);
              themeModeNotifier.value = effectiveIsDark
                  ? ThemeMode.light
                  : ThemeMode.dark;
            },
          ),
          const SizedBox(width: 10),

          // Profile button
          Builder(
            builder: (context) => CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF2DA9FF),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.surface,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),

      // Contenido con IndexedStack
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Bottom Navigation persistente
      bottomNavigationBar: NavigationBar(
        height: 64,
        backgroundColor: cs.surface,
        indicatorColor: cs.primary.withValues(alpha: 0.14),
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite_rounded),
            label: 'Health',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined_rounded),
            selectedIcon: Icon(Icons.insert_chart_rounded),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_rounded),
            selectedIcon: Icon(Icons.event_note),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Commit',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Widgets auxiliares para el AppBar personalizado
class _LogoDiamond extends StatelessWidget {
  final double size;
  const _LogoDiamond({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45°
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: const Color(0xFF15C492),
                borderRadius: BorderRadius.circular(size * 0.18),
              ),
            ),
          ),
          const Icon(
            Icons.bolt_rounded,
            size: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconPill({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Icon(icon, size: 18, color: cs.onSurface),
      ),
    );
  }
}
*/