import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Homepage'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/demo-page-1');
              },
              child: Text('Go to Page 1'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/demo-page-2');
              },
              child: Text('Go to Page 2'),
            ),
            
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/quick-links');
              },
              child: Text('Go to Quick Links'),
            ),
          ],
        ),
      ),
    );
  }
}
