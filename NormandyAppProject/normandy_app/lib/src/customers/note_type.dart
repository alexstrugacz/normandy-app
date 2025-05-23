import 'package:intl/intl.dart';

class Note {
  final String content;
  final Author author;
  final String postTime;

  Note({
    required this.content,
    required this.author,
    required this.postTime,
  });

  factory Note.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Note(
        content: 'Blank note',
        author: Author(displayName: 'Unknown', occupation: 'Unknown'),
        postTime: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      );
    }
    return Note(
      content: json['content'] ?? 'Blank note',
      author: Author.fromJson(json['author'] as Map<String, dynamic>?),
      postTime: _validateDate(json['postTime']),
    );
  }

  static String _validateDate(String? date) {
    if (date == null || date.isEmpty) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
    try {
      DateTime.parse(date);
      return date;
    } catch (e) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }
}

class Author {
  final String displayName;
  final String occupation;

  Author({
    required this.displayName,
    required this.occupation,
  });

  factory Author.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Author(
        displayName: 'Unknown',
        occupation: 'Unknown',
      );
    }
    return Author(
      displayName: json['displayName'] ?? 'Unknown',
      occupation: json['occupation'] ?? 'Unknown',
    );
  }
}
