import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:normandy_app/src/api/api_helper.dart';
import 'package:normandy_app/src/customers/customer_type.dart';
import 'package:normandy_app/src/so_forms/user_class.dart';
import 'package:normandy_app/src/customers/note_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  // String userId = '';

  @override
  void initState() {
    super.initState();
    fetchCustomerDetails();
    // fetchUserId();
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

      if(kDebugMode) print(customerContact?.email ?? 'No email found');
    }
  }

  // void fetchUserId() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   if(prefs.getString('email') == null) {
  //     return;
  //   }
  //   var response = await APIHelper.get('users/:email/?${prefs.getString('email')}', context, mounted);
  //   if (response != null && response.statusCode == 200) {
  //     print(response.body);
  //     var user = User.fromJson(json.decode(response.body)['user']);
  //     setState(() {
  //       userId = user.userId ?? '';
  //     });
  //   }
  // }

  void openMailApp(List<String> emails) {
    if (emails.isEmpty || emails.every((email) => email.isEmpty)) return;
    final emailString = emails.where((email) => email.isNotEmpty).join(',');
    launchUrl(Uri.parse('mailto:$emailString'));
  }

  void openPhoneApp(String? phone1, String? phone2, String? phone3) {
    final phone = phone1?.isNotEmpty == true
        ? phone1
        : phone2?.isNotEmpty == true
            ? phone2
            : phone3?.isNotEmpty == true
                ? phone3
                : null;

    if (phone != null) {
      launchUrl(Uri.parse('tel:$phone'));
    }
  }

  void openMessageApp(String? phone1, String? phone2, String? phone3) {
    final phone = phone1?.isNotEmpty == true
        ? phone1
        : phone2?.isNotEmpty == true
            ? phone2
            : phone3?.isNotEmpty == true
                ? phone3
                : null;

    if (phone != null) {
      launchUrl(Uri.parse('sms:$phone'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(customer?.lname1 ?? 'Customer Details'),
      ),
      body: customer == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        customer?.fname1 ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => openPhoneApp(customer?.cellPhone1, customer?.homePhone1, customer?.workPhone1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.phone,
                            size: 28,
                            color: (customer?.cellPhone1.isNotEmpty == true || customer?.homePhone1.isNotEmpty == true || customer?.workPhone1.isNotEmpty == true) ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => openMessageApp(customer?.cellPhone1, customer?.homePhone1, customer?.workPhone1),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.message,
                            size: 28,
                            color: (customer?.cellPhone1.isNotEmpty == true || customer?.homePhone1.isNotEmpty == true || customer?.workPhone1.isNotEmpty == true) ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => openMailApp([customer?.email ?? '']),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.email,
                            size: 28,
                            color: (customer?.email.isNotEmpty == true) ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Text(
                        customer?.fname2 ?? '',
                        style: TextStyle(fontSize: 16),
                      ),
                      GestureDetector(
                        onTap: () => openPhoneApp(customer?.cellPhone2, customer?.homePhone2, customer?.workPhone2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.phone,
                            size: 28,
                            color: (customer?.cellPhone2.isNotEmpty == true || customer?.homePhone2.isNotEmpty == true || customer?.workPhone2.isNotEmpty == true) ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => openMessageApp(customer?.cellPhone2, customer?.homePhone2, customer?.workPhone2),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.message,
                            size: 28,
                            color: (customer?.cellPhone2.isNotEmpty == true || customer?.homePhone2.isNotEmpty == true || customer?.workPhone2.isNotEmpty == true) ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => openMailApp([customer?.email2 ?? '']),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.email,
                            size: 28,
                            color: (customer?.email2.isNotEmpty == true) ? Colors.blue : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  if (customerContact != null) ...[
                    Row(
                      children: [
                        Text(
                          customerContact?.displayName ?? customer?.lastSoldJobDesignerName ?? 'N/A',
                          style: TextStyle(fontSize: 16),
                        ),
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse('msteams:/l/call/0/0?users=${customerContact!.email}')),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.call,
                              size: 28,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse('msteams:/l/chat/0/0?users=${customerContact!.email}')),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.message,
                              size: 28,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => openMailApp([customerContact!.email]),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.email,
                              size: 28,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 20), 
                  Text(
                    customer?.address ?? 'N/A',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "${customer?.city ?? 'N/A'}, ${customer?.state ?? 'N/A'} ${customer?.zip ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Tax ID: ${customer?.taxId ?? 'N/A'}",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "Sharepoint Folder Name: ${customer?.spFolderName ?? 'N/A'}",
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
                  // SizedBox(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  //   children: [
                  //     ElevatedButton.icon(
                  //       onPressed: () {
                  //         // Add to one drive
                  //         APIHelper.post('/customers/:cid/shortcut?${customer!.customerId}', {"userId": userId}, context, mounted);
                  //       },
                  //       icon: Icon(Icons.add),
                  //       label: Text("Add Shortcut to OneDrive"),
                  //     ),
                  //     ElevatedButton.icon(
                  //       onPressed: () {
                  //         // Logic to open OneDrive
                  //         launchUrl(Uri.parse('https://onedrive.live.com/'));
                  //       },
                  //       icon: Icon(Icons.cloud),
                  //       label: Text("Open OneDrive"),
                  //     ),
                  //   ],
                  // ),
                ],
              ),
            ),
    );
  }
}
