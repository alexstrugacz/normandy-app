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
        centerTitle: false,
        title: null,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 48),
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
                    onPressed: widget.contact.businessPhone.isNotEmpty ? () {
                      handlePhoneCall(widget.contact.businessPhone);
                    } : null
                  ),
                  IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: widget.contact.businessPhone.isNotEmpty ? () {
                      handleMessage(widget.contact.businessPhone);
                    } : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.email),
                    onPressed: widget.contact.emailAddress.isNotEmpty ? () {
                      handleEmail(widget.contact.emailAddress);
                    } : null,
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
                    Text(
                      widget.contact.businessPhone.isEmpty ? "No phone available." : widget.contact.businessPhone,
                      style: TextStyle(color: widget.contact.businessPhone.isEmpty ? const Color.fromARGB(100, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0))
                    )
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
                    Text(
                      widget.contact.emailAddress.isEmpty ? "No email available." : widget.contact.emailAddress,
                      style: TextStyle(color: widget.contact.emailAddress.isEmpty ? const Color.fromARGB(100, 0, 0, 0) : const Color.fromARGB(255, 0, 0, 0))
                    ),
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
                  children: 
                    _buildLocationTextSpans()
                ),
              ),
            ],
          ),
        )
      ) 
      
    );
  }

  // String _getHeaderText() {
  //   if (widget.contact.firstName.isEmpty && widget.contact.lastName.isEmpty) {
  //     return widget.contact.company;
  //   } else if (widget.contact.firstName.isNotEmpty && widget.contact.lastName.isNotEmpty) {
  //     return '${widget.contact.lastName}, ${widget.contact.firstName}';
  //   } else if (widget.contact.firstName.isNotEmpty) {
  //     return widget.contact.firstName;
  //   } else if (widget.contact.lastName.isNotEmpty) {
  //     return widget.contact.lastName;
  //   } else {
  //     return "";
  //   }
  // }

  List<Text> _buildTitleTextSpans(BuildContext context) {
    if (widget.contact.firstName.isEmpty && widget.contact.lastName.isEmpty) {
      return [
        Text(
          widget.contact.company,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ];
    } else {
      List<Text> textList = [
        Text(
          "${widget.contact.firstName} ${widget.contact.lastName}".trim(),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        )
      ];

      if (widget.contact.jobTitle.isNotEmpty) {
        textList.add(
          Text(
            widget.contact.jobTitle,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          )
        );
      }

      if (widget.contact.company.isNotEmpty) {
        textList.add(
          Text(
            widget.contact.company,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          )
        );
      }
      return textList;
    }
  }

  List<Text> _buildLocationTextSpans() {
    List<Text> locationText = [
      const Text(
        'Company',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      )
    ];
    if (widget.contact.company.isNotEmpty) {
      locationText.add(Text(widget.contact.company));
    }
    locationText.add(Text(_getAddress()));
    return locationText;
  }

  String _getAddress() {
    String address = widget.contact.businessStreet.trim();
    if (widget.contact.businessCity.isNotEmpty) {
      address += " ${widget.contact.businessCity}";
    }
    if (widget.contact.businessCountryRegion.isNotEmpty) {
      address += ", ${widget.contact.businessCountryRegion}";
    }

    if (widget.contact.businessPostalCode.isNotEmpty) {
      address += " ${widget.contact.businessPostalCode}";
    }

    return address.trim();
  }
}
