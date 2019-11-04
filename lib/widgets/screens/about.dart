import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.indigo,
        body: Container(
          padding: EdgeInsets.all(100),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Olrac OlTrace',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                Text(
                  '© 2019 OlSPS Marine',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                BackButton(color: Colors.orange)
              ],
            ),
          ),
        ));
  }
}
