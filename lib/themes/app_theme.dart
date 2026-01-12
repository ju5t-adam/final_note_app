/// Application theme configuration
///
/// This file defines the app-wide theme settings including:
/// - Color scheme (purple-based Material 3 design)
/// - Typography (Poppins font family)
/// - Component themes (AppBar, Cards, Buttons, Input fields)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppTheme class - Centralized theme configuration
///
/// Contains color constants and the complete ThemeData configuration
/// for the application's visual design
class AppTheme{

  /// Primary purple color used throughout the app
  static const Color primarycolor = Color(0xFF6750A4);

  /// Secondary white color for contrast
  static const Color secondaryycolor = Color(0xFFFFFFFF);

  /// Light purple background color
  static const Color backgroundcolor = Color(0xFFF6EDFF);

  /// Red error color for validation messages
  static const Color errorcolor = Color(0xFFB3261E);

  /// White surface color for cards and containers
  static const Color surfacecolor = Color(0xFFFFFFFF);

  /// Light theme configuration using Material 3 design
  ///
  /// Includes custom styling for:
  /// - Color scheme
  /// - AppBar with Poppins font
  /// - Text theme
  /// - Input fields with rounded borders
  /// - Elevated buttons
  /// - Cards with rounded corners
  static final ThemeData lightTheme = ThemeData(
   // Enable Material 3 design system
   useMaterial3: true,

    // Define app-wide color scheme
    colorScheme: ColorScheme.light(
      primary: primarycolor,
      secondary: secondaryycolor,
      error: errorcolor,
      surface: surfacecolor,
    ),

    // AppBar styling
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: primarycolor,
      foregroundColor: secondaryycolor,
      titleTextStyle: GoogleFonts.poppins(
        color: secondaryycolor,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),

    // Background color for all scaffolds
    scaffoldBackgroundColor: backgroundcolor,

    // Global text theme using Poppins font
    textTheme: GoogleFonts.poppinsTextTheme(),

    // Floating action button styling
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarycolor,
      foregroundColor: secondaryycolor,
    ),

    // Input field styling with rounded borders
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      // Focused state border
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primarycolor,
        ),
      ),
      // Enabled state border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),

      ),
       contentPadding: EdgeInsets.all(16),
  ),

  // Elevated button styling
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primarycolor,
      foregroundColor: secondaryycolor,
      textStyle: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    ),
  ),

  // Card styling with rounded corners and subtle shadow
  cardTheme: CardThemeData(
    surfaceTintColor: surfacecolor,
    shadowColor: Colors.grey.shade200,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  ),
  );
}