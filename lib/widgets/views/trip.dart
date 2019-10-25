import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/vessel_info.dart';
import 'package:oltrace/widgets/big_button.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

final _fakeTrip = (AppStore _appStore) =>
    Trip(startedAt: DateTime.now(), vessel: _appStore.vessel);

class TripView extends StatelessWidget {
  final AppStore _appStore;

  TripView(this._appStore);

  /// Helpful text

  Future<bool> _showConfirmDialog(context) async {
    return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => ConfirmDialog('Start trip', 'Are you sure?'));
  }

  _onPressMainButton(context) async {
    if (_appStore.tripHasStarted) {
      final bool confirmed = await _showConfirmDialog(context);
      if (confirmed) {
        _appStore.endTrip();
      }
    } else {
      if (_appStore.vesselIsConfigured) {
        final bool confirmed = await _showConfirmDialog(context);
        if (confirmed) {
          _appStore.startTrip(_fakeTrip(_appStore));
          _appStore.changeMainView(MainViewIndex.haul);
        }
      } else {
        _appStore.changeMainView(MainViewIndex.configureVessel);
      }
    }
  }

  /// The big button at the bottom
  Widget _buildMainButton(context) {
    String _buttonLabel;
    if (_appStore.tripHasStarted) {
      _buttonLabel = 'End Trip';
    } else {
      _buttonLabel = _appStore.vesselIsConfigured
          ? 'Start Trip'
          : 'Configure Vessel'; //todo or continue trip
    }

    return BigButton(
      label: _buttonLabel,
      onPressed: () async => await _onPressMainButton(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Observer(builder: (_) {
//        final _mainW =
//            _appStore.vesselIsConfigured ? 'Start Trip' : 'Configure Vessel';

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[VesselInfo(_appStore), _buildMainButton(context)],
        );
      }),
    );
  }
}
