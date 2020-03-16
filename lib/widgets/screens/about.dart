import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';

class AboutScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  String get copyright {
    final year = DateTime.now().year;
    return '© $year OLSPS Marine';
  }

  @override
  Widget build(BuildContext context) {
    const title = 'OlTrace';

    final version = _appStore.packageInfo.version + ' build ' + _appStore.packageInfo.buildNumber;
    void _onPressBackButton() {
      Navigator.pop(_scaffoldKey.currentContext);
    }

    _onLongPressBackButton() {
      Navigator.pushNamed(_scaffoldKey.currentContext, '/developer');
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        padding: EdgeInsets.all(100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30),
              ),
              Text(
                version,
              ),
              Text(
                copyright,
                textAlign: TextAlign.center,
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: FlatButton(
                  highlightColor: olracBlue,
                  child: Icon(Icons.arrow_back, color: olracBlue),
                  onPressed: _onPressBackButton,
                  onLongPress: AppConfig.debugMode ? _onLongPressBackButton : null,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
