import 'package:oltrace/framework/util.dart';

enum CoordinateOrientation { Latitude, Longitude }

enum CompassDirection { N, S, E, W }

class Coordinate {
  final double decimalValue;
  final CoordinateOrientation coordinateOrientation;
  final CompassDirection compassDirection;

  int _degrees;

  int get degrees => _degrees;

  int _minutes;

  int get minutes => _minutes;

  double _seconds;

  double get seconds => _seconds;

  Coordinate.fromDecimal({this.decimalValue, this.coordinateOrientation})
      : assert(decimalValue != null),
        assert(coordinateOrientation != null),
        compassDirection = coordinateOrientation == CoordinateOrientation.Latitude
            ? decimalValue >= 0 ? CompassDirection.N : CompassDirection.S
            : decimalValue >= 0 ? CompassDirection.E : CompassDirection.W {
    List result = _decimal2sexagesimal(decimalValue);
    _degrees = result[0];
    _minutes = result[1];
    _seconds = result[2];
  }

  Coordinate.fromSexagesimal({
    int degrees,
    int minutes,
    double seconds,
    CompassDirection compassDirection,
  })  : compassDirection = compassDirection,
        coordinateOrientation = compassDirection == CompassDirection.N || compassDirection == CompassDirection.S
            ? CoordinateOrientation.Latitude
            : CoordinateOrientation.Longitude,
        decimalValue = _sexagesimal2decimal(
          degrees,
          minutes,
          seconds,
          compassDirection,
        );

  String get compassSymbol => coordinateOrientation == CoordinateOrientation.Latitude
      ? decimalValue >= 0 ? 'N' : 'S'
      : decimalValue >= 0 ? 'E' : 'W';

  String get sexagesimalString => "$degrees° $minutes' $seconds\" $compassSymbol";
}

List _decimal2sexagesimal(double decimal) {
  final double positiveDecimal = decimal < 0 ? decimal = decimal * -1 : decimal;
  List<String> _split(final double value) => value.toString().split('.');

  final List<String> parts = _split(positiveDecimal);

  final int degrees = int.parse(parts[0]);

  final String fractionalPart = parts[1];

  final double min = double.parse("0.$fractionalPart") * 60;

  final int minutes = min.floor();

  final List<String> minParts = _split(min);

  final String minFractionalPart = minParts[1];

  final double seconds = double.parse("0.$minFractionalPart") * 60;

  final double secondsRounded = roundDouble(seconds, decimals: 2);
  return [degrees, minutes, secondsRounded];
}

double _sexagesimal2decimal(int degrees, int minutes, double seconds, CompassDirection compassDirection) {
  int factor = 1;
  if (compassDirection == CompassDirection.S || compassDirection == CompassDirection.W) {
    factor = -1;
  }
  final double decimal = (degrees + (minutes / 60) + (seconds / 3600)) * factor;

  return decimal;
}
