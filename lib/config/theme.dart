import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Paleta de colores de la aplicación
class AppColors {
  static const Color primary = Color(0xFFFE3C72);
  static const Color secondary = Color(0xFFFF7854);
  static const Color accent = Color(0xFFFFC107);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color background = Color(0xFF0F0F15);
  static const Color glassBg = Color.fromRGBO(255, 255, 255, 0.05);
  static const Color cardBg = Color.fromRGBO(255, 255, 255, 0.08);
}

/// Tema principal de la aplicación
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.background,
  ),
  textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  ),
  // Estilo para Inputs
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.glassBg,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide.none,
    ),
    hintStyle: TextStyle(color: AppColors.textSecondary),
    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  ),
  // Estilo para Botones
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      elevation: 0,
    ),
  ),
  // AppBar
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: AppColors.textPrimary),
    titleTextStyle: GoogleFonts.outfit(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
  ),
);
