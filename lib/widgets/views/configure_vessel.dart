import 'package:flutter/material.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:oltrace/stores/app_store.dart';

var _fakeVessel = Vessel(
    name: 'Fake vessel',
    fishery: Fishery(
        name: 'Fake fishery',
        safsCode: 'safs',
        jurisdiction: 'everywhere',
        country: Country(name: 'South Africa', iso3166Alpha3: 'ZA')));

class ConfigureVesselView extends StatelessWidget {
  final AppStore _appStore;

  ConfigureVesselView(this._appStore);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text(
            'Vessel'), // we know fishery by reference? No we should first select fishery then it loads vessels
        Text('Skipper'),
        Text('Config vessel'),
        Text('Config vessel'),
        RaisedButton(
            child: Text('Save'),
            onPressed: () {
              _appStore.setVessel(_fakeVessel);
              _appStore.changeMainView(MainViewIndex.home);
            })
      ],
    ));
  }
}
