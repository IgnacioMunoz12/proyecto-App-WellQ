import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/signup.dart';
import 'screens/signin.dart';
import 'widgets/streak_badge.dart';
import 'services/database_service.dart';
import 'services/notification_service.dart';
import 'services/native_notify_bridge.dart'; // ⭐ NUEVO

// 👇 NUEVO (segundo script): pantallas extra
import 'screens/health_register_english.dart';
import 'screens/doctor_feedback_screen.dart';

// Estado global para manejar el tema
final themeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

// NUEVO: estado global para el idioma (null = seguir idioma del sistema)
final localeNotifier = ValueNotifier<Locale?>(null);

// Helpers de idioma
Future<void> setAppLanguage(String code) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('appLocale', code);
  localeNotifier.value = Locale(code);
}

Future<void> useSystemLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('appLocale');
  localeNotifier.value = null; // vuelve a seguir el sistema
}

// Iniciar sesión con Google
Future<UserCredential?> signInWithGoogle() async {
  final gsi.GoogleSignInAccount? googleUser = await gsi.GoogleSignIn().signIn();
  if (googleUser == null) return null; // cancelado por el usuario

  final gsi.GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  return await FirebaseAuth.instance.signInWithCredential(credential);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ⭐ Asegurar canal de IMPORTANCE_HIGH una sola vez (heads-up)
  //    Esto crea un canal nuevo (p.ej. "wellq_high_v1") si no existe.
  await NativeNotifyBridge.ensureHighImportanceChannel(
    id: 'wellq_high_v1',
    name: 'Recordatorios (WellQ)',
    description: 'Recordatorios y hábitos',
  );

  // >>> Inicializar zona horaria + notificaciones y pedir permiso una vez
  await NotificationService().ensureTimezoneInitialized();
  await NotificationService().init();
  await NotificationService().requestPermissionIfNeeded();
  // <<<

  // Inicializar Base de Datos Drift
  // print para diagnóstico
  print('Inicializando base de datos...');
  await DatabaseService().initialize();

  final dbHealthy = await DatabaseService().healthCheck();
  if (dbHealthy) {
    print('Base de datos ta joya');
  } else {
    print('Advertencia: La base de datos puede tener problemas');
  }

  // Cargar preferencia guardada del tema e idioma
  final prefs = await SharedPreferences.getInstance();

  final themeIndex = prefs.getInt('themeMode') ?? 0;
  themeModeNotifier.value = ThemeMode.values[themeIndex];

  final savedLocaleCode = prefs.getString('appLocale');
  if (savedLocaleCode != null && savedLocaleCode.isNotEmpty) {
    localeNotifier.value = Locale(savedLocaleCode);
  } else {
    localeNotifier.value = null; // seguir idioma del sistema
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final Type _keepStreakBadge = StreakBadge;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (_, mode, __) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (_, appLocale, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false, // 👈 añadido del segundo script
              title: 'WellQ',

              // Idioma
              locale: appLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocale, supported) {
                if (appLocale != null) return appLocale;
                if (deviceLocale == null) return supported.first;
                return supported.firstWhere(
                      (l) => l.languageCode == deviceLocale.languageCode,
                  orElse: () => supported.first,
                );
              },

              // Tema (definiciones al final)
              themeMode: mode,
              theme: buildLightTheme(),
              darkTheme: buildDarkTheme(),

              // 🔹 Arranca en HomePage y define rutas que usan tus pantallas importadas
              initialRoute: '/',
              routes: {
                '/': (_) => const HomePage(),
                '/dashboard': (_) => const DashboardScreen(),
                '/settings': (_) => SettingsScreen(),
                '/signup': (_) => SignUpScreen(),
                '/signin': (_) => const SignInScreen(),

                // 👇 añadidas del segundo script
                '/healthRegisterEnglish': (_) => const HealthRegisterEnglishScreen(),
                '/doctorFeedback': (_) => const DoctorFeedbackScreen(),
              },
            );
          },
        );
      },
    );
  }
}

// ----------------------- HomePage -----------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Si ya hay usuario logueado, salta directo al dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context); // ← textos localizados

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF1A1A1A), const Color(0xFF0D1117)]
                : [const Color(0xFFF6F8FC), const Color(0xFFEDF2F7)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              _buildLogo(context, isDark, l10n),
              const Spacer(flex: 3),
              _buildMainCard(context, isDark, l10n),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
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
          child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
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
        Text(
          l10n.tagline, // ← 'Your Health, Our Priority'
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPrimaryButton(
            context,
            text: l10n.signUp, // ← localizado
            onPressed: () => Navigator.pushNamed(context, '/signup'),
          ),
          const SizedBox(height: 16),
          _buildSecondaryButton(
            context,
            text: l10n.signIn, // ← localizado
            onPressed: () => Navigator.pushNamed(context, '/signin'),
            isDark: isDark,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(child: Container(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300])),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l10n.orContinueWith, // ← localizado
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
              Expanded(child: Container(height: 1, color: isDark ? Colors.grey[700] : Colors.grey[300])),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.g_mobiledata,
                onPressed: () async {
                  try {
                    final cred = await signInWithGoogle();
                    if (cred != null) {
                      // ignore: use_build_context_synchronously
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.loginCanceled)),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.loginError}: $e')),
                    );
                  }
                },
                isDark: isDark,
              ),
              _buildSocialButton(
                icon: Icons.apple,
                onPressed: () {
                  // Implementar Apple Sign In (pendiente)
                },
                isDark: isDark,
              ),
              _buildSocialButton(
                icon: Icons.facebook,
                onPressed: () {
                  // Implementar Facebook Sign In (pendiente)
                },
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(
      BuildContext context, {
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
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
      BuildContext context, {
        required String text,
        required VoidCallback onPressed,
        required bool isDark,
      }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF22D3A6), width: 1.5),
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
              style: const TextStyle(color: Color(0xFF22D3A6), fontSize: 16, fontWeight: FontWeight.w600),
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
          const Icon(Icons.bolt_rounded, size: 14, color: Colors.white),
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

// ================== Temas “mejorados” del segundo script ==================
ThemeData buildLightTheme() {
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

ThemeData buildDarkTheme() {
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





