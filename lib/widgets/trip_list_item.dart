import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/time_ago.dart';

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

    final TimeAgo timeAgo = TimeAgo(prefix: 'Ended ', dateTime: _trip.endedAt,);

    final title = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Trip ${_trip.id}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(' (' + _haulsText(_trip.hauls.length) + ')', style: TextStyle(fontSize: 18))
      ],
    );

    return Card(
      child: FlatButton(
        child: ListTile(
          title: title,
          subtitle: timeAgo,
          trailing: Icon(Icons.keyboard_arrow_right),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
