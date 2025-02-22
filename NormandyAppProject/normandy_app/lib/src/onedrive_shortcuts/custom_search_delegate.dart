import 'dart:convert';




import 'package:flutter/material.dart';
import 'package:normandy_app/src/onedrive_shortcuts/customer_class.dart';
import 'package:http/http.dart' as http;
import 'package:normandy_app/src/api/api_helper.dart';

class CustomSearchDelegate extends SearchDelegate {
  BuildContext context;
  bool mounted;
  final Function onSelectCustomer;

  CustomSearchDelegate({required this.context, required this.mounted, required this.onSelectCustomer});

  String? jwt;
  String _errorMessage = '';

  Future<List<Customer>> _loadCustomers() async {

    http.Response? response = await APIHelper.get(
      'customers/search?query=$query',
      context,
      mounted
    );

    if ((response != null) && response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['customers'];
      List<Customer> customers = data.map((dynamic item) => Customer.fromJson(item)).toList(); 
      return customers;
    } else {
      _errorMessage = 'Failed to load contacts data. Please try again later.';
      return [];
      // throw Exception('Failed to load contacts data. Please try again later.');
    }
  }
  // @override 
  // void _onQueryChanged(String newQuery) {
  //   if(kDebugMode) print("Query changed: $newQuery");
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

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Expanded(child: ListTile(title: Text('Start typing to search')));
    }
    return FutureBuilder<List<Customer>>(
      future: _loadCustomers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            return ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    visualDensity: const VisualDensity(horizontal: 0, vertical: 0),
                    title: Text(
                      snapshot.data![index].folderName,
                    ),
                    onTap: () {
                      if (snapshot.data?[index] != null) {
                        onSelectCustomer(snapshot.data![index]);
                        close(context, snapshot.data![index]);
                      }
                    },
                  );
                },
              );
          } else {
            return const Expanded(child: ListTile(title: Text('No results found')));
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.none) {
          return const ListTile(title: Text('No results found'));
        } else {
          return ListTile(title: Text(_errorMessage));
        }
      }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}