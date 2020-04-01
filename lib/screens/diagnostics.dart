import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/info_table.dart';
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

class DiagnosticsScreen extends StatefulWidget {
  final SharedPreferences sharedPreferences = SharedPreferencesProvider().sharedPreferences;

  @override
  State<StatefulWidget> createState() {
    return DiagnosticsScreenState();
  }
}

class DiagnosticsScreenState extends State<DiagnosticsScreen> {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Profile _profile;

  Widget _version() => Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
          AppConfig.APP_TITLE + ' ' + _appStore.packageInfo.version + ' build ' + _appStore.packageInfo.buildNumber));

  Future _resetDatabase() async {
    await widget.sharedPreferences.remove('darkMode');
    await widget.sharedPreferences.remove('allowMobileData');
    await widget.sharedPreferences.remove('uploadAutomatically');
    await widget.sharedPreferences.remove('fishingMethod');
    final Database database = DatabaseProvider().database;
    final Migrator migrator = Migrator(database, AppConfig.migrations);
    await migrator.run(true);
  }

  Widget _buildProfile() {
    return InfoTable(
      title: 'Profile',
      data: [
        ['UUID', '...' + _profile.uuid.toString().substring(10)],
        ['First Name', _profile.skipper.firstName],
        ['Last Name', _profile.skipper.lastName],
        ['Country Name', _profile.country.name],
        ['Country Code', _profile.country.iso3166Alpha3],
        ['Fishery Type', _profile.fisheryType.name],
        ['Jurisdiction', _profile.fisheryType.jurisdiction],
        ['SAFS Code', _profile.fisheryType.safsCode],
        ['Fishing License No.', _profile.fishingLicenseNumber.toString()],
      ],
    );
  }

  Widget _sharedPrefs() {
    final String darkMode = widget.sharedPreferences.getBool('darkMode').toString();
    final String allowMobileData = widget.sharedPreferences.getBool('allowMobileData').toString();
    final String uploadAutomatically = widget.sharedPreferences.getBool('uploadAutomatically').toString();
    final String fishingMethod = widget.sharedPreferences.getString('fishingMethod').toString();
    return InfoTable(
      title: 'SharedPrefs',
      data: [
        ['darkMode', darkMode],
        ['allowMobileData', allowMobileData],
        ['uploadAutomatically', uploadAutomatically],
        ['fishingMethod', fishingMethod],
      ],
    );
  }

  Widget _environment() {
    return InfoTable(
      title: 'Environment',
      data: [
        ['debugMode', AppConfig.debugMode.toString()],
        ['TRIP_UPLOAD_URL', AppConfig.TRIP_UPLOAD_URL],
        ['MAX_SOAK_HOURS_SELECTABLE', AppConfig.MAX_SOAK_HOURS_SELECTABLE.toString()],
        ['MAX_HISTORY_SELECTABLE', AppConfig.MAX_HISTORY_SELECTABLE.toString()],
        ['DATABASE_FILENAME', AppConfig.DATABASE_FILENAME],
        ['RESET_DATABASE', AppConfig.RESET_DATABASE.toString()],
        [
          'SENTRY_DSN',
          '...' + AppConfig.SENTRY_DSN.substring(AppConfig.SENTRY_DSN.length - 5, AppConfig.SENTRY_DSN.length)
        ],
      ],
    );
  }

  Widget _resetApp() {
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
      appBar: AppBar(title: Text('Diagnostics')),
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
                _version(),
                _buildProfile(),
                _sharedPrefs(),
                _environment(),
                _resetApp(),
              ],
            ),
          );
        },
      ),
    );
  }
}
