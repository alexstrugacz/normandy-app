import "package:flutter/material.dart";
import "package:normandy_app/src/active_trades/category_page.dart";
import "package:normandy_app/src/business_contacts/business_contacts_list.dart";

class CategoryButton extends StatelessWidget {
  final String label;

  const CategoryButton(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Probably don't need a page for the categories; can just use the business contacts list and send it filtered data
            builder: (context) => BusinessContactsList(
              isActiveTrades: true,
              category: label
            )
          ),
        );
      },
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
