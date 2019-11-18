import 'package:flutter/material.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/screens/welcome.dart';

void main() => runApp(OlTraceApp());

class OlTraceApp extends StatelessWidget {
  final AppStore _appStore = AppStore();

  OlTraceApp() {
//    _appStore.setVessel(Vessel(
//        fisheryType: FisheryType(name: 'foo'),
//        name: 'a',
//        country: Country(name: 'a'),
//        skipper: Skipper(name: 'a')));
  }

  @override
  Widget build(BuildContext context) {
    // If no vessel is set, show the welcome screen
    final initialRoute = _appStore.vessel == null ? '/welcome' : '/';
    return MaterialApp(
      title: 'OlTrace',
      theme: ThemeData(
          primarySwatch: Colors.blueGrey, accentColor: Colors.deepOrangeAccent),
      initialRoute: initialRoute,
      routes: {
        '/': (context) => MainScreen(_appStore),
        '/about': (context) => AboutScreen(),
        '/trip': (context) => TripScreen(_appStore),
        '/fishing_methods': (context) => FishingMethodScreen(),
        '/welcome': (context) => WelcomeScreen(_appStore),
      },
    );
  }
}
