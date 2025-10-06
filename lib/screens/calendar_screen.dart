import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'analytics_screen.dart';
import 'commit_screen.dart';
import 'settings_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;
  DateTime? _selectedDate;

  // Eventos de ejemplo
  final Map<int, List<Event>> _events = {
    3: [Event('Morning Stretches', '6:00 AM - 6:30 AM', Colors.blue)],
    7: [
      Event('Physical Therapy', '10:00 AM - 11:00 AM', Colors.green),
      Event('Evening Walk', '6:00 PM - 6:30 PM', Colors.orange),
    ],
    12: [Event('Doctor Appointment', '2:00 PM - 3:00 PM', Colors.red)],
    15: [Event('Gym Session', '7:00 AM - 8:00 AM', Colors.purple)],
    20: [Event('Yoga Class', '5:00 PM - 6:00 PM', Colors.teal)],
    24: [Event('Nutrition Consultation', '11:00 AM - 12:00 PM', Colors.indigo)],
    28: [Event('Physical Check-up', '9:00 AM - 10:00 AM', Colors.pink)],
  };

  // Recordatorios
  final List<Reminder> _reminders = [
    Reminder('Take medication', '18 minutes', Colors.orange),
    Reminder('Ice therapy session', '1h 2 hours', Colors.blue),
    Reminder('Log pain levels', 'Due in 2 hours', Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLightMode = Theme.of(context).brightness == Brightness.light;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600; // Determinar si es tablet/desktop

    return Scaffold(
      backgroundColor: isLightMode ? Colors.grey[100] : const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: isLightMode ? Colors.white : const Color(0xFF2A2A2A),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded( // ARREGLADO: Evitar overflow en el título
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calendar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                  ),
                  Text(
                    'Schedule and track your recovery activities',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis, // ARREGLADO: Evitar overflow del subtítulo
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: _showAddEventDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // ARREGLADO: Padding más pequeño
              ),
              child: Text(
                'Add Event',
                style: TextStyle(
                  fontSize: isTablet ? 12 : 10, // ARREGLADO: Texto más pequeño en móvil
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: isTablet
          ? _buildTabletLayout(isLightMode) // Layout horizontal para tablets
          : _buildMobileLayout(isLightMode), // Layout vertical para móviles
      bottomNavigationBar: const _CalendarBottomNav(),
    );
  }

  // NUEVO: Layout para tablets/desktop (horizontal)
  Widget _buildTabletLayout(bool isLightMode) {
    return Row(
      children: [
        // Calendario principal
        Expanded(
          flex: 2,
          child: _buildCalendarCard(isLightMode),
        ),
        // Panel lateral derecho
        SizedBox(
          width: 320,
          child: _buildSidePanel(isLightMode),
        ),
      ],
    );
  }

  // NUEVO: Layout para móviles (vertical)
  Widget _buildMobileLayout(bool isLightMode) {
    return SingleChildScrollView( // ARREGLADO: Permitir scroll vertical
      child: Column(
        children: [
          // Calendario
          _buildCalendarCard(isLightMode),
          // Panel de eventos y recordatorios
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Today's Events
                _buildEventsCard(isLightMode),
                const SizedBox(height: 16),
                // Reminders
                _buildRemindersCard(isLightMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarCard(bool isLightMode) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 400, // ARREGLADO: Altura fija para evitar overflow
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header del calendario
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible( // ARREGLADO: Evitar overflow del título
                  child: Text(
                    _getMonthYearText(_currentDate),
                    style: TextStyle(
                      fontSize: 20, // ARREGLADO: Tamaño más pequeño
                      fontWeight: FontWeight.bold,
                      color: isLightMode ? Colors.black : Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
                        });
                      },
                      icon: Icon(
                        Icons.chevron_left,
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
                        });
                      },
                      icon: Icon(
                        Icons.chevron_right,
                        color: isLightMode ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Días de la semana
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                      fontSize: 11, // ARREGLADO: Tamaño más pequeño
                    ),
                  ),
                ),
              ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),
          // Calendar Grid
          Expanded( // ARREGLADO: Usar Expanded para ajustar al espacio disponible
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildCalendarGrid(isLightMode),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSidePanel(bool isLightMode) {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      child: Column(
        children: [
          Expanded(child: _buildEventsCard(isLightMode)),
          const SizedBox(height: 16),
          Expanded(child: _buildRemindersCard(isLightMode)),
        ],
      ),
    );
  }

  Widget _buildEventsCard(bool isLightMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 250, // ARREGLADO: Altura fija
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF69B4), Color(0xFFFF1493)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Events",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildTodaysEvents(),
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersCard(bool isLightMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 250, // ARREGLADO: Altura fija
      decoration: BoxDecoration(
        color: isLightMode ? Colors.white : const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Reminders',
                style: TextStyle(
                  color: isLightMode ? Colors.black : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildReminders(isLightMode),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(bool isLightMode) {
    final firstDayOfMonth = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDayOfMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final startDate = firstDayOfMonth.subtract(Duration(days: firstDayOfMonth.weekday % 7));

    return GridView.builder(
      shrinkWrap: true, // ARREGLADO: Permitir que el GridView se ajuste
      physics: const NeverScrollableScrollPhysics(), // ARREGLADO: Evitar scroll interno
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.2, // ARREGLADO: Ratio más compacto
      ),
      itemCount: 35, // ARREGLADO: 5 semanas en lugar de 6
      itemBuilder: (context, index) {
        final date = startDate.add(Duration(days: index));
        final isCurrentMonth = date.month == _currentDate.month;
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _selectedDate != null && _isSameDay(date, _selectedDate!);
        final hasEvents = _events.containsKey(date.day) && isCurrentMonth;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          child: Container(
            margin: const EdgeInsets.all(1), // ARREGLADO: Margin más pequeño
            decoration: BoxDecoration(
              color: hasEvents ? Colors.orange : (isSelected ? Colors.orange.withValues(alpha: 0.3) : null),
              borderRadius: BorderRadius.circular(6), // ARREGLADO: Border radius más pequeño
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(
                      color: !isCurrentMonth
                          ? Colors.grey[400]
                          : hasEvents
                          ? Colors.white
                          : isToday
                          ? Colors.orange
                          : isLightMode
                          ? Colors.black
                          : Colors.white,
                      fontWeight: isToday || hasEvents ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14, // ARREGLADO: Tamaño más pequeño
                    ),
                  ),
                ),
                if (hasEvents)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTodaysEvents() {
    final today = DateTime.now();
    final todaysEvents = _events[today.day] ?? [];

    if (todaysEvents.isEmpty) {
      return const Center(
        child: Text(
          'No events for today',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: todaysEvents.length,
      itemBuilder: (context, index) {
        final event = todaysEvents[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10), // ARREGLADO: Padding más pequeño
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // ARREGLADO: Tamaño más pequeño
                ),
                overflow: TextOverflow.ellipsis, // ARREGLADO: Evitar overflow del texto
              ),
              const SizedBox(height: 2),
              Text(
                event.time,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11, // ARREGLADO: Tamaño más pequeño
                ),
                overflow: TextOverflow.ellipsis, // ARREGLADO: Evitar overflow del texto
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildReminders(bool isLightMode) {
    return ListView.builder(
      itemCount: _reminders.length,
      itemBuilder: (context, index) {
        final reminder = _reminders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8), // ARREGLADO: Margin más pequeño
          padding: const EdgeInsets.all(10), // ARREGLADO: Padding más pequeño
          decoration: BoxDecoration(
            color: isLightMode
                ? Colors.grey[100]
                : const Color(0xFF3A3A3A),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: reminder.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded( // ARREGLADO: Evitar overflow del texto
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: TextStyle(
                        color: isLightMode ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12, // ARREGLADO: Tamaño más pequeño
                      ),
                      overflow: TextOverflow.ellipsis, // ARREGLADO: Evitar overflow
                    ),
                    Text(
                      reminder.time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 10, // ARREGLADO: Tamaño más pequeño
                      ),
                      overflow: TextOverflow.ellipsis, // ARREGLADO: Evitar overflow
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _getMonthYearText(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(
                labelText: 'Time',
                hintText: '10:00 AM - 11:00 AM',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && _selectedDate != null) {
                setState(() {
                  final events = _events[_selectedDate!.day] ?? [];
                  events.add(Event(
                    titleController.text,
                    timeController.text.isEmpty ? 'All day' : timeController.text,
                    Colors.blue,
                  ));
                  _events[_selectedDate!.day] = events;
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

// Clases auxiliares (sin cambios)
class Event {
  final String title;
  final String time;
  final Color color;

  Event(this.title, this.time, this.color);
}

class Reminder {
  final String title;
  final String time;
  final Color color;

  Reminder(this.title, this.time, this.color);
}

// BottomNav específico para Calendar (sin cambios)
class _CalendarBottomNav extends StatefulWidget {
  const _CalendarBottomNav();

  @override
  State<_CalendarBottomNav> createState() => _CalendarBottomNavState();
}

class _CalendarBottomNavState extends State<_CalendarBottomNav> {
  int _currentIndex = 2;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return NavigationBar(
      height: 64,
      backgroundColor: cs.surface,
      indicatorColor: cs.primary.withValues(alpha: 0.14),
      selectedIndex: _currentIndex,
      onDestinationSelected: (int index) {
        setState(() {
          _currentIndex = index;
        });

        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DashboardScreen()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AnalyticsScreen()),
            );
            break;
          case 2:
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CommitScreen()),
            );
            break;
          case 4:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
            break;
        }
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
    );
  }
}
