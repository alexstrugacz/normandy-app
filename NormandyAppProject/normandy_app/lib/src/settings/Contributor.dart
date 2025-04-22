
class Contributor {
  final String id;
  final String name;
  final String description;

  Contributor({required this.id, required this.name, required this.description});

  factory Contributor.fromJson(Map<String, dynamic> json) {
    return Contributor(id: json['id'], name: json['name'], description: json['description']);
  }
}