import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';

Future<List<Person>?> loadContactsData(String jwt) async {
  final response = await http.get(
      Uri.parse(
          'https://normandy-backend.azurewebsites.net/api/microsoft-users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "Authorization": "Bearer $jwt"
      });

  if (response.statusCode == 201) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> data = json.decode(response.body)['users'];
    await prefs.setString('contacts', json.encode(data));
    return data.map((item) => Person.fromJson(Map.castFrom(item))).toList();
  } else {
    return null;
  }
}