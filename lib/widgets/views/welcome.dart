import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';

class WelcomeView extends StatelessWidget {
  final AppStore _appStore;

  WelcomeView(this._appStore);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Container(
            padding: EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text(
                  'Welcome to OlTrace',
                  style: TextStyle(fontSize: 32, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                Column(
                  children: <Widget>[
                    Text(
                        'Before you begin, we need some information about your vessel.',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                        textAlign: TextAlign.center),
                  ],
                ),
                BigButton(
                  onPressed: () {
                    _appStore.changeMainView(NavIndex.configureVessel);
                  },
                  label: 'Continue',
                ),
              ],
            )));
  }
}
