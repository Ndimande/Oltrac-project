import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/time_ago.dart';

final double _detailRowFontSize = 16;

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
    if (confirmed) {
      await _appStore.endTrip();
    }
  }

  // Widget _buildStartedAt() {
  //   return Container(
  //     margin: EdgeInsets.only(top: 10),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         Text(
  //           'Started: ' + friendlyDateTimestamp(_appStore.activeTrip.startedAt),
  //           style: TextStyle(fontSize: 18),
  //         ),
  //         TimeAgo(
  //           startedAt: _appStore.activeTrip.startedAt,
  //           textStyle: TextStyle(fontSize: 18),
  //           prefix: ' (',
  //           suffix: ')',
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildEndTripButton(context) {
    return RaisedButton.icon(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      color: Colors.red,
      onPressed: _appStore.hasActiveHaul ? null : () async => await _onPressEndTrip(context),
      icon: Icon(
        Icons.stop,
        color: Colors.white,
      ),
      label: Container(
        alignment: Alignment.center,
        height: 50,
        child: Text(
          'End Trip',
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
      ),
    );
  }

  Widget _detailRow(String lhs, String rhs) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            lhs,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(rhs,style: TextStyle(fontSize: 16),),
        ],
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
                _buildEndTripButton(context),
              ],
            ),
            _detailRow('Started', friendlyDateTimestamp(_appStore.activeTrip.startedAt)),
            _detailRow('Start Location',
                Location.fromPosition(_appStore.activeTrip.startPosition).toString()),
          ],
        ),
      ),
      onPressed: () async {
        await Navigator.pushNamed(context, '/trip', arguments: _appStore.activeTrip);
      },
    );
  }
}
