import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/coordinate.dart';

@immutable
class Location extends Model {
  /// Latitude in radians
  final double latitude;

  /// Longitude in radians
  final double longitude;

  const Location({
    @required this.latitude,
    @required this.longitude,
  });

  String get sexagesimalLatitude {
    return Coordinate.fromDecimal(
      decimalValue: latitude,
      coordinateOrientation: CoordinateOrientation.Latitude,
    ).sexagesimalString;
  }

  String get sexagesimalLongitude {
    return Coordinate.fromDecimal(
      decimalValue: longitude,
      coordinateOrientation: CoordinateOrientation.Longitude,
    ).sexagesimalString;
  }

  Location.fromPosition(Position position)
      : latitude = position.latitude,
        longitude = position.longitude;

  @override
  String toString() => "$sexagesimalLatitude, $sexagesimalLongitude";

  String toMultilineString() => "$sexagesimalLatitude\n $sexagesimalLongitude";

  @override
  Model copyWith({double latitude, double longitude}) {
    return Location(latitude: latitude ?? this.latitude, longitude: longitude ?? this.longitude);
  }

  Location.fromMap(Map data)
      : latitude = data['latitude'],
        longitude = data['longitude'];

  @override
  Map<String, double> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Converts a decimal coordinate value to sexagesimal format
///
///     final String sexa1 = _decimal2sexagesimal(51.519475);
///     expect(sexa1, '51° 31\' 10.11"');
///
//String _decimal2sexagesimal(final double dec) {
//  List<int> _split(final double value) {
//    // NumberFormat is necessary to create digit after comma if the value
//    // has no decimal point (only necessary for browser)
//    final List<String> tmp =
//        new NumberFormat("0.0#####").format(roundDouble(value, decimals: 10)).split('.');
//    return <int>[int.parse(tmp[0]).abs(), int.parse(tmp[1])];
//  }
//
//  final List<int> parts = _split(dec);
//  final int integerPart = parts[0];
//  final int fractionalPart = parts[1];
//
//  final int deg = integerPart;
//  final double min = double.parse("0.$fractionalPart") * 60;
//
//  final List<int> minParts = _split(min);
//  final int minFractionalPart = minParts[1];
//
//  final double sec = double.parse("0.$minFractionalPart") * 60;
//
//  return "$deg° ${min.floor()}' ${roundDouble(sec, decimals: 2).toStringAsFixed(2)}\"";
//}
