import 'package:flutter/material.dart';

import '../../domain/models/note.dart';

class NoteCard extends StatelessWidget {
  const NoteCard({
    super.key,
    required this.note,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(note.title),
        subtitle: note.body.isEmpty ? null : Text(note.body, maxLines: 3),
        isThreeLine: note.body.isNotEmpty,
        trailing: IconButton(
          onPressed: onDelete,
          tooltip: 'Delete note',
          icon: const Icon(Icons.delete_outline),
        ),
      ),
    );
  }
}
