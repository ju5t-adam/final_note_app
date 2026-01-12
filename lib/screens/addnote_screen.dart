/// Screen for creating a new note
///
/// This screen provides a form interface for users to create new notes with:
/// - Title input
/// - Content input with markdown support
/// - Tag management (add/remove tags)
/// - Save functionality with validation

import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';

/// AddnoteScreen widget - Screen for creating new notes
///
/// A StatefulWidget that manages the form state for creating notes
class AddnoteScreen extends StatefulWidget {
  const AddnoteScreen({super.key});

  @override
  State<AddnoteScreen> createState() => _AddnoteScreenState();
}

/// State class for AddnoteScreen
///
/// Manages form validation, text input, tags, and save operations
class _AddnoteScreenState extends State<AddnoteScreen> {
  /// Service instance for Firestore operations
  final FireStoreServices _fireStoreServices = FireStoreServices();

  /// Form key for validation
  final _formKey = GlobalKey<FormState>();

  /// Controller for the title input field
  final _TitleController = TextEditingController();

  /// Controller for the content input field
  final _ContentController = TextEditingController();

  /// Controller for the tag input field
  final _tagsController = TextEditingController();

  /// Flag indicating whether a save operation is in progress
  bool _isLoading = false;

  /// List of tags added to the note
  List<String> _tags = [];

  /// Currently selected color index for the note (currently unused in UI)
  int _selectedColorIndex = 0;

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

  /// Saves the new note to Firestore
  ///
  /// Validates the form, then creates a new note with the provided data
  /// Shows loading indicator during save and navigates back on success
  /// Displays error message if save fails
  Future<void> _saveNote() async {
    // Validate form inputs
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      try{
        // Create the note in Firestore
        await _fireStoreServices.addNote(
           _TitleController.text,
           _ContentController.text,
           _selectedColorIndex.toString(),
          _tags,
        );
        // Only navigate if widget is still mounted
        if (mounted) {
          Navigator.pop(context);
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

  /// Builds the UI for the add note screen
  ///
  /// Returns a Scaffold with:
  /// - AppBar with save button
  /// - Form with title, tags, and content fields
  /// - Loading indicator during save operation
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundcolor,
      appBar: AppBar(
        title: const Text('Add Note'),
        actions: [
          // Save button - disabled during loading
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),

      // Show loading indicator while saving, otherwise show form
      body: _isLoading ? Center(child: CircularProgressIndicator(color: AppTheme.backgroundcolor,))
      : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input field with validation
            TextFormField(
              controller: _TitleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
                filled: true
              ),
              style: Theme.of(context).textTheme.headlineSmall,
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Display added tags as chips
            if(_tags.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                  deleteIcon: Icon(Icons.close, size: 18,),
                );
              }).toList(),
             ),
            const SizedBox(height: 16),

            // Tag input field with add button
             Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Add Tag',
                      border: OutlineInputBorder(),
                      filled: true,
                      prefixIcon: Icon(Icons.tag),
                    ),
                    // Add tag when Enter key is pressed
                    onFieldSubmitted: (value) => _addTag(),
                  ),
                ),
                // Add button
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
             ),
            const SizedBox(height: 16),

            // Content input field with validation
            // Multiline with minimum 10 lines
            TextFormField(
              controller: _ContentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                border: OutlineInputBorder(),
                filled: true
              ),
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: null,
              minLines: 10,
              validator: (value){
                if(value == null || value.isEmpty){
                  return 'Please enter content';
                }
                return null;
              },
            ),
          ],
        ),
        ),
      ),

    );
  }

  /// Cleanup method called when widget is removed
  ///
  /// Disposes of all text controllers to prevent memory leaks
  @override
  void dispose() {
    _TitleController.dispose();
    _ContentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}