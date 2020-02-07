import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
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
    return FlatButton(
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        leading: NumberedBoat(
          number: _trip.id,
        ),
        title: Text(_haulsText(_trip.hauls.length)),
        subtitle: Text(friendlyDateTimestamp(_trip.endedAt)),
        trailing: ForwardArrow(),
      ),
      onPressed: onPressed,
    );
  }
}
