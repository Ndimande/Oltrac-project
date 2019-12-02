import 'package:flutter/material.dart';
import 'package:oltrace/app_migrations.dart';

class AppConfig {
  /// Drop and recreate the database if true
  static const resetDatabaseOnRestart = false;

  /// The title of the app
  static const appTitle = 'OlTrace';

  /// The sqlite database filename
  static const databaseFilename = 'oltrace.db';

  static final backgroundColor = Colors.blueGrey[900];

  static final primarySwatch = Colors.blueGrey;

  static final accentColor = Colors.deepOrange;

  static final _dividerThemeData = DividerThemeData(
    thickness: 2,
    space: 2,
    indent: 10,
    endIndent: 10,
    color: primarySwatch,
  );

  /// Material app global theme data
  static final materialAppTheme = ThemeData(
    textTheme: TextTheme(
      body1: TextStyle(color: Colors.white),
      body2: TextStyle(color: Colors.black), // Drawer menu items
      button: TextStyle(color: Colors.pink),
      display1: TextStyle(color: Colors.pink),
      display2: TextStyle(color: Colors.pink),
      caption: TextStyle(color: Colors.white70), // List item caption
      title: TextStyle(color: Colors.pink),
      subtitle: TextStyle(color: Colors.pink),
      headline: TextStyle(color: Colors.lightGreenAccent),
      subhead: TextStyle(color: Colors.white), // List item heading
      display4: TextStyle(color: Colors.pink),
      overline: TextStyle(color: Colors.pink),
    ),
    backgroundColor: backgroundColor,
    primarySwatch: primarySwatch,
    accentColor: accentColor,
    dividerTheme: _dividerThemeData,
  );

  static final migrations = appMigrations;
}
