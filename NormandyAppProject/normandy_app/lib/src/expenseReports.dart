import 'package:flutter/material.dart';

class ExpenseReports extends StatelessWidget {
  final String header;

  const ExpenseReports({required this.header});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(header),
      ),
      body: Center(
        child: Text(header),
      ),
    );
  }
}
