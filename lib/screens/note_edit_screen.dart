import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/note_details_screen.dart';
import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class NoteEditScreen extends StatefulWidget {
  final Notes note;
  const NoteEditScreen({super.key, required this.note});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final FireStoreServices _fireStoreServices = FireStoreServices();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _tagsController;
  late List<String> _tags;
  late bool _isLoading = false;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _tagsController = TextEditingController();
    _tags = List.from(widget.note.tags);
  }

  void _addTag(){
    final tag = _tagsController.text.trim();
    if(tag.isNotEmpty && !_tags.contains(tag)){
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag){
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _saveNote() async {
    if(_formKey.currentState!.validate()){
      setState(() {
        _isLoading = true;
      });
      try{
       final updatedNote = widget.note.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          tags: _tags,
        );
        await _fireStoreServices.updateNote(updatedNote);
        if (mounted) {
 Navigator.push(context, MaterialPageRoute(builder: (context) => NoteDetailScreen(note: updatedNote)));
}
      } catch (e){
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundcolor,
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: AppTheme.primarycolor,),)
      :SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //title
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
              //content
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

              //tags
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

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}