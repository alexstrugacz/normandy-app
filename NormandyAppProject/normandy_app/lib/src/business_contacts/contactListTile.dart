import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/businessContactDetails.dart';
import 'package:normandy_app/src/business_contacts/businessContactsList.dart';
import 'package:normandy_app/src/business_contacts/contactsClass.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final int index;

  ContactTile({required this.contact, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(contact.initials),
      ),
      title: Text('${contact.firstName} ${contact.lastName}'),
      subtitle: Text(contact.jobTitle),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ContactDetailView(contact: sampleContacts[index]),
              ),
            );
      },
    );
  }
}