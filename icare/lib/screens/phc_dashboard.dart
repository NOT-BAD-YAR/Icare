import 'package:flutter/material.dart';

class PhcDashboard extends StatelessWidget {
  final bool darkTheme;
  final Function(bool) onThemeToggle;
  PhcDashboard({required this.darkTheme, required this.onThemeToggle});

  @override
  Widget build(BuildContext context) {
    Color accent = Colors.indigo;
    return Scaffold(
      appBar: AppBar(
        title: Text("PHC Staff Dashboard"),
        backgroundColor: accent,
        actions: [
          IconButton(
            icon: darkTheme
                ? Icon(Icons.nightlight_round, color: Colors.white)
                : Icon(Icons.wb_sunny, color: Colors.yellowAccent),
            tooltip: darkTheme ? "Switch to light mode" : "Switch to dark mode",
            onPressed: () => onThemeToggle(!darkTheme),
          ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 10,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          margin: EdgeInsets.all(36),
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.medical_services, size: 48, color: accent),
                SizedBox(height: 20),
                Text(
                  "Welcome to PHC Dashboard!",
                  style: TextStyle(
                    fontSize: 24,
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Access PHC features, reports, and visit stats here.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
