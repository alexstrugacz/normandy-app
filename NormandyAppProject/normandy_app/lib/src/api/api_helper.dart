import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;


class APIHelper {
  // static String baseUrl = "https://normandy-backend.azurewebsites.net/api/";
  static String baseUrl = "http://localhost:4000/api/";

  static Future<http.Response?> get(String url, BuildContext context, bool mounted) async {
    String? jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      if (mounted) {
        Navigator.pushNamed(context, '/');
      } else {
        return null;
      }
    }

    final response = await http.get(
        Uri.parse(baseUrl + url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt",
        }
      );
      
    return response;
  }

  static Future<http.Response?> post(String url, Map<String, dynamic> body, BuildContext context, bool mounted) async {
    String? jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      if (mounted) { 
        Navigator.pushNamed(context, '/');
      } else {
        return null;
      }
    }

    final response = await http.post(
        Uri.parse(baseUrl + url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt"
        },
        body: jsonEncode(body)
      );
    return response;
  }

  static Future<http.Response?> delete(String url, BuildContext context, bool mounted) async {
    String? jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      if (mounted) {
        Navigator.pushNamed(context, '/');
      } else {
        return null;
      }
    }

    final response = await http.delete(
        Uri.parse(baseUrl + url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt"
        });
    return response;
  }
}