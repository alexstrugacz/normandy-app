import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:normandy_app/src/settings/Contributor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:normandy_app/src/api/api_helper.dart';

import '../components/list_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class NormandyAppContributers extends StatefulWidget {
  const NormandyAppContributers({super.key});

  @override
  ContributersState createState() => ContributersState();
}

class ContributersState extends State<NormandyAppContributers> {
  @override
  void initState() {
    super.initState();
    _getContributors();
  }

  bool _loading = false;
  String _errorMessage = '';
  List<dynamic> allContributors = [];

  Future<void> _getContributors() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });
    final prefs = await SharedPreferences.getInstance();

    final URL = Uri.parse("http://localhost:4000/api/contributors");
    final response = await http.get(URL, headers: {
      'Authorization':
          'Bearer ${prefs.getString("jwt")}',
      'Content-Type': 'application/json'
    });

    if (response.statusCode == 200) {
      final decodedData = jsonDecode(response.body);
      allContributors = List.from(decodedData['contributors']);
    } else {
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load contributors';
      });
      return;
    }

    setState(() {
      _loading = false;
      _errorMessage = '';
    });
  } 

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(child: CircularProgressIndicator()));
    }

    if (_errorMessage != "") {
      return Text(_errorMessage);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Normandy App Contributers'),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16), 
            child: Column( 
              children: [
              Text("These contributors helped create the Normandy App and website.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color.fromRGBO(0, 0, 0, 0.6), fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              ListView.builder(
                itemCount: allContributors.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      SizedBox(height: 3),
                      ListCard(
                      text: allContributors[index]["name"],
                      description: allContributors[index]["description"],
                      image: allContributors[index]["imageURL"]),
                      SizedBox(height: 3)
                    ],
                  );
                },
              )
            ]
            )
          )
        );
  }
}  


