import "package:flutter/material.dart";
import "package:normandy_app/src/direct_phone_numbers/direct_phone_item_details.dart";
import "package:normandy_app/src/employee-list/employee_class.dart";

class DirectPhoneCard extends StatelessWidget {
  final Person person;
  final int index;
  final VoidCallback onRefresh;

  const DirectPhoneCard({super.key, required this.person, required this.index, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(person.initials),
      ),
      title: Text('${person.firstName} ${person.lastName}'),
      subtitle: Text(person.directOffice),
      trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (person.favorite) const Icon(Icons.star, color: Color.fromARGB(255, 221, 150, 8)),
            const Icon(Icons.chevron_right),
          ],
      ),
      onTap: () async {
        await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DirectPhoneItemDetails(person: person),
              ),
            );
          onRefresh();
      },
    );
  }
}