import 'package:flutter/material.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

class NoActiveTrip extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  _onPressStartTrip() async {
    await _appStore.startTrip();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              color: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                    Text(
                      'Start Trip',
                      style: TextStyle(color: Colors.white, fontSize: 28),
                    ),
                  ],
                ),
                height: 80,
                width: 200,
              ),
              onPressed: _onPressStartTrip,
            ),
          ],
        ),
      ),
    );
  }
}
