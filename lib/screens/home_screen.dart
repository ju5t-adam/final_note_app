/// Home screen of the note-taking application
///
/// This is the main screen that displays all notes with features including:
/// - Grid and List view modes
/// - Search functionality
/// - Real-time updates from Firestore
/// - Pin/unpin notes
/// - Delete notes
/// - Navigation to add new notes

import 'package:final_note_app/constants/app_constants.dart';
import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/addnote_screen.dart';
import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:final_note_app/widgets/notes_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// HomeScreen widget - Main screen displaying all notes
///
/// A StatefulWidget that manages the display of notes in either grid or list view
/// Includes real-time search and filtering capabilities
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State class for HomeScreen
///
/// Manages:
/// - View mode switching (grid/list)
/// - Search functionality
/// - Real-time note streaming from Firestore
class _HomeScreenState extends State<HomeScreen> {
  /// Instance of Firestore service for database operations
  final FireStoreServices _fireStoreServices = FireStoreServices();

  /// Current view mode (grid or list)
  /// Default is grid view mode
  int _viewMode = AppConstants.gridviewMode;

  /// Flag indicating whether search mode is active
  bool _isSearching = false;

  /// Controller for the search text field
  final TextEditingController _searchController = TextEditingController();

  /// List of all notes from Firestore (unfiltered)
  List<Notes> _notes = [];

  /// List of notes filtered by search query
  List<Notes> _filteredNotes = [];

/// Stream providing real-time updates of notes from Firestore
  Stream<List<Notes>>? _notesStream;

  /// Initializes the state and sets up the notes stream
  ///
  /// Called once when the widget is first created
  /// Sets up the real-time listener to Firestore notes collection
  @override
  void initState(){
    super.initState();
    // Initialize the stream to listen for note changes
    _notesStream = _fireStoreServices.getNotes();
  }

  /// Toggles between grid view and list view modes
  ///
  /// Switches the view mode and triggers a rebuild to reflect the change
  void _toggleViewMode(){
    setState(() {
      _viewMode = _viewMode == AppConstants.gridviewMode
      ? AppConstants.listviewMode
      : AppConstants.gridviewMode;
    });
  }

  /// Applies search filtering to the notes list
  ///
  /// Performs case-insensitive search across note titles, content, and tags
  ///
  /// Parameters:
  /// - [query]: The search string entered by the user
  void _applySearch(String query){
    // Activate search mode if not already active
    if (!_isSearching) {
      setState(() {
        _isSearching = true;
      });
    }

    // If query is empty, show all notes
    if(query.isEmpty){
      setState(() {
        _filteredNotes = _notes;
      });
    }
    // Otherwise, filter notes based on query
    else{
      final searchquery = query.toLowerCase();
      setState(() {
        // Filter notes by checking title, content, and tags
        _filteredNotes = _notes.where((note) {
          final titleLower = note.title.toLowerCase();
          final contentLower = note.content.toLowerCase();
          // Match query against title, content, or any tag
          return titleLower.contains(searchquery) ||
          contentLower.contains(searchquery) ||
          note.tags.any(
            (tag) => tag.toLowerCase().contains(searchquery)
          );
        }).toList();
      });
    }
  }

  /// Clears the search and returns to normal view
  ///
  /// Resets the search controller, filtered list, and search mode flag
  void _clearSearch(){
    setState(() {
      _searchController.clear();
      _filteredNotes = [];
      _isSearching = false;
    });
  }

  /// Builds the main UI for the home screen
  ///
  /// Returns a Scaffold containing:
  /// - AppBar with search and view mode toggle
  /// - StreamBuilder showing notes in grid or list view
  /// - FloatingActionButton to add new notes
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Show search AppBar when searching, otherwise show normal AppBar
      appBar: _isSearching? _buildSearchAppBar() :
      AppBar(
        // Empty leading widget to center the title
        leading: SizedBox(),
        title: const Text('Final Note App'),
        actions: [
          // Search button to activate search mode
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){
              setState(() {
                _isSearching = true;
              });
            },
          ),
          // Toggle between grid and list view
          IconButton(
            icon: Icon(
              _viewMode == AppConstants.gridviewMode
              ? Icons.view_list
              : Icons.grid_view,
            ),
            onPressed: _toggleViewMode,
          ),
        ],
      ),

      // StreamBuilder listens to real-time updates from Firestore
      body: StreamBuilder<List<Notes>>(
        stream: _notesStream,
        builder: (context, snapshot){
          // Show loading indicator while waiting for data
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(color: AppTheme.primarycolor,));
          }
          // Show error message if something went wrong
          if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Show empty state when no notes exist
          if (!snapshot.hasData || snapshot.data!.isEmpty){
            return  Center(child:
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_add_outlined, size: 80, color: Colors.grey.shade700,),
                SizedBox(height: 16,),
                Text('No notes available. Add some notes!', style: TextStyle(fontSize: 16, color: Colors.grey),),
              ],
            ),
            );
          }
          // Update the notes list with fresh data
          _notes = snapshot.data!;
          // Determine which notes to display (filtered or all)
          final displayNotes = _isSearching ? _filteredNotes : _notes;

          // Build the appropriate view based on current mode
          return _viewMode == AppConstants.gridviewMode
          ? _buigridGridView(displayNotes)
          : _buildListView(displayNotes);
        },
      ),
      // Button to navigate to add note screen
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => AddnoteScreen(),
            ));
        },
        child: const Icon(Icons.add),
        backgroundColor: AppTheme.primarycolor,
      ),
    );
  }
/// Builds the grid view layout for notes
  ///
  /// Uses MasonryGridView for a Pinterest-style staggered grid
  /// where cards can have different heights
  ///
  /// Parameters:
  /// - [notes]: List of notes to display
  ///
  /// Returns: A padded MasonryGridView widget
  Widget _buigridGridView (List<Notes> notes){
    return Padding(
      padding: EdgeInsets.all(8),
      child: MasonryGridView.count(
      // Two columns in the grid
      crossAxisCount: 2,
      // Spacing between rows
      mainAxisSpacing: 8,
      // Spacing between columns
      crossAxisSpacing: 8,
      itemCount: notes.length,
       itemBuilder: (context, index){
        return NotesCard(
          note: notes[index],
          // Callback to delete the note
          onDelete: () async{
            await _fireStoreServices.deleteNote(notes[index].id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Note deleted successfully')),
            );
          },
          // Callback to toggle pin status
          onTogglePin: ()async{
            await _fireStoreServices.togglePinStatus(notes[index]);
          },
          // Flag indicating this is grid view mode
          isListView: false,
        );
       },
    ),
    );
  }

  /// Builds the list view layout for notes
  ///
  /// Displays notes in a vertical scrollable list
  /// Each note card takes the full width
  ///
  /// Parameters:
  /// - [notes]: List of notes to display
  ///
  /// Returns: A ListView.builder widget
  Widget _buildListView (List<Notes> notes){
    return ListView.builder(
      padding: EdgeInsets.all(8),
      itemCount: notes.length,
      itemBuilder: (context, index){
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: NotesCard(
            note: notes[index],
            // Callback to delete the note
            onDelete: ()async{
              await _fireStoreServices.deleteNote(notes[index].id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Note deleted successfully')),
              );
            },
            // Callback to toggle pin status
            onTogglePin: ()async{
              await _fireStoreServices.togglePinStatus(notes[index]);
            },
          ),
        );
      },
    );
  }

  /// Builds the search mode AppBar
  ///
  /// Replaces the normal AppBar when search is active
  /// Contains a TextField for entering search queries
  /// and a clear button to exit search mode
  ///
  /// Returns: AppBar configured for search
  PreferredSizeWidget _buildSearchAppBar(){
    return AppBar(
      title: TextField(
        controller: _searchController,
        // Auto-focus when search mode activates
        autofocus: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(13),
          hintText: 'Search notes...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
          prefixIcon: Icon( Icons.search, color: Colors.white70,)
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        // Call search function as user types
        onChanged: _applySearch,
        cursorColor: Colors.white,
      ),
      actions: [
        // Button to clear search and exit search mode
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSearch
        ),
      ],
    );
  }

  /// Cleanup method called when widget is removed
  ///
  /// Disposes of the search controller to prevent memory leaks
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}