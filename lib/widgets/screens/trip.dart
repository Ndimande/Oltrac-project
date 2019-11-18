import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';

class TripScreen extends StatelessWidget {
  final AppStore _appStore;

  TripScreen(this._appStore);

  @override
  Widget build(BuildContext context) {
    final Trip trip = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
          title: Text('Trip'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('uuid: ' + trip.uuid),
              Text('Completed hauls: ' + trip.hauls.length.toString()),
              Text('Started: ' + friendlyTimestamp(trip.startedAt)),
              Text('Ended: ' + friendlyTimestamp(trip.endedAt)),
            ],
          ),
        ));
  }
}
