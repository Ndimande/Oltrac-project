import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';

class AboutScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  @override
  Widget build(BuildContext context) {
    final title = 'Olrac OlTrace';

    final version = _appStore.packageInfo.version + ' build ' + _appStore.packageInfo.buildNumber;

    final copyright = '© 2019 OlSPS Marine';

    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(100),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, color: AppConfig.textColor1),
              ),
              Text(
                version,
                style: TextStyle(color: AppConfig.textColor1),
              ),
              Text(
                copyright,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppConfig.textColor1),
              ),
              Container(
                padding: EdgeInsets.all(20),
                child: BackButton(color: AppConfig.primarySwatch),
              )
            ],
          ),
        ),
      ),
    );
  }
}
