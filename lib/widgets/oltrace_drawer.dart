import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/location.dart';

Widget _drawerHeader(Vessel vessel) {
  final _vesselName = Text(
    vessel.name,
    style: TextStyle(color: Colors.white, fontSize: 28),
  );
  final _skipperName = Text(
    vessel.skipper.name,
    style: TextStyle(color: Colors.black, fontSize: 22),
  );

  var _headerChild = Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_vesselName, _skipperName],
        ),
        Location()
      ]));

  return DrawerHeader(
    child: _headerChild,
    decoration: BoxDecoration(
      color: Colors.blueGrey,
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
          _drawerHeader(_appStore.vessel),
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
