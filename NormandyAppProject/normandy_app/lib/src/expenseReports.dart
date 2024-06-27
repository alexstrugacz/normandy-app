import 'package:flutter/material.dart';

class ExpenseReports extends StatelessWidget {
  final String header;

  final List<String> buttonNames = [
    'Choose Image',
    'Take Photo',
  ];

  final Map<String, String> buttonRoutes = {
    'Choose Image': '/expense-report-choose-image',
    'Take Photo': '/expense-report-take-a-photo',
  };

  ExpenseReports({required this.header});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(header),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, '/home', (route) => false);
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: List.generate(buttonNames.length, (index) {
                    return ElevatedButton(
                      onPressed: () {
                        if (buttonRoutes.containsKey(buttonNames[index])) {
                          Navigator.pushNamed(
                              context, buttonRoutes[buttonNames[index]]!);
                        } else {
                          print('No route defined for ${buttonNames[index]}');
                        }
                        print('Pressed ${buttonNames[index]}');
                      },
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        buttonNames[index],
                        style: TextStyle(fontWeight: FontWeight.normal),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
