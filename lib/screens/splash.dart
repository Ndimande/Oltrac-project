import 'package:flutter/material.dart';

const TextStyle _h1 = TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'RobotoLight');
const TextStyle _h2 = TextStyle(color: Colors.white, fontSize: 18, fontFamily: 'RobotoLight');

const Image _sharkTrackLogo = Image(image: AssetImage('assets/images/SharkTrack_Logo_White.png'), width: 200);
const Image _olspsLogo = Image(image: AssetImage('assets/images/olsps_logo_white.png'), width: 160);
const Image _sharkConservationFundLogo =
    Image(image: AssetImage('assets/images/shark_conservation_fund_logo_white.png'), width: 100);
const Image _fishwellLogo = Image(image: AssetImage('assets/images/fishwell_logo_white.png'), width: 100);
const Image _trafficLogo = Image(image: AssetImage('assets/images/traffic_logo_white.png'), width: 100);

class SplashScreen extends StatelessWidget {
  Widget _appLogo() => Container(
        margin: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          children: <Widget>[
            _sharkTrackLogo,
            Text('Mobile Shark-Product Tracing Application'.toUpperCase(), style: _h1, textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _developedBy() => Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text('Developed by'.toUpperCase(), style: _h2),
            SizedBox(height: 15),
            _olspsLogo,
          ],
        ),
      );

  Widget _supportedBy() => Container(
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text('Supported by'.toUpperCase(), style: _h2),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _sharkConservationFundLogo,
                _fishwellLogo,
                _trafficLogo,
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MaterialColor(0xFF086178, {}),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _appLogo(),
          Column(
            children: <Widget>[
              _developedBy(),
              SizedBox(height: 20),
              _supportedBy(),
            ],
          )
        ],
      ),
    );
  }
}
