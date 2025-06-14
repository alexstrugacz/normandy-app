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
        text: TextSpan(
          children: _buildTitleTextSpans(context),
        ) 
      ),
      subtitle: (_generateSubtitleText() != null) ? Text(
        _generateSubtitleText() ?? "",
        style: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 123, 123, 123))
      ) : null,
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
  
  String? _generateSubtitleText() {
    if (contact.nickname.isNotEmpty && contact.company.isNotEmpty) {
      return "${contact.nickname.trim() } / ${contact.company.trim()}";
    } else if (contact.nickname.isNotEmpty) {
      return contact.nickname.trim();
    } else if (contact.company.isNotEmpty) {
      return contact.company.trim();
    }

    // Most likely will remove this in the future
    if (contact.firstName == "" && contact.lastName == "") {
      return null;
    }
    if (contact.jobTitle != "" && contact.company != "") {
      return '${contact.company.trim()}, ${contact.jobTitle.trim()}';
    } else if (contact.jobTitle != "") {
      return contact.jobTitle.trim();
    } else if (contact.company != "") {
      return contact.company.trim();
    } else {
      return null;
    }
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
          text: '${contact.firstName.trim()} ',
          style: DefaultTextStyle.of(context)
            .style
            .copyWith(fontSize: 16)
        ),
        TextSpan(
          text: contact.lastName.trim(),
          style: DefaultTextStyle.of(context)
              .style
              .copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16
              )        
              )
      ];
    }
  }
}
