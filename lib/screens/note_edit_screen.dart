/// Screen for editing an existing note
///
/// This screen provides a form interface for users to edit notes with:
/// - Pre-filled title and content from existing note
/// - Tag management (add/remove tags)
/// - Save functionality with validation
/// - Navigation back to detail screen after save

import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/note_details_screen.dart';
import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';

/// NoteEditScreen widget - Screen for editing existing notes
///
/// A StatefulWidget that manages the form state for editing notes
class NoteEditScreen extends StatefulWidget {
  /// The note to edit
  final Notes note;

  const NoteEditScreen({super.key, required this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

/// State class for NoteEditScreen
///
/// Manages form validation, text input, tags, and update operations
class _NoteEditScreenState extends State<NoteEditScreen> {
  /// Service instance for Firestore operations
  final FireStoreServices _fireStoreServices = FireStoreServices();

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controller for the title input field (initialized with existing title)
  late TextEditingController _titleController;

  /// Controller for the content input field (initialized with existing content)
  late TextEditingController _contentController;

  /// Controller for the tag input field
  late TextEditingController _tagsController;

  /// List of tags for the note (initialized with existing tags)
  late List<String> _tags;

  /// Flag indicating whether a save operation is in progress
  late bool _isLoading = false;

  /// Initializes controllers with existing note data
  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing note data
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _tagsController = TextEditingController();
    // Create a mutable copy of the tags list
    _tags = List.from(widget.note.tags);
  }

  /// Adds a new tag to the note
  ///
  /// Validates that the tag is not empty and doesn't already exist
  /// Clears the tag input field after adding
  void _addTag(){
    final tag = _tagsController.text.trim();
    // Only add if tag is not empty and not already in the list
    if(tag.isNotEmpty && !_tags.contains(tag)){
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  /// Removes a tag from the note
  ///
  /// Parameters:
  /// - [tag]: The tag string to remove
  void _removeTag(String tag){
    setState(() {
      _tags.remove(tag);
    });
  }

  /// Saves the updated note to Firestore
  ///
  /// Validates the form, then updates the note with the modified data
  /// Shows loading indicator during save and navigates to detail screen on success
  /// Displays error message if save fails
  Future<void> _saveNote() async {
    // Validate form inputs
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      try{
        // Create updated note with new values
       final updatedNote = widget.note.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          tags: _tags,
        );
        // Update the note in Firestore
        await _fireStoreServices.updateNote(updatedNote);
        // Only navigate if widget is still mounted
        if (mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailScreen(note: updatedNote)));
        }
      } catch (e){
        // Show error message if save fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving note: $e')),
        );
      } finally{
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  /// Builds the UI for the edit note screen
  ///
  /// Returns a Scaffold with:
  /// - AppBar with save button
  /// - Form with pre-filled title, content, and tags fields
  /// - Loading indicator during save operation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundcolor,
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          // Save button - disabled during loading
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      // Show loading indicator while saving, otherwise show form
      body: _isLoading ? Center(child: CircularProgressIndicator(color: AppTheme.primarycolor,),)
      :SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title input field with validation
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Content input field with validation
              TextFormField(
                controller: _contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                validator: (value){
                  if(value == null || value.isEmpty){
                    return 'Please enter content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Display existing tags as removable chips
              if(_tags.isNotEmpty)...[
                Wrap(
                  spacing: 8,
                  children: _tags.map((tag) {
                     return Chip(
                    label: Text(tag),
                    deleteIcon: Icon(Icons.close),
                    onDeleted: () => _removeTag(tag),
                  );
                  }).toList(),
                ),
              ]
              ,SizedBox(height: 16),

              // Tag input field with add button
              TextFormField(
                controller: _tagsController,
                decoration: InputDecoration(
                  labelText: 'Add Tag',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addTag,
                  ),
                ),
              ),
              SizedBox(height: 8),
            ],
          ),
        ),
      )
    );
  }

  /// Cleanup method called when widget is removed
  ///
  /// Disposes of all text controllers to prevent memory leaks
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}