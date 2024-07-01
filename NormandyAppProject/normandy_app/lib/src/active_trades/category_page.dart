import "package:flutter/material.dart";

class CategoryPage extends StatelessWidget {
  final String category;

  const CategoryPage(this.category, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(category),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Text(
          '$category page',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
