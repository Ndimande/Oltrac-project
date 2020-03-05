import 'package:flutter/material.dart';

Widget _spinnerStack() {
  return Stack(
    children: <Widget>[
      Container(
        width: 200,
        height: 200,
        child: CircularProgressIndicator(
          strokeWidth: 30,
        ),
      ),
      Container(
        width: 200,
        height: 200,
        child: Center(
          child: Text(
            'OlTrace',
            textAlign: TextAlign.center,
            textScaleFactor: 2.8,
          ),
        ),
      ),
    ],
  );
}

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _spinnerStack(),
            Image(
              image: AssetImage('assets/images/olsps-logo.png'),
              width: 200,
            ),
          ],
        ),
      ),
    );
  }
}
