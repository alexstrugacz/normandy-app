import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';

Future<List<Person>?> loadContactsData(String jwt, BuildContext context, bool mounted) async {
  final response = await APIHelper.get('microsoft-users', context, mounted);

  if (response != null && response.statusCode == 201) {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<dynamic> data = json.decode(response.body)['users'];
    await prefs.setString('contacts', json.encode(data));
    return data.map((item) => Person.fromJson(Map.castFrom(item))).toList();
  } else {
    return null;
  }
}