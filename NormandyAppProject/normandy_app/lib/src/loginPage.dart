import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        print(response.statusCode);
        final Map<String, dynamic> data = jsonDecode(response.body);

        print("Data");
        print(data);

        final String jwt = data['token'];

        if (_prefs != null) {
          await _prefs!.setString('jwt', jwt);
        }

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
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _formKey,
            child: (Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png', height: 100),
                SizedBox(height: 8),
                Text(
                  'Normandy App',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome to the Normandy App.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  'Use your MS 365 Login.',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                  validator: _validatePassword,
                ),
                SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                SizedBox(height: 16),
                SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Background color
                        foregroundColor: Colors.white, // Text color
                        padding: EdgeInsets.symmetric(
                            horizontal: 32, vertical: 0), // Padding
                        textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold), // Text style
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(8), // Reduced border radius
                        ),
                      ),
                      child: Text('Log In'),
                    ))
              ],
            ))),
      ),
    );
  }
}
