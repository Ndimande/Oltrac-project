import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(100),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Olrac OlTrace',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30),
            ),
            Text('© 2019 OlSPS Marine', textAlign: TextAlign.center),
            BackButton(color: Colors.indigoAccent)
          ],
        ),
      ),
    ));
  }
}
