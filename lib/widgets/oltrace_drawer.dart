import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/stores/app_store.dart';

final Color _drawerHeaderColor = AppConfig.backgroundColor;
final Color _drawerHeaderTextColor = AppConfig.textColor1;
final double _drawerItemFontSize = 22;

Widget _drawerHeader(Profile profile) {
  final _vesselName = Text(
    profile.vesselName,
    style: TextStyle(color: _drawerHeaderTextColor, fontSize: 30),
  );
  final _skipperNameText = Text(
    profile.skipper.firstName + ' ' + profile.skipper.lastName,
    style: TextStyle(
      color: _drawerHeaderTextColor,
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );

  final _headerChild = Container(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _vesselName,
            _skipperNameText,
          ],
        ),
//        LocationCoords()
      ]));

  return DrawerHeader(
    child: _headerChild,
    decoration: BoxDecoration(
      color: _drawerHeaderColor,
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
          _drawerHeader(_appStore.profile),

          // Trip history
          ListTile(
            leading: Icon(
              Icons.history,
            ),
            title: Text(
              'Trip History',
              style: TextStyle(fontSize: _drawerItemFontSize),
            ),
            onTap: () => Navigator.pushNamed(context, '/trip_history'),
          ),

          // Settings
          ListTile(
            leading: Icon(
              Icons.settings,
            ),
            title: Text(
              'Settings',
              style: TextStyle(fontSize: _drawerItemFontSize),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),

          // About
          ListTile(
            leading: Icon(
              Icons.info,
            ),
            title: Text(
              'About',
              style: TextStyle(fontSize: _drawerItemFontSize),
            ),
            onTap: () => Navigator.pushNamed(context, '/about'),
          ),
        ],
      ),
    );
  }
}
