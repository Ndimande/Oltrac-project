import 'package:flutter/material.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/time_ago.dart';

final double _detailRowFontSize = 18;

class TripSection extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  _onPressEndTrip(context) async {
    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
        'End Trip',
        'Are you sure you want to end the trip?',
      ),
    );
    if (confirmed == true) {
      await _appStore.endTrip();
    }
  }

  Widget _endTripButton(context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: RaisedButton.icon(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        color: Colors.red,
        onPressed: _appStore.hasActiveHaul ? null : () async => await _onPressEndTrip(context),
        icon: Icon(
          Icons.stop,
          color: Colors.white,
        ),
        label: Container(
          alignment: Alignment.center,
          height: 55,
          child: Text(
            'End Trip',
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            // First row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Trip name
                Text(
                  'Trip ${_appStore.activeTrip.id}',
                  style: TextStyle(fontSize: 32),
                ),

                // End Haul
                _endTripButton(context),
              ],
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: TimeAgo(
                    prefix: 'Started ',
                    dateTime: _appStore.activeTrip.startedAt,
                    textStyle: TextStyle(fontSize: _detailRowFontSize),
                  ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(Location.fromPosition(_appStore.activeTrip.startPosition).toString(),style: TextStyle(fontSize: 16),),
            ),
          ],
        ),
      ),
      onPressed: () async {
        await Navigator.pushNamed(context, '/trip', arguments: _appStore.activeTrip);
      },
    );
  }
}
