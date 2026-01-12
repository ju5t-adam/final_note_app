import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/home_screen.dart';
import 'package:final_note_app/screens/note_edit_screen.dart';
import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:markdown_widget/widget/markdown.dart';

class NoteDetailScreen extends StatefulWidget {
  final Notes note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late Notes _note;
  final FireStoreServices _fireStoreServices = FireStoreServices();
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _note = widget.note;
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMM, yyyy HH:mm');
    return Scaffold(
      backgroundColor: AppTheme.backgroundcolor,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back),
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (context)=> HomeScreen()),
          );
        }  ),
        actions: [
          IconButton(
             icon: Icon(
              _note.ispinned ? Icons.push_pin : Icons.push_pin_outlined,
             ),
             tooltip: _note.ispinned ? 'Unpin Note' : 'Pin Note',
             onPressed: () async {
              final updateNotes = await _fireStoreServices.togglePinStatus(_note);
              setState(() {
                _note = updateNotes;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _note.ispinned ? 'Note Pinned' : 'Note Unpinned',
                  ),
                ),
              );
             },
             ),
          IconButton(onPressed: (){
            Navigator.push(context
              , MaterialPageRoute(builder: (context) => NoteEditScreen(
                note : _note,
              ),
              ),
            );
          }
          , icon: Icon(Icons.edit), color: AppTheme.backgroundcolor,),


          IconButton(
            tooltip: 'Delete Note'  ,
            onPressed: (){
             showDialog(context: context, 
             builder: (context) => 
             AlertDialog(
              title: Text('Delete Note'),
              content: Text('Are you sure you want to delete this note?'),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  }, 
                  child: Text('Cancel'),
                  ),
                TextButton(
                  onPressed: () async{
                    await _fireStoreServices.deleteNote(_note.id);
                    Navigator.push(context, 
                    MaterialPageRoute(builder: (context) => HomeScreen(),
                    ),
                    );
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _note.title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Text(
              'Last updated: ${dateFormat.format(_note.updatedAt)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),  
            const SizedBox(height: 16),
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
