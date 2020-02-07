import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/olrac_icons.dart';
import 'package:oltrace/strings.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/numbered_boat.dart';
import 'package:oltrace/widgets/olrac_icon.dart';
import 'package:oltrace/widgets/strip_button.dart';

class TripSection extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  _onPressEndTrip(context) async {
    // Ending trip
    if (_appStore.hasActiveHaul) {
      return;
    }

    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('End Trip', Strings.CONFIRM_END_TRIP),
    );
    if (confirmed == true) {
      await _appStore.endTrip();
    }
  }

  _onPressCancelTrip(context) async {
    if (_appStore.hasActiveHaul) {
      return;
    }

    final bool confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog('Cancel Trip', Strings.CONFIRM_CANCEL_TRIP),
    );
    if (confirmed == true) {
      await _appStore.cancelTrip();
    }
  }

  Widget _endTripButton(context) {
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
  }


  Widget _cancelTripButton(context) {
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
  }

  Widget tripIcon() {
    String tripNumber = _appStore.activeTrip.id.toString();

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 64,
          height: 64,
          child: OlracIcon(
            assetPath: OlracIcons.path('Boat'),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            tripNumber,
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    LocationButton(
                      location: _appStore.activeTrip.startLocation,
                    ),
                    Container(
                      child: ElapsedCounter(
                        textStyle: TextStyle(fontSize: 20),
                        prefix: 'Trip duration: ',
                        startedDateTime: _appStore.activeTrip.startedAt,
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Row(children: <Widget>[
            Expanded(child: _endTripButton(context),),
            Expanded(child: _cancelTripButton(context),)
          ],)
        ],
      ),
    );
  }
}
