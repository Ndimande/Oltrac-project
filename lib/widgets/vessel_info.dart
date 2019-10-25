import 'package:flutter/material.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:oltrace/stores/app_store.dart';

class VesselInfo extends StatelessWidget {
  final AppStore _appStore;

  VesselInfo(this._appStore);

  @override
  Widget build(BuildContext context) {
    final Vessel _vessel = _appStore.vessel;
    if (_vessel == null) {
      return Text('Vessel not configured');
    }
    return FlatButton(
        onPressed: () {
          _appStore.changeMainView(MainViewIndex.configureVessel);
        },
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(_vessel.name, style: TextStyle(fontSize: 32)),
              Text(_vessel.skipper.name),
              Text(_vessel.country.name, style: TextStyle(fontSize: 29))
            ],
          ),
        ));
  }
}
