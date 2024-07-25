import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contact_button_functions.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';
import 'package:normandy_app/src/employee-list/launch_teams.dart';
import 'package:normandy_app/src/helpers/check_favorite.dart';
import 'package:normandy_app/src/helpers/toggle_favorite.dart';

class DirectPhoneItemDetails extends StatefulWidget {
  final Person person;

  const DirectPhoneItemDetails({super.key, required this.person});

  @override
  DirectPhoneItemDetailsState createState() => DirectPhoneItemDetailsState();
}

class DirectPhoneItemDetailsState extends State<DirectPhoneItemDetails> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    loadContactIsFavorite();
  }

  void toggleFavorite() async {
    await toggleIsFavorite(widget.person.id, 'directPhones');
    setState(() {
      isFavorite = !isFavorite;
    });
  }

  void loadContactIsFavorite() async {
    bool currentlyIsFavorite = await checkIsFavorite(widget.person.id, 'directPhones');
    setState(() {
      isFavorite = currentlyIsFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.person.lastName}, ${widget.person.firstName}"),
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
                widget.person.initials,
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${widget.person.firstName} ${widget.person.lastName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.person.jobTitle} - ${widget.person.department}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const Text(
              'Normandy Remodeling',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.call),
                  onPressed: () {
                    handlePhoneCall(widget.person.cellPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    handleMessage(widget.person.cellPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    handleEmail(widget.person.email);
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
            GestureDetector(
              onTap: () => {
                handleLaunchTeamsCall(widget.person.email)
              },
              child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/teamsLogo.png', width: 20, height: 20, fit: BoxFit.cover,),
                        const SizedBox(width: 5),
                        const Text(
                          'Call via Teams',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ),
                    Text('${widget.person.firstName} ${widget.person.lastName}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => {
                handleLaunchTeamsMessage(widget.person.email)
              },
              child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/teamsLogo.png', width: 20, height: 20, fit: BoxFit.cover,),
                        const SizedBox(width: 5),
                        const Text(
                          'Message via Teams',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ]
                    ),
                    Text('${widget.person.firstName} ${widget.person.lastName}'),
                  ],
                ),
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
                    'Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(widget.person.cellPhone),
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
                  Text(widget.person.email),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Company',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('Normandy Remodeling'),
                  Text('Add address here'), // To do - Add Normandy Address
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}