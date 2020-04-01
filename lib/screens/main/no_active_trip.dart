import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/trip_list_item.dart';

class NoActiveTrip extends StatelessWidget {
  final Function onPressStartTrip;
  final List<Trip> completedTrips;

  NoActiveTrip({@required this.completedTrips, @required this.onPressStartTrip})
      : assert(completedTrips != null),
        assert(onPressStartTrip != null);

  Widget _completedTripList() {
    final List reversedCompletedTrips = completedTrips.reversed.toList();

    if (reversedCompletedTrips.length == 0) {
      return Container(
          alignment: Alignment.center,
          child: Text(
            'No completed trips.\nYour trip history will be shown here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ));
    }
    return ListView.builder(
      itemCount: reversedCompletedTrips.length,
      itemBuilder: (context, index) {
        return TripListItem(reversedCompletedTrips[index], () async {
          await Navigator.pushNamed(context, '/trip', arguments: reversedCompletedTrips[index]);
        });
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
            color: Colors.green,
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
