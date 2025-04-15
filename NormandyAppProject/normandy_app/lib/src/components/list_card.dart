import 'package:flutter/material.dart';

class ListCard extends StatelessWidget {
  final String text;
  final description;
  final String image;
  final Function()? onTap;
  const ListCard(
      {super.key,
      required this.text,
      required this.description,
      required this.image,
      this.onTap});
 
  @override
  Widget build(BuildContext context) { 

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(0, 0, 0, 0.05)),
      child: Row(
        children: [
          Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10)),
                child: Image.network(image, height: 230, fit: BoxFit.cover),
              )),
          Expanded(
            flex: 7,
            child: Padding(
              padding: EdgeInsets.only(top: 20, left: 15, right: 15),
              child: SizedBox(
                  height: 200,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(children: [
                      Align(
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            height: 40,
                            child: SingleChildScrollView(
                              child: Text(text,
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Color.fromRGBO(0, 0, 0, 0.6),
                                  fontWeight: FontWeight.bold))),
                          ),
                        ),
                      Container(
                          height: 3,
                          decoration: const BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Color.fromARGB(255, 167, 165, 165))),
                          )),
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.topLeft,
                        child:  SizedBox(
                            height: 130,
                            child: SingleChildScrollView(
                              child: Text(description.map((item) => '• ${item['message']}').join('\n')),
                          ),
                        ) 
                      )
                    ]),
                  )),
            ),
          )
        ],
      ),
    );
  }
}
