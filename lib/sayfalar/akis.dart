import 'package:flutter/material.dart';
import 'package:socialapp/sayfalar/yukle.dart';

class Akis extends StatefulWidget {
  @override
  _AkisState createState() => _AkisState();
}

class _AkisState extends State<Akis> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 70.0,
                    height: 70.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(180.0),
                      color: Colors.blue,
                    ),
                    child: IconButton(
                        icon: Icon(
                          Icons.add_a_photo_outlined,
                          color: Colors.white,
                          size: 40.0,
                        ),
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => Yukle()));
                        }),
                  ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
