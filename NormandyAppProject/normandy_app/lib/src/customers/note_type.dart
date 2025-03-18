class Note {
  final String content;
  final Author author;
  final String postTime;

  Note({
    required this.content,
    required this.author,
    required this.postTime,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      content: json['content'] ?? 'Blank note',
      author: Author.fromJson(json['author']),
      postTime: json['postTime'],
    );
  }
}

class Author {
  final String displayName;
  final String occupation;

  Author({
    required this.displayName,
    required this.occupation,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      displayName: json['displayName'] ?? 'Unknown',
      occupation: json['occupation'] ?? 'Unknown',
    );
  }
}
