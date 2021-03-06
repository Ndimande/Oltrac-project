import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:oltrace/models/location.dart';

class LocationButton extends StatelessWidget {
  final Location location;
  final double iconSize;

  LocationButton({this.location, this.iconSize = 26});

  Function get onPressLocation => location == null
      ? () {}
      : () async => await MapsLauncher.launchCoordinates(
            location.latitude,
            location.longitude,
          );

  @override
  Widget build(BuildContext context) {
    final Function onPressLocation = location == null
        ? () {}
        : () async => await MapsLauncher.launchCoordinates(
              location.latitude,
              location.longitude,
            );
    return IconButton(
      alignment: Alignment.centerLeft,
      tooltip: location.toString(),
      iconSize: iconSize,
      icon: Icon(Icons.my_location),
      onPressed: onPressLocation,
    );
  }
}
