import 'package:flutter/material.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';

// final Color _drawerHeaderColor = AppConfig.backgroundColor;
// final Color _drawerHeaderTextColor = AppConfig.textColor1;
final double _drawerItemFontSize = 22;

Widget _drawerHeader(Profile profile) {
  final _vesselName = Text(
    profile.vesselName,
    style: TextStyle(fontSize: 30),
  );
  final _skipperNameText = Text(
    profile.skipper.firstName + ' ' + profile.skipper.lastName,
    style: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  );

  return DrawerHeader(
    child: Container(
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
        ],
      ),
    ),
  );
}

class MainDrawer extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

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


          // Products
          ListTile(
            leading: Icon(
              Icons.local_offer,
            ),
            title: Text(
              'Product Tags',
              style: TextStyle(fontSize: _drawerItemFontSize),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/products');
            },
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
