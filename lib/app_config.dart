import 'package:flutter/material.dart';
import 'package:oltrace/app_migrations.dart';

/// Global flags.
/// These values are checked by
/// git before you commit to avoid bad
/// production values.
///
/// Enables / disables development features
/// like buttons to fake data etc.
const DEV_MODE = false;

/// Drop and recreate the database if true
const RESET_DATABASE = false;

class AppConfig {
  /// Drop and recreate the database if true
  static const resetDatabaseOnRestart = RESET_DATABASE;

  /// Emulators cannot fake RFID/NFC scan
  /// so we need a button to do this manually.
  static const fakeRfidButton = DEV_MODE;

  /// The title of the app
  static const appTitle = 'OlTrace';

  /// The sqlite database filename
  static const databaseFilename = 'oltrace.db';

  static final backgroundColor = Colors.grey[900];

  static final primarySwatch = Colors.grey;

  static final primarySwatchDark = Colors.grey[750];

  static final accentColor = Colors.deepOrangeAccent;

  static final textColor1 = Colors.white;

  static final textColor2 = Colors.grey[500];

  static final _dividerThemeData = DividerThemeData(
    thickness: 4,
    space: 3,
    indent: 10,
    endIndent: 10,
    color: accentColor,
  );

  /// Material app global theme data
  static final materialAppTheme = ThemeData(
    snackBarTheme: SnackBarThemeData(
      actionTextColor: accentColor,
      contentTextStyle: TextStyle(color: Colors.white, fontSize: 18),
      backgroundColor: Colors.black,
    ),
    scaffoldBackgroundColor: AppConfig.backgroundColor,
    cardTheme: CardTheme(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: AppConfig.primarySwatchDark,
      titleTextStyle: TextStyle(fontSize: 32),
      contentTextStyle: TextStyle(fontSize: 20),
    ),
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
      focusColor: Colors.pink,
      fillColor: Colors.pink,
      hoverColor: Colors.pink,
    ),
    canvasColor: primarySwatchDark,
    buttonTheme: ButtonThemeData(
      buttonColor: primarySwatch,
      textTheme: ButtonTextTheme.primary,
    ),
    textTheme: TextTheme(
      body1: TextStyle(color: textColor1),
      body2: TextStyle(color: textColor1), // Drawer menu items
      button: TextStyle(color: Colors.pink),
      display1: TextStyle(color: Colors.pink),
      display2: TextStyle(color: Colors.pink),
      display3: TextStyle(color: Colors.pink),
      caption: TextStyle(color: Colors.white70), // List item caption
      title: TextStyle(color: Colors.pink),
      subtitle: TextStyle(color: Colors.pink),
      headline: TextStyle(color: Colors.pink),
      subhead: TextStyle(color: textColor1), // List item heading / Car items
      display4: TextStyle(color: Colors.pink),
      overline: TextStyle(color: Colors.pink),
    ),
    // Appears to do nothing
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
    brightness: Brightness.dark,
  );

  static final migrations = appMigrations;
}
