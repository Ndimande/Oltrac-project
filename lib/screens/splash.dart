import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oltrace/app_data.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _screenWidth;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  double _scale(double fontSize, double ratio) {
    final scaledFontSize = _screenWidth / ratio * fontSize;
    return scaledFontSize;
  }

  double _scaleText(double fontSize) {
    return _scale(fontSize, 250);
  }

  double _scaleImage(double imageSize) {
    return _scale(imageSize, 500);
  }

  TextStyle _fontStyle(double fontSize) =>
      TextStyle(color: Colors.white, fontSize: _scaleText(fontSize), fontFamily: 'RobotoLight');

  Image _sharkTraceLogo(double imageWidth) => Image(
        image: const AssetImage('assets/images/SharkTrace_Logo_White.png'),
        width: _scaleImage(imageWidth),
      );

  Image _olspsLogo(double imageWidth) => Image(
        image: const AssetImage('assets/images/olsps_logo_white.png'),
        width: _scaleImage(imageWidth),
      );

  Image _sharkConservationFundLogo(double imageWidth) => Image(
        image: const AssetImage('assets/images/shark_conservation_fund_logo_white.png'),
        width: _scaleImage(imageWidth),
      );

  Image _fishwellLogo(double imageWidth) => Image(
        image: const AssetImage('assets/images/fishwell_logo_white.png'),
        width: _scaleImage(imageWidth),
      );

  Image _trafficLogo(double imageWidth) => Image(
        image: const AssetImage('assets/images/traffic_logo_white.png'),
        width: _scaleImage(imageWidth),
      );

  Widget _appInfo() => Container(
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: Column(
          children: <Widget>[
            _sharkTraceLogo(200),
            Text('Onboard'.toUpperCase(), style: _fontStyle(16), textAlign: TextAlign.center),
            Text(AppData.packageInfo?.version, style: _fontStyle(10)),
            Divider(color: Colors.white, thickness: 1),
            Text('Mobile Shark-Product Tracing Application', style: _fontStyle(10), textAlign: TextAlign.center),
          ],
        ),
      );

  Widget _developedBy() => Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text('Developed By', style: _fontStyle(10)),
            const SizedBox(height: 15),
            _olspsLogo(160),
          ],
        ),
      );

  Widget _supportedBy() => Container(
        margin: const EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Text('Supported By', style: _fontStyle(10)),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _sharkConservationFundLogo(100),
                _fishwellLogo(100),
                _trafficLogo(100),
              ],
            )
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const MaterialColor(0xFF086178, {}),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const SizedBox(height: 10),
          _appInfo(),
          Column(
            children: <Widget>[
              _developedBy(),
              const SizedBox(height: 20),
              _supportedBy(),
            ],
          )
        ],
      ),
    );
  }
}
