import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/location.dart';

Widget _drawerHeader(Trip trip) {
  Widget _headerChild = Text('No active trip');

  if (trip != null) {
    final _vesselName = Text(
      trip.vessel.name,
      style: TextStyle(color: Colors.white, fontSize: 26),
    );
    final _skipperName = Text(trip.vessel.skipper.name);

    _headerChild = Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
          _vesselName,
          Column(
            children: <Widget>[_skipperName, Location()],
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
            title: Text('Trip', style: TextStyle(fontSize: 26)),
            onTap: () {
              _appStore.changeMainView(MainViewIndex.home);
              Navigator.pop(context);
            },
          ),
          ListTile(
            enabled: _appStore.tripHasStarted,
            title: Text('Haul', style: TextStyle(fontSize: 26)),
            onTap: () {
              _appStore.changeMainView(MainViewIndex.haul);
              Navigator.pop(context);
            },
          ),
          ListTile(
            enabled: _appStore.tripHasStarted && _appStore.haulHasStarted,
            title: Text('Tag', style: TextStyle(fontSize: 26)),
            onTap: () {
              _appStore.changeMainView(MainViewIndex.tag);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('About', style: TextStyle(fontSize: 26)),
            onTap: () {
              Navigator.pushNamed(context, '/about');
            },
          ),
        ],
      ),
    );
  }
}
