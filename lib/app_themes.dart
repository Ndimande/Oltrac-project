import 'package:flutter/material.dart';

final Map<String, ThemeData> appThemes = {'dark': _darkTheme, 'light': _olspsTheme};

const MaterialColor olracBlue = MaterialColor(0xFF458196, {
  50: Color.fromRGBO(4, 131, 184, .1),
  100: Color.fromRGBO(4, 131, 184, .2),
  200: Color.fromRGBO(4, 131, 184, .3),
  300: Color.fromRGBO(4, 131, 184, .4),
  400: Color.fromRGBO(4, 131, 184, .5),
  500: Color.fromRGBO(4, 131, 184, .6),
  600: Color.fromRGBO(4, 131, 184, .7),
  700: Color.fromRGBO(4, 131, 184, .8),
  800: Color.fromRGBO(4, 131, 184, .9),
  900: Color.fromRGBO(4, 131, 184, 1),
});

const MaterialColor olracDarkBlue = MaterialColor(0xFF242C4D, {
  50: Color.fromRGBO(4, 131, 184, .1),
  100: Color.fromRGBO(4, 131, 184, .2),
  200: Color.fromRGBO(4, 131, 184, .3),
  300: Color.fromRGBO(4, 131, 184, .4),
  400: Color.fromRGBO(4, 131, 184, .5),
  500: Color.fromRGBO(4, 131, 184, .6),
  600: Color.fromRGBO(4, 131, 184, .7),
  700: Color.fromRGBO(4, 131, 184, .8),
  800: Color.fromRGBO(4, 131, 184, .9),
  900: Color.fromRGBO(4, 131, 184, 1),
});

final _olspsTheme = ThemeData(
//  dialogBackgroundColor: olracBlue,
  dialogTheme: DialogTheme(
    backgroundColor: olracBlue,
    titleTextStyle: TextStyle(fontSize: 32, color: Colors.white),
    contentTextStyle: TextStyle(fontSize: 20, color: Colors.white),
  ),
  primarySwatch: olracBlue,
  accentColor: olracBlue,
  textTheme: TextTheme(
    body1: TextStyle(color: Colors.black),
    body2: TextStyle(color: Colors.black),
    // Drawer menu items
    caption: TextStyle(color: Colors.black),
    // List item caption
    subhead: TextStyle(color: Colors.black),
    // List item heading / Car items
    display1: TextStyle(color: Colors.lightGreen),
    display2: TextStyle(color: Colors.lightGreen),
    display3: TextStyle(color: Colors.lightGreen),
    display4: TextStyle(color: Colors.lightGreen),
    button: TextStyle(color: Colors.lightGreen),
    title: TextStyle(color: Colors.lightGreen),
    headline: TextStyle(color: Colors.lightGreen),
    subtitle: TextStyle(color: Colors.lightGreen),
    overline: TextStyle(color: Colors.lightGreen),
  ),
  highlightColor: olracBlue,
  accentTextTheme: TextTheme(
    body1: TextStyle(color: Colors.lightGreen),
    body2: TextStyle(color: Colors.lightGreen),
    // Drawer menu items
    caption: TextStyle(color: Colors.lightGreen),
    // List item caption
    subhead: TextStyle(color: Colors.red),
    // List item heading / Car items
    display1: TextStyle(color: Colors.red),
    display2: TextStyle(color: Colors.red),
    display3: TextStyle(color: Colors.red),
    display4: TextStyle(color: Colors.red),
    button: TextStyle(color: Colors.red),
    title: TextStyle(color: Colors.red),
    headline: TextStyle(color: Colors.red),
    subtitle: TextStyle(color: Colors.red),
    overline: TextStyle(color: Colors.red),
  ),
  primaryTextTheme: TextTheme(
    body1: TextStyle(color: Colors.white),
    body2: TextStyle(color: Colors.red),
    // Drawer menu items
    caption: TextStyle(color: Colors.red),
    // List item caption
    subhead: TextStyle(color: Colors.red),
    // List item heading / Car items
    display1: TextStyle(color: Colors.red),
    display2: TextStyle(color: Colors.red),
    display3: TextStyle(color: Colors.red),
    display4: TextStyle(color: Colors.red),
    button: TextStyle(color: Colors.red),
    title: TextStyle(color: Colors.white),
    headline: TextStyle(color: Colors.red),
    subtitle: TextStyle(color: Colors.red),
    overline: TextStyle(color: Colors.red),
  ),
  buttonColor: Colors.lime,
  buttonTheme: ButtonThemeData(buttonColor: olracBlue, textTheme: ButtonTextTheme.primary),
  secondaryHeaderColor: Colors.orange,
  colorScheme: ColorScheme.light(primary: Colors.white),
  scaffoldBackgroundColor: Colors.white,
  cardTheme: CardTheme(
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  ),
  snackBarTheme: SnackBarThemeData(
    contentTextStyle: TextStyle(fontSize: 18),
  ),
);

final _darkTheme = ThemeData(
  snackBarTheme: SnackBarThemeData(
    actionTextColor: Colors.deepOrangeAccent,
    contentTextStyle: TextStyle(color: Colors.white, fontSize: 18),
    backgroundColor: Colors.black,
  ),
  scaffoldBackgroundColor: Colors.grey[900],
  cardTheme: CardTheme(
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.grey[750],
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
        color: Colors.deepOrangeAccent,
        width: 3,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.grey,
        width: 2,
      ),
    ),
    contentPadding: EdgeInsets.symmetric(
      vertical: 22,
      horizontal: 30,
    ),
    labelStyle: TextStyle(
      fontSize: 26,
      color: Colors.grey[750],
    ),
    helperStyle: TextStyle(
      fontSize: 16,
      color: Colors.white,
    ),
  ),
  canvasColor: Colors.grey[750],
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.grey,
    textTheme: ButtonTextTheme.primary,
  ),
  textTheme: TextTheme(
    body1: TextStyle(color: Colors.white),
    body2: TextStyle(color: Colors.white), // Drawer menu items
    caption: TextStyle(color: Colors.white70), // List item caption
    subhead: TextStyle(color: Colors.white), // List item heading / Car items
  ),
  backgroundColor: Colors.grey[900],
  primarySwatch: Colors.grey,
  accentColor: Colors.deepOrangeAccent,
  dividerTheme: DividerThemeData(
    thickness: 4,
    space: 3,
    color: Colors.deepOrange[400],
  ),
  brightness: Brightness.dark,
);
