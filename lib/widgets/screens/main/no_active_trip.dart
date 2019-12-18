import 'package:flutter/material.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/trip_list_item.dart';

class NoActiveTrip extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  _onPressStartTrip() async {
    await _appStore.startTrip();
  }

  Widget _completedTripList() {
    final List completedTrips = _appStore.completedTrips.reversed.toList();
    if (completedTrips.length == 0) {
      return Container(
          alignment: Alignment.center,
          child: Text(
            'No completed trips.\nYour trip history will be shown here.',
            textAlign: TextAlign.center,
          ));
    }
    return ListView.builder(
      itemCount: completedTrips.length,
      itemBuilder: (context, index) {
        return TripListItem(completedTrips[index], () async {
            await Navigator.pushNamed(context, '/trip',arguments: completedTrips[index]);

        });
      },
    );
  }

  Widget _startTripButton() {
    return RaisedButton(
      color: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
            Text(
              'Start Trip',
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
          ],
        ),
        height: 80,
        width: 200,
      ),
      onPressed: _onPressStartTrip,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(child: _completedTripList()),
            Container(padding: EdgeInsets.all(15), child: _startTripButton()),
          ],
        ),
      ),
    );
  }
}
