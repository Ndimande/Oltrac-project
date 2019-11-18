import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationCoords extends StatefulWidget {
  @override
  LocationCoordsState createState() => LocationCoordsState();

  LocationCoords();
}

class LocationCoordsState extends State<LocationCoords> {
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
      return Text('-');
    }
    return Text(_currentPosition.toString());
  }

  @override
  void dispose() {
    updateTimer.cancel();
    super.dispose();
  }
}
