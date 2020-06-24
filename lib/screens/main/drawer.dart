import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/models/profile.dart';

const double drawerLabelFontSize = 20;
const double drawerTextFontSize = 26;

Widget _drawerHeader(Profile profile) {
  return Builder(builder: (context) {
    final vesselName = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Vessel Name',
          style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          profile.vesselName,
          style: Theme.of(context).primaryTextTheme.headline4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final skipperName = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Skipper Name',
          style: Theme.of(context).textTheme.caption.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          profile.skipper.firstName + ' ' + profile.skipper.lastName,
          style: Theme.of(context).primaryTextTheme.headline4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return DrawerHeader(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.all(15),
        color: OlracColours.fauxPasBlue[50],
        child: Stack(
          children: <Widget>[
            Container(
              child: const Image(image: AssetImage('assets/images/olsps-logo.png'), width: 100),
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
  });
}

class MainDrawer extends StatelessWidget {
  Widget _listTile({IconData iconData, String text, Function onTap}) {
    return Builder(
      builder: (BuildContext context) {
        return ListTile(
          leading: Icon(
            iconData,
            color: OlracColours.fauxPasBlue,
            size: 36,
          ),
          title: Text(
            text,
            style: Theme.of(context).textTheme.headline5,
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
            _drawerHeader(AppData.profile),
            const Divider(
              color: OlracColours.fauxPasBlue,
              height: 0,
              thickness: 5,
            ),
            _listTile(
              iconData: Icons.history,
              text: 'Trip History',
              onTap: () => Navigator.pushNamed(context, '/trip_history'),
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
