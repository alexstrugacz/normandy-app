import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/business_contact_details.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';

class ContactTile extends StatelessWidget {
  final Contact contact;
  final int index;
  final VoidCallback onRefresh;

  const ContactTile({super.key, required this.contact, required this.index, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
          child: Padding(
        padding: const EdgeInsets.only(left: 6, right: 4),
        child: FittedBox(
          child: Text(contact.initials),
        ),
      )),
      title: RichText(
        text: TextSpan(children: _buildTitleTextSpans(context))
      ),
      subtitle: Text(contact.jobTitle),
      trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact.favorite) const Icon(Icons.star, color: Color.fromARGB(255, 221, 150, 8)),
            const Icon(Icons.chevron_right),
          ],
      ),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContactDetailView(contact: contact)
          )
        );
        onRefresh();
      }
    );
  }

  List<TextSpan> _buildTitleTextSpans(BuildContext context) {
    if (contact.firstName.isEmpty && contact.lastName.isEmpty) {
      return [
        TextSpan(
          text: contact.company,
          style: DefaultTextStyle.of(context).style,
        )
      ];
    } else {
      return [
        TextSpan(
          text: '${contact.firstName} ',
          style: DefaultTextStyle.of(context).style,
        ),
        TextSpan(
          text: contact.lastName,
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(fontWeight: FontWeight.bold),
        )
      ];
    }
  }
}
