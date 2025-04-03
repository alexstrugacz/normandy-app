import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/so_forms/user_class.dart';
import 'package:normandy_app/src/customers/note_type.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({Key? key, required this.customerId}) : super(key: key);

  @override
  _CustomerDetailPageState createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  Customer? customer;
  User? customerContact;
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
  }

  fetchCustomerDetails() async {
    var response = await APIHelper.get('customers/${widget.customerId}', context, mounted);
    if (response != null && response.statusCode == 200 && mounted) {
      
      var newCustomer = Customer.fromJson(json.decode(response.body)['customer']);
      setState(() {
        customer = newCustomer;
      });

      if(newCustomer.customerContactID != '') {
        var response2 = await APIHelper.get('users/${newCustomer.customerContactID}', context, mounted);
        if (response2 != null && response2.statusCode == 200) {
          var newCustomerContact = User.fromJson(json.decode(response2.body)['user']);
          setState(() {
            customerContact = newCustomerContact;
          });
        }
      }

      var response3 = await APIHelper.get('notes?customerId=${widget.customerId}&noteFor=customer', context, mounted);
      if (response3 != null && response3.statusCode == 200) {
        var newNotes = (json.decode(response3.body)['notes'] as List)
            .map((note) => Note.fromJson(note))
            .toList();
        setState(() {
          notes = newNotes;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Details'),
      ),
      body: customer == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Owner 1",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "First Name 1: ${customer!.fname1}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Last Name 1: ${customer!.lname1}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Home Phone: ${customer!.homePhone1}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        "Cell Phone: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:${customer!.cellPhone1}')),
                        child: Text(
                          customer!.cellPhone1,
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Work Phone: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:${customer!.workPhone1}')),
                        child: Text(
                          customer!.workPhone1,
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Email: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('mailto:${customer!.email}')),
                        child: Text(
                          customer!.email,
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Owner 2",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "First Name 2: ${customer!.fname2}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Last Name 2: ${customer!.lname2}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Home Phone: ${customer!.homePhone2}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      Text(
                        "Cell Phone: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:${customer!.cellPhone2}')),
                        child: Text(
                          customer!.cellPhone2,
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Work Phone: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('tel:${customer!.workPhone2}')),
                        child: Text(
                          customer!.workPhone2,
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        "Email: ",
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse('mailto:${customer!.email2}')),
                        child: Text(
                          customer!.email2,
                          style: TextStyle(fontSize: 16, color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Home Info",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Address: ${customer!.address}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "City, State: ${customer!.city}, ${customer!.state}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Zip, County: ${customer!.zip}, ${customer!.county}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Tax ID, Census Tract: ${customer!.taxId}, ${customer!.censusTract}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Estimate, Date of Est.: ${customer!.currHomeEstimate}, ${customer!.currHomeEstimateDate}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Customer Contact: ${customerContact?.firstName ?? ''} ${customerContact?.lastName ?? ''}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "More Info",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Status: ${customer!.status}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Newsletter: ${customer!.newsletter}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Newsletter Method: ${customer!.newsletterMethod}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Use as Reference: ${customer!.useAsReference}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Moved: ${customer!.moved}",
                    style: TextStyle(fontSize: 16),
                  ),
                    Text("Date Added: ${customer!.dateCreated}", 
                    style: TextStyle(fontSize: 16)
                  ),
                  Text(
                    "Customer ID (old): ${customer!.customerId}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Sharepoint URL: ${customer!.spUrl}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  if (notes.isNotEmpty) ...[
                    Text(
                      "Notes",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    ...notes.map((note) => Text(
                      "${note.author.displayName} (${note.author.occupation}) | ${DateFormat.yMd().add_jm().format(DateTime.parse(note.postTime))}\n${note.content}",
                      style: TextStyle(fontSize: 16),
                    )),
                  ],
                ],
              ),
            ),
    );
  }
}
