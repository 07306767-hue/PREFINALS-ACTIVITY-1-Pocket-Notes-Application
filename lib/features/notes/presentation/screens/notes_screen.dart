import 'package:flutter/material.dart';

import '../../data/repositories/notes_repository.dart';
import '../../domain/models/note.dart';
import '../widgets/note_card.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({
    super.key,
    this.repository,
    this.isDark = false,
    this.onToggleTheme,
  });

  final NotesRepository? repository;
  final bool isDark;
  final VoidCallback? onToggleTheme;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final NotesRepository _repository;
  late List<Note> _notes;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? InMemoryNotesRepository();
    _notes = _repository.getAll();
  }

  Future<void> _createNote() async {
    final input = await showDialog<(String, String)>(
      context: context,
      builder: (context) => const _CreateNoteDialog(),
    );

    if (!mounted || input == null) return;

    setState(() {
      _repository.add(title: input.$1, body: input.$2);
      _notes = _repository.getAll();
    });
  }

  void _deleteNote(Note note) {
    setState(() {
      _repository.deleteById(note.id);
      _notes = _repository.getAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Notes'),
        actions: [
          if (widget.onToggleTheme != null)
            IconButton(
              onPressed: widget.onToggleTheme,
              tooltip: widget.isDark
                  ? 'Switch to light mode'
                  : 'Switch to dark mode',
              icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            ),
        ],
      ),
      body: _notes.isEmpty
          ? const _EmptyNotes()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final note = _notes[index];
                return NoteCard(note: note, onDelete: () => _deleteNote(note));
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNote,
        tooltip: 'Create note',
        icon: const Icon(Icons.add),
        label: const Text('New note'),
      ),
    );
  }
}

class _CreateNoteDialog extends StatefulWidget {
  const _CreateNoteDialog();

  @override
  State<_CreateNoteDialog> createState() => _CreateNoteDialogState();
}

class _CreateNoteDialogState extends State<_CreateNoteDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              key: const Key('note-title'),
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter a title'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('note-body'),
              controller: _bodyController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Write a note'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.of(
              context,
            ).pop((_titleController.text.trim(), _bodyController.text.trim()));
          },
          child: const Text('Save note'),
        ),
      ],
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sticky_note_2_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text('No notes yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Tap New note to save your first thought.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
