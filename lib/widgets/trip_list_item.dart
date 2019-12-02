import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';

String _haulsText(int length) {
  switch (length) {
    case 0:
      return 'No hauls';
    case 1:
      return '1 haul';
  }
  return '${length.toString()} hauls';
}

class TripListItem extends StatelessWidget {
  final Trip _trip;
  final Function onPressed;

  TripListItem(this._trip, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final String startedAt = friendlyTimestamp(_trip.startedAt);
    final String endedAt = friendlyTimestamp(_trip.endedAt);
    final timePeriod = Text('$startedAt - $endedAt');

    final title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Trip ${_trip.id}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(' (' + _haulsText(_trip.hauls.length) + ')')
      ],
    );

    return Card(
      color: Colors.blueGrey,
      child: FlatButton(
        child: ListTile(
          title: title,
          subtitle: timePeriod,
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
