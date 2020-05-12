import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/numbered_boat.dart';

class TripListItem extends StatelessWidget {
  final Trip _trip;
  final VoidCallback onPressed;

  const TripListItem(this._trip, this.onPressed);

  String _haulsText(int length) {
    String text;
    if (length == 0) {
      text = 'No hauls';
    } else if (length == 1) {
      text = '1 haul';
    } else {
      text = '${length.toString()} hauls';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: ListTile(
        contentPadding: const EdgeInsets.all(0),
        leading: NumberedBoat(
          color: _trip.isUploaded ? OlracColours.olspsDarkBlue : OlracColours.olspsBlue,
          number: _trip.id,
        ),
        title: Text(_haulsText(_trip.hauls.length)),
        subtitle: Text(_trip.endedAt == null ? '-' : friendlyDateTime(_trip.endedAt)),
        trailing: ForwardArrow(),
      ),
      onPressed: onPressed,
    );
  }
}
