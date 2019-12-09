import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

import 'package:oltrace/framework/model.dart';

/// Create sexagesimal position from radian position.
///
///     final pos = SexagesimalPosition(-12.4343,23.223);
///     final sexagesimalLat = pos.latitude;
///     final sexagesimalLon = pos.longitude;
///
@immutable
class Location extends Model {
  /// Latitude in radians
  final double latitude;

  /// Longitude in radians
  final double longitude;

  Location({
    @required this.latitude,
    @required this.longitude,
  });

  String get sexagesimalLat {
    final direction = latitude >= 0 ? "N" : "S";
    return _decimal2sexagesimal(latitude) + ' ' + direction;
  }

  String get sexagesimalLon {
    final direction = longitude >= 0 ? "E" : "W";
    return _decimal2sexagesimal(longitude) + ' ' + direction;
  }

  Location.fromPosition(Position position)
      : latitude = position.latitude,
        longitude = position.longitude;

  @override
  String toString() => "$sexagesimalLat, $sexagesimalLon";

  @override
  Model copyWith({double latitude, double longitude}) {
    return Location(latitude: latitude, longitude: longitude);
  }

  Location.fromMap(Map data)
      : latitude = data['latitudeRadians'],
        longitude = data['longitudeRadians'];

  @override
  Map<String, double> toMap() {
    return {
      'latitudeRadians': latitude,
      'longitudeRadians': longitude,
    };
  }
}

/// Converts a decimal coordinate value to sexagesimal format
///
///     final String sexa1 = _decimal2sexagesimal(51.519475);
///     expect(sexa1, '51° 31\' 10.11"');
///
String _decimal2sexagesimal(final double dec) {
  List<int> _split(final double value) {
    // NumberFormat is necessary to create digit after comma if the value
    // has no decimal point (only necessary for browser)
    final List<String> tmp =
        new NumberFormat("0.0#####").format(_round(value, decimals: 10)).split('.');
    return <int>[int.parse(tmp[0]).abs(), int.parse(tmp[1])];
  }

  final List<int> parts = _split(dec);
  final int integerPart = parts[0];
  final int fractionalPart = parts[1];

  final int deg = integerPart;
  final double min = double.parse("0.$fractionalPart") * 60;

  final List<int> minParts = _split(min);
  final int minFractionalPart = minParts[1];

  final double sec = double.parse("0.$minFractionalPart") * 60;

  return "$deg° ${min.floor()}' ${_round(sec, decimals: 2).toStringAsFixed(2)}\"";
}

/// Rounds [value] to given number of [decimals]
double _round(final double value, {final int decimals: 6}) =>
    (value * math.pow(10, decimals)).round() / math.pow(10, decimals);
