import 'package:final_note_app/services/fire_store_services.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';

class AddnoteScreen extends StatefulWidget {
  const AddnoteScreen({super.key});

  @override
  State<AddnoteScreen> createState() => _AddnoteScreenState();
}

class _AddnoteScreenState extends State<AddnoteScreen> {
  final FireStoreServices _fireStoreServices = FireStoreServices();
  final _formKey = GlobalKey<FormState>();
  final _TitleController = TextEditingController();
  final _ContentController = TextEditingController();
  final _tagsController = TextEditingController();
  bool _isLoading = false;
  List<String> _tags = [];
  int _selectedColorIndex = 0;

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
        await _fireStoreServices.addNote(
           _TitleController.text,
           _ContentController.text,
           _selectedColorIndex.toString(),
          _tags,
        );
        if (mounted) {
 Navigator.pop(context);
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
        title: const Text('Add Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveNote,
          ),
        ],
      ),

      body: _isLoading ? Center(child: CircularProgressIndicator(color: AppTheme.backgroundcolor,))
      : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onFieldSubmitted: (value) => _addTag(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ],
             ),
            const SizedBox(height: 16),
            
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

  @override
  void dispose() {
    _TitleController.dispose();
    _ContentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}