import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupScreen extends StatefulWidget {
  final bool darkTheme;
  final Function(bool) onThemeToggle;
  SignupScreen({required this.darkTheme, required this.onThemeToggle});
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedRole = 'ASHA';
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreeToTerms = false;

  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // PROFESSIONAL COLOR PALETTE (matching LoginScreen)
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color goldAccent = Color(0xFFF59E0B);
  static const Color lightBlue = Color(0xFF3B82F6);
  static const Color darkNavy = Color(0xFF0F172A);
  static const Color softWhite = Color(0xFFFAFBFC);

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
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    String email = _emailController.text.trim();
    String password = _passController.text.trim();
    String confirmPassword = _confirmPassController.text.trim();
    String name = _nameController.text.trim();

    // Validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill in all required fields", Colors.red[400]!);
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar("Passwords do not match", Colors.red[400]!);
      return;
    }

    if (password.length < 6) {
      _showSnackBar("Password must be at least 6 characters", Colors.red[400]!);
      return;
    }

    if (!_agreeToTerms) {
      _showSnackBar("Please accept the terms and conditions", goldAccent);
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'role': _selectedRole,
        'email': email,
        'name': name,
        'createdAt': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Send email verification
      await userCredential.user?.sendEmailVerification();

      _showSnackBar(
        "Account created! Please check your email for verification.",
        emeraldGreen,
      );

      // Navigate back to login after a short delay
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } catch (e) {
      _showSnackBar("Registration failed: ${_formatError(e)}", Colors.red[400]!);
    }

    setState(() => _loading = false);
  }

  String _formatError(Object error) {
    String msg = error.toString();
    if (msg.contains('] ')) return msg.split('] ').last;
    return msg.replaceFirst('Exception: ', '');
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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
          child: Column(
            children: [
              // CUSTOM APP BAR
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: isDark ? Colors.white : primaryColor,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        "Create Account",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : primaryColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),
              
              // MAIN CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          // HEADER SECTION
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
                                  child: Icon(Icons.person_add, color: Colors.white, size: 28),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Join ICare",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Healthcare Professional",
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
                          SizedBox(height: 24),
                          
                          // MAIN SIGNUP CARD
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
                                  
                                  // NAME FIELD
                                  TextField(
                                    controller: _nameController,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[100] : Colors.grey[800],
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Full Name",
                                      hintText: "Enter your full name",
                                      prefixIcon: Icon(Icons.person_outline, color: goldAccent),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: goldAccent, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  
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
                                  SizedBox(height: 16),
                                  
                                  // PASSWORD FIELD
                                  TextField(
                                    controller: _passController,
                                    obscureText: _obscurePassword,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[100] : Colors.grey[800],
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Password",
                                      hintText: "Create a strong password",
                                      prefixIcon: Icon(Icons.lock_outlined, color: lightBlue),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                      ),
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
                                  SizedBox(height: 16),
                                  
                                  // CONFIRM PASSWORD FIELD
                                  TextField(
                                    controller: _confirmPassController,
                                    obscureText: _obscureConfirmPassword,
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[100] : Colors.grey[800],
                                    ),
                                    decoration: InputDecoration(
                                      labelText: "Confirm Password",
                                      hintText: "Re-enter your password",
                                      prefixIcon: Icon(Icons.lock_outlined, color: Colors.orange),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                          color: Colors.grey[600],
                                        ),
                                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        borderSide: BorderSide(color: Colors.orange, width: 2),
                                      ),
                                      filled: true,
                                      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.withOpacity(0.05),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  
                                  // TERMS AND CONDITIONS
                                  Row(
                                    children: [
                                      Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (value) => setState(() => _agreeToTerms = value!),
                                        activeColor: emeraldGreen,
                                      ),
                                      Expanded(
                                        child: Text(
                                          "I agree to the Terms & Conditions and Privacy Policy",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 24),
                                  
                                  // SIGNUP BUTTON
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
                                      onPressed: _loading ? null : _registerUser,
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
                                                Icon(Icons.person_add, color: Colors.white, size: 22),
                                                SizedBox(width: 8),
                                                Text(
                                                  "Create Account",
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
                                  SizedBox(height: 16),
                                  
                                  // BACK TO LOGIN
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.arrow_back, color: lightBlue, size: 18),
                                        SizedBox(width: 8),
                                        Text(
                                          "Already have an account? Sign In",
                                          style: TextStyle(
                                            color: lightBlue,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
