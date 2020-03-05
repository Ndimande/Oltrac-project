import 'package:flutter/material.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/trip_list_item.dart';

final _tripRepo = TripRepository();
final _haulRepo = HaulRepository();

Future<Map> _load() async {
  final List<Trip> completedTrips = await _tripRepo.getCompleted();

  final List<Trip> tripsWithHauls = [];
  for(Trip trip in completedTrips) {
    List<Haul> hauls = await _haulRepo.forTripId(trip.id);
    tripsWithHauls.add(trip.copyWith(hauls: hauls));
  }
  return {'completedTrips':tripsWithHauls};
}


class TripHistoryScreen extends StatelessWidget {
  List<Trip> _completedTrips;

  Widget _buildBottomSection() {
    final List<Trip> trips =
        _completedTrips.reversed.where((Trip trip) => trip.endedAt != null).toList();

    if (trips.length == 0) {
      return Container(
        child: Text(
          'No completed trips',
          style: TextStyle(fontSize: 18),
        ),
        alignment: Alignment.center,
      );
    }

    return ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final Trip trip = trips[index];

          return TripListItem(trip, () async {
            await Navigator.pushNamed(context, '/trip', arguments: trip);
          });
        });
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
      future: _load(),
      initialData: null,
      builder: (BuildContext buildContext, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Text(snapshot.error.toString()));
        }
        // Show blank screen until ready
        if (!snapshot.hasData) {
          return Scaffold();
        }

        _completedTrips = snapshot.data['completedTrips'] as List<Trip>;
        final bool isActiveTrip = snapshot.data['isActiveTrip'];
        return Scaffold(
          appBar: AppBar(
            title: Text('Trip History'),
          ),
          body: Container(
            child: _buildBottomSection(),
          ));

      },
    );


  }
}
