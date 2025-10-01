import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  bool _loading = false;

  // PROFESSIONAL COLOR PALETTE
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color softWhite = Color(0xFFFAFBFC);

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showSnack("Please enter your email", goldAccent);
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      _showSnack("Reset email sent! Check your inbox.", emeraldGreen);
      Future.delayed(Duration(seconds: 2), () => Navigator.pop(context));
    } catch (e) {
      _showSnack("Failed: ${e.toString()}", Colors.red.shade400);
    }
    setState(() => _loading = false);
  }

  void _showSnack(String message, Color bg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: bg,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgGradient = isDark
        ? LinearGradient(colors: [darkNavy, Color(0xFF1E293B)])
        : LinearGradient(colors: [softWhite, Color(0xFFF1F5F9)]);
    final surface = isDark ? Color(0xFF232947) : Colors.white;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    // HEADER CARD
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryNavy, emeraldGreen]),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: primaryNavy.withOpacity(0.3),
                            blurRadius: 20,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_reset, color: Colors.white, size: 32),
                          SizedBox(width: 12),
                          Text(
                            "Forgot Password",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    // FORM CARD
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Enter your email below to receive a password reset link.",
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey[300] : Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 24),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: "Email Address",
                              prefixIcon: Icon(Icons.email_outlined, color: emeraldGreen),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                              filled: true,
                              fillColor: isDark ? Color(0xFF22233B) : Colors.grey.withOpacity(0.1),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide(color: emeraldGreen, width: 2),
                              ),
                            ),
                            style: TextStyle(color: isDark ? Colors.grey[100] : Colors.grey[900]),
                          ),
                          SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [primaryNavy, emeraldGreen]),
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: emeraldGreen.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _loading ? null : _sendResetEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: _loading
                                  ? CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation(Colors.white), strokeWidth: 2)
                                  : Text(
                                      "Send Reset Email",
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          SizedBox(height: 16),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Back to Login",
                              style: TextStyle(color: lightBlue, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
