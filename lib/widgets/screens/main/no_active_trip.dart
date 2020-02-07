import 'package:flutter/material.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/trip_list_item.dart';

class NoActiveTrip extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final Function onPressStartTrip;

  NoActiveTrip({this.onPressStartTrip});

  Widget _completedTripList() {
    final List completedTrips = _appStore.completedTrips.reversed.toList();
    if (completedTrips.length == 0) {
      return Container(
          alignment: Alignment.center,
          child: Text(
            'No completed trips.\nYour trip history will be shown here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20),
          ));
    }
    return ListView.builder(
      itemCount: completedTrips.length,
      itemBuilder: (context, index) {
        return TripListItem(completedTrips[index], () async {
          await Navigator.pushNamed(context, '/trip', arguments: completedTrips[index]);
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
            centered: true,
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
