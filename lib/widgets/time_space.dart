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
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
            Text(
              dateTimeLabel,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.left,
            )
          ],
        ),
        Container(
          height: 0, // This seems to remove the random padding / margin they have put onto this one
          color: Colors.red,
          child: LocationButton(
            location: location,
          ),
        ),
      ],
    );
  }
}
