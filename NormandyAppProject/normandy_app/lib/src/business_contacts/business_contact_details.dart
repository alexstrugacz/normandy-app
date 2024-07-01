import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contact_button_functions.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';

class ContactDetailView extends StatelessWidget {
  final Contact contact;

  const ContactDetailView({super.key, required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${contact.lastName}, ${contact.firstName}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${contact.firstName} ${contact.lastName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              contact.jobTitle,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              contact.company,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    handlePhoneCall(contact.businessPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    handleMessage(contact.businessPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    handleEmail(contact.emailAddress);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  onPressed: () {
                    // Favorite functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(contact.businessPhone),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(contact.emailAddress),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
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