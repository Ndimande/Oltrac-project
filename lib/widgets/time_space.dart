import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/widgets/location_button.dart';

class TimeSpace extends StatelessWidget {
  final String label;
  final Location location;
  final DateTime dateTime;

  const TimeSpace({this.label, this.location, this.dateTime});

  @override
  Widget build(BuildContext context) {
    final String dateTimeLabel = friendlyDateTime(dateTime) ?? 'In progress';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (label != null) Text(label, style: Theme.of(context).textTheme.caption),
            Text(dateTimeLabel, style: Theme.of(context).textTheme.headline6, textAlign: TextAlign.left)
          ],
        ),
        LocationButton(location: location),
      ],
    );
  }
}
