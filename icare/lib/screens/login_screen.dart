import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'asha_dashboard.dart';
import 'phc_dashboard.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool darkTheme;
  final Function(bool) onThemeToggle;
  LoginScreen({required this.darkTheme, required this.onThemeToggle});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  String _selectedRole = 'ASHA';
  String _selectedLanguage = 'English';
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;
  
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // PROFESSIONAL COLOR PALETTE
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color softWhite = Color(0xFFFAFBFC);

  final List<String> languageOptions = [
    'English', 'Hindi', 'Tamil', 'Telugu'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.elasticOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _cardAnimationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
    Future.delayed(Duration(milliseconds: 300), () {
      _cardAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
    String email = _emailController.text.trim();
    String password = _passController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please enter both email and password!"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      User? user = userCredential.user;

      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something went wrong during login. Please try again."),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      if (!user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please verify your email. Check your inbox for a verification mail."),
            backgroundColor: goldAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = userDoc.data() as Map<String, dynamic>?;

      if (!userDoc.exists || data == null || !data.containsKey('role')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("No role found for this user. Please contact support."),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      String role = data['role'];
      if (role != _selectedRole) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account is registered as $role. Please select $role to login."),
            backgroundColor: goldAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _loading = false);
        return;
      }

      Widget target = (role == 'ASHA')
          ? AshaDashboard(
              darkTheme: widget.darkTheme,
              onThemeToggle: widget.onThemeToggle,
            )
          : PhcDashboard(
              darkTheme: widget.darkTheme,
              onThemeToggle: widget.onThemeToggle,
            );

      Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => target));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Login failed: ${_formatError(e)}"),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() => _loading = false);
  }

  String _formatError(Object error) {
    String msg = error.toString();
    if (msg.contains('] ')) return msg.split('] ').last;
    return msg.replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.darkTheme;
    final primaryColor = primaryNavy;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [darkNavy, Color(0xFF1E293B), Color(0xFF0F172A)],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [softWhite, Color(0xFFF1F5F9), Color(0xFFE2E8F0)],
                ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PREMIUM LOGO SECTION
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, emeraldGreen],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(Icons.medical_services, color: Colors.white, size: 32),
                            ),
                            SizedBox(width: 15),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "ICare",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  "Healthcare Platform",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      
                      // MAIN LOGIN CARD
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: isDark ? darkNavy.withOpacity(0.8) : Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isDark ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 25,
                                offset: Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Welcome Back",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.grey[100] : primaryColor,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "Sign in to your account",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 28),
                              
                              // LANGUAGE SELECTOR
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : emeraldGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: emeraldGreen.withOpacity(0.3),
                                  ),
                                ),
                                child: DropdownButton<String>(
                                  value: _selectedLanguage,
                                  icon: Icon(Icons.language, color: emeraldGreen),
                                  underline: Container(),
                                  isExpanded: true,
                                  items: languageOptions
                                      .map((lang) => DropdownMenuItem(
                                          value: lang, 
                                          child: Text(lang, style: TextStyle(
                                            color: isDark ? Colors.grey[200] : Colors.grey[800],
                                          ))))
                                      .toList(),
                                  onChanged: (lang) => setState(() => _selectedLanguage = lang!),
                                ),
                              ),
                              SizedBox(height: 20),
                              
                              // THEME TOGGLE
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : goldAccent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          widget.darkTheme ? Icons.dark_mode : Icons.light_mode,
                                          color: goldAccent,
                                          size: 24,
                                        ),
                                        SizedBox(width: 12),
                                        Text(
                                          "Dark Theme",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.grey[200] : Colors.grey[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Switch(
                                      value: widget.darkTheme,
                                      onChanged: widget.onThemeToggle,
                                      activeColor: goldAccent,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 24),
                              
                              // ROLE SELECTOR
                              Text(
                                "Select Your Role",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                                ),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedRole = 'ASHA'),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: _selectedRole == 'ASHA'
                                              ? LinearGradient(colors: [primaryColor, emeraldGreen])
                                              : null,
                                          color: _selectedRole != 'ASHA'
                                              ? (isDark ? Colors.grey[800] : Colors.grey[200])
                                              : null,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: _selectedRole == 'ASHA' ? emeraldGreen : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          "ASHA Worker",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _selectedRole == 'ASHA' ? Colors.white : Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedRole = 'PHC'),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        decoration: BoxDecoration(
                                          gradient: _selectedRole == 'PHC'
                                              ? LinearGradient(colors: [primaryColor, lightBlue])
                                              : null,
                                          color: _selectedRole != 'PHC'
                                              ? (isDark ? Colors.grey[800] : Colors.grey[200])
                                              : null,
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(
                                            color: _selectedRole == 'PHC' ? lightBlue : Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          "PHC Staff",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: _selectedRole == 'PHC' ? Colors.white : Colors.grey[600],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 24),
                              
                              // EMAIL FIELD
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: isDark ? Colors.grey[100] : Colors.grey[800],
                                ),
                                decoration: InputDecoration(
                                  labelText: "Email Address",
                                  hintText: "Enter your email",
                                  prefixIcon: Icon(Icons.email_outlined, color: emeraldGreen),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: emeraldGreen, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                ),
                              ),
                              SizedBox(height: 20),
                              
                              // PASSWORD FIELD
                              TextField(
                                controller: _passController,
                                obscureText: true,
                                style: TextStyle(
                                  color: isDark ? Colors.grey[100] : Colors.grey[800],
                                ),
                                decoration: InputDecoration(
                                  labelText: "Password",
                                  hintText: "Enter your password",
                                  prefixIcon: Icon(Icons.lock_outlined, color: lightBlue),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide(color: lightBlue, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                ),
                              ),
                              SizedBox(height: 28),
                              
                              // LOGIN BUTTON
                              Container(
                                width: double.infinity,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [primaryColor, emeraldGreen],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _loading ? null : _loginUser,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: _loading
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.login, color: Colors.white, size: 22),
                                            SizedBox(width: 8),
                                            Text(
                                              "Sign In",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              SizedBox(height: 20),
                              
                              // FORGOT PASSWORD
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                                  );
                                },
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: lightBlue,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              
                              // DIVIDER
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  children: [
                                    Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "New to ICare?",
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: Colors.grey.withOpacity(0.3))),
                                  ],
                                ),
                              ),
                              
                              // SIGN UP BUTTON
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                  border: Border.all(color: goldAccent, width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignupScreen(
                                          darkTheme: widget.darkTheme,
                                          onThemeToggle: widget.onThemeToggle,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    "Create New Account",
                                    style: TextStyle(
                                      color: goldAccent,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
