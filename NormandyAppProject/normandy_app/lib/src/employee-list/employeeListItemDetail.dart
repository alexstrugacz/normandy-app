import 'package:flutter/material.dart';
import 'package:normandy_app/src/business_contacts/contactButtonFunctions.dart';
import 'package:normandy_app/src/employee-list/employeeClass.dart';
import 'package:normandy_app/src/employee-list/launchTeams.dart';

class EmployeeItemDetails extends StatelessWidget {
  final Person person;

  EmployeeItemDetails({required this.person});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${person.lastName}, ${person.firstName}"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
                'NA',
                style: TextStyle(fontSize: 24),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "${person.firstName} ${person.lastName}",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '${person.jobTitle} - ${person.department}',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Normandy Remodeling',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.call),
                  onPressed: () {
                    handlePhoneCall(person.cellPhone);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    handleMessage(person.cellPhone);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.email),
                  onPressed: () {
                    handleEmail(person.email);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.star),
                  onPressed: () {
                    // Favorite functionality
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            new GestureDetector(
              onTap: () => {
                handleLaunchTeamsCall(person.email)
              },
              child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/teamsLogo.png', width: 20, height: 20, fit: BoxFit.cover,),
                        SizedBox(width: 5),
                        Text(
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
            SizedBox(height: 8),
            new GestureDetector(
              onTap: () => {
                handleLaunchTeamsMessage(person.email)
              },
              child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset('assets/images/teamsLogo.png', width: 20, height: 20, fit: BoxFit.cover,),
                        SizedBox(width: 5),
                        Text(
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
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(person.cellPhone),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(person.email),
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[200],
              width: MediaQuery.of(context).size.width,
              child: Column(
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