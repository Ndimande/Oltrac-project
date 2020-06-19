import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/coordinate.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/widgets/location_button.dart';

class LocationEditor extends StatelessWidget {
  final Location location;
  final String title;
  final Function(Location) onChanged;

  const LocationEditor({@required this.location, this.title, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final latitudePicker = _CoordinatePicker(
      decimalValue: location.latitude,
      orientation: CoordinateOrientation.Latitude,
      onPressConfirm: (double value) {
        onChanged(location.copyWith(latitude: value));
      },
    );

    final longitudePicker = _CoordinatePicker(
      decimalValue: location.longitude,
      orientation: CoordinateOrientation.Longitude,
      onPressConfirm: (double value) {
        onChanged(location.copyWith(longitude: value));
      },
    );

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(title, style: Theme.of(context).accentTextTheme.headline6),
            padding: const EdgeInsets.symmetric(vertical: 5),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    latitudePicker,
                    longitudePicker,
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(5),
                child: LocationButton(location: location),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _CoordinatePicker extends StatelessWidget {
  final double decimalValue;
  final CoordinateOrientation orientation;
  final Function(double) onPressConfirm;

  const _CoordinatePicker({@required this.orientation, @required this.onPressConfirm, @required this.decimalValue})
      : assert(orientation != null),
        assert(onPressConfirm != null),
        assert(decimalValue != null);

  void _onConfirm(Picker picker, List value) {
    final int degrees = _degreesRange(orientation)[value[0]];
    final int minutes = _minutesRange[value[1]];
    final double seconds = _secondsRange[value[2]];
    final CompassDirection compassDirection = CoordinateOrientation.Latitude == orientation
        ? _LATITUDE_COMPASS_DIRECTION_INDEXES[value[3]]
        : _LONGITUDE_DIRECTION_INDEXES[value[3]];

    // convert to decimal lat/long and return
    final coordinate = Coordinate.fromSexagesimal(
      degrees: degrees,
      minutes: minutes,
      seconds: seconds,
      compassDirection: compassDirection,
    );

    onPressConfirm(coordinate.decimalValue);
  }

  Widget _title() {
    return Builder(
      builder: (BuildContext context) {
        return Text(
          orientation == CoordinateOrientation.Latitude ? 'Latitude' : 'Longitude',
          style: Theme.of(context).textTheme.caption,
        );
      },
    );
  }

  Picker _picker() {
    final coordinate = Coordinate.fromDecimal(decimalValue: decimalValue, coordinateOrientation: orientation);

    final List<int> degreesRange = _degreesRange(orientation);

    final int degreeIndex = degreesRange.indexOf(coordinate.degrees);
    final int minuteIndex = _minutesRange.indexOf(coordinate.minutes);
    final int secondsIndex = _secondsRange.indexOf(roundDouble(coordinate.seconds, decimals: 1));

    assert(degreeIndex != -1);
    assert(minuteIndex != -1);
    assert(secondsIndex != -1);

    final List selectedIndexes = <int>[
      degreeIndex,
      minuteIndex,
      secondsIndex,
      if (decimalValue < 0) 1 else 0,
    ];

    return Picker(
      selecteds: selectedIndexes,
      adapter: PickerDataAdapter<String>(pickerdata: _pickerData(orientation), isArray: true),
      title: _title(),
      onConfirm: _onConfirm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Coordinate coordinate = Coordinate.fromDecimal(
      decimalValue: decimalValue,
      coordinateOrientation: orientation,
    );

    return Builder(
      builder: (BuildContext context) {
        final decoration = BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey[350], width: 1)),
        );

        return FlatButton(
          padding: const EdgeInsets.symmetric(vertical: 5),
          onPressed: () {
            _picker().showModal(context);
          },
          child: Container(
            alignment: Alignment.centerLeft,
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _title(),
                Text(coordinate.sexagesimalString, style: Theme.of(context).textTheme.headline5),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<int> _degreesRange(CoordinateOrientation orientation) {
  final int limit = orientation == CoordinateOrientation.Latitude ? 90 : 180;
  final List<int> degrees = [];
  for (int i = 0; i <= limit; i++) {
    degrees.add(i);
  }
  return degrees;
}

List<String> _addSymbol(List<dynamic> numbers, String symbol) => numbers.map((e) => '${e.toString()} $symbol').toList();

List<int> get _minutesRange {
  final List<int> minutes = [];
  for (int i = 0; i <= 59; i++) {
    minutes.add(i);
  }
  return minutes;
}

List<double> get _secondsRange {
  final List<double> seconds = [];
  for (int i = 0; i <= 599; i++) {
    seconds.add(i / 10);
  }
  return seconds;
}

const _LONGITUDE_DIRECTION_INDEXES = <CompassDirection>[
  CompassDirection.E,
  CompassDirection.W,
];

const _LATITUDE_COMPASS_DIRECTION_INDEXES = <CompassDirection>[
  CompassDirection.N,
  CompassDirection.S,
];

List<List<String>> _pickerData(CoordinateOrientation orientation) => [
      _addSymbol(_degreesRange(orientation), '°'),
      _addSymbol(_minutesRange, "'"),
      _addSymbol(_secondsRange, "''"),
      if (orientation == CoordinateOrientation.Latitude) ['N', 'S'] else ['E', 'W']
    ];
