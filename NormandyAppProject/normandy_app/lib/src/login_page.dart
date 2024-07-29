import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final String apiUrl =
      "https://normandy-backend.azurewebsites.net/api/auth/login";

  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _errorMessage = '';
    });
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    if (_formKey.currentState!.validate()) {
      // TODO: Refactor to use api_helper.dart
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'email': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String jwt = data['token'];
        _prefs?.setString("jwt", jwt);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _errorMessage = 'Login failed. Please check your email and password.';
        });
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
            key: _formKey,
            child: (Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(height: 8),
                const Text(
                  'Normandy App',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
                ),
                const Text(
                  'Welcome to the Normandy App.',
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  'Use your MS 365 Login.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 32),
                TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                      labelText: 'Email',
                    ),
                    validator: _validateEmail,
                    style: const TextStyle(fontSize: 14.0)),
                const SizedBox(height: 16),
                TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Password',
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                    ),
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    validator: _validatePassword,
                    style: const TextStyle(fontSize: 14.0)),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(_errorMessage,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 14))),
                SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue, // Background color
                            foregroundColor: Colors.white, // Text color

                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 0), // Padding
                            textStyle: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold), // Text style
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Reduced border radius
                            )),
                        child: const Text("Log In",
                            style: TextStyle(fontSize: 14))))
              ],
            ))),
      ),
    );
  }
}
