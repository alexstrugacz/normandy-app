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
            Navigator.pop(context);
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
                  CategoryButton('Concrete/Masonry'),
                  CategoryButton('Demolition'),
                  CategoryButton('Supplier'),
                  CategoryButton('Rough Carpenters'),
                  CategoryButton('Plumbing'),
                  CategoryButton('HVAC'),
                  CategoryButton('Electrical'),
                  CategoryButton('Insulators'),
                  CategoryButton('Drywall'),
                  CategoryButton('Custom Stairs'),
                  CategoryButton('Hardwood Floor'),
                  CategoryButton('Tile'),
                  CategoryButton('Exterior Finish/Roofing'),
                  CategoryButton('Interior Trim'),
                  CategoryButton('Custom Countertops'),
                  CategoryButton('Shower Doors and Mirrors'),
                  CategoryButton('Misc Trades and Vendors'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
