import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/customer_detail_page.dart';

class CustomerSearchPage extends StatefulWidget {
  const CustomerSearchPage({super.key});

  @override
  CustomerSearchPageState createState() => CustomerSearchPageState();
}

class CustomerSearchPageState extends State<CustomerSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  handleSearch() async {
    var response = await APIHelper.get(
        'customers?mode=1&searchTerm=${_searchController.text}&limit=15',
        context,
        mounted);
    var newResults =
        response != null ? json.decode(response.body)['customers'] : [];
    for (var customer in newResults) {
      if(customer['lastSoldJobDate'] != null) {
        customer['lastSoldJobDate'] = DateFormat('yMd').format(DateTime.parse(customer['lastSoldJobDate']));
      } else {
        customer['lastSoldJobDate'] = 'N/A';
      }
      if(customer['lastSoldJobDesignerName'] == null) {
        customer['lastSoldJobDesignerName'] = 'N/A';
      }
    }
    setState(() {
      searchResults = newResults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                handleSearch();
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  var customer = searchResults[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailPage(customerId: customer['_id']),
                        ),
                      );
                    },
                    child: Container(
                      color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                      child: ListTile(
                        title: Text(
                          "Last Name 1: ${customer['lname1']}",
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "First Name 1: ${customer['fname1']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Last Name 2: ${customer['lname2']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "First Name 2: ${customer['fname2']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "City: ${customer['city']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Status: ${customer['status']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Last Job Designer: ${customer['lastSoldJobDesignerName']}",
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Last Job Date: ${customer['lastSoldJobDate']}",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
