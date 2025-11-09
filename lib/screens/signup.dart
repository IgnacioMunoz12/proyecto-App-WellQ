import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controladores - SIN CAMBIOS
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _user = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();

  // Estados - SIN CAMBIOS
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  // Función de signup - LÓGICA INTACTA
  Future<void> signup() async {
    if (!_validateForm()) return;

    setState(() { _isLoading = true; });
    final l10n = AppLocalizations.of(context);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      // Actualizar el displayName del usuario
      await userCredential.user?.updateDisplayName(_user.text.trim());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountCreatedOk),
          backgroundColor: Colors.green,
        ),
      );

      // Navegar al dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.registrationFailed(_getErrorMessage(e.toString()))),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  bool _validateForm() {
    final l10n = AppLocalizations.of(context);

    if (_user.text.trim().isEmpty) {
      _showError(l10n.pleaseEnterUsername);
      return false;
    }
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      _showError(l10n.pleaseEnterValidEmail);
      return false;
    }
    if (_password.text.length < 6) {
      _showError(l10n.passwordMinChars(6));
      return false;
    }
    if (_password.text != _confirmPassword.text) {
      _showError(l10n.passwordsDontMatch);
      return false;
    }
    if (!_agreeToTerms) {
      _showError(l10n.pleaseAcceptTerms);
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getErrorMessage(String error) {
    final l10n = AppLocalizations.of(context);
    if (error.contains('email-already-in-use')) {
      return l10n.emailAlreadyRegistered;
    } else if (error.contains('weak-password')) {
      return l10n.passwordTooWeak;
    } else if (error.contains('invalid-email')) {
      return l10n.invalidEmailFormat;
    }
    return l10n.registrationGenericError;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Header con botón de regreso
                  _buildHeader(context, isDark),

                  const SizedBox(height: 40),

                  // Logo y título
                  _buildLogo(isDark, l10n),

                  const SizedBox(height: 40),

                  // Formulario principal
                  _buildMainForm(isDark, l10n),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
            ),
          ),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? Colors.white : Colors.black,
              size: 20,
            ),
          ),
        ),
        const Spacer(),
        Text(
          l10n.createAccountHeader,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const Spacer(),
        const SizedBox(width: 48), // Para balancear el botón de regreso
      ],
    );
  }

  Widget _buildLogo(bool isDark, AppLocalizations l10n) {
    return Column(
      children: [
        // Logo icon
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              colors: [Color(0xFF22D3A6), Color(0xFF43E97B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22D3A6).withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'WellQ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF1A202C),
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          l10n.joinCommunity,
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainForm(bool isDark, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Campo Username
          _buildTextField(
            controller: _user,
            label: l10n.usernameLabel,
            hint: l10n.usernameHint,
            icon: Icons.person_outline,
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          // Campo Email
          _buildTextField(
            controller: _email,
            label: l10n.emailLabel,
            hint: l10n.emailHint,
            icon: Icons.email_outlined,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
          ),

          const SizedBox(height: 20),

          // Campo Password
          _buildTextField(
            controller: _password,
            label: l10n.passwordLabel,
            hint: l10n.passwordHint,
            icon: Icons.lock_outline,
            isDark: isDark,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Campo Confirm Password
          _buildTextField(
            controller: _confirmPassword,
            label: l10n.confirmPasswordLabel,
            hint: l10n.confirmPasswordHint,
            icon: Icons.lock_outline,
            isDark: isDark,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Checkbox Terms & Conditions
          Row(
            children: [
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFF22D3A6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    children: [
                      TextSpan(text: l10n.iAgreeTo),
                      TextSpan(
                        text: l10n.termsAndConditions,
                        style: const TextStyle(
                          color: Color(0xFF22D3A6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(text: ' ${l10n.and} '),
                      TextSpan(
                        text: l10n.privacyPolicy,
                        style: const TextStyle(
                          color: Color(0xFF22D3A6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Botón Sign Up
          _buildSignUpButton(l10n),

          const SizedBox(height: 24),

          // Divider
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
                  l10n.orSignUpWith,
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
                onPressed: () {},
                isDark: isDark,
              ),
              _buildSocialButton(
                icon: Icons.apple,
                onPressed: () {},
                isDark: isDark,
              ),
              _buildSocialButton(
                icon: Icons.facebook,
                onPressed: () {},
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Link to Sign In
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.alreadyHaveAccount,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, '/signin'),
                child: Text(
                  l10n.signIn, // ya existe en tus .arb
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF22D3A6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required bool isDark,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1A202C),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF7F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
            ),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey[500] : Colors.grey[500],
                fontSize: 16,
              ),
              prefixIcon: Icon(
                icon,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 20,
              ),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton(AppLocalizations l10n) {
    return Container(
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
          onTap: _isLoading ? null : signup,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: _isLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              l10n.createAccountCta,
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _user.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }
}

