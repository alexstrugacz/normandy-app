import 'package:flutter/material.dart';
import 'package:normandy_app/src/customers/customer_detail_page.dart';

class CustomerListTile extends StatefulWidget {
  final List<Map<String, dynamic>> searchResults;
  final VoidCallback nextPage;
  final bool anotherPage; // New required parameter

  const CustomerListTile({
    Key? key,
    required this.searchResults,
    required this.nextPage,
    required this.anotherPage,
  }) : super(key: key);

  @override
  _CustomerListTileState createState() => _CustomerListTileState();
}

class _CustomerListTileState extends State<CustomerListTile> {
  late int page;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.searchResults.isNotEmpty
          ? widget.searchResults.length + 1
          : 0, // Add 1 for the button if results exist
      itemBuilder: (context, index) {
        if (index == widget.searchResults.length && widget.anotherPage) {
          return Center(
            child: ElevatedButton(
              onPressed: widget.nextPage, // Use the passed function
              child: Text('Next Page'),
            ),
          );
        } else if(index == widget.searchResults.length) {
          if (index >= widget.searchResults.length) {
            return Container(); // Return an empty container if no more results
          }
        }

        var customer = widget.searchResults[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CustomerDetailPage(customerId: customer['_id']),
              ),
            );
          },
          child: Container(
            color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
            child: ListTile(
              title: Text(
                "${customer['fname1']} ${customer['lname1']}${customer['fname2'] != null ? " & ${customer['fname2']} ${customer["lname2"]}" : ""}",
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer['city'],
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    customer['lastSoldJobDesignerName'],
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              trailing: Text(
                customer['status'] != null && customer['status'].isNotEmpty
                    ? customer['status'][0].toUpperCase()
                    : 'N/A',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}