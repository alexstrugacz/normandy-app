import "package:flutter/material.dart";
import "package:normandy_app/src/employee-list/employee_class.dart";
import "package:normandy_app/src/employee-list/employee_list_tile.dart";

  // Sample data for the Person class
  List<Person> people = [
    Person(
      initials: 'JS',
      ext: '1234',
      lastName: 'Smith',
      firstName: 'John',
      cellPhone: '555-1234',
      directOffice: '555-5678',
      homePhone: '555-8765',
      email: 'john.smith@example.com',
      jobTitle: 'Software Engineer',
      department: 'Engineering',
      id: '1',
      microsoftId: '1',
      favorite: false,
    ),
    Person(
      initials: 'JD',
      ext: '5678',
      lastName: 'Doe',
      firstName: 'Jane',
      cellPhone: '555-2345',
      directOffice: '555-6789',
      homePhone: '555-9876',
      email: 'jane.doe@example.com',
      jobTitle: 'Product Manager',
      department: 'Product',
      id: '2',
      microsoftId: '2',
      favorite: false,
    ),
    Person(
      initials: 'MB',
      ext: '9101',
      lastName: 'Brown',
      firstName: 'Michael',
      cellPhone: '555-3456',
      directOffice: '555-7890',
      homePhone: '555-0987',
      email: 'michael.brown@example.com',
      jobTitle: 'UX Designer',
      department: '',
      id: '3',
      microsoftId: '3',
      favorite: false,
    ),
  ];

class EmployeeList extends StatelessWidget {
  const EmployeeList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee List'),
      ),
      body: ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          return EmployeeTile(person: people[index], index: index);
        })
    );
  }
}