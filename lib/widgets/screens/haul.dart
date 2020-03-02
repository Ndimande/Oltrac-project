import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/screens/add_source_landing.dart';
import 'package:oltrace/widgets/screens/haul/haul_info.dart';
import 'package:oltrace/widgets/strip_button.dart';

enum SpeciesDialogSelection { Single, Bulk, Cancel }

class HaulScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Haul _haul;
  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;
  final int listIndex;

  HaulScreen(this._haul, {this.listIndex});

  Widget bottomButtons(Haul haul) => Builder(
        builder: (context) => Row(
          children: <Widget>[
            Expanded(
              child: StripButton(
                centered: true,
                icon: Icon(
                  Icons.add,
                  color: Colors.white,
                ),
                color: Colors.green,
                labelText: 'Species',
                onPressed: () async => await _onPressAddLandingButton(haul, context),
              ),
            ),
            Expanded(
              child: StripButton(
                centered: true,
                icon: Icon(
                  Icons.local_offer,
                  color: Colors.white,
                ),
                color: olracBlue,
                labelText: 'Tag',
                onPressed: () async => await _onPressAddTagButton(haul, context),
              ),
            )
          ],
        ),
      );

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

  _onPressLandingListItem(Landing landing, landingIndex) async {
    await Navigator.pushNamed(
      _scaffoldKey.currentContext,
      '/landing',
      arguments: [landing, landingIndex],
    );
  }

  Widget _buildLandingsList(List<Landing> landings) {
    int landingIndex = landings.length;

    final List<LandingListItem> listLandings = landings.reversed
        .map(
          (Landing landing) => LandingListItem(
            landing: landing,
            onPressed: (index) async => await _onPressLandingListItem(landing, index),
            //() async => await _onPressLandingListItem(landing, landingIndex),
            listIndex: landingIndex--,
          ),
        )
        .toList();

    return Expanded(
      child: ListView(
        children: listLandings,
      ),
    );
  }

  Future<void> _onPressAddLandingButton(Haul haul, context) async {
    // todo update to ask for bulk / single with dialog
    final bool bulkMode = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Add Species'),
        content: Text('How do you want to add species?'),
        actions: <Widget>[
          FlatButton(
            child: Text('Single'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          FlatButton(
            child: Text('Bulk'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(null),
          ),
        ],
      ),
    );
    if (bulkMode == null) {
      return;
    }
    sharedPrefs.setBool('bulkMode', bulkMode);
    await Navigator.pushNamed(context, '/create_landing', arguments: haul);
  }

  showAddSpeciesDialog(BuildContext context) async {
    return await showDialog<SpeciesDialogSelection>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        actions: <Widget>[
          FlatButton(
            child: Text('Single'),
            onPressed: () => Navigator.of(_).pop(SpeciesDialogSelection.Single),
          ),
          FlatButton(
            child: Text('Bulk'),
            onPressed: () => Navigator.of(_).pop(SpeciesDialogSelection.Bulk),
          ),
          FlatButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(_).pop(SpeciesDialogSelection.Cancel),
          ),
        ],
        title: Text('Add Species'),
        content: Text('How do you want to add species?'),
      ),
    );
  }

  Future<void> _onPressAddTagButton(Haul haul, context) async {
    SpeciesDialogSelection selection = await showAddSpeciesDialog(context);
    if (selection == SpeciesDialogSelection.Cancel) {
      return;
    }
    print(selection);
// todo show select species screen
    final List<Landing> selectedLandings = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSourceLandingsScreen(
          alreadySelectedLandings: [],
          selectionMode: selection,
          sourceHaul: _haul,
        ),
      ),
    );
    await Navigator.pushNamed(context, '/create_product',
        arguments: {'haul': haul, 'landings': selectedLandings});
  }

  Widget _buildLandingsLabel(List<Landing> landings) {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10),
      alignment: Alignment.centerLeft,
      child: Text(
        'Species List',
        style: TextStyle(fontSize: 30, color: olracBlue),
      ),
    );
  }

  bool _isHaulOfActiveTrip(Haul haul) => haul.tripId == _appStore.activeTrip?.id;

  bool isActiveHaul(Haul haul) => _appStore.activeHaul?.id == haul.id;

  Future<void> onPressCancelHaul() async {
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
  }

  Future<void> onPressEndHaul() async {
    bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => ConfirmDialog(
        'End Haul',
        'Are you sure you want to end the haul? You will not be able to continue later.',
      ),
    );

    if (confirmed == true) {
      await _appStore.endHaul();
    }
  }

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

      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(haul.fishingMethod.name),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              HaulInfo(
                haul: haul,
                onPressEndHaul: onPressEndHaul,
                onPressCancelHaul: onPressCancelHaul,
                listIndex: listIndex,
              ),
              _buildLandingsSection(haul.landings),
              _isHaulOfActiveTrip(haul) ? bottomButtons(haul) : Container(),
            ],
          ),
        ),
      );
    });
  }
}
