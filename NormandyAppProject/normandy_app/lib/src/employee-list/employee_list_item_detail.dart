import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contact_button_functions.dart';
import 'package:normandy_app/src/employee-list/employee_class.dart';
import 'package:normandy_app/src/employee-list/launch_teams.dart';

class EmployeeItemDetails extends StatelessWidget {
  final Person person;

  const EmployeeItemDetails({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${person.lastName}, ${person.firstName}"),
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
            const CircleAvatar(
              radius: 40,
              child: Text(
                'NA',
                style: TextStyle(fontSize: 24),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "${person.firstName} ${person.lastName}",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${person.jobTitle} - ${person.department}',
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
                    handlePhoneCall(person.cellPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    handleMessage(person.cellPhone);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.email),
                  onPressed: () {
                    handleEmail(person.email);
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
            GestureDetector(
              onTap: () => {
                handleLaunchTeamsCall(person.email)
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
                    Text('${person.firstName} ${person.lastName}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => {
                handleLaunchTeamsMessage(person.email)
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
                    Text('${person.firstName} ${person.lastName}'),
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
                  Text(person.cellPhone),
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
                  Text(person.email),
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
                  Text('Add address here'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}