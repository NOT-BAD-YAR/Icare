import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String selected;
  final Function(String) onChanged;
  final List<String> languages;

  LanguageSelector({
    required this.selected,
    required this.onChanged,
    this.languages = const ['English', 'Hindi', 'Tamil', 'Telugu'],
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selected,
      items: languages.map((lang) {
        return DropdownMenuItem(
          value: lang,
          child: Text(lang),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
