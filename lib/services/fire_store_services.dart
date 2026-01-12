import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_note_app/constants/app_constants.dart';
import 'package:final_note_app/model/notes_modle.dart';

class FireStoreServices {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notesCollection{
    return _firestore.collection(AppConstants.notescollection);
  }
Stream<List<Notes>> getNotes(){
  return _notesCollection
  .orderBy('ispinned', descending: true)
  .orderBy('updatedAt', descending: true)
  .snapshots()
  .map((snapshot) =>
   snapshot.docs.map((doc) => Notes.fromMap(doc.data())).toList());
}

Future<Notes> getNote(String id) async {
  try{ 
    final docSnapshot = await _notesCollection.doc(id).get();
    if(docSnapshot.exists){
      return Notes.fromMap(docSnapshot.data()!);
    }
    else{
      throw Exception('Note not found');} 
    }catch(e){
    rethrow;
    }
  }

  Future<Notes> addNote(
    String title,
    String content,
    String colorIndex,
    List<String> tags,
    ) async {
    try {
      final noteid = _notesCollection.doc().id;
      final now = DateTime.now();
      final newNote = Notes(
        title: title,
        content: content,
        id: noteid,
        createdAt: now,
        updatedAt: now,
        colorIndex: int.parse(colorIndex),
        tags: tags,
      );
      await _notesCollection.doc(noteid).set(newNote.toMap());
      return newNote;
    } catch (e) {
      rethrow;
    }
  }
  Future<Notes> updateNote(Notes note) async {
    try {
      final updatedNote = note.copyWith(
        updatedAt: DateTime.now(),
      );
      await _notesCollection.doc(note.id).update(updatedNote.toMap());
      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }
  Future<Notes> togglePinStatus(Notes note) async {
    try {
      final updatedNote = note.copyWith(
        ispinned: !note.ispinned,
        updatedAt: DateTime.now(),
      );
      await _notesCollection.doc(note.id).update(updatedNote.toMap());
      return updatedNote;
    } catch (e) {
      rethrow;
    }
  }
  Future<void> deleteNote(String id) async {
    try {
      await _notesCollection.doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  Stream<List<Notes>> searchNotes(String query) {
   final String searchquery = query.toLowerCase();
   return _notesCollection
      .orderBy('updatedAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => Notes.fromMap(doc.data()))
            .where((note,
            ) {
              final titleLower = note.title.toLowerCase();
              final contentLower = note.content.toLowerCase();
              return titleLower.contains(searchquery) ||
                  contentLower.contains(searchquery)|| note.tags.any((tag) => tag.toLowerCase().contains(searchquery));}).toList();
      });
  }
}