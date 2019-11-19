import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/time_ago.dart';

class TripView extends StatelessWidget {
  final AppStore _appStore;

  TripView(this._appStore);

  /// Helpful text

  Future<bool> _showConfirmDialog(context) async {
    return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ConfirmDialog('Begin a new trip', 'Are you sure?'));
  }

  Widget _buildTripInfo() {
    return Column(children: <Widget>[
      Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.all(10),
          child: TimeAgo(
            prefix: 'Trip started ',
            startedAt: _appStore.activeTrip.startedAt,
          )),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Text(
                  _appStore.activeTrip.hauls.length.toString(),
                  style: TextStyle(fontSize: 40),
                ),
                Text(
                  'Hauls',
                  style: TextStyle(fontSize: 14),
                )
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Text(
                0.toString(),
                style: TextStyle(fontSize: 40),
              ),
              Text(
                'Tags',
                style: TextStyle(fontSize: 14),
              )
            ],
          ),
        ],
      )
    ]);
  }

  Widget _buildTopSection() {
    if (!_appStore.tripHasStarted) {
      return Container(
          alignment: Alignment.center,
          child: Text(
            'No active trip.',
            style: TextStyle(fontSize: 26),
          ));
    }
    return _buildTripInfo();
  }

  Widget _buildBottomSection() {
    final List<Trip> trips = _appStore.completedTrips;
    if (trips.length == 0) {
      return Text('No completed trips.');
    }
    return ListView.builder(
        itemCount: trips.length,
        itemBuilder: (context, index) {
          final Trip trip = trips[index];
          final String startedAt = friendlyTimestamp(trip.startedAt);
          final String endedAt = friendlyTimestamp(trip.endedAt);
          final timePeriod = Text('$startedAt - $endedAt');
          return FlatButton(
              child: ListTile(
                subtitle: Text(trip.hauls.length.toString() + ' Haul(s)'),
                title: timePeriod,
                trailing: Icon(Icons.keyboard_arrow_right),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TripScreen(_appStore),
                    // Pass the arguments as part of the RouteSettings. The
                    // ExtractArgumentScreen reads the arguments from these
                    // settings.
                    settings: RouteSettings(
                      arguments: trips[index],
                    ),
                  ),
                );
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: _buildTopSection(),
          height: 100,
        ),
        Divider(),
        Expanded(child: _buildBottomSection()),
      ],
    );
  }
}
