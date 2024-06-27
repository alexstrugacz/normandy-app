import "package:flutter/material.dart";
import "package:normandy_app/src/employee-list/employeeClass.dart";
import "package:normandy_app/src/employee-list/employeeListItemDetail.dart";

class EmployeeTile extends StatelessWidget {
  final Person person;
  final int index;

  EmployeeTile({required this.person, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('NA'),
      ),
      title: Text('${person.firstName} ${person.lastName}'),
      subtitle: Text(person.jobTitle),
      trailing: Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeItemDetails(person: person),
              ),
            );
      },
    );
  }
}