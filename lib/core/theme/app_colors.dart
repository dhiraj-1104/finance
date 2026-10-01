import 'package:flutter/material.dart';

/// App color palettes for light and dark themes.
abstract final class AppColors {
  // Brand Colors (ezBookkeeping terracotta/copper palette)
  static const Color primary = Color(0xFFBA6938); // ezBookkeeping Terracotta
  static const Color primaryDark = Color(0xFFE08852); // Light terracotta
  static const Color secondary = Color(0xFFD47A43);
  static const Color accent = Color(0xFFFFB300); // Amber

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Colors.white;
  static const Color lightCard = Colors.white;
  static const Color lightTextPrimary = Color(0xFF1E293B);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightError = Color(0xFFDC2626);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF334155);
  static const Color darkError = Color(0xFFEF4444);
}
