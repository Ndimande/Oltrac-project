import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer _longPressTimer;
  bool _backButtonBeingPressed = false;
  int _backButtonLongPressedSeconds = 0;
  Color _backButtonColor = OlracColours.olspsBlue;

  String get _version => AppData.packageInfo.version + ' build ' + AppData.packageInfo.buildNumber;

  @override
  void initState() {
    _longPressTimer = Timer.periodic(const Duration(seconds: 1), _onTimerTick);
    super.initState();
  }

  void _onTimerTick(Timer timer) {
    if (_backButtonBeingPressed) {
      setState(() {
        _backButtonColor = _backButtonColor == OlracColours.olspsBlue ? Colors.deepOrange : OlracColours.olspsBlue;
        _backButtonLongPressedSeconds += 1;
      });
    } else {
      setState(() {
        _backButtonLongPressedSeconds = 0;
      });
    }
    if (_backButtonLongPressedSeconds > 2) {
      setState(() {
        _backButtonLongPressedSeconds = 0;
        _backButtonBeingPressed = false;
        _backButtonColor = OlracColours.olspsBlue;
      });
      Navigator.pushNamed(_scaffoldKey.currentContext, '/developer');
      return;
    }
  }

  void _onPressBackButton() {
    Navigator.pop(_scaffoldKey.currentContext);
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _backButtonBeingPressed = true;
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _backButtonBeingPressed = false;
    });
  }

  Widget _backButton() {
    return Container(
        padding: const EdgeInsets.all(20),
        child: GestureDetector(
          child: Icon(
            Icons.arrow_back,
            color: _backButtonColor,
            size: 40,
          ),
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          onTap: _onPressBackButton,
        ));
  }

  @override
  void dispose() {
    _longPressTimer.cancel();
    super.dispose();
  }

  Future<void> _launchOLSPSSite() async {
    const url = 'https://marine.olsps.com';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  Widget _olspsLogo() {
    return Container(
      child: FlatButton(
        padding: const EdgeInsets.all(15),
        onPressed: _launchOLSPSSite,
        child: const Image(
          image: AssetImage('assets/images/olsps-logo.png'),
          width: 120,
        ),
      ),
      alignment: Alignment.bottomCenter,
    );

  }

  Widget _sharkTrackLogo() {
    const Image logo = Image(
      image: AssetImage('assets/images/shark_track_icon.png'),
      width: 120,
    );
    return Container(
      padding: const EdgeInsets.all(5),
      child: logo,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _foreground() {
    return Container(
      padding: const EdgeInsets.all(50),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _sharkTrackLogo(),
            Text(AppConfig.APP_TITLE, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30)),
            const Text('Onboard', textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
            Text(_version),
            Text(_copyright, textAlign: TextAlign.center),
            _backButton(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          _olspsLogo(),
          _foreground(),
        ],
      ),
    );
  }
}

String get _copyright => '© ${DateTime.now().year} OLSPS Marine';
