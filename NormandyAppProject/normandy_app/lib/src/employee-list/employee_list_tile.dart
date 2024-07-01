import "package:flutter/material.dart";
import "package:normandy_app/src/employee-list/employee_class.dart";
import "package:normandy_app/src/employee-list/employee_list_item_detail.dart";

class EmployeeTile extends StatelessWidget {
  final Person person;
  final int index;

  const EmployeeTile({super.key, required this.person, required this.index});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(
        child: Text('NA'),
      ),
      title: Text('${person.firstName} ${person.lastName}'),
      subtitle: Text(person.jobTitle),
      trailing: const Icon(Icons.chevron_right),
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