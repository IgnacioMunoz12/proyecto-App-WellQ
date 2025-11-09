import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/health_data_service.dart';
import 'dashboard_screen.dart';
import '../l10n/app_localizations.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    final l10n = AppLocalizations.of(context);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.enterEmailAndPassword)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // 1. Login con Firebase
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null && mounted) {
        // 2. Inicializar HealthDataService
        final healthService = HealthDataService();
        await healthService.initialize();

        // 3. Navegar al Dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      final l10n = AppLocalizations.of(context);

      // ✅ Mensajes localizados
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        mensaje = l10n.wrongCredentials;
      } else if (e.code == 'invalid-email') {
        mensaje = l10n.invalidEmailFormat;
      } else if (e.code == 'user-disabled') {
        mensaje = l10n.userDisabled;
      } else if (e.code == 'too-many-requests') {
        mensaje = l10n.tooManyRequests;
      } else if (e.code == 'network-request-failed') {
        mensaje = l10n.networkError;
      } else {
        mensaje = l10n.signInGenericError;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).unexpectedError),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signIn)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.emailLabel,
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            isLoading
                ? const CircularProgressIndicator(
              color: Color(0xFF22D3A6),
            )
                : SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: signIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22D3A6),
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.signInButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
