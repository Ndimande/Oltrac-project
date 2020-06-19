import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:oltrace/models/location.dart';

class LocationButton extends StatelessWidget {
  final Location location;
  final double iconSize;

  const LocationButton({@required this.location, this.iconSize = 30}) : assert(location != null);

  Future<bool> onPressLocation() async => await MapsLauncher.launchCoordinates(location.latitude, location.longitude);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      width: iconSize * 1.2,
      height: iconSize * 1.2,
      child: FlatButton(
        padding: const EdgeInsets.all(0),
        child: Icon(Icons.location_on, size: iconSize, color: Theme.of(context).primaryColor),
        onPressed: onPressLocation,
      ),
    );
  }
}
