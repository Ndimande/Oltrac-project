import 'package:flutter/material.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';

class CompleteTrips extends StatelessWidget {
  final AppStore _appStore;

  CompleteTrips(this._appStore);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: _appStore.completedTrips.length,
        itemBuilder: (context, index) {
          final Trip trip = _appStore.completedTrips[index];
          return ListTile(
            title: Text(trip.startedAt.toString()),
            subtitle: Text('example'),
          );
        });
  }
}
