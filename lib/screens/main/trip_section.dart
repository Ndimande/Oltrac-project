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
  final Function onPressMasterContainerButton;

  TripSection({
    this.trip,
    this.hasActiveHaul,
    this.onPressEndTrip,
    this.onPressCancelTrip,
    this.onPressEditTrip,
    this.onPressMasterContainerButton,
  }) : assert(onPressMasterContainerButton != null);

  Widget get endTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          labelText: 'End Trip',
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
        LocationButton(location: trip.startLocation),
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
        ),
      ],
    );
  }

  Widget _masterContainerButton() {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        IconButton(
          onPressed: (){},
          iconSize: 40,
          icon: Icon(
            Icons.inbox,
            color: OlracColours.olspsBlue,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: IconButton(
            onPressed: onPressMasterContainerButton,
            iconSize: 22,
            icon: Icon(
              Icons.add,
              color: OlracColours.olspsBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget build(BuildContext context) {
    return Container(
      color: OlracColours.olspsBlue[50],
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    NumberedBoat(number: trip.id),
                    SizedBox(width: 5),
                    tripInfo,
                  ],
                ),
                _masterContainerButton(),
              ],
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
