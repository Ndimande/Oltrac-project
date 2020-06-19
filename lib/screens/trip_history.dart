import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/widgets/trip_list_item.dart';


Future<Map> _load() async {
  final _tripRepo = TripRepository();
  final List<Trip> completedTrips = await _tripRepo.getCompleted();


  return {'completedTrips': completedTrips};
}

class TripHistoryScreen extends StatefulWidget {
  @override
  _TripHistoryScreenState createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  List<Trip> _completedTrips;

  Widget _buildBottomSection() {
    final List<Trip> trips = _completedTrips.reversed.where((Trip trip) => trip.endedAt != null).toList();

    if (trips.isEmpty) {
      return Builder(builder: (BuildContext context){
        return Container(
          child: Text('No completed trips', style: Theme.of(context).textTheme.subtitle1),
          alignment: Alignment.center,
        );
      });

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
          return const Scaffold();
        }

        _completedTrips = snapshot.data['completedTrips'] as List<Trip>;

        return Scaffold(
            appBar: AppBar(
              title: const Text('Trip History')
            ),
            body: Container(
              child: _buildBottomSection()
            ));
      },
    );
  }
}
