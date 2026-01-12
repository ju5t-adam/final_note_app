import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme{

  static const Color primarycolor = Color(0xFF6750A4);
  static const Color secondaryycolor = Color(0xFFFFFFFF);
  static const Color backgroundcolor = Color(0xFFF6EDFF);
  static const Color errorcolor = Color(0xFFB3261E);
  static const Color surfacecolor = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
   useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: primarycolor,
      secondary: secondaryycolor,
      error: errorcolor,
      surface: surfacecolor,
    ),
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
    scaffoldBackgroundColor: backgroundcolor,
    textTheme: GoogleFonts.poppinsTextTheme(),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primarycolor,
      foregroundColor: secondaryycolor, 
    ),  
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: primarycolor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
       
      ),
       contentPadding: EdgeInsets.all(16),
  ),
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
  cardTheme: CardThemeData(
    surfaceTintColor: surfacecolor,
    shadowColor: Colors.grey.shade200,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  ),  
  );
}