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
      backgroundColor: MaterialColor(0xFF086178, {}),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Column(
              children: <Widget>[
                Image(image: AssetImage('assets/images/oltrace_logo.png'), width: 200),
                Text(
                  'Mobile Shark-Product Tracing Application',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Developed by', style: TextStyle(color: Colors.white, fontSize: 26)),
                ),
                Image(image: AssetImage('assets/images/olsps_logo_white.png'), width: 200),
              ],
            ),
            Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text('Supported by', style: TextStyle(color: Colors.white, fontSize: 26)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Image(image: AssetImage('assets/images/traffic_logo.png'), width: 160),
                    Image(image: AssetImage('assets/images/fishwell_logo.png'), width: 160),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
