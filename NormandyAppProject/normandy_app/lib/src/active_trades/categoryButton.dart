import "package:flutter/material.dart";
import "package:normandy_app/src/active_trades/categoryPage.dart";

class CategoryButton extends StatelessWidget {
  final String label;

  CategoryButton(this.label);

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
            builder: (context) => CategoryPage(label),
          ),
        );
      },
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}