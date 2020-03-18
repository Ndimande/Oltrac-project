import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

const _headingStyle = TextStyle(color: olracBlue, fontWeight: FontWeight.bold, fontSize: 20);

final _jsonRepo = JsonRepository();

Future<Map> _load() async {
  final Map result = await _jsonRepo.get('profile');
  final Profile profile = Profile.fromMap(result);
  return {
    'profile': profile,
  };
}

class DeveloperScreen extends StatefulWidget {
  final SharedPreferences sharedPreferences = SharedPreferencesProvider().sharedPreferences;

  @override
  State<StatefulWidget> createState() {
    return DeveloperScreenState();
  }
}

class DeveloperScreenState extends State<DeveloperScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Profile _profile;

  Widget _heading(String text) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: _headingStyle),
    );
  }

  Widget _buildProfile() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _heading('Profile'),
          Table(
            children: <TableRow>[
              _profileRow('UUID', _profile.uuid.toString()),
              _profileRow('ID', _profile.id.toString()),
              _profileRow('First Name', _profile.skipper.firstName),
              _profileRow('Last Name', _profile.skipper.lastName),
              _profileRow('Country Name', _profile.country.name),
              _profileRow('Country Code', _profile.country.iso3166Alpha3),
              _profileRow('Fishery Type', _profile.fisheryType.name),
              _profileRow('Jurisdiction', _profile.fisheryType.jurisdiction),
              _profileRow('SAFS Code', _profile.fisheryType.safsCode),
              _profileRow('Fishing License No.', _profile.fishingLicenseNumber.toString()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSettings() {
    final darkMode = widget.sharedPreferences.getBool('darkMode');
    final allowMobileData = widget.sharedPreferences.getBool('allowMobileData');
    final uploadAutomatically = widget.sharedPreferences.getBool('uploadAutomatically');
    return Container(
      padding: EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _heading('Settings'),
          Table(
            children: <TableRow>[
              _profileRow('darkMode', darkMode.toString()),
              _profileRow('allowMobileData', allowMobileData.toString()),
              _profileRow('uploadAutomatically', uploadAutomatically.toString()),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildReset() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          Text(
            'Tap and hold the button to reset the app.\nWarning! All data will be deleted!',
            textAlign: TextAlign.center,
          ),
          RaisedButton(
            color: Colors.red,
            onPressed: () {
              showTextSnackBar(_scaffoldKey, 'Press and hold to reset');
            },
            onLongPress: () async {
              await _resetDatabase();
              await Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
            },
            child: Text('Reset App'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Diagnostics'),
      ),
      body: FutureBuilder(
        future: _load(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Container();
          }
          _profile = snapshot.data['profile'];

          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _buildProfile(),
                _buildSettings(),
                _buildReset(),
              ],
            ),
          );
        },
      ),
    );
  }
}

TableRow _profileRow(String left, String right) => TableRow(
      children: <Widget>[
        Text(left),
        Text(right),
      ],
    );

Future _resetDatabase() async {
  final Database database = DatabaseProvider().database;
  final Migrator migrator = Migrator(database, AppConfig.migrations);
  await migrator.run(true);
}
