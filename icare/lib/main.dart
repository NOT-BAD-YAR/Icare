import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/login_screen.dart';
import 'screens/asha_dashboard.dart';
import 'screens/phc_dashboard.dart';

final Color magenta = Color(0xFFD500A3);  // Vibrant magenta
final Color magentaLight = Color(0xFFFF82EA); // Light magenta accent

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: magenta,
  primarySwatch: Colors.pink,
  colorScheme: ColorScheme.light(
    primary: magenta,
    surface: Colors.white,
    background: Color(0xFFFDF2FB),
    secondary: magentaLight,
  ),
  scaffoldBackgroundColor: Color(0xFFFDF2FB),
  cardColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.pink.shade50,
    filled: true,
    labelStyle: TextStyle(color: magenta),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  ),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: magenta,
  primarySwatch: Colors.pink,
  colorScheme: ColorScheme.dark(
    primary: magenta,
    surface: Color(0xFF2B1936),
    background: Color(0xFF14001A),
    secondary: magentaLight,
  ),
  scaffoldBackgroundColor: Color(0xFF14001A),
  cardColor: Color(0xFF221124),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Color(0xFF25122D),
    filled: true,
    labelStyle: TextStyle(color: Colors.white),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: magenta,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(IcareApp());
}

class IcareApp extends StatefulWidget {
  @override
  State<IcareApp> createState() => _IcareAppState();
}

class _IcareAppState extends State<IcareApp> {
  bool _darkTheme = false;

  void _toggleTheme(bool value) {
    setState(() {
      _darkTheme = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ICare',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _darkTheme ? ThemeMode.dark : ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // For future: check user role from Firestore for routing!
            return AshaDashboard(darkTheme: _darkTheme, onThemeToggle: _toggleTheme); // or PhcDashboard
          }
          return LoginScreen(darkTheme: _darkTheme, onThemeToggle: _toggleTheme);
        },
      ),
    );
  }
}
