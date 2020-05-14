import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/trip_list_item.dart';

class NoActiveTrip extends StatelessWidget {
  final Function onPressStartTrip;
  final Function onPressCompletedTrip;
  final List<Trip> completedTrips;

  NoActiveTrip({@required this.completedTrips, @required this.onPressStartTrip, @required this.onPressCompletedTrip})
      : assert(completedTrips != null),
        assert(onPressStartTrip != null),
        assert(onPressCompletedTrip != null);

  Widget _completedTripList() {
    final List reversedCompletedTrips = completedTrips.reversed.toList();

    if (reversedCompletedTrips.isEmpty) {
      return Container(
          alignment: Alignment.center,
          child: const Text(
            'No completed trips.\nYour trip history will be shown here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ));
    }
    return ListView.builder(
      itemCount: reversedCompletedTrips.length,
      itemBuilder: (context, index) {
        return TripListItem(
            reversedCompletedTrips[index], () async => await onPressCompletedTrip(reversedCompletedTrips[index]));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(child: _completedTripList()),
          StripButton(
            labelText: 'Start Trip',
            color: OlracColours.ninetiesGreen,
            icon: Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: onPressStartTrip,
          )
        ],
      ),
    );
  }
}
