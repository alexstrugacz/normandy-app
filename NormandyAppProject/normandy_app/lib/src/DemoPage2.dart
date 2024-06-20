import 'package:flutter/material.dart';

class DemoPage2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Page 2'),
        ),
        body: Center(
            child: Column(children: <Widget>[
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
            child: Text('Back to Homepage'),
          ),
        ])));
  }
}
