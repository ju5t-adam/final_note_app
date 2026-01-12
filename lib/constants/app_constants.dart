/// Application-wide constants
///
/// This file defines constant values used throughout the application
/// to maintain consistency and avoid magic numbers/strings

/// AppConstants class - Container for application constants
///
/// All constants are static and can be accessed without instantiation
/// Example: AppConstants.notescollection
class AppConstants {
  /// Firestore collection name for notes
  ///
  /// Used to reference the Notes collection in Firebase Firestore
  static const String notescollection = 'Notes';

  /// Constant representing grid view display mode
  ///
  /// Value: 0
  /// Used in HomeScreen to determine current view mode
  static const int gridviewMode = 0;

  /// Constant representing list view display mode
  ///
  /// Value: 1
  /// Used in HomeScreen to determine current view mode
  static const int listviewMode = 1;
}