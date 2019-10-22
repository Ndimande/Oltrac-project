import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/trip_started.dart';

Widget _drawerHeader(Trip trip) {
  Widget _headerChild = Text('No active trip');

  if (trip != null) {
    final _vesselName = Text(
      trip.vessel.name,
      style: TextStyle(color: Colors.white, fontSize: 26),
    );
    final _skipperName = Text('Hardcoded name');
    final _fisheryName = Text(
      trip.vessel.fishery.name,
      style: TextStyle(fontSize: 20, color: Colors.black),
    );

    _headerChild = Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          _vesselName,
          Column(
            children: <Widget>[
              _fisheryName,
              _skipperName,
            ],
          )
        ]));
  }

  return DrawerHeader(
    child: _headerChild,
    decoration: BoxDecoration(
      color: Colors.indigoAccent,
    ),
  );
}

class OlTraceDrawer extends StatelessWidget {
  final AppStore _appStore;

  OlTraceDrawer(this._appStore);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: <Widget>[
          _drawerHeader(_appStore.currentTrip),
          ListTile(
            title: Text('Trip'),
            onTap: () {
              _appStore.changeMainView(MainViewIndex.home);
              Navigator.pop(context);
            },
          ),
          ListTile(
            enabled: _appStore.tripHasStarted,
            title: Text('Haul'),
            onTap: () {
              _appStore.changeMainView(MainViewIndex.haul);
              Navigator.pop(context);
            },
          ),
          ListTile(
            enabled: _appStore.tripHasStarted && _appStore.haulHasStarted,
            title: Text('Tag'),
            onTap: () {
              _appStore.changeMainView(MainViewIndex.tag);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
