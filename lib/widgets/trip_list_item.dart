import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/westlake/forward_arrow.dart';
import 'package:olrac_widgets/westlake/westlake_list_item.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/numbered_boat.dart';

class TripListItem extends StatelessWidget {
  final Trip _trip;
  final VoidCallback onPressed;

  const TripListItem(this._trip, this.onPressed);

  Widget _title() {
    return Builder(builder: (BuildContext context) {
      return Text(_haulsText(_trip.hauls.length), style: Theme.of(context).textTheme.headline6);
    });
  }

  Widget _subtitle() {
    return Builder(builder: (BuildContext context) {
      return Text(_trip.endedAt == null ? '-' : friendlyDateTime(_trip.endedAt),
          style: Theme.of(context).textTheme.subtitle1);
    });
  }

  Widget _leading() {
    return Builder(
      builder: (BuildContext context) {
        return Hero(
          tag: 'numbered_boat'+_trip.id.toString(),
          child: NumberedBoat(
            color: _trip.isUploaded ? OlracColours.olspsDarkBlue : Theme.of(context).primaryColor,
            number: _trip.id,
          ),
        );
      },
    );
  }

  Widget _trailing() {
    return const ForwardArrow();
  }

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
    return WestlakeListItem(
      leading: _leading(),
      title: _title(),
      subtitle: _subtitle(),
      trailing: _trailing(),
      onPressed: onPressed,
    );
  }
}
