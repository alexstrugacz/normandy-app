import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class APIHelper {
  static String baseUrl = "https://normandy-backend.azurewebsites.net/api/";

  // Only uncomment this in development, and ensure your NormandyBackend copy is running on Port 4000
  // static String baseUrl = "http://localhost:4000/api/";

  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(base64.normalize(parts[1]))));
      final expiry = payload['exp'];
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now >= expiry;
    } catch (_) {
      return true;
    }
  }

  static Future<http.Response?> get(
      String url, BuildContext context, bool mounted) async {
    String? jwt = await getJwt();
    if (jwt == null || isTokenExpired(jwt)) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('jwt');
      // Redirect to the login page
      if (context.mounted) {
        Navigator.pushNamed(context, '/');
      } else {
        return null;
      }
    }

    final response =
        await http.get(Uri.parse(baseUrl + url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "Bearer $jwt",
    });

    return response;
  }

  static Future<http.Response?> post(
      String url, Map<String, dynamic> body, BuildContext context, bool mounted,
      [bool? overrideJWT]) async {
    if (overrideJWT != true) {
      String? jwt = await getJwt();
      if (jwt == null || isTokenExpired(jwt)) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.remove('jwt');
        // Redirect to the login page
        if (context.mounted) {
          Navigator.pushNamed(context, '/');
        } else {
          return null;
        }
      }

      final response = await http.post(Uri.parse(baseUrl + url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            "Authorization": "Bearer $jwt"
          },
          body: jsonEncode(body));
      return response;
    } else {
      final response = await http.post(Uri.parse(baseUrl + url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(body));
      return response;
    }
  }

  static Future<http.Response?> put(String url, Map<String, dynamic> body,
      BuildContext context, bool mounted) async {
    String? jwt = await getJwt();
    if (jwt == null || isTokenExpired(jwt)) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('jwt');
      // Redirect to the login page
      if (context.mounted) {
        Navigator.pushNamed(context, '/');
      } else {
        return null;
      }
    }

    final response = await http.put(Uri.parse(baseUrl + url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt"
        },
        body: jsonEncode(body));
    return response;
  }

  static Future<http.Response?> delete(
      String url, BuildContext context, bool mounted) async {
    String? jwt = await getJwt();
    if (jwt == null || isTokenExpired(jwt)) {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('jwt');
      // Redirect to the login page
      if (context.mounted) {
        Navigator.pushNamed(context, '/');
      } else {
        return null;
      }
    }

    final response =
        await http.delete(Uri.parse(baseUrl + url), headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      "Authorization": "Bearer $jwt"
    });
    return response;
  }
}
