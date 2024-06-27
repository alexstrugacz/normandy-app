import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contactListTile.dart';
import 'package:normandy_app/src/business_contacts/contactsClass.dart';
import 'package:normandy_app/src/api/getJwt.dart';
import 'package:http/http.dart' as http;

class BusinessContactsList extends StatefulWidget {
  @override
  _BusinessContactsListState createState() => _BusinessContactsListState();
}

class _BusinessContactsListState extends State<BusinessContactsList> {
  String? jwt;
  String _errorMessage = '';
  List<Contact> _contacts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadContactsData();
  }

  Future<void> _loadContactsData() async {
    setState(() {
      _errorMessage = '';
    });
    jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      Navigator.pushNamed(context, '/');
    }

  
    setState(() {
      _loading = true;
    });

    final response = await http.get(
        Uri.parse('https://normandy-backend.azurewebsites.net/api/rolodex'), 
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt"
        });

    if (response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body)['rolodex'];
      setState(() {
        _contacts =
            data.map((item) => Contact.fromJson(Map.castFrom(item))).toList();
      _loading = false;
      });
    } else {
      setState(() {
        _errorMessage = 'Failed to load contacts data. Please try again later.';
      _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Business Contacts'),
        ),
        body: Column(children: <Widget>[
          if (_errorMessage.isNotEmpty)
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ))
          else if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            Column(
              children: [
                SizedBox(
                  height: (MediaQuery.of(context).size.height) -
                      56, // Appbar is 56 logical pixels tall
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      return ContactTile(
                          contact: _contacts[index], index: index);
                    },
                  ),
                ),
              ],
            )
        ]));
  }
}
