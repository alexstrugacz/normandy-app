import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:normandy_app/src/onedrive_shortcuts/customer_class.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:async/async.dart';

class CustomSearchDelegate extends SearchDelegate {
  BuildContext context;
  bool mounted;
  final Function onSelectCustomer;
  CustomSearchDelegate(
      {required this.context,
      required this.mounted,
      required this.onSelectCustomer});

  String? jwt;
  String _errorMessage = '';
  String currQuery = '';
  List<Customer> customers = [];
  Timer? _debounce;

  Future<List<Customer>> _loadCustomers() async {
    http.Response? response =
        await APIHelper.get('customers/search?query=^$query', context, mounted);

    if ((response != null) && response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['customers'];
      List<Customer> customers =
          data.map((dynamic item) => Customer.fromJson(item)).toList();
      return customers;
    } else {
      _errorMessage = 'Failed to load contacts data. Please try again later.';
      return [];
      // throw Exception('Failed to load contacts data. Please try again later.');
    }
  }
  // @override
  // void _onQueryChanged(String newQuery) {
  //   print("Query changed: $newQuery");
  //   _loadCustomers(newQuery);
  // }

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

  Widget displayCustomers() {
    return (customers.isEmpty && !query.isEmpty)
        ? const ListTile(title: Text('No matches'))
        : ListView.builder(
            scrollDirection: Axis.vertical,
            itemCount: customers.length,
            itemBuilder: (context, index) {
              return ListTile(
                visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
                title: Text(
                  customers[index].folderName,
                ),
                onTap: () {
                  onSelectCustomer(customers[index]);
                  close(context, customers[index]);
                },
              );
            },
          );
  }

  @override
  Widget buildResults(BuildContext context) {
    return displayCustomers();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query == currQuery) {
        return;
      }
      customers = [];
      query = query;
      if (query.isEmpty) {
        currQuery = query;
        return;
      }
      customers = await _loadCustomers();
      query = query;
      currQuery = query;
    });
    if (query.isEmpty) {
      return ListTile(title: Text('Start typing to search'));
    }
    if (query != currQuery) {
      return const Padding(
          padding: EdgeInsets.only(top: 20),
          child: Center(child: CircularProgressIndicator()));
    }
    return displayCustomers();
  }

  @override
  dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
