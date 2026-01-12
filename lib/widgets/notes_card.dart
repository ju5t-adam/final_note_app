import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/note_details_screen.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';


class NotesCard extends StatelessWidget {
  final Notes note;
  final bool isListView;
  final Function()? onDelete;
  final Function()? onTogglePin;

  const NotesCard({
    super.key,
    required this.note,
    this.isListView = false,
    this.onDelete,
    this.onTogglePin,
  });

  @override
  Widget build(BuildContext context) {
    final dateformat = DateFormat('dd MMM, yyyy HH:mm');
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_){
              onTogglePin?.call();
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: note.ispinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.ispinned ? 'Unpin' : 'Pin',
          ),
          SlidableAction(onPressed: (_){
            onDelete?.call();
          },
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: note.ispinned ? 4 : 1,
        color: AppTheme.backgroundcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side:
              note.ispinned ? const BorderSide(color: Colors.amber, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
            );
          },
          borderRadius: BorderRadius.all(Radius.circular(12)),
          child: Padding(padding:  EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                    note.title,
                    style: 
                    TextStyle(
                      fontSize: isListView ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if(note.ispinned)
                  Icon(Icons.push_pin, color: Colors.amber, size: 18,),

                ],
              ),
             
              Text(note.content,
              style: TextStyle(fontSize: 14,color: Colors.grey[700], ),
              maxLines: isListView ? 1 : 4,
              overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12,),
              if(note.tags.isNotEmpty)...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: note.tags.take(isListView ? 1 : 3).map((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 12,),
                        ),
                      );
                    
                  }).toList(),
                ),
                SizedBox(height: 8),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    dateformat.format(note.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}