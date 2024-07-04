import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contact_button_functions.dart';
import 'package:normandy_app/src/business_contacts/contacts_class.dart';
import 'package:normandy_app/src/employee-list/launch_teams.dart';
import 'package:normandy_app/src/helpers/check_contact_is_favorite.dart';
import 'package:normandy_app/src/helpers/toggle_favorite_contact.dart';

class ContactDetailView extends StatefulWidget {
  final Contact contact;

  const ContactDetailView({super.key, required this.contact});

  @override
  ContactDetailViewState createState() => ContactDetailViewState();
}

class ContactDetailViewState extends State<ContactDetailView> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadContactIsFavorite();
  }

  void loadContactIsFavorite() async {
    bool currentlyIsFavorite = await checkContactIsFavorite(widget.contact.id);
    setState(() {
      isFavorite = currentlyIsFavorite;
    });
  }

  void toggleFavorite() async {
    await toggleFavoriteContact(widget.contact.id);
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void _handleRedirectToTeamsMessage() async {
    handleLaunchTeamsMessage(widget.contact.emailAddress);
  }

  void _handleRedirectToTeamsCall() async {
    handleLaunchTeamsCall(widget.contact.emailAddress);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getHeaderText()),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
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
                widget.contact.initials,
                style: const TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            ..._buildTitleTextSpans(context),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    handlePhoneCall(widget.contact.businessPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    handleMessage(widget.contact.businessPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    handleEmail(widget.contact.emailAddress);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.star),
                  color: isFavorite
                      ? const Color.fromARGB(255, 221, 150, 8)
                      : const Color.fromARGB(255, 80, 80, 80),
                  onPressed: () {
                    toggleFavorite();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.contact.emailType == "EX")
              Column(children: [
                GestureDetector(
                  onTap: () {
                    _handleRedirectToTeamsMessage();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Image.asset("assets/images/teams.png",
                              height: 25, width: 25),
                          const SizedBox(width: 10),
                          const Text(
                            'Message via Teams',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ])
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    _handleRedirectToTeamsCall();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Image.asset("assets/images/teams.png",
                              height: 25, width: 25),
                          const SizedBox(width: 10),
                          const Text(
                            'Call via Teams',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        ])
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ]),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(5),
              ),
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.contact.businessPhone),
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
                  Text(widget.contact.emailAddress),
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
                  Text(widget.contact.company),
                  Text(
                      "${widget.contact.businessStreet} ${widget.contact.businessCity}, ${widget.contact.businessCountryRegion} ${widget.contact.businessPostalCode}"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHeaderText() {
    if (widget.contact.firstName.isEmpty && widget.contact.lastName.isEmpty) {
      return widget.contact.company;
    } else {
      return '${widget.contact.lastName}, ${widget.contact.firstName}';
    }
  }

  List<Text> _buildTitleTextSpans(BuildContext context) {
    if (widget.contact.firstName.isEmpty && widget.contact.lastName.isEmpty) {
      return [
        Text(
          widget.contact.company,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ];
    } else {
      return [
        Text(
          "${widget.contact.firstName} ${widget.contact.lastName}",
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          widget.contact.jobTitle,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        Text(
          widget.contact.company,
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ];
    }
  }
}
