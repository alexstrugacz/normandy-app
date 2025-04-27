import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/customer_list_tile.dart';

class SearchUtils {
  static Future<Map<String, dynamic>> handleSearch({
    required String searchTerm,
    required String searchByField,
    required int page,
    required BuildContext context,
    required bool mounted,
  }) async {
    if (searchTerm.isEmpty) {
      return {'results': [], 'anotherPage': false};
    }
    var anotherPage = false;
    var response = await APIHelper.get(
        'customers?mode=1&searchTerm=$searchTerm&limit=50&searchByField=$searchByField&page=$page',
        context,
        mounted);
    List<Map<String, dynamic>> newResults =
        response != null ? List<Map<String, dynamic>>.from(json.decode(response.body)['customers']) : [];
    for (var customer in newResults) {
      if (customer['lastSoldJobDate'] != null) {
        customer['lastSoldJobDate'] =
            DateFormat('yMd').format(DateTime.parse(customer['lastSoldJobDate']));
      } else {
        customer['lastSoldJobDate'] = 'N/A';
      }
      if (customer['lastSoldJobDesignerName'] == null) {
        customer['lastSoldJobDesignerName'] = 'N/A';
      }
    }

    // sort the results so customers with status="Customer" are first
    newResults.sort((a, b) {
      String statusA = a['status'] ?? '';
      String statusB = b['status'] ?? '';
      if (statusA == 'Customer' && statusB != 'Customer') {
        return -1;
      } else if (statusA != 'Customer' && statusB == 'Customer') {
        return 1;
      }
      return 0;
    });

    if(newResults.length == 50) {
      anotherPage = true;
    }

    newResults =
        newResults.where((customer) => customer['status'] != 'Inquiry').toList();

    return {'results': newResults, 'anotherPage': anotherPage};
  }
}

class CustomerSearchPage extends StatefulWidget {
  const CustomerSearchPage({super.key});

  @override
  CustomerSearchPageState createState() => CustomerSearchPageState();
}

class CustomerSearchPageState extends State<CustomerSearchPage> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showSearch(context: context, delegate: CustomerSearchDelegate(context: context));
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // placeholder
      appBar: AppBar(
        title: Text('Customers'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: CustomerSearchDelegate(context: context));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: ListTile(title: Text('Start typing to search')),
      ),
    );
  }
}

class CustomerSearchDelegate extends SearchDelegate {
  final BuildContext context;
  List<Map<String, dynamic>> searchResults = [];
  String searchByField = 'lname1'; // Default search field
  final searchFields = [
    'lname1',
    'fname1',
    'lname2',
    'fname2',
    'city',
  ];
  int page = 1; // Default page number

  @override
  CustomerSearchDelegate({required this.context});

  // handle page increase
  void increasePage() {
    page++;
    if(kDebugMode) print("Page increased to $page");
    showResults(context); // Refresh results  
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      DropdownButton<String>(
        value: searchByField,
        onChanged: (String? newValue) {
          searchByField = newValue!;
          page = 1; // Reset page to 1 when search field changes
          showSuggestions(context); // Refresh suggestions
        },
        items: searchFields.map<DropdownMenuItem<String>>((String field) {
          return DropdownMenuItem<String>(
            value: field,
            child: Text(field),
          );
        }).toList(),
      ),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder(
      future: SearchUtils.handleSearch(
        searchTerm: query,
        searchByField: searchByField,
        page: page,
        context: context,
        mounted: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null || (snapshot.data as Map<String, dynamic>)['results'].isEmpty) {
          return Center(child: Text('No results found.'));
        }
        var results = (snapshot.data as Map<String, dynamic>);
        searchResults = results['results'] as List<Map<String, dynamic>>;
        var anotherPage = results['anotherPage'] as bool;
        return CustomerListTile(searchResults: searchResults, nextPage: increasePage, anotherPage: anotherPage);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    
    page = 1; // Reset page to 1 when suggestions are built (called on field change)

    if (query.isEmpty) {
      return const ListTile(
        title: Text('Start typing to search'),
      );
    }

    return FutureBuilder(
      future: SearchUtils.handleSearch(
        searchTerm: query,
        searchByField: searchByField,
        page: page,
        context: context,
        mounted: true,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No results found.'));
        }
        var results = (snapshot.data as Map<String, dynamic>);
        searchResults = results['results'] as List<Map<String, dynamic>>;
        var anotherPage = results['anotherPage'] as bool;
        return CustomerListTile(searchResults: searchResults, nextPage: increasePage, anotherPage: anotherPage);
      },
    );
  }
}