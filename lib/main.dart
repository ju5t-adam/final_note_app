/// Main entry point for the Final Note App
///
/// This application is a fully-featured note-taking app with Firebase integration
/// Features include:
/// - Create, read, update, and delete notes
/// - Pin important notes
/// - Tag-based organization
/// - Search functionality
/// - Grid and List view modes
/// - Markdown rendering support

import 'package:final_note_app/firebase_options.dart';
import 'package:final_note_app/screens/home_screen.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

/// Main function - Entry point of the application
///
/// Initializes Firebase before running the app
/// Uses async/await to ensure Firebase is properly initialized before the app starts
void main()async{
  // Ensures that Flutter binding is initialized before Firebase
  // Required when using async operations in main()
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific configuration
  // Configuration is auto-generated in firebase_options.dart
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,);

  // Launch the Flutter application
  runApp(const MyApp());
}

/// Root widget of the application
///
/// Configures the MaterialApp with custom theme and initial route
/// This is a StatelessWidget as it doesn't maintain any state
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// Builds the root MaterialApp widget
  ///
  /// Returns a MaterialApp configured with:
  /// - Custom Material 3 theme
  /// - HomeScreen as the initial route
  /// - Debug banner disabled for cleaner UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove debug banner in top-right corner
      debugShowCheckedModeBanner: false,

      // Application title shown in task switcher
      title: 'Final Note App',

      // Custom purple-themed Material 3 design
      theme: AppTheme.lightTheme,

      // Initial screen shown when app launches
      home: HomeScreen(),
    );
  }
}