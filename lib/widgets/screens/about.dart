import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
          child: Icon(Icons.arrow_back,color: _backButtonColor),
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

  @override
  Widget build(BuildContext context) {
    const title = 'OlTrace';

    final version = _appStore.packageInfo.version + ' build ' + _appStore.packageInfo.buildNumber;

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: const EdgeInsets.all(100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 30)),
              Text(version),
              Text(_copyright, textAlign: TextAlign.center),
              _backButton(),
            ],
          ),
        ),
      ),
    );
  }
}

String get _copyright => '© ${DateTime.now().year} OLSPS Marine';
