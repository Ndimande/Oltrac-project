import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class Location extends StatefulWidget {
  @override
  LocationState createState() => LocationState();

  Location();
}

class LocationState extends State<Location> {
  Timer updateTimer;
  final Geolocator geolocator = Geolocator();
  Position _currentPosition;

  @override
  void initState() {
    super.initState();
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) => print(e));
    updateTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
      geolocator
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
          .then((Position position) {
        setState(() {
          _currentPosition = position;
        });
      }).catchError((e) => print(e));
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition == null) {
      return Text('null');
    }
    return Text(_currentPosition.toString());
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }
}
