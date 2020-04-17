import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/strip_button.dart';

class TripSection extends StatelessWidget {
  final Trip trip;
  final bool hasActiveHaul;
  final Function onPressEndTrip;
  final Function onPressCancelTrip;
  final Function onPressEditTrip;

  TripSection({
    this.trip,
    this.hasActiveHaul,
    this.onPressEndTrip,
    this.onPressCancelTrip,
    this.onPressEditTrip,
  });

  Widget get endTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'End',
          color: hasActiveHaul ? Colors.grey : Colors.red,
          onPressed: () async => await onPressEndTrip(),
          icon: Icon(
            Icons.stop,
            color: Colors.white,
          ),
        );
      });

  Widget get cancelTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'Cancel',
          color: hasActiveHaul ? Colors.grey : OlracColours.olspsBlue,
          onPressed: () async => await onPressCancelTrip(),
          icon: Icon(
            Icons.cancel,
            color: Colors.white,
          ),
        );
      });

  Widget get editTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'Edit',
          color: OlracColours.olspsBlue,
          onPressed: onPressEditTrip,
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        );
      });

  Widget get tripInfo {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        LocationButton(
          location: trip.startLocation,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                'Start: ' + friendlyDateTime(trip.startedAt),
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              child: ElapsedCounter(
                style: TextStyle(fontSize: 18),
                prefix: 'Duration: ',
                startedDateTime: trip.startedAt,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget build(BuildContext context) {
    return Container(
      color: OlracColours.olspsBlue[50],
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[NumberedBoat(number: trip.id), SizedBox(width: 5), tripInfo],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(child: endTripButton),
              Expanded(child: editTripButton),
            ],
          )
        ],
      ),
    );
  }
}
