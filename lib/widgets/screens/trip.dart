import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/strings.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/grouped_hauls_list.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/time_space.dart';

class TripScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppStore _appStore = StoreProvider().appStore;

  final Trip _trip;

  TripScreen(this._trip);

  Widget _buildTripInfo(Trip trip) {
    return Container(
      color: olracBlue[50],
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          NumberedBoat(
            number: _trip.id,
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TimeSpace(label: 'Start', location: _trip.startLocation, dateTime: _trip.startedAt),
                SizedBox(
                  height: 5,
                ),
                _trip.endedAt != null
                    ? TimeSpace(label: 'End', location: _trip.endLocation, dateTime: _trip.endedAt)
                    : Container(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHaulsLabel() {
    return Container(
      margin: EdgeInsets.all( 10),
      child: Text(
        'Hauls',
        style: TextStyle(fontSize: 30, color: olracBlue),
      ),
    );
  }

  Widget _endTripActionButton() => FlatButton.icon(
        textColor: Colors.white,
        icon: Icon(Icons.check_circle),
        label: Text('End'),
        onPressed: () async {
          bool confirmed = await showDialog<bool>(
            context: _scaffoldKey.currentContext,
            builder: (_) => ConfirmDialog('End Trip', Strings.CONFIRM_END_TRIP),
          );
          if (confirmed == true) {
            await _appStore.endTrip();
            Navigator.pop(_scaffoldKey.currentContext);
          }
        },
      );

  Widget _cancelTripActionButton() => FlatButton.icon(
        textColor: Colors.white,
        icon: Icon(Icons.cancel),
        label: Text('Cancel'),
        onPressed: () async {
          bool confirmed = await showDialog<bool>(
            context: _scaffoldKey.currentContext,
            builder: (_) => ConfirmDialog('Cancel Trip', Strings.CONFIRM_CANCEL_TRIP),
          );
          if (confirmed == true) {
            Navigator.pop(_scaffoldKey.currentContext);
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
      // Show the actions only if there is no active haul
      if (!_appStore.hasActiveHaul) {
        actions.add(_endTripActionButton());
        actions.add(_cancelTripActionButton());
      }
    }
    // You may not delete a trip that has been completed
    // so there is no delete button.
    return actions;
  }

  Widget get noHauls => Container(
        alignment: Alignment.center,
        child: Text(
          'No hauls on this trip',
          style: TextStyle(fontSize: 20),
        ),
      );

  Widget get stripButton => StripButton(
        centered: true,
        labelText: 'Upload Trip',
        color: olracBlue,
        onPressed: onPressUploadTrip,
        icon: Icon(
          Icons.cloud_upload,
          color: Colors.white,
        ),
      );

  onPressUploadTrip() {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Trip upload started...'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) {

        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            actions: _appBarActions(),
            title: Text('Completed Trip'),
          ),
          body: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildTripInfo(_trip),
                _buildHaulsLabel(),
                Expanded(
                  child: _trip.hauls.length > 0
                      ? GroupedHaulsList(hauls: _trip.hauls.reversed.toList())
                      : noHauls,
                ),
                _appStore.hasActiveTrip && _appStore.activeTrip.id == _trip.id ? Container(): stripButton
              ],
            ),
          ),
        );
      },
    );
  }
}
