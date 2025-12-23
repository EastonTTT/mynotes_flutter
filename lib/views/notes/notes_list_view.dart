import 'package:flutter/material.dart';
import 'package:mynotes/services/cloud/cloud_note.dart';
// import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/utils/dialogs/delete_dialog.dart';

// typedef NoteCallback = void Function(DatabaseNote note);
typedef NoteCallback = void Function(CloudNote note);

class NotesListView extends StatelessWidget {
  final Iterable<CloudNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes.elementAt(index);
        return ListTile(
          title: Text(
            note.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            onPressed: () async {
              final shouDelete = await showDeleteDialog(context);
              if (shouDelete) {
                onDeleteNote(note);
              }
            },
            icon: Icon(Icons.delete),
          ),
          onTap: () {
            onTap(note);
          },
        );
      },
    );
  }
}
