import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/business_contact_details.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final int index;

  const ContactTile({super.key, required this.contact, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Padding(
          padding: const EdgeInsets.only(left: 6, right: 4),
          child: FittedBox(
            child: Text(contact.initials),
          ),
        )
      ),
      title: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${contact.firstName} ',
              style: DefaultTextStyle.of(context).style,
            ),
            TextSpan(
              text: contact.lastName,
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      subtitle: Text(contact.jobTitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ContactDetailView(contact: contact),
          ),
        );
      },
    );
  }
}
