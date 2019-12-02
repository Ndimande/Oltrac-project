import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/stores/app_store.dart';

class AboutScreen extends StatelessWidget {
  final AppStore _appStore;

  AboutScreen(this._appStore);
  @override
  Widget build(BuildContext context) {
    final title = 'Olrac OlTrace';

    final version = _appStore.packageInfo.version +
        ' build ' +
        _appStore.packageInfo.buildNumber;

    final copyright = '© 2019 OlSPS Marine';

    return Scaffold(
        backgroundColor: AppConfig.backgroundColor,
        body: Container(
          padding: EdgeInsets.all(100),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
                Text(
                  version,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  copyright,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                Container(
                  padding: EdgeInsets.all(20),
                  child: BackButton(color: AppConfig.primarySwatch),
                )
              ],
            ),
          ),
        ));
  }
}
