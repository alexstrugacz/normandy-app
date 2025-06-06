import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/api/api_helper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    WidgetsFlutterBinding.ensureInitialized();
    _prefs = await SharedPreferences.getInstance();
    if (_prefs?.getString("email") != null) {
      _usernameController.text = (_prefs?.getString("email"))!;
    }
    if(_prefs?.getString("jwt") != null && mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  bool _loading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    if (_formKey.currentState!.validate()) {
      http.Response? response = await APIHelper.post(
        "auth/login",
        {
          'email': username,
          'password': password,
        },
        context,
        mounted,
        true
      );

      if(kDebugMode) print("Response received.");

      if ((response != null) && response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String jwt = data['token'];
        _prefs?.setString("jwt", jwt);
        _prefs?.setString("email", username);
        if (!mounted) return;
        setState(() {
          _loading = false;
          _errorMessage = '';
        });

        Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() {
          _loading = false;
          _errorMessage = 'Login failed. Please check your email and password.';
        });
      }
    } else {
        setState(() {
          _loading = false;
        });
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
                
                if (_loading)
                  const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator())
                  )
                else
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
                            style: TextStyle(fontSize: 14)))),
              ],
            ))),
      ),
    );
  }
}
