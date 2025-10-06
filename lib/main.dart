import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'services/database_service.dart';

// Estado global para manejar el tema
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //Inicializar Base de Datos Drift
  print('Inicializando base de datos...');
  await DatabaseService().initialize();

  // Verificar que la BD esté funcionando
  final dbHealthy = await DatabaseService().healthCheck();
  if (dbHealthy) {
    print('Base de datos ta joya');
  } else {
    print('Advertencia: La base de datos puede tener problemas');
  }

  // Cargar preferencia guardada del tema
  final prefs = await SharedPreferences.getInstance();
  final themeIndex = prefs.getInt('themeMode') ?? 0;
  themeModeNotifier.value = ThemeMode.values[themeIndex];

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WellQ',
          themeMode: mode,
          theme: _buildLightTheme(), // NUEVO: Tema mejorado
          darkTheme: _buildDarkTheme(), // NUEVO: Tema mejorado
          home: const HomePage(),
          routes: {
            '/dashboard': (_) => const DashboardScreen(),
            '/settings': (_) => const SettingsScreen(),
            '/signup': (_) => SignUpScreen(),
            '/signin': (_) => SignInScreen(),
          },
        );
      },
    );
  }

  // Tema claro
  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF22D3A6),
        brightness: Brightness.light,
        primary: const Color(0xFF22D3A6),
        secondary: const Color(0xFF43E97B),
        surface: Colors.white,
        background: const Color(0xFFF6F8FC),
      ).copyWith(
        primary: const Color(0xFF22D3A6),
        secondary: const Color(0xFF43E97B),
      ),
      scaffoldBackgroundColor: const Color(0xFFF6F8FC),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  // NUEVO: Tema oscuro mejorado
  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF22D3A6),
        brightness: Brightness.dark,
        primary: const Color(0xFF22D3A6),
        secondary: const Color(0xFF43E97B),
        surface: const Color(0xFF1E1E1E),
        background: const Color(0xFF121212),
      ).copyWith(
        primary: const Color(0xFF22D3A6),
        secondary: const Color(0xFF43E97B),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      useMaterial3: true,
      fontFamily: 'SF Pro Display',
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

// HomePage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
              const Color(0xFF1A1A1A),
              const Color(0xFF0D1117),
            ]
                : [
              const Color(0xFFF6F8FC),
              const Color(0xFFEDF2F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Logo WellQ
              _buildLogo(context, isDark),

              const Spacer(flex: 3),

              // Card principal
              _buildMainCard(context, isDark),

              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isDark) {
    return Column(
      children: [
        // Logo icon con diamante
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFF22D3A6), Color(0xFF43E97B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22D3A6).withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'WellQ',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A202C),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        // Subtítulo
        Text(
          'Your Health, Our Priority',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.grey[800]!
              : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sign Up Button (Primario)
          _buildPrimaryButton(
            context,
            text: 'Sign Up',
            onPressed: () => Navigator.pushNamed(context, '/signup'),
          ),

          const SizedBox(height: 16),

          // Sign In Button (Secundario)
          _buildSecondaryButton(
            context,
            text: 'Sign In',
            onPressed: () => Navigator.pushNamed(context, '/signin'),
            isDark: isDark,
          ),

          const SizedBox(height: 32),

          // Divider con texto
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'or continue with',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botones sociales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                onPressed: () {
                  // Implementar Google Sign In
                },
                isDark: isDark,
              ),
              _buildSocialButton(
                icon: Icons.apple,
                onPressed: () {
                  // Implementar Apple Sign In
                },
                isDark: isDark,
              ),
              _buildSocialButton(
                icon: Icons.facebook,
                onPressed: () {
                  // Implementar Facebook Sign In
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context, {
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22D3A6), Color(0xFF43E97B)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF22D3A6).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(BuildContext context, {
    required String text,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF22D3A6),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF22D3A6),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isDark,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Icon(
            icon,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
            size: 24,
          ),
        ),
      ),
    );
  }
}

// Clases auxiliares para widgets reutilizables
class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: cs.surface,
      elevation: 0,
      title: Row(
        children: [
          _LogoDiamond(size: 22),
          const SizedBox(width: 8),
          Text(
            'WellQ',
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
    );
  }
}

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
