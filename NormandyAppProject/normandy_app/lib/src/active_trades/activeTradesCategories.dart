import 'package:flutter/material.dart';
import 'package:normandy_app/src/active_trades/categoryButton.dart';

class SelectCategoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Trades'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
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