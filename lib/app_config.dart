import 'package:flutter/material.dart';
import 'package:oltrace/app_migrations.dart';

class AppConfig {
  /// Drop and recreate the database if true
  static const resetDatabaseOnRestart = true;

  /// The title of the app
  static const appTitle = 'OlTrace';

  /// The sqlite database filename
  static const databaseFilename = 'oltrace.db';

  static final backgroundColor = Colors.blueGrey[900];

  static final primarySwatch = Colors.blueGrey;
  static final primarySwatchDark = Colors.blueGrey[700];

  static final accentColor = Colors.deepOrange;

  static final textColor1 = Colors.white;
  static final textColor2 = Colors.blueGrey[200];

  static final _dividerThemeData = DividerThemeData(
    thickness: 2,
    space: 2,
    indent: 10,
    endIndent: 10,
    color: primarySwatch,
  );

  /// Material app global theme data
  static final materialAppTheme = ThemeData(
    inputDecorationTheme: InputDecorationTheme(
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 3,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.red,
          width: 3,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppConfig.accentColor,
          width: 3,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: AppConfig.primarySwatch,
          width: 2,
        ),
      ),

      contentPadding: EdgeInsets.symmetric(
        vertical: 22,
        horizontal: 30,
      ),
      labelStyle: TextStyle(
        fontSize: 26,
        color: AppConfig.primarySwatchDark,
      ),
      helperStyle: TextStyle(
        fontSize: 16,
        color: AppConfig.textColor1,
      ),

//      prefixStyle: TextStyle(
//        fontSize: 35,
//        color: Colors.pink,
//      ),
//      suffixStyle: TextStyle(
//        fontSize: 35,
//        color: Colors.pink,
//      ),

//      counterStyle: TextStyle(
//        fontSize: 35,
//        color: Colors.pink,
//      ),
      focusColor: Colors.pink,
      fillColor: Colors.pink,
      hoverColor: Colors.pink,
    ),
    canvasColor: AppConfig.primarySwatch,
    buttonColor: primarySwatch,
    textTheme: TextTheme(
      body1: TextStyle(color: textColor1),
      body2: TextStyle(color: Colors.white), // Drawer menu items
      button: TextStyle(color: Colors.pink),
      display1: TextStyle(color: Colors.pink),
      display2: TextStyle(color: Colors.pink),
      display3: TextStyle(color: Colors.pink),
      caption: TextStyle(color: Colors.white70), // List item caption
      title: TextStyle(color: Colors.pink),
      subtitle: TextStyle(color: Colors.pink),
      headline: TextStyle(color: Colors.pink),
      subhead: TextStyle(color: textColor1), // List item heading
      display4: TextStyle(color: Colors.pink),
      overline: TextStyle(color: Colors.pink),
    ),
    accentTextTheme: TextTheme(
      body1: TextStyle(color: Colors.pink),
      body2: TextStyle(color: Colors.pink), // Drawer menu items
      button: TextStyle(color: Colors.pink),
      display1: TextStyle(color: Colors.pink),
      display2: TextStyle(color: Colors.pink),
      display3: TextStyle(color: Colors.pink),
      caption: TextStyle(color: Colors.pink), // List item caption
      title: TextStyle(color: Colors.pink),
      subtitle: TextStyle(color: Colors.pink),
      headline: TextStyle(color: Colors.pink),
      subhead: TextStyle(color: Colors.pink), // List item heading
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
