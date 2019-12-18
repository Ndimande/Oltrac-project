import 'package:flutter/material.dart';

final Map<String, ThemeData> appThemes = {'dark': _darkTheme, 'light': _olspsTheme};

MaterialColor olracBlue = MaterialColor(0xFF458196, {
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
  primarySwatch: olracBlue,
  accentColor: olracBlue,
  dialogTheme: DialogTheme(
    titleTextStyle: TextStyle(fontSize: 32, color: Colors.black),
    contentTextStyle: TextStyle(fontSize: 20, color: Colors.black),
  ),
  textTheme: TextTheme(
    body1: TextStyle(color: Colors.black),
    body2: TextStyle(color: Colors.black), // Drawer menu items
    caption: TextStyle(color: Colors.black), // List item caption
    subhead: TextStyle(color: Colors.black), // List item heading / Car items
  ),
  canvasColor: Colors.white,
  scaffoldBackgroundColor: Colors.white,
  dividerTheme: DividerThemeData(
    thickness: 4,
    space: 3,
    color: olracBlue,
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
    focusColor: Colors.pink,
    fillColor: Colors.pink,
    hoverColor: Colors.pink,
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
