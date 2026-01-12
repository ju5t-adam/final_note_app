import 'package:cloud_firestore/cloud_firestore.dart';

class Notes{
  final String title;
  final String content; 
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int colorIndex;
  final bool ispinned;
  final List<String> tags;

  Notes(
    {
    required this.title, 
    required this.content, 
    required this.id,
    required this.createdAt, 
    required this.updatedAt,
     this.colorIndex =  0, 
     this.ispinned = false, 
     this.tags= const [],
    });
Map<String, dynamic> toMap(){
  return {
    'title': title,
    'content': content,
    'id': id,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'colorIndex': colorIndex,
    'ispinned': ispinned,
    'tags': tags,
  };
}
factory Notes.fromMap(Map<String, dynamic> map){
  return Notes(
    title: map['title'] ?? '',
    content: map['content'] ?? '',
    id: map['id'] ?? '',
    createdAt: (map['createdAt'] as Timestamp).toDate(),
    updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    colorIndex: map['colorIndex'] ?? 0,
    ispinned: map['ispinned'] ?? false,
    tags: List<String>.from(map['tags'] ?? []),
  );
}
Notes copyWith({
  String? title,
  String? content,
  String? id,
  DateTime? createdAt,
  DateTime? updatedAt,
  int? colorIndex,
  bool? ispinned,
  List<String>? tags,
})
{
  return Notes(
    title: title ?? this.title,
    content: content ?? this.content,
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    colorIndex: colorIndex ?? this.colorIndex,
    ispinned: ispinned ?? this.ispinned,
    tags: tags ?? this.tags,
  );
}
}