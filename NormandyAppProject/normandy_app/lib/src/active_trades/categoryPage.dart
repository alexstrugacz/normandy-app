import "package:flutter/material.dart";

class CategoryPage extends StatelessWidget {
  final String category;

  CategoryPage(this.category);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          '$category page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}