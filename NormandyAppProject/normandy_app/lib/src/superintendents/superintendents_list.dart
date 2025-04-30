import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/direct_phone_numbers/direct_phone_list.dart';
import 'package:normandy_app/src/superintendents/superintendent_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';
import 'package:normandy_app/src/load_contacts.dart';

class SuperintendentsList extends StatefulWidget {
  const SuperintendentsList({super.key});

  @override
  SuperintendentsListState createState() => SuperintendentsListState();
}

class SuperintendentsListState extends State<SuperintendentsList> {
  String? jwt;
  String _errorMessage = '';
  List<Person> _people = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadContactsData().then((_) {
      // wait for contacts to load before opening search delegate
      if (_people.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSearch(context: context, delegate: CustomPersonSearchDelegate(contacts: _people));
        });
      }
    });
  }

  Future<List<Person>> sortPeople(List<Person> newPeople) async {
    // Favorite ones first
    List<Person> favoriteSuperintendents = [];
    List<Person> nonFavorites = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePeople = prefs.getStringList('superintendents') ?? [];
    for (Person person in newPeople) {
      if (favoritePeople.contains(person.id)) {
        person.favorite = true;
        favoriteSuperintendents.add(person);
      } else {
        person.favorite = false;
        nonFavorites.add(person);
      }
    }

    return favoriteSuperintendents + nonFavorites;
  }

  Future<void> _refreshContactOrder() async {
    List<Person> sortedContacts = await sortPeople(_people);
    setState(() {
      _people = sortedContacts;
    });
  }

  Future<void> _loadContactsData() async {
    setState(() {
      _loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final cached = await prefs.getString('contacts');
    if (cached != null) {
      List<dynamic> data = json.decode(cached);
      List<Person> parsed = await sortPeople(data
          .map((item) => Person.fromJson(Map.castFrom(item)))
          .where((person) => person.jobTitle == 'Superintendent')
          .toList());
      setState(() {
        _people = parsed;
        _loading = false;
      });
    }

    setState(() {
      _errorMessage = '';
    });
    jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      if (!mounted) return;
      Navigator.pushNamed(context, '/');
    }

    final contacts = await loadContactsData(jwt!);

    if (contacts != null) {
      List<Person> sortedContacts = await sortPeople(contacts
          .where((person) => person.jobTitle == 'Superintendent')
          .toList());

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

  List<String> _getSearchTerms() {
    return _people.map((contact) => contact.searchTerm).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Superintendents'), actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                    context: context,
                    delegate: CustomPersonSearchDelegate(contacts: _people));
                _refreshContactOrder();
              },
              icon: const Icon(Icons.search))
        ]),
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
                child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
                child: RefreshIndicator(
                    onRefresh: _loadContactsData,
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: _people.length,
                        itemBuilder: (context, index) {
                          return SuperintendentCard(
                            key: UniqueKey(),
                            person: _people[index],
                            index: index,
                            onRefresh: _refreshContactOrder,
                          );
                        })))
        ]));
  }
}
