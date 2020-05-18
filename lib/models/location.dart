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
      : assert(position != null),
        latitude = position.latitude,
        longitude = position.longitude;

  @override
  String toString() => '$sexagesimalLatitude, $sexagesimalLongitude';

  String toMultilineString() => '$sexagesimalLatitude\n $sexagesimalLongitude';

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
