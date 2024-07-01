import 'package:flutter/material.dart';
import 'package:normandy_app/src/active_trades/category_button.dart';

class SelectCategoryPage extends StatelessWidget {
  const SelectCategoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Trades'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamed(context, '/home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  CategoryButton('Demolition'),
                  CategoryButton('Plumbing'),
                  CategoryButton('Electrical'),
                  CategoryButton('Professional'),
                  CategoryButton('Carpentry'),
                  CategoryButton('Supplier'),
                  CategoryButton('Business Vendor'),
                  CategoryButton('HVAC'),
                  CategoryButton('Concrete/Masonry'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}