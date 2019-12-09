import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/trip_list_item.dart';

class TripHistoryScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  Widget _buildBottomSection() {
    final List<Trip> trips =
        _appStore.completedTrips.where((Trip trip) => trip.endedAt != null).toList();

    if (trips.length == 0) {
      return Text('No completed trips.');
    }

    return ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final Trip trip = trips[index];

          return TripListItem(trip, () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TripScreen(),
                settings: RouteSettings(
                  arguments: trip,
                ),
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Trip History'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: _buildBottomSection(),
        ));
  }
}
