import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/business_contact_details.dart';
import 'package:normandy_app/src/business_contacts/contact_list_tile.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BusinessContactsList extends StatefulWidget {
  const BusinessContactsList({super.key});

  @override
  BusinessContactsListState createState() => BusinessContactsListState();
}

class BusinessContactsListState extends State<BusinessContactsList> {
  String? jwt;
  String _errorMessage = '';
  List<Contact> _contacts = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadContactsData();
  }

  Future<List<Contact>> sortContacts(List<Contact> newContacts) async {
    // Favorite ones first
    List<Contact> favoriteContacts = [];
    List<Contact> nonFavoriteContacts = [];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteContactIds =
        prefs.getStringList('favoriteContacts') ?? [];

    for (Contact contact in newContacts) {
      if (favoriteContactIds.contains(contact.id)) {
        contact.updateFavorite(true);
        favoriteContacts.add(contact);
      } else {
        contact.updateFavorite(false);
        nonFavoriteContacts.add(contact);
      }
    }

    return favoriteContacts + nonFavoriteContacts;
  }

  Future<void> _refreshContactOrder() async {
    List<Contact> sortedContacts = await sortContacts(_contacts);
    setState(() {
      _contacts = sortedContacts;
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
        Uri.parse('http://localhost:5000/api/rolodex'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          "Authorization": "Bearer $jwt"
        });

    if (response.statusCode == 201) {
      List<dynamic> data = json.decode(response.body)['rolodex'];
      List<Contact> sortedContacts = await sortContacts(
          data.map((item) => Contact.fromJson(Map.castFrom(item))).toList());

      setState(() {
        _contacts = sortedContacts;
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
    List<String> updatedSearchTerms = [];

    for (Contact contact in _contacts) {
      if (contact.firstName.isNotEmpty && contact.lastName.isNotEmpty) {
        updatedSearchTerms.add('${contact.firstName} ${contact.lastName}');
      } else if (contact.firstName.isNotEmpty) {
        updatedSearchTerms.add(contact.firstName);
      } else if (contact.lastName.isNotEmpty) {
        updatedSearchTerms.add(contact.lastName);
      } else if (contact.company.isNotEmpty) {
        updatedSearchTerms.add(contact.company);
      }
    }

    return updatedSearchTerms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Business Contacts'), actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(
                      searchTerms: _getSearchTerms(), 
                      contacts: _contacts
                    ));
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
                          contact: _contacts[index], 
                          index: index,
                          onRefresh: _refreshContactOrder
                        );
                    },
                  ),
                ),
              ],
            )
        ]));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  List<String> searchTerms;
  List<Contact> contacts;
  @override
  CustomSearchDelegate({required this.searchTerms, required this.contacts});

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
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (String term in searchTerms) {
      if (term.contains(query)) {
        matchQuery.add(term);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(matchQuery[index]),
          );
        });
  }

  void _handleReturn() {
    log("handle return.");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const ListTile(title: Text('Start typing to search'));
    }
    List<String> matchQuery = [];
    List<Contact> matchingContacts = [];

    int i = 0;
    for (String term in searchTerms) {
      Contact matchingContact = contacts[i];
      if (term.toLowerCase().trim().contains(query.toLowerCase().trim())) {
        matchQuery.add(term);
        matchingContacts.add(matchingContact);
      }
      i++;
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          return ListTile(
              title: Text(matchQuery[index]),
              onTap: () async {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ContactDetailView(
                            contact: matchingContacts[index])));
              });
        });
  }
}
