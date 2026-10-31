/// Represents one book stored by Pocket Notes.
class Book {
  /// Creates a book. The database assigns [id] when it is first inserted.
  const Book({this.id, required this.title, required this.author});

  /// The database ID, or `null` before the book has been inserted.
  final int? id;

  /// The book's title.
  final String title;

  /// The book's author.
  final String author;

  /// Converts this book to the column-name/value format used by SQLite.
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'author': author};
  }

  /// Creates a book from a row returned by SQLite.
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] as int?,
      title: map['title'] as String,
      author: map['author'] as String,
    );
  }

  /// Creates a copy, keeping the current value for each omitted field.
  Book copyWith({int? id, String? title, String? author}) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
    );
  }
}
