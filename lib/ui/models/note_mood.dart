import 'package:flutter/material.dart';

class NoteMood {
  final String name;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  final String fontFamily;

  const NoteMood({
    required this.name,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    required this.fontFamily,
  });

  static List<NoteMood> moods = [
    const NoteMood(
      name: 'Modern',
      primaryColor: Color(0xFF0F0F12),
      secondaryColor: Color(0xFF1A1A1F),
      accentColor: Colors.deepPurpleAccent,
      fontFamily: 'Outfit',
    ),
    const NoteMood(
      name: 'Calm',
      primaryColor: Color(0xFFE8F5E9),
      secondaryColor: Color(0xFFC8E6C9),
      accentColor: Colors.green,
      fontFamily: 'Georgia',
    ),
    const NoteMood(
      name: 'Creative',
      primaryColor: Color(0xFFFFF3E0),
      secondaryColor: Color(0xFFFFE0B2),
      accentColor: Colors.orangeAccent,
      fontFamily: 'Courier',
    ),
    const NoteMood(
      name: 'Cyber',
      primaryColor: Color(0xFF000000),
      secondaryColor: Color(0xFF0D0D0D),
      accentColor: Colors.cyanAccent,
      fontFamily: 'RobotoMono',
    ),
  ];

  static NoteMood getMood(String? name) {
    return moods.firstWhere((m) => m.name == name, orElse: () => moods[0]);
  }
}
