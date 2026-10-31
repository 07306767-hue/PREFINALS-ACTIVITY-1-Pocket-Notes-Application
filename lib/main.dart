import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' show databaseFactory;
import 'package:sqflite_common_ffi/sqflite_ffi.dart'
    show databaseFactoryFfi, sqfliteFfiInit;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart'
    show databaseFactoryFfiWeb;

import 'book.dart';
import 'core/theme/app_theme.dart';
import 'db_helper.dart';

/// Loads the saved theme before building the app to avoid a theme flash.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Select a database implementation before the first database access.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  } else if (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Restore the saved choice before the first frame is rendered.
  final preferences = SharedPreferencesAsync();
  final isDark = await preferences.getBool('isDark') ?? false;

  runApp(_PocketNotesApp(initialIsDark: isDark, preferences: preferences));
}

/// Root app widget that applies the selected theme.
class _PocketNotesApp extends StatefulWidget {
  const _PocketNotesApp({
    required this.initialIsDark,
    required this.preferences,
  });

  final bool initialIsDark;
  final SharedPreferencesAsync preferences;

  @override
  State<_PocketNotesApp> createState() => _PocketNotesAppState();
}

class _PocketNotesAppState extends State<_PocketNotesApp> {
  late bool _isDark = widget.initialIsDark;

  /// Saves the theme selection before applying it.
  Future<void> _setDarkMode(bool isDark) async {
    try {
      await widget.preferences.setBool('isDark', isDark);
      if (!mounted) return;

      setState(() {
        _isDark = isDark;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save theme setting: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Notes: Books',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: _BooksScreen(isDark: _isDark, onThemeChanged: _setDarkMode),
    );
  }
}

/// Displays books from SQLite and provides add, edit, and delete actions.
class _BooksScreen extends StatefulWidget {
  const _BooksScreen({required this.isDark, required this.onThemeChanged});

  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<_BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<_BooksScreen> {
  List<Book> _books = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  /// Loads the current rows from the books table.
  Future<void> _loadBooks() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final books = await DBHelper.instance.getBooks();
      if (!mounted) return;
      setState(() {
        _books = books;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = 'Could not load books: $error';
        _isLoading = false;
      });
    }
  }

  /// Opens the add/edit form and writes the result to SQLite.
  Future<void> _editBook([Book? book]) async {
    final editedBook = await showDialog<Book>(
      context: context,
      builder: (context) => _BookDialog(book: book),
    );
    if (editedBook == null || !mounted) return;

    try {
      if (editedBook.id == null) {
        await DBHelper.instance.insertBook(editedBook);
      } else {
        await DBHelper.instance.updateBook(editedBook);
      }
      await _loadBooks();
    } catch (error) {
      _showError('Could not save book: $error');
    }
  }

  /// Confirms and removes a book from SQLite.
  Future<void> _deleteBook(Book book) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete book?'),
        content: Text('Delete "${book.title}" from your books?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete != true || book.id == null || !mounted) return;

    try {
      await DBHelper.instance.deleteBook(book.id!);
      await _loadBooks();
    } catch (error) {
      _showError('Could not delete book: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pocket Notes: Books'),
        actions: [
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Center(child: Text('Dark')),
          ),
          Semantics(
            label: 'Toggle dark mode',
            child: Switch(
              value: widget.isDark,
              onChanged: widget.onThemeChanged,
            ),
          ),
        ],
      ),
      body: _buildBookList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editBook(),
        tooltip: 'Add book',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBookList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final loadError = _loadError;
    if (loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loadError, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _loadBooks, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (_books.isEmpty) {
      return const Center(child: Text('No books yet. Tap + to add one.'));
    }

    return ListView.separated(
      itemCount: _books.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final book = _books[index];
        return ListTile(
          title: Text(book.title),
          subtitle: Text(book.author),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _editBook(book),
                tooltip: 'Edit ${book.title}',
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                onPressed: () => _deleteBook(book),
                tooltip: 'Delete ${book.title}',
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Validated form dialog used for creating and editing books.
class _BookDialog extends StatefulWidget {
  const _BookDialog({this.book});

  final Book? book;

  @override
  State<_BookDialog> createState() => _BookDialogState();
}

class _BookDialogState extends State<_BookDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _authorController = TextEditingController(text: widget.book?.author ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      Book(
        id: widget.book?.id,
        title: _titleController.text.trim(),
        author: _authorController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? 'Add book' : 'Edit book'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
              textCapitalization: TextCapitalization.sentences,
              validator: _requiredValidator,
            ),
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(labelText: 'Author'),
              textCapitalization: TextCapitalization.words,
              validator: _requiredValidator,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }
}
