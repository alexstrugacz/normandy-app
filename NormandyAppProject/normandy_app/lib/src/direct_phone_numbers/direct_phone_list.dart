import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:normandy_app/src/direct_phone_numbers/direct_phone_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';
import 'package:normandy_app/src/load_contacts.dart';

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
    List<Person> favoriteContacts = [];
    List<Person> nonFavorites = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoritePeople = prefs.getStringList('directPhones') ?? [];
    for (Person person in newPeople) {
      if (favoritePeople.contains(person.id)) {
        person.favorite = true;
        favoriteContacts.add(person);
      } else {
        person.favorite = false;
        nonFavorites.add(person);
      }
    }

    int compar(Person a, Person b) {
      var res = a.firstName.compareTo(b.firstName);
      if (res == 0) {
        res = a.lastName.compareTo(b.lastName);
      }
      return res;
    }

    favoriteContacts.sort(compar);
    nonFavorites.sort(compar);
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
      _loading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.remove('contacts');
    final cached = await prefs.getString('contacts');
    if (cached != null) {
      List<dynamic> data = json.decode(cached);
      List<Person> parsed = await sortPeople(
          data.map((item) => Person.fromJson(Map.castFrom(item))).toList());
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

    List<Person>? contacts = await loadContactsData(jwt!, context, mounted);
    if (contacts != null) {
      List<Person> sortedContacts = await sortPeople(contacts);

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
        appBar: AppBar(title: const Text('Direct Phone Numbers'), actions: [
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
                        return DirectPhoneCard(
                          key: UniqueKey(),
                          person: _people[index],
                          index: index,
                          onRefresh: _refreshContactOrder,
                        );
                      },
                    )))
        ]));
  }
}

class CustomPersonSearchDelegate extends SearchDelegate {
  List<Person> contacts;
  @override
  CustomPersonSearchDelegate({required this.contacts});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context, true);
        });
  }

  bool match(Person c) {
    final q = query.toLowerCase().trim();
    return c.firstName.toLowerCase().startsWith(q) ||
        c.lastName.toLowerCase().startsWith(q);
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const ListTile(title: Text('Start typing to search'));
    }

    List<Person> matchedContacts = [];

    for (Person person in contacts) {
      if (match(person)) {
        matchedContacts.add(person);
      }
    }

    return (matchedContacts.isEmpty)
        ? const ListTile(title: Text('No matches'))
        : ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: matchedContacts.length,
            itemBuilder: (context, index) {
              return DirectPhoneCard(
                  key: UniqueKey(), // Ensure each ContactTile has a unique key
                  person: matchedContacts[index],
                  index: index,
                  onRefresh: () {});
            });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const ListTile(title: Text('Start typing to search'));
    }

    List<Person> matchedContacts = [];

    for (Person person in contacts) {
      if (match(person)) {
        matchedContacts.add(person);
      }
    }

    return (matchedContacts.isEmpty)
        ? const ListTile(title: Text('No matches'))
        : ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: matchedContacts.length,
            itemBuilder: (context, index) {
              return DirectPhoneCard(
                  key: UniqueKey(), // Ensure each ContactTile has a unique key
                  person: matchedContacts[index],
                  index: index,
                  onRefresh: () {});
            });
  }
}
