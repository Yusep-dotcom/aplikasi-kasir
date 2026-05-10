import 'package:flutter/material.dart';

class AppTheme {
  // Warna utama aplikasi kasir — merah bata
  // Dipakai di navbar, tombol utama, header
  static const Color primary = Color(0xFF7D2A2A);
  static const Color primaryDark = Color.fromARGB(255, 0, 0, 0);
  static const Color primaryLight = Color.fromARGB(255, 255, 255, 255);

  // Warna teks
  static const Color textPrimary = Color(0xFF2C2C2A);
  static const Color textSecondary = Color(0xFF999999);

  // Warna background
  static const Color bgMain = Color(0xFFF5F2EE);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFFAF8F6);

  // Warna border
  static const Color border = Color(0xFFE8E4DF);

  // Warna status
  static const Color success = Color(0xFF1D9E75);
  static const Color warning = Color(0xFFF0A500);
  static const Color error = Color(0xFFC0392B);
  static const Color info = Color(0xFF2563EB);

  // Theme lengkap untuk GetMaterialApp
  static ThemeData get theme => ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: bgMain,
    fontFamily: 'Segoe UI',
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary),
    appBarTheme: const AppBarTheme(
      backgroundColor: bgCard,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    cardTheme: CardThemeData(
      color: bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
    ),
  );
}
