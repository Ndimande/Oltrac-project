import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/info_table.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

final _jsonRepo = JsonRepository();

Future<Map> _load() async {
  final Map result = await _jsonRepo.get('profile');
  final Profile profile = Profile.fromMap(result);
  final int backgroundFetchStatus = await BackgroundFetch.status;
  return {
    'profile': profile,
    'backgroundFetchStatus': backgroundFetchStatus,
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
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Profile _profile;
  int _backgroundFetchStatus;

  Widget _version() => Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
          AppConfig.APP_TITLE + ' ' + AppData.packageInfo.version + ' build ' + AppData.packageInfo.buildNumber));

  Future _resetDatabase() async {
    await widget.sharedPreferences.remove('mobileData');
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
    final String mobileData = widget.sharedPreferences.getBool('mobileData').toString();
    final String uploadAutomatically = widget.sharedPreferences.getBool('uploadAutomatically').toString();
    final String fishingMethod = widget.sharedPreferences.getString('fishingMethod').toString();
    return InfoTable(
      title: 'SharedPrefs',
      data: [
        ['mobileData', mobileData],
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

  Widget _backgroundFetch() {
    return InfoTable(
      title: 'BackgroundFetch',
      data: [
        ['status', _backgroundFetchStatus.toString()]
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
          _backgroundFetchStatus = snapshot.data['backgroundFetchStatus'] as int;
          return SingleChildScrollView(
            child: Column(
              children: <Widget>[
                _version(),
                _buildProfile(),
                _sharedPrefs(),
                _environment(),
                _backgroundFetch(),
                _TripUploadQueue(),
                _resetApp(),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TripUploadQueue extends StatefulWidget {
  @override
  _TripUploadQueueState createState() => _TripUploadQueueState();
}

class _TripUploadQueueState extends State<_TripUploadQueue> {
  int seconds = 0;
  List<Trip> _trips = [];
  Timer _timer;
  Future<List<Trip>> _getTrips() async {
    final tripRepo = TripRepository();
    return await tripRepo.all();
  }

  _getTripsAndRefresh() {
    _getTrips().then((List<Trip> trips) {
      setState(() {
        _trips = trips;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _getTripsAndRefresh();

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      _getTripsAndRefresh();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<List> dataRows =
        _trips.map((Trip t) => [t.id.toString(), t.isUploaded ? 'Uploaded' : 'Not Uploaded']).toList();
    return InfoTable(
      title: 'Trip Upload Status',
      data: dataRows,
    );
  }
}
