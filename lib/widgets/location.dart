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
  final Geolocator geoLocator = Geolocator();
  Position _currentPosition;

  _updatePosition() async {
    final position = await geoLocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    setState(() {
      if (mounted) {
        _currentPosition = position;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _updatePosition().then(() {
      updateTimer = Timer.periodic(Duration(seconds: 10), (Timer timer) {
        _updatePosition();
      });
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
