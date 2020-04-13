import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';

final double _drawerItemFontSize = 22;
const double drawerLabelFontSize = 18;
const double drawerTextFontSize = 26;

Widget _drawerHeader(Profile profile) {
  final vesselName = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Vessel Name',
        style: TextStyle(fontSize: drawerLabelFontSize),
      ),
      Text(profile.vesselName, style: TextStyle(fontSize: drawerTextFontSize)),
    ],
  );

  final skipperName = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(
        'Skipper Name',
        style: TextStyle(fontSize: drawerLabelFontSize),
      ),
      Text(
        profile.skipper.firstName + ' ' + profile.skipper.lastName,
        style: TextStyle(
          fontSize: drawerTextFontSize,
        ),
      ),
    ],
  );

  return DrawerHeader(
    padding: EdgeInsets.all(0),
    margin: EdgeInsets.all(0),
    child: Container(
      padding: EdgeInsets.all(15),
      color: olracBlue[50],
      child: Stack(
        children: <Widget>[
          Container(
            child: Image(
              image: AssetImage('assets/images/olsps-logo.png'),
              width: 100,
            ),
            alignment: Alignment.topRight,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  vesselName,
                  skipperName,
                ],
              ),
            ],
          )
        ],
      ),
    ),
  );
}

class MainDrawer extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  Widget _listTile({IconData iconData, String text, Function onTap}) {
    return Builder(
      builder: (BuildContext context) {
        return ListTile(
          leading: Icon(
            iconData,
            color: olracBlue,
            size: 36,
          ),
          title: Text(
            text,
            style: TextStyle(fontSize: _drawerItemFontSize, color: Colors.black),
          ),
          onTap: onTap,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: Container(
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            _drawerHeader(_appStore.profile),
            Divider(
              color: olracBlue,
              height: 0,
              thickness: 5,
            ),
            _listTile(
              iconData: Icons.history,
              text: 'Trip History',
              onTap: () => Navigator.pushNamed(context, '/trip_history'),
            ),
            _listTile(
              iconData: Icons.inbox,
              text: 'Master Containers',
              onTap: () => Navigator.pushNamed(context, '/master_containers'),
            ),
            _listTile(
              iconData: Icons.settings,
              text: 'Settings',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _listTile(
              iconData: Icons.info,
              text: 'About',
              onTap: () => Navigator.pushNamed(context, '/about'),
            ),
          ],
        ),
      ),
    );
  }
}
