/// Screen for viewing note details
///
/// This screen displays the full content of a note with:
/// - Full title and content (with markdown rendering)
/// - Last updated timestamp
/// - Tags display
/// - Pin/unpin functionality
/// - Edit and delete options

import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/home_screen.dart';
import 'package:final_note_app/screens/note_edit_screen.dart';
import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/widget/markdown.dart';

/// NoteDetailScreen widget - Screen for viewing note details
///
/// A StatefulWidget that displays full note information
/// Allows editing, deleting, and toggling pin status
class NoteDetailScreen extends StatefulWidget {
  /// The note to display
  final Notes note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

/// State class for NoteDetailScreen
///
/// Manages the note state and provides actions like pin toggle and delete
class _NoteDetailScreenState extends State<NoteDetailScreen> {
  /// Current note being displayed (can be updated when toggling pin)
  late Notes _note;

  /// Service instance for Firestore operations
  final FireStoreServices _fireStoreServices = FireStoreServices();

  /// Initializes the state with the provided note
  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  /// Builds the UI for the note detail screen
  ///
  /// Returns a Scaffold with:
  /// - AppBar with back, pin, edit, and delete buttons
  /// - Scrollable content showing title, timestamp, tags, and markdown content
  @override
  Widget build(BuildContext context) {
    // Date formatter for displaying last updated timestamp
    final DateFormat dateFormat = DateFormat('dd MMM, yyyy HH:mm');
    return Scaffold(
      backgroundColor: AppTheme.backgroundcolor,
      appBar: AppBar(
        elevation: 0,
        // Back button to return to home screen
        leading: IconButton(icon: const Icon(Icons.arrow_back),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()),
          );
        }  ),
        actions: [
          // Pin/Unpin button
          IconButton(
             icon: Icon(
              _note.ispinned ? Icons.push_pin : Icons.push_pin_outlined,
             ),
             tooltip: _note.ispinned ? 'Unpin Note' : 'Pin Note',
             onPressed: () async {
              // Toggle pin status in Firestore
              final updateNotes = await _fireStoreServices.togglePinStatus(_note);
              // Update local state with new note data
              setState(() {
                _note = updateNotes;
              });
              // Show confirmation message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _note.ispinned ? 'Note Pinned' : 'Note Unpinned',
                  ),
                ),
              );
             },
             ),
          // Edit button to navigate to edit screen
          IconButton(onPressed: (){
            Navigator.push(context
              , MaterialPageRoute(builder: (context) => NoteEditScreen(
                note : _note,
              ),
              ),
            );
          }
          , icon: Icon(Icons.edit), color: AppTheme.backgroundcolor,),

          // Delete button with confirmation dialog
          IconButton(
            tooltip: 'Delete Note'  ,
            onPressed: (){
             // Show confirmation dialog before deleting
             showDialog(context: context,
             builder: (context) =>
             AlertDialog(
              title: Text('Delete Note'),
              content: Text('Are you sure you want to delete this note?'),
              actions: [
                // Cancel button
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text('Cancel'),
                  ),
                // Delete button
                TextButton(
                  onPressed: () async{
                    // Delete note from Firestore
                    await _fireStoreServices.deleteNote(_note.id);
                    // Navigate back to home screen
                    Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomeScreen(),
                    ),
                    );
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Note deleted successfully')),
                    );
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red),),
                  ),
              ],
             )
             );
            },
            icon: Icon(Icons.delete),
            ),
        ],
      ),
      // Scrollable content area
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Note title
            Text(
              _note.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Last updated timestamp
            Text(
              'Last updated: ${dateFormat.format(_note.updatedAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Display tags if any exist
            if(_note.tags.isNotEmpty)...[
              Wrap(
                spacing: 8,
                children: _note.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    backgroundColor: Colors.blue.shade100,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Render note content as markdown
            MarkdownWidget(
              data: _note.content,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
          ],
        ),
      ),
    );
  }
}
