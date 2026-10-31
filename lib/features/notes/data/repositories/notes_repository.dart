import '../../domain/models/note.dart';

abstract interface class NotesRepository {
  List<Note> getAll();

  Note add({required String title, required String body});

  void deleteById(int id);
}

class InMemoryNotesRepository implements NotesRepository {
  final List<Note> _notes = [];
  int _nextId = 0;

  @override
  List<Note> getAll() => List.unmodifiable(_notes);

  @override
  Note add({required String title, required String body}) {
    final note = Note(id: _nextId++, title: title, body: body);
    _notes.insert(0, note);
    return note;
  }

  @override
  void deleteById(int id) {
    _notes.removeWhere((note) => note.id == id);
  }
}
