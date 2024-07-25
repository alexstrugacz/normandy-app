import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/direct_phone_numbers/direct_phone_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';

class DirectPhoneList extends StatefulWidget {
  const DirectPhoneList({super.key});

  @override
  DirectPhoneListState createState() => DirectPhoneListState();
}

class DirectPhoneListState extends State<DirectPhoneList> {
  String? jwt;
  String _errorMessage = '';
  List<Person> _people = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadContactsData();
  }

  Future<List<Person>> sortPeople(List<Person> newPeople) async {
    // Favorite ones first
    List<Person> favoriteContacts = [];
    List<Person> nonFavorites = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePeople =
        prefs.getStringList('directPhones') ?? [];
    print(favoritePeople);
    for (Person person in newPeople) {
      if (favoritePeople.contains(person.id)) {
        person.favorite = true;
        favoriteContacts.add(person);
      } else {
        person.favorite = false;
        nonFavorites.add(person);
      }
    }

    return favoriteContacts + nonFavorites;
  }

  Future<void> _refreshContactOrder() async {
    List<Person> sortedContacts = await sortPeople(_people);
    setState(() {
      _people = sortedContacts;
    });
  }

  Future<void> _loadContactsData() async {
    setState(() {
      _errorMessage = '';
    });
    jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      if (!mounted) return;
      Navigator.pushNamed(context, '/');
    }

    setState(() {
      _loading = true;
    });

    final response = await http.get(
        Uri.parse('https://normandy-backend.azurewebsites.net/api/microsoft-users'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt"
        });

    if (response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body)['users'];
      List<Person> sortedContacts = await sortPeople(
          data.map((item) => Person.fromJson(Map.castFrom(item))).toList());

      setState(() { 
        _people = sortedContacts;
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
        appBar: AppBar(title: const Text('Direct Phone Numbers')),
        body: Column(children: <Widget>[
          if (_errorMessage.isNotEmpty)
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ))
          else if (_loading)
            const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator())
            )
          else Expanded(
              child: RefreshIndicator(
                onRefresh: _loadContactsData,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _people.length,
                  itemBuilder: (context, index) {
                    return DirectPhoneCard(
                      key: UniqueKey(), 
                      person: _people[index], 
                      index: index,
                      onRefresh: _refreshContactOrder,
                    );
                  },
                )
                )
            )
        ]));
  }
}
