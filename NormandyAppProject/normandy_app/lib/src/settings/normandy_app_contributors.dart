import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/list_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NormandyAppContributors extends StatefulWidget {
  const NormandyAppContributors({super.key});

  @override
  ContributorsState createState() => ContributorsState();
}

class ContributorsState extends State<NormandyAppContributors> {
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

    final URL = Uri.parse("https://normandy-backend.azurewebsites.net/api/contributors");
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

    if (_errorMessage != "") {
      return Text(_errorMessage);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Contributors'),
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16), 
            child: Column( 
              children: [
              Text("These contributors helped create the Normandy App and web app.", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Color.fromRGBO(0, 0, 0, 0.6), fontWeight: FontWeight.bold)),
              SizedBox(height: 3),
              _loading ? (
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Center(child: CircularProgressIndicator()))
              ) : (
                SingleChildScrollView(
                child: ListView.builder(
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
              ),
              )
              )
            ]
            )
          )
        );
  }
}  


