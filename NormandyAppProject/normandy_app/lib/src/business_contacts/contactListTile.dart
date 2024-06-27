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




  // void initState() {
  //   super.initState();
  //   _loadContactsData();
  // }

  // void _showErrorDialog(String message) {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text('Error'),
  //       content: Text(message),
  //       actions: <Widget>[
  //         TextButton(
  //           child: Text('Okay'),
  //           onPressed: () {
  //             Navigator.of(ctx).pop();
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _loadContactsData() async {
  //   print("Load contacts data.");
  //   _jwt = await getJwt();
  //   if (_jwt != null) {
  //     apiService = ApiService(
  //       baseUrl: 'https://normandy-backend.azurewebsites.net/api/rolodex',
  //       authToken: _jwt ?? ""
  //     );
  //     try {
  //       futureContacts = apiService.fetchContacts(); 
  //     } catch (error) {
  //       _showErrorDialog('Failed to load contacts: $error');

  //     }
  //   } else {
  //       _showErrorDialog('User not authenticated.');
  //   }
   
  // }
