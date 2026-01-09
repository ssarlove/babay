import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color palette
  static const Color primaryGreen = Color(0xFF88B04B);
  static const Color secondaryBlue = Color(0xFF92A8D1);
  static const Color alertAmber = Color(0xFFFF9F1C);
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  static const Color nightModeTint = Color(0xFFFF4444);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryBlue,
      background: backgroundLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.quicksandTextTheme(
      ThemeData.light().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primaryGreen.withOpacity(0.2),
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryGreen,
      primary: primaryGreen,
      secondary: secondaryBlue,
      background: backgroundDark,
      surface: backgroundDark,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.quicksandTextTheme(
      ThemeData.dark().textTheme.apply(bodyColor: Colors.white),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: primaryGreen.withOpacity(0.2),
    ),
  );

  // Helper methods
  static Color getEmotionColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
      case 'laughing':
        return const Color(0xFF88B04B); // Green
      case 'crying':
      case 'sad':
        return alertAmber; // Amber (not harsh red)
      case 'tired':
        return const Color(0xFF6B5B95); // Purple
      case 'neutral':
        return secondaryBlue; // Blue
      default:
        return secondaryBlue;
    }
  }

  static IconData getEmotionIcon(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Icons.sentiment_satisfied;
      case 'laughing':
        return Icons.sentiment_very_satisfied;
      case 'crying':
        return Icons.sentiment_dissatisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'tired':
        return Icons.bedtime;
      case 'neutral':
        return Icons.sentiment_neutral;
      default:
        return Icons.help_outline;
    }
  }
}