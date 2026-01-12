/// Reusable widget for displaying a note card
///
/// This widget displays a note in either grid or list view format with:
/// - Note title, content preview, and timestamp
/// - Tag display (limited based on view mode)
/// - Swipe actions for pin/unpin and delete
/// - Visual indicator for pinned notes
/// - Tap to view full note details

import 'package:final_note_app/model/notes_modle.dart';
import 'package:final_note_app/screens/note_details_screen.dart';
import 'package:final_note_app/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

/// NotesCard widget - Displays a single note as a card
///
/// A stateless widget that adapts its layout based on grid or list view mode
/// Supports swipe gestures for quick actions
class NotesCard extends StatelessWidget {
  /// The note data to display
  final Notes note;

  /// Whether the card is being displayed in list view (affects layout)
  final bool isListView;

  /// Callback function to execute when delete action is triggered
  final Function()? onDelete;

  /// Callback function to execute when pin toggle action is triggered
  final Function()? onTogglePin;

  /// Constructor with required note parameter
  ///
  /// Parameters:
  /// - [note]: The note to display (required)
  /// - [isListView]: Display mode flag (default: false for grid view)
  /// - [onDelete]: Callback for delete action
  /// - [onTogglePin]: Callback for pin toggle action
  const NotesCard({
    super.key,
    required this.note,
    this.isListView = false,
    this.onDelete,
    this.onTogglePin,
  });

  /// Builds the note card widget
  ///
  /// Returns a Slidable card with:
  /// - Swipe actions for pin/unpin and delete
  /// - Visual distinction for pinned notes
  /// - Tap to navigate to detail screen
  /// - Responsive layout based on view mode
  @override
  Widget build(BuildContext context) {
    // Date formatter for displaying last updated time
    final dateformat = DateFormat('dd MMM, yyyy HH:mm');
    return Slidable(
      // Swipe actions appear on the right side
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          // Pin/Unpin action
          SlidableAction(
            onPressed: (_){
              onTogglePin?.call();
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: note.ispinned ? Icons.push_pin : Icons.push_pin_outlined,
            label: note.ispinned ? 'Unpin' : 'Pin',
          ),
          // Delete action
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
      // Main card content
      child: Card(
        // Pinned notes have higher elevation
        elevation: note.ispinned ? 4 : 1,
        color: AppTheme.backgroundcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // Pinned notes have amber border
          side:
              note.ispinned ? const BorderSide(color: Colors.amber, width: 2) : BorderSide.none,
        ),
        child: InkWell(
          // Navigate to detail screen on tap
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
              // Title row with pin indicator
              Row(
                children: [
                  Expanded(
                    child: Text(
                    note.title,
                    style:
                    TextStyle(
                      // Larger font in grid view
                      fontSize: isListView ? 18 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Show pin icon for pinned notes
                  if(note.ispinned)
                  Icon(Icons.push_pin, color: Colors.amber, size: 18,),

                ],
              ),

              // Content preview
              Text(note.content,
              style: TextStyle(fontSize: 14,color: Colors.grey[700], ),
              // Show more lines in grid view
              maxLines: isListView ? 1 : 4,
              overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 12,),

              // Tags display (limited by view mode)
              if(note.tags.isNotEmpty)...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  // Show 1 tag in list view, up to 3 in grid view
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

              // Last updated timestamp at bottom right
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