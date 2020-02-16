import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/widgets/location_button.dart';

class TimeSpace extends StatelessWidget {
  final String label;
  final Location location;
  final DateTime dateTime;

  TimeSpace({this.label, this.location, this.dateTime});

  @override
  Widget build(BuildContext context) {
    String dateTimeLabel = friendlyDateTime(dateTime) ?? 'In progress';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label ?? '',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              dateTimeLabel,
              style: TextStyle(fontSize: 17),
              textAlign: TextAlign.left,
            )
          ],
        ),
        LocationButton(
          location: location,
        ),
      ],
    );
  }
}
