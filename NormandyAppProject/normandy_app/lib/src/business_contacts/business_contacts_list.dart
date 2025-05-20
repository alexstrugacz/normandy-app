import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/business_contacts/contact_list_tile.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';
import 'package:normandy_app/src/business_contacts/usercontacts_class.dart';
import 'package:normandy_app/src/api/get_jwt.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/helpers/load_favorite_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessContactsList extends StatefulWidget {
  final bool? isActiveTrades;
  final String? category;
  final bool? isEmployee;
  final bool? isFavorite;

  const BusinessContactsList(
      {super.key,
      this.isActiveTrades,
      this.category,
      this.isEmployee,
      this.isFavorite});

  @override
  BusinessContactsListState createState() => BusinessContactsListState();
}

class BusinessContactsListState extends State<BusinessContactsList> {
  String? jwt;
  String _errorMessage = '';
  List<Contact> _contacts = [];
  bool _loading = false;
  String pageTitle = "";

  void generatePageTitle() {
    if (widget.category != null) {
      pageTitle = widget.category!;
    } else if (widget.isEmployee == true) {
      pageTitle = "Employees";
    } else if (widget.isFavorite == true) {
      pageTitle = "Favorite Contacts";
    } else {
      pageTitle = "Business Contacts";
    }
  }

  @override
  void initState() {
    super.initState();
    generatePageTitle();
    _loadContactsData().then((_) {
      // wait for contacts to load before opening search delegate
      if (_contacts.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showSearch(
              context: context,
              delegate: CustomSearchDelegate(
                  searchTerms: _getSearchTerms(), contacts: _contacts));
        });
      }
    });
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

    int compar(Contact a, Contact b) {
      var res = a.firstName.compareTo(b.firstName);
      if (res == 0) {
        res = a.lastName.compareTo(b.lastName);
      }
      return res;
    }

    favoriteContacts.sort(compar);
    nonFavoriteContacts.sort(compar);

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
    String key = 'rolodex';
    if (widget.isActiveTrades == true) {
      url += '?isActiveTrades=true';
      if (widget.category != null) {
        url += '&category=${widget.category}';
      }
    } else if (widget.isEmployee == true) {
      url = 'users';
      key = 'users';
    } else if (widget.isFavorite == true) {
      url += '?isFavorite=true';
      List<String> favoriteContactIds = await loadFavoriteContacts();
      if (favoriteContactIds.isNotEmpty) {
        url += '&favoriteIds=${favoriteContactIds.join(',')}';
      }
    }
    print(url);

    http.Response? response;

    if (mounted) {
      response = await APIHelper.get(url, context, mounted);
    }

    if ((response != null) &&
        200 <= response.statusCode &&
        response.statusCode < 300) {
      List<dynamic> data = json.decode(response.body)[key];
      List<Contact> sortedContacts = await sortContacts(data
          .map((item) => (key == 'users')
              ? UserContact.fromJson(Map.castFrom(item))
              : Contact.fromJson(Map.castFrom(item)))
          .toList());

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
        appBar: AppBar(title: Text(pageTitle), actions: [
          IconButton(
              onPressed: () async {
                await showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(
                        searchTerms: _getSearchTerms(), contacts: _contacts));
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
          else if (_contacts.isEmpty)
            const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "No contacts found.",
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ))
          else
            Expanded(
                child: RefreshIndicator(
                    onRefresh: _loadContactsData,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        return ContactTile(
                          key:
                              UniqueKey(), // Ensure each ContactTile has a unique key
                          contact: _contacts[index],
                          index: index,
                          onRefresh: _refreshContactOrder,
                        );
                      },
                    )))
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
      if (contact.searchTerm
          .toLowerCase()
          .trim()
          .contains(query.toLowerCase().trim())) {
        matchedContacts.add(contact);
      }
    }

    return ListView.builder(
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
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const ListTile(title: Text('Start typing to search'));
    }

    List<Contact> matchedContacts = [];

    for (Contact contact in contacts) {
      if (contact.searchTerm
          .toLowerCase()
          .trim()
          .contains(query.toLowerCase().trim())) {
        matchedContacts.add(contact);
      }
    }

    return ListView.builder(
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
    );
  }
}
