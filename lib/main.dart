import 'package:flutter/material.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/main.dart';

void main() => runApp(OlTraceApp());

class OlTraceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OlTrace',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}
