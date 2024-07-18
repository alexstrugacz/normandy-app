import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/business_contacts/contact_list_tile.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/helpers/load_favorite_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessContactsList extends StatefulWidget {
  final bool? isActiveTrades;
  final String? category;
  final bool? isEmployee;
  final bool? isFavorite;
  late String pageTitle;

  BusinessContactsList({super.key, this.isActiveTrades, this.category, this.isEmployee, this.isFavorite }) {
    if (category != null) {
      pageTitle = category!;
    } else if (isEmployee == true) {
      pageTitle = "Employees";
    } else if (isFavorite == true) {
      pageTitle = "Favorite Contacts";
    } else {
      pageTitle = "Business Contacts";
    }
  }

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
    jwt = await getJwt();
    if (jwt == null) {
      // Redirect to the login page
      if (!mounted) return;
      Navigator.pushNamed(context, '/');
    }

    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    String url = 'rolodex';
    if (widget.isActiveTrades == true) {
      url += '?isActiveTrades=true';
      if (widget.category != null) {
        url += '&category=${widget.category}';
      }
    } else if (widget.isEmployee == true) {
      url += '?isEmployee=true';
    } else if (widget.isFavorite == true) {
      List<String> favoriteContactIds = await loadFavoriteContacts();
      url += '?favoriteIds=${favoriteContactIds.join(',')}';
    }

    http.Response? response = await APIHelper.get(
      url,
      context,
      mounted
    );

    if ((response != null) && response.statusCode == 201) {
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
    return _contacts.map((contact) => contact.searchTerm).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.pageTitle), actions: [
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
            const Padding(
                padding: EdgeInsets.only(top: 20),
                child: Center(child: CircularProgressIndicator())
            )
          else Expanded(
              child: RefreshIndicator(
                onRefresh: _loadContactsData,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    return ContactTile(
                      key: UniqueKey(), // Ensure each ContactTile has a unique key
                      contact: _contacts[index], 
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

    if (query.isEmpty) {
      return const ListTile(title: Text('Start typing to search'));
    }

    List<Contact> matchedContacts = [];

    for (Contact contact in contacts) {
      if (contact.searchTerm.toLowerCase().trim().contains(query.toLowerCase().trim())) {
        matchedContacts.add(contact);
      }
    }

    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: matchedContacts.length,
        itemBuilder: (context, index) {
          return ContactTile(
            key: UniqueKey(), // Ensure each ContactTile has a unique key
            contact: matchedContacts[index], 
            index: index,
            onRefresh: () {},
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const ListTile(title: Text('Start typing to search'));
    }

    List<Contact> matchedContacts = [];

    for (Contact contact in contacts) {
      if (contact.searchTerm.toLowerCase().trim().contains(query.toLowerCase().trim())) {
        matchedContacts.add(contact);
      }
    }

    // if (matchedContacts.isEmpty) {
    //   return const ListTile(title: Text('No results found'));
    // }

    return Expanded(
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: matchedContacts.length,
        itemBuilder: (context, index) {
          return ContactTile(
            key: UniqueKey(), // Ensure each ContactTile has a unique key
            contact: matchedContacts[index], 
            index: index,
            onRefresh: () {},
          );
        },

      ),
    );
  }
}
