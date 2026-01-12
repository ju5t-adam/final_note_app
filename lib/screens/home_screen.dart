import 'package:final_note_app/constants/app_constants.dart';
import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/addnote_screen.dart';
import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:final_note_app/widgets/notes_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FireStoreServices _fireStoreServices = FireStoreServices();
  int _viewMode = AppConstants.gridviewMode;
  bool _isSearching = false;
  
  final TextEditingController _searchController = TextEditingController();
  List<Notes> _notes = [];
  List<Notes> _filteredNotes = [];

Stream<List<Notes>>? _notesStream;
@override
void initState(){
  super.initState();
  _notesStream = _fireStoreServices.getNotes();
}
void _toggleViewMode(){
  setState(() {
    _viewMode = _viewMode == AppConstants.gridviewMode
    ? AppConstants.listviewMode
    : AppConstants.gridviewMode;
  });
}


void _applySearch(String query){
  if (!_isSearching) {
    setState(() {
      _isSearching = true;
    });
  }

  if(query.isEmpty){
    setState(() {
      _filteredNotes = _notes;
    });
}
  else{
    final searchquery = query.toLowerCase();
    setState(() {
      _filteredNotes = _notes.where((note) {
        final titleLower = note.title.toLowerCase();
        final contentLower = note.content.toLowerCase();
        return titleLower.contains(searchquery) ||
        contentLower.contains(searchquery) ||
        note.tags.any(
          (tag) => tag.toLowerCase().contains(searchquery)
        );
      }).toList();
    });
  }
}

void _clearSearch(){
  setState(() {
    _searchController.clear();
  _filteredNotes = [];
  _isSearching = false;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSearching? _buildSearchAppBar() : 
      AppBar(
        leading: SizedBox(),
        title: const Text('Final Note App'),
        actions: [
            IconButton(
            icon: const Icon(Icons.search),
            onPressed: (){
              setState(() {
                _isSearching = true;
              });
            },
            ),
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

      body: StreamBuilder<List<Notes>>(
        stream: _notesStream,
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(child: CircularProgressIndicator(color: AppTheme.primarycolor,));
          }
          if(snapshot.hasError){
            return Center(child: Text('Error: ${snapshot.error}'));
          }
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
          _notes = snapshot.data!;
          final displayNotes = _isSearching ? _filteredNotes : _notes;
          
          return _viewMode == AppConstants.gridviewMode
          ? _buigridGridView(displayNotes)
          : _buildListView(displayNotes);
        },
      ),
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
Widget _buigridGridView (List<Notes> notes){
  return Padding(
    padding: EdgeInsets.all(8),
    child: MasonryGridView.count(
    crossAxisCount: 2,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    itemCount: notes.length,
     itemBuilder: (context, index){
      return NotesCard(
        note: notes[index],
      onDelete: () async{
        await _fireStoreServices.deleteNote(notes[index].id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note deleted successfully')),
        );
      },
      onTogglePin: ()async{
        await _fireStoreServices.togglePinStatus(notes[index]);
      },
       isListView: false,);
     },
  ),
  );
}
Widget _buildListView (List<Notes> notes){
  return ListView.builder(
    padding: EdgeInsets.all(8),
    itemCount: notes.length,
    itemBuilder: (context, index){
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: NotesCard(
          note: notes[index],
          onDelete: ()async{
            await _fireStoreServices.deleteNote(notes[index].id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Note deleted successfully')),
            );
          },  
          onTogglePin: ()async{
            await _fireStoreServices.togglePinStatus(notes[index]);
          },
        ),
      );
    },
  
  );
}

  PreferredSizeWidget _buildSearchAppBar(){
    return AppBar(
      title: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(13),
          hintText: 'Search notes...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
          prefixIcon: Icon( Icons.search, color: Colors.white70,)
        ),
        style: const TextStyle(color: Colors.white, fontSize: 16),
        onChanged: _applySearch,
        cursorColor: Colors.white,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: _clearSearch
        ),
      ],
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _searchController.dispose();
    super.dispose();
  }
}