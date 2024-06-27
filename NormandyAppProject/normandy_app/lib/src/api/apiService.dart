import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/business_contacts/contactsClass.dart';

class ApiService {
  final String baseUrl;
  final String authToken;

  ApiService({required this.baseUrl, required this.authToken});

  Future<List<Contact>> fetchContacts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/rolodex'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['rolodex'];
      return data.map((item) => Contact.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load contacts');
    }
    
  }
}
