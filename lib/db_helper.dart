import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'book.dart';

/// Provides the single shared SQLite connection and book database operations.
class DBHelper {
  DBHelper._();

  /// The app-wide database helper instance.
  static final DBHelper instance = DBHelper._();

  static const String _databaseName = 'pocket_notes.db';
  static const String _tableName = 'books';
  static const int _databaseVersion = 1;

  Database? _database;
  Future<Database>? _openingDatabase;

  /// Returns the shared database, opening it only on the first request.
  ///
  /// Caching the opening future also prevents simultaneous first requests from
  /// creating more than one database connection.
  Future<Database> get database async {
    final existingDatabase = _database;
    if (existingDatabase != null) return existingDatabase;

    final openingDatabase = _openingDatabase ??= _openDatabase();
    final openedDatabase = await openingDatabase;
    _database = openedDatabase;
    return openedDatabase;
  }

  /// Opens the SQLite file and creates its table for a new database.
  Future<Database> _openDatabase() async {
    final databasesDirectory = await getDatabasesPath();
    final databasePath = join(databasesDirectory, _databaseName);

    return openDatabase(
      databasePath,
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            author TEXT
          )
        ''');
      },
    );
  }

  /// Inserts a book and returns the new row's auto-incremented ID.
  Future<int> insertBook(Book book) async {
    final db = await database;
    final values = book.toMap()..remove('id');
    return db.insert(_tableName, values);
  }

  /// Retrieves all stored books as [Book] objects.
  Future<List<Book>> getBooks() async {
    final db = await database;
    final rows = await db.query(_tableName);
    // ignore: avoid_print
    print(rows);
    return rows.map(Book.fromMap).toList();
  }

  /// Updates the stored book and returns the number of rows changed.
  ///
  /// Throws [ArgumentError] if [book] has no database ID.
  Future<int> updateBook(Book book) async {
    final id = book.id;
    if (id == null) {
      throw ArgumentError.value(book.id, 'book.id', 'Book must have an ID');
    }

    final db = await database;
    final values = book.toMap()..remove('id');
    return db.update(_tableName, values, where: 'id = ?', whereArgs: [id]);
  }

  /// Deletes a book by ID and returns the number of rows deleted.
  Future<int> deleteBook(int id) async {
    final db = await database;
    return db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  /// Prints all book rows to the console for debugging.
  Future<void> debugPrintBooks() async {
    final db = await database;
    // ignore: avoid_print
    print(await db.query(_tableName));
  }
}
