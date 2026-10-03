import 'package:flutter/material.dart';

class AppColorScheme {
  final String id;
  final String name;
  final String description;
  final Color primary;
  final Color primaryVariant;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color cardBorder;
  final Color onPrimary;

  const AppColorScheme({
    required this.id,
    required this.name,
    required this.description,
    required this.primary,
    required this.primaryVariant,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.cardBorder,
    this.onPrimary = Colors.black,
  });

  static const List<AppColorScheme> all = [
    AppColorScheme(
      id: 'cyber_mint',
      name: 'Cyber Mint',
      description: 'Signature neon mint green & deep obsidian',
      primary: Color(0xFF00FFA3),
      primaryVariant: Color(0xFF00D287),
      secondary: Color(0xFF00B0FF),
      background: Color(0xFF080C14),
      surface: Color(0xFF111824),
      cardBorder: Color(0xFF1A2637),
      onPrimary: Colors.black,
    ),
    AppColorScheme(
      id: 'electric_cobalt',
      name: 'Electric Cobalt',
      description: 'High-tech cyan blue & deep naval shadow',
      primary: Color(0xFF00B0FF),
      primaryVariant: Color(0xFF0081CB),
      secondary: Color(0xFF00FFA3),
      background: Color(0xFF060D17),
      surface: Color(0xFF0E1826),
      cardBorder: Color(0xFF17293E),
      onPrimary: Colors.black,
    ),
    AppColorScheme(
      id: 'crimson_titan',
      name: 'Crimson Titan',
      description: 'Maximum adrenaline scarlet red & volcanic ember',
      primary: Color(0xFFFF2A55),
      primaryVariant: Color(0xFFD50032),
      secondary: Color(0xFFFF9100),
      background: Color(0xFF0F070A),
      surface: Color(0xFF1A0F14),
      cardBorder: Color(0xFF2C1620),
      onPrimary: Colors.white,
    ),
    AppColorScheme(
      id: 'solar_amber',
      name: 'Solar Amber',
      description: 'Championship gold & midnight carbon',
      primary: Color(0xFFFFD600),
      primaryVariant: Color(0xFFFFAB00),
      secondary: Color(0xFFFF6D00),
      background: Color(0xFF0E0C06),
      surface: Color(0xFF1A170E),
      cardBorder: Color(0xFF2C2616),
      onPrimary: Colors.black,
    ),
    AppColorScheme(
      id: 'neon_violet',
      name: 'Neon Violet',
      description: 'Cyberpunk synthwave violet & dark matrix',
      primary: Color(0xFFA855F7),
      primaryVariant: Color(0xFF7C3AED),
      secondary: Color(0xFFEC4899),
      background: Color(0xFF0C0714),
      surface: Color(0xFF170E24),
      cardBorder: Color(0xFF291840),
      onPrimary: Colors.white,
    ),
    AppColorScheme(
      id: 'lava_blaze',
      name: 'Lava Blaze',
      description: 'Volcanic magma orange & basalt dark',
      primary: Color(0xFFFF6B00),
      primaryVariant: Color(0xFFDD5300),
      secondary: Color(0xFFFFD600),
      background: Color(0xFF0E0805),
      surface: Color(0xFF1B110A),
      cardBorder: Color(0xFF2E1C12),
      onPrimary: Colors.black,
    ),
  ];

  static AppColorScheme get defaultScheme => all.first;

  static AppColorScheme fromId(String id) {
    return all.firstWhere((s) => s.id == id, orElse: () => defaultScheme);
  }
}
