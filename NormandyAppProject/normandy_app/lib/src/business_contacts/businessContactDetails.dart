import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contactButtonFunctions.dart';
import 'package:normandy_app/src/business_contacts/contactsClass.dart';

class ContactDetailView extends StatelessWidget {
  final Contact contact;

  ContactDetailView({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${contact.lastName}, ${contact.firstName}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                contact.initials,
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "${contact.firstName} ${contact.lastName}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              contact.jobTitle,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              contact.company,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    handlePhoneCall(contact.businessPhone);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    // Message functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.email),
                  onPressed: () {
                    // Email functionality
                  },
                ),
                IconButton(
                  icon: Icon(Icons.star),
                  onPressed: () {
                    // Favorite functionality
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(contact.businessPhone),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(contact.emailAddress),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(contact.company),
                  Text("${contact.businessStreet} ${contact.businessCity}, ${contact.businessCountryRegion} ${contact.businessPostalCode}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}