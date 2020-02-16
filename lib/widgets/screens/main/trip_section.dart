import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/strip_button.dart';

class TripSection extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  _onPressEndTrip(BuildContext context) async {

    if(_appStore.hasActiveHaul) {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('You must first end the trip')));
      return;
    }

    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('End Trip', Messages.CONFIRM_END_TRIP),
    );
    if (confirmed == true) {
      await _appStore.endTrip();
    }
  }

  _onPressCancelTrip(BuildContext context) async {
    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog('Cancel Trip', Messages.CONFIRM_CANCEL_TRIP),
    );
    if (confirmed == true) {
      await _appStore.cancelTrip();
    }
  }

  _onPressEditTrip(BuildContext context) async {
    await Navigator.pushNamed(context, '/edit_trip', arguments: _appStore.activeTrip);
  }

  Widget get endTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          centered: true,
          labelText: 'End',
          color: _appStore.hasActiveHaul ? Colors.grey : Colors.red,
          onPressed: () async => await _onPressEndTrip(context),
          icon: Icon(
            Icons.stop,
            color: Colors.white,
          ),
        );
      });

  Widget get cancelTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          centered: true,
          labelText: 'Cancel',
          color: _appStore.hasActiveHaul ? Colors.grey : olracBlue,
          onPressed: () async => await _onPressCancelTrip(context),
          icon: Icon(
            Icons.cancel,
            color: Colors.white,
          ),
        );
      });

  Widget get editTripButton => Builder(builder: (BuildContext context) {
        return StripButton(
          centered: true,
          labelText: 'Edit',
          color: olracBlue,
          onPressed: () async => await _onPressEditTrip(context),
          icon: Icon(
            Icons.edit,
            color: Colors.white,
          ),
        );
      });

  Widget get tripInfo {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        LocationButton(
          location: _appStore.activeTrip.startLocation,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              child: Text(
                'Start: ' + friendlyDateTime(_appStore.activeTrip.startedAt),
                style: TextStyle(fontSize: 18),
              ),
            ),
            Container(
              child: ElapsedCounter(
                style: TextStyle(fontSize: 18),
                prefix: 'Duration: ',
                startedDateTime: _appStore.activeTrip.startedAt,
              ),
            ),

          ],
        )
      ],
    );
  }

  Widget build(BuildContext context) {
    return Container(
      color: olracBlue[50],
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                NumberedBoat(number: _appStore.activeTrip.id),
                SizedBox(width: 5),
                tripInfo
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(child: endTripButton),
              Expanded(child: cancelTripButton),
            ],
          )
        ],
      ),
    );
  }
}
