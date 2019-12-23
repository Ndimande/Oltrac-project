import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/haul_list_item.dart';

class TripScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppStore _appStore = StoreProvider().appStore;

  final Trip _trip;

  TripScreen(this._trip);

  Widget _buildInfoItem(String label, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(Trip trip) {
    final String startCoords = Location.fromPosition(trip.startPosition).toMultilineString();
    final String endCoords =
        trip.endPosition != null ? Location.fromPosition(trip.endPosition).toMultilineString() : '-';
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInfoItem('Total hauls ', trip.hauls.length.toString()),

             _buildInfoItem('Started', friendlyDateTimestamp(trip.startedAt) + '\n' + startCoords),
          _buildInfoItem('Ended', (friendlyDateTimestamp(trip.endedAt) ?? '-') + '\n' + endCoords),
        ],
      ),
    );
  }

  Widget _buildHaulsList(List<Haul> hauls) {
    final List<HaulListItem> haulListItems = hauls
        .map((Haul haul) => HaulListItem(
              haul,
              () async => await Navigator.pushNamed(
                _scaffoldKey.currentContext,
                '/haul',
                arguments: haul,
              ),
            ))
        .toList();

    return Expanded(
      child: ListView(children: haulListItems),
    );
  }

  Widget _buildHaulsLabel() {
    return Container(
      child: Text(
        'Hauls',
        style: TextStyle(fontSize: 30),
      ),
      padding: EdgeInsets.only(top: 15),
    );
  }

  Widget _endTripActionButton() => FlatButton.icon(
        icon: Icon(Icons.check_circle),
        label: Text('End'),
        onPressed: () async {
          bool confirmed = await showDialog<bool>(
            context: _scaffoldKey.currentContext,
            builder: (_) => ConfirmDialog('End Trip', 'Are you sure you want to end the trip?'),
          );
          if (confirmed == true) {
            await _appStore.endTrip();
          }
        },
      );

  Widget _cancelTripActionButton() => FlatButton.icon(
        icon: Icon(Icons.cancel),
        label: Text('Cancel'),
        onPressed: () async {
          bool confirmed = await showDialog<bool>(
            context: _scaffoldKey.currentContext,
            builder: (_) =>
                ConfirmDialog('Cancel Trip', 'Are you sure you want to cancel the trip?'),
          );
          if (confirmed == true) {
            await _appStore.cancelTrip();
          }
        },
      );

  /// Allows the user to cancel or end a [Trip].
  ///
  /// The action buttons will be hidden if there is
  /// an active [Haul] because the user may not end
  /// the [Trip] if a [Haul] is active.
  List<Widget> _appBarActions() {
    var actions = <Widget>[];

    // Is there an active trip? Is this the active trip?
    if (_appStore.hasActiveTrip && _trip.id == _appStore.activeTrip.id) {
      // Is there no active haul?
      if (!_appStore.hasActiveHaul) {
        // Show the actions
        actions.add(_endTripActionButton());
        actions.add(_cancelTripActionButton());
      }
    }
    // You may not delete a trip that has been completed
    // so there is no delete button.
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {
        var title = 'Trip ${_trip.id}';
        if (_appStore.hasActiveTrip && _appStore.activeTrip.id == _trip.id) {
          title += ' (Active)';
        }
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            actions: _appBarActions(),
            title: Text(title),
          ),
          body: Container(
            child: Column(
              children: <Widget>[
                Container(
                  child: _buildTripInfo(_trip),
                  padding: EdgeInsets.all(5),
                ),
                Divider(),
                _buildHaulsLabel(),
                _trip.hauls.length > 0
                    ? _buildHaulsList(_trip.hauls.reversed.toList())
                    : Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Text(
                            'No hauls on this trip',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}
