import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';

class AboutScreen extends StatefulWidget {
  @override
  _AboutScreenState createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Timer _longPressTimer;
  bool _backButtonBeingPressed = false;
  int _backButtonLongPressedSeconds = 0;
  Color _backButtonColor = olracBlue;

  String get _version => _appStore.packageInfo.version + ' build ' + _appStore.packageInfo.buildNumber;

  @override
  void initState() {
    _longPressTimer = Timer.periodic(Duration(seconds: 1), _onTimerTick);
    super.initState();
  }

  void _onTimerTick(Timer timer) {
    if (_backButtonBeingPressed) {
      setState(() {
        _backButtonColor = _backButtonColor == olracBlue ? Colors.deepOrange : olracBlue;
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
        _backButtonColor = olracBlue;
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

  Widget _olspsLogo() {
    const Image logo = Image(
      image: AssetImage('assets/images/olsps-logo.png'),
      width: 120,
    );
    return Container(
      padding: EdgeInsets.all(5),
      child: logo,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _sharkTrackLogo() {
    const Image logo = Image(
      image: AssetImage('assets/images/shark_track_icon.png'),
      width: 120,
    );
    return Container(
      padding: EdgeInsets.all(5),
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
            Text(AppConfig.APP_TITLE, textAlign: TextAlign.center, style: TextStyle(fontSize: 30)),
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
