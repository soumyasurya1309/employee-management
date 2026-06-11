import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color accentEnd = Color(0xFF3B82F6);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  // ── DARK THEME ──────────────────────────────────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentEnd,
      error: errorColor,
      surface: Color(0xFF161D35),
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1020),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0B1020),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF161D35),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1C2545),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide:
            const BorderSide(color: Color(0x14FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0x14FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      hintStyle: const TextStyle(color: Color(0xFF6B7280)),
      errorStyle: const TextStyle(color: errorColor, fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle:
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF1C2545),
      contentTextStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerColor: const Color(0x14FFFFFF),
    iconTheme: const IconThemeData(color: Color(0xFF9CA3AF)),
  );

  // ── LIGHT THEME ─────────────────────────────────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
      primary: primaryColor,
      secondary: accentEnd,
      error: errorColor,
      surface: const Color(0xFFF4F6FB),
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFFF4F6FB),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFFF4F6FB),
      foregroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: const Color(0xFF1A1A2E),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFF6B7280)),
      hintStyle: const TextStyle(color: Color(0xFFADB5BD)),
      errorStyle: const TextStyle(color: errorColor, fontSize: 11),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
        textStyle:
            GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Color(0xFF1A1A2E),
      contentTextStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    dividerColor: const Color(0xFFE5E7EB),
    iconTheme: const IconThemeData(color: Color(0xFF6B7280)),
  );
}

class AppConstants {
  static const List<String> departments = [
    'Engineering',
    'Product',
    'Design',
    'Marketing',
    'Sales',
    'HR',
    'Finance',
    'Operations',
    'Legal',
    'Customer Support',
  ];

  static const List<String> designations = [
    'Intern',
    'Junior Developer',
    'Developer',
    'Senior Developer',
    'Lead Developer',
    'Manager',
    'Senior Manager',
    'Director',
    'VP',
    'C-Suite',
  ];
}

class AppValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final regex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Enter a valid email address';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Phone number must be exactly 10 digits';
    }
    return null;
  }

  static String? validateSalary(String? value) {
    if (value == null || value.trim().isEmpty) return 'Salary is required';
    final parsed = double.tryParse(value.trim());
    if (parsed == null) return 'Salary must be a valid number';
    if (parsed <= 0) return 'Salary must be greater than 0';
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }
}

String formatCurrency(double amount) {
  return '\$${amount.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}