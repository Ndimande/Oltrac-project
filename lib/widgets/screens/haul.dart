import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/landing_list_item.dart';

final double _detailRowFontSize = 18;

class HaulScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Haul _haul;

  HaulScreen(this._haul);

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      // Is the haul arg in the current trip?
      final bool isActiveTrip =
          _appStore.hasActiveTrip ? _appStore.activeTrip.id == _haul.tripId : false;

      // Either the active trip or a completed trip
      final Trip trip = isActiveTrip
          ? _appStore.activeTrip
          : _appStore.completedTrips.firstWhere((trip) => trip.id == _haul.tripId);

      // Look through all hauls including hauls in the active trip
      final haul = trip.hauls.firstWhere((h) => _haul.id == h.id);

      final floatingActionButton = _isHaulOfActiveTrip(haul)
          ? _floatingActionButton(
              onPressed: () async => await _onPressTagButton(haul, context),
            )
          : null;

      final titleText = _isActiveHaul(haul) ? 'Haul ${haul.id} (Active)' : 'Haul ${haul.id}';

      return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: floatingActionButton,
        appBar: AppBar(
          title: Text(titleText),
          actions: _actions(haul),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: _buildHaulDetails(haul),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Divider(),
              ),
              _buildLandingsSection(haul.landings),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(
                fontSize: _detailRowFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(fontSize: _detailRowFontSize),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaulDetails(Haul haul) {
    final String startLocation = haul.startLocation.toMultilineString();
    final String endLocation =
        haul.endLocation != null ? haul.endLocation.toMultilineString() : '-';

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDetailRow('Fishing method', haul.fishingMethod.name),
          _buildDetailRow('Started', friendlyDateTimestamp(haul.startedAt) + '\n' + startLocation),
          _buildDetailRow(
              'Ended', (friendlyDateTimestamp(haul.endedAt) ?? '-') + '\n' + endLocation),
        ],
      ),
    );
  }

  Widget _noLandings() {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        child: Text(
          'No sharks',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildLandingsSection(List<Landing> landings) {
    if (landings.length == 0) {
      return _noLandings();
    }

    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            _buildLandingsLabel(landings),
            _buildLandingsList(landings),
          ],
        ),
      ),
    );
  }

  Widget _buildLandingsList(List<Landing> landings) {
    final List<LandingListItem> listLandings = landings
        .map(
          (Landing landing) => LandingListItem(
            landing,
            () async => await Navigator.pushNamed(_scaffoldKey.currentContext, '/landing',
                arguments: landing),
          ),
        )
        .toList();

    return Expanded(
      child: ListView(
        children: listLandings,
      ),
    );
  }

  _onPressTagButton(Haul haul, context) async {
    await Navigator.pushNamed(context, '/create_landing', arguments: haul);
  }

  _floatingActionButton({onPressed}) {
    return Container(
      height: 65,
      width: 200,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Add Shark',
          style: TextStyle(fontSize: 20),
        ),
        icon: Icon(Icons.add),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildLandingsLabel(List<Landing> landings) {
    final text = landings.length > 0 ? 'Sharks ' : 'No sharks for this haul';
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 30),
      ),
    );
  }

  bool _isHaulOfActiveTrip(Haul haul) => haul.tripId == _appStore.activeTrip?.id;

  bool _isActiveHaul(Haul haul) => _appStore.activeHaul?.id == haul.id;

  _cancelHaulAction() {
    return FlatButton.icon(
      textColor: Colors.white,
      label: Text('Cancel'),
      icon: Icon(
        Icons.cancel,
      ),
      onPressed: () async {
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('Cancel Haul',
              'Are you sure you want to cancel the haul? The haul will be removed. This action cannot be undone.'),
        );

        if (confirmed != null && confirmed) {
          Navigator.pop(_scaffoldKey.currentContext);
          // We must make sure to be back to the previous screen
          // before removing the haul or the widget will crash.
          // Ideally the widget should have a 'canceled' state
          // just for the purpose of preventing the page from
          // crashing due to rendering before navigation has
          // completed.
          await Future.delayed(Duration(milliseconds: 500));
          await _appStore.cancelHaul();
        }
      },
    );
  }

  Widget _endHaulAction() {
    return FlatButton.icon(
      textColor: Colors.white,
      label: Text('End'),
      icon: Icon(
        Icons.check_circle,
      ),
      onPressed: () async {
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('End Haul',
              'Are you sure you want to end the haul? You will not be able to continue later.'),
        );

        if (confirmed == true) {
          await _appStore.endHaul();
        }
      },
    );
  }

  List<Widget> _actions(Haul haul) {
    final List actions = <Widget>[];
    if (_isActiveHaul(haul)) {
      actions.add(_endHaulAction());
      actions.add(_cancelHaulAction());
    }
    return actions;
  }
}
