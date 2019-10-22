import 'package:flutter/material.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/main.dart';

void main() => runApp(OlTraceApp());

class OlTraceApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OlTrace',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => MainScreen(),
        '/about': (context) => AboutScreen(),
      },
    );
  }
}
