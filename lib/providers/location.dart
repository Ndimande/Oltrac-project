import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:oltrace/models/location.dart';

class LocationProvider {
  final Geolocator _geoLocator = Geolocator()..forceAndroidLocationManager = true;

  Position _position;
  StreamSubscription<Position> _positionStream;

  static final LocationProvider _locationProvider = LocationProvider._();

  bool listening = false;

  LocationProvider._();

  factory LocationProvider() {
    return _locationProvider;
  }

  Future<bool> get locationServiceEnabled async => await _geoLocator.isLocationServiceEnabled();

  startListening({LocationAccuracy accuracy = LocationAccuracy.high, int distanceFilter = 10}) {
    final locationOptions = LocationOptions(accuracy: accuracy, distanceFilter: distanceFilter);
    if (!listening) {
      _positionStream = _geoLocator.getPositionStream(locationOptions).listen((Position position) {
        print('locationProvider ' + _position.toString());
        _position = position;
      }, onError: (e) => print('Could not establish location stream.'));
      listening = true;
    }
  }

  stopListening() {
    _positionStream.cancel();
    listening = false;
  }

  Future<Location> get location async {
    if (!await _geoLocator.isLocationServiceEnabled()) {
      return null;
    }

    final Position position =
        await _geoLocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low);
    if (position == null) {
      return null;
    }

    return Location.fromPosition(_position);
  }

  Future<GeolocationStatus> get geolocationPermissionStatus async {
    return await _geoLocator.checkGeolocationPermissionStatus();
  }

  Future<bool> get permissionGranted async =>
      await geolocationPermissionStatus == GeolocationStatus.granted;
}
