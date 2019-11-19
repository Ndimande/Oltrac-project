import 'package:flutter/material.dart';

class AppConfig {
  static const resetDatabaseOnRestart = false;

  /// The title of the app
  static const appTitle = 'OlTrace';

  /// The sqlite database filename
  static const databaseFilename = 'oltrace.db';

  static const _dividerThemeData =
      DividerThemeData(thickness: 2, space: 2, indent: 10, endIndent: 10);

  /// Material app global theme data
  static final materialAppTheme = ThemeData(
      primarySwatch: Colors.blueGrey,
      accentColor: Colors.deepOrangeAccent,
      dividerTheme: _dividerThemeData);

  static final migrations = _migrations;
}

final List<Map<String, String>> _migrations = const [
  {
    'name': 'create_trips',
    'up': 'CREATE TABLE trips ( '
        'id INTEGER PRIMARY KEY, '
        'json TEXT '
        ')',
    'down': 'DROP TABLE trips'
  },
//  {
//    'name': 'create_trips_table',
//    'up': 'CREATE TABLE trips ( '
//        'id INTEGER PRIMARY KEY, '
//        'uuid TEXT, '
//        'vessel_name TEXT, '
//        'skipper_name TEXT, '
//        'country TEXT, '
//        'fishery_name TEXT, '
//        'fishing_license_number TEXT, '
//        'started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, '
//        'ended_at TIMESTAMP'
//        ')',
//    'down': 'DROP TABLE trips'
//  },
//  {
//    'name': 'create_hauls_table',
//    'up': 'CREATE TABLE hauls ( '
//        'id INTEGER PRIMARY KEY, '
//        'created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, '
//        'trip_id INTEGER, '
//        'FOREIGN KEY (trip_id) REFERENCES trips (id)'
//        ')',
//    'down': 'DROP TABLE hauls'
//  },
//  {
//    'name': 'create_tags_table',
//    'up': 'CREATE TABLE tags ( '
//        'id INTEGER PRIMARY KEY, '
//        'created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, '
//        'haul_id INTEGER, '
//        'FOREIGN KEY (haul_id) REFERENCES hauls (id)'
//        ')',
//    'down': 'DROP TABLE tags'
//  },
];
