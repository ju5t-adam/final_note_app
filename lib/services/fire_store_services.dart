/// Firebase Firestore service layer for note operations
///
/// This service class handles all database operations for notes including:
/// - CRUD operations (Create, Read, Update, Delete)
/// - Real-time streaming of notes
/// - Search functionality
/// - Pin/unpin operations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_note_app/constants/app_constants.dart';
import 'package:final_note_app/model/notes_modle.dart';

/// Service class that manages all Firestore operations for notes
///
/// This class follows the repository pattern to abstract database operations
/// from the UI layer, making the code more maintainable and testable
class FireStoreServices {
  /// Private instance of FirebaseFirestore for database access
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Getter for the notes collection reference
  ///
  /// Returns a typed CollectionReference pointing to the 'Notes' collection
  /// Used internally by all methods to access the notes database
  CollectionReference<Map<String, dynamic>> get _notesCollection{
    return _firestore.collection(AppConstants.notescollection);
  }
/// Retrieves all notes as a real-time stream
  ///
  /// Returns a Stream that emits a new list of notes whenever the database changes
  /// Notes are ordered by:
  /// 1. Pin status (pinned notes first)
  /// 2. Last update time (most recent first)
  ///
  /// This allows the UI to automatically update when notes are added, modified, or deleted
  Stream<List<Notes>> getNotes(){
    return _notesCollection
    // First sort by pin status (pinned notes appear first)
    .orderBy('ispinned', descending: true)
    // Then sort by update time (most recent first)
    .orderBy('updatedAt', descending: true)
    // Listen to real-time changes
    .snapshots()
    // Transform Firestore snapshots into Notes objects
    .map((snapshot) =>
     snapshot.docs.map((doc) => Notes.fromMap(doc.data())).toList());
  }

  /// Retrieves a single note by its ID
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the note to retrieve
  ///
  /// Returns: A Future that resolves to the requested Notes object
  /// Throws: Exception if the note is not found or if there's a database error
  Future<Notes> getNote(String id) async {
    try{
      // Fetch the document from Firestore
      final docSnapshot = await _notesCollection.doc(id).get();

      // Check if the document exists in the database
      if(docSnapshot.exists){
        // Convert Firestore document to Notes object
        return Notes.fromMap(docSnapshot.data()!);
      }
      else{
        // Throw exception if note doesn't exist
        throw Exception('Note not found');
      }
    }catch(e){
      // Re-throw any errors to be handled by the caller
      rethrow;
    }
  }

  /// Creates and saves a new note to Firestore
  ///
  /// Parameters:
  /// - [title]: The title of the new note
  /// - [content]: The content/body of the new note
  /// - [colorIndex]: String representation of the color index (will be parsed to int)
  /// - [tags]: List of tags for organizing the note
  ///
  /// Returns: The newly created Notes object with generated ID and timestamps
  /// Throws: Any exception that occurs during the save operation
  Future<Notes> addNote(
    String title,
    String content,
    String colorIndex,
    List<String> tags,
    ) async {
    try {
      // Generate a unique ID for the new note
      final noteid = _notesCollection.doc().id;

      // Use current time for both created and updated timestamps
      final now = DateTime.now();

      // Create a new Notes object with the provided data
      final newNote = Notes(
        title: title,
        content: content,
        id: noteid,
        createdAt: now,
        updatedAt: now,
        colorIndex: int.parse(colorIndex),
        tags: tags,
      );

      // Save the note to Firestore
      await _notesCollection.doc(noteid).set(newNote.toMap());

      // Return the created note
      return newNote;
    } catch (e) {
      rethrow;
    }
  }

  /// Updates an existing note in Firestore
  ///
  /// Automatically updates the 'updatedAt' timestamp to the current time
  ///
  /// Parameters:
  /// - [note]: The Notes object containing the updated information
  ///
  /// Returns: The updated Notes object with the new timestamp
  /// Throws: Any exception that occurs during the update operation
  Future<Notes> updateNote(Notes note) async {
    try {
      // Create a copy of the note with updated timestamp
      final updatedNote = note.copyWith(
        updatedAt: DateTime.now(),
      );

      // Update the document in Firestore
      await _notesCollection.doc(note.id).update(updatedNote.toMap());

      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }

  /// Toggles the pin status of a note (pinned ↔ unpinned)
  ///
  /// Pinned notes appear at the top of the notes list
  /// Also updates the 'updatedAt' timestamp
  ///
  /// Parameters:
  /// - [note]: The note whose pin status should be toggled
  ///
  /// Returns: The updated Notes object with toggled pin status
  /// Throws: Any exception that occurs during the update operation
  Future<Notes> togglePinStatus(Notes note) async {
    try {
      // Create a copy with inverted pin status and new timestamp
      final updatedNote = note.copyWith(
        ispinned: !note.ispinned,
        updatedAt: DateTime.now(),
      );

      // Update the document in Firestore
      await _notesCollection.doc(note.id).update(updatedNote.toMap());

      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }

  /// Permanently deletes a note from Firestore
  ///
  /// Parameters:
  /// - [id]: The unique identifier of the note to delete
  ///
  /// Returns: A Future that completes when the deletion is finished
  /// Throws: Any exception that occurs during the delete operation
  Future<void> deleteNote(String id) async {
    try {
      // Remove the document from Firestore
      await _notesCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Searches notes by query string (currently unused in the app)
  ///
  /// Searches through note titles, content, and tags for matches
  /// This method performs client-side filtering since Firestore doesn't
  /// support full-text search natively
  ///
  /// Parameters:
  /// - [query]: The search string to match against notes
  ///
  /// Returns: A Stream of filtered notes matching the search query
  ///
  /// Note: The app currently uses client-side search in HomeScreen instead
  Stream<List<Notes>> searchNotes(String query) {
   // Convert query to lowercase for case-insensitive search
   final String searchquery = query.toLowerCase();

   return _notesCollection
      // Order by most recently updated
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        // Filter notes on the client side
        return snapshot.docs
            .map((doc) => Notes.fromMap(doc.data()))
            .where((note,
            ) {
              // Convert note fields to lowercase for comparison
              final titleLower = note.title.toLowerCase();
              final contentLower = note.content.toLowerCase();

              // Check if query matches title, content, or any tag
              return titleLower.contains(searchquery) ||
                  contentLower.contains(searchquery)||
                  note.tags.any((tag) => tag.toLowerCase().contains(searchquery));
            }).toList();
      });
  }
}