import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _user = TextEditingController();

  bool _isLoading = false;
  final azulWellQ = Color(0xFF17C6F7);
  final verdeA = Color(0xFF43E97B);
  final verdeB = Color(0xFF38F9D7);

  Future<void> signup() async {
    setState(() { _isLoading = true; });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Widget _buildTextField(
      {required TextEditingController controller,
        required IconData icon,
        required String hintText,
        bool obscureText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.black38),
          hintText: hintText,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.black38),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF6F7FB),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // LOGIN/REGISTER
            Text(
              'LOGIN/REGISTER',
              style: TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            // WellQ Logo Text
            Text(
              'WellQ',
              style: TextStyle(
                color: azulWellQ,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // Caja blanca
            Container(
              width: 320,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 36),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 32,
                    offset: Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTextField(
                    controller: _user,
                    icon: Icons.person,
                    hintText: "Username",
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _email,
                    icon: Icons.email,
                    hintText: "Email",
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    controller: _password,
                    icon: Icons.lock,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  SizedBox(height: 28),
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: LinearGradient(
                        colors: [verdeA, verdeB],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: verdeB.withOpacity(0.11),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: _isLoading ? null : signup,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          fontFamily: 'Roboto',
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Sign Up"),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}