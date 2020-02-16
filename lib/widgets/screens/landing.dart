import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/landing/landing_details.dart';
import 'package:oltrace/widgets/screens/landing/products_list.dart';
import 'package:oltrace/widgets/shark_info_card.dart';
import 'package:oltrace/widgets/strip_button.dart';

const double rowFontSize = 18;

class LandingScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final Landing _landingArg;
  final int listIndex;

  LandingScreen(this._landingArg, {this.listIndex});

  _onPressTagProduct(Landing landing) async {
    // We will pop true if a product was created
    await Navigator.pushNamed(_scaffoldKey.currentContext, '/create_product', arguments:[ landing,listIndex]);
  }

  Widget actionButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            centered: true,
            onPressed: _onPressDelete,
            labelText: 'Delete',
            color: Colors.red,
            icon: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StripButton(
            centered: true,
            onPressed: _onPressEdit,
            labelText: 'Edit',
            color: olracBlue,
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  _onPressDelete() async {
    bool confirmed = await showDialog<bool>(
      context: _scaffoldKey.currentContext,
      builder: (_) => ConfirmDialog('Delete Shark', 'Are you sure you want to delete this shark?'),
    );
    if (!confirmed) {
      return;
    }
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text('Shark deleted'),
      ),
    );
    await Future.delayed(Duration(seconds: 1));
    Navigator.pop(_scaffoldKey.currentContext);
    await Future.delayed(Duration(milliseconds: 500));
    await _appStore.deleteLanding(_landingArg);
  }

  _onPressEdit() {
    final Landing landing = _getLandingFromState(_getHaulFromActiveTripState());
    Navigator.pushNamed(_scaffoldKey.currentContext, '/edit_landing', arguments: landing);
  }

  Haul _getHaulFromActiveTripState() =>
      _appStore.activeTrip.hauls.singleWhere((h) => h.id == _landingArg.haulId, orElse: () => null);

  // TODO Selfishness must always be forgiven you know, because there is no hope of a cure.
  Haul getHaulFromState() {
    Haul foundHaul;
    if (_appStore.hasActiveTrip) {
      foundHaul = _getHaulFromActiveTripState();
    }

    if (foundHaul != null) {
      return foundHaul;
    }

    for (Trip currentTrip in _appStore.completedTrips) {
      if (currentTrip.hauls.length == 0) {
        continue;
      }
      for (Haul haul in currentTrip.hauls) {
        if (haul.id == _landingArg.haulId) {
          foundHaul = haul;
        }
      }

      if (foundHaul != null) {
        return foundHaul;
      }
    }

    return null;
  }

  Landing _getLandingFromState(Haul haul) {
    // We need to be sure not to use the stale data from
    // the item pushed as an argument
    // It would be wise to push an int instead and always retrieve
    // the item from global state.

    return haul.landings.singleWhere((Landing l) => l.id == _landingArg.id);
  }

  Widget tagProductButton(Haul haul, Landing landing) {
    if (haul == null || !(haul.tripId == _appStore.activeTrip?.id) || landing.doneTagging == true) {
      return Container();
    }

    return StripButton(
      color: Colors.green,
      centered: true,
      labelText: 'Tag Product',
      icon: Icon(
        Icons.local_offer,
        color: Colors.white,
      ),
      onPressed: () async => await _onPressTagProduct(landing),
    );
  }

  Widget noProducts() {
    return Text(
      'No product tags yet',
      style: TextStyle(fontSize: 16),
    );
  }

  Widget doneTaggingSwitch(Landing landing) {
    // TODO only show this if it is a landing of an active trip
    return Row(
      children: <Widget>[
        Text('Done'),
        Switch(
          activeColor: Colors.white,
          value: landing.doneTagging ?? false,
          onChanged: (bool value) async {
            await _appStore.editLanding(landing.copyWith(doneTagging: value));
          },
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      // We need to be sure not to use the stale data from
      // the item pushed as an argument
      // It would be wise to push an int instead and always retrieve
      // the item from global state.

      final Haul haul = getHaulFromState();
      final Landing landing = _getLandingFromState(haul);

      return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text(landing.individuals > 1 ? 'Bulk bin' : 'Shark'),
          actions: <Widget>[doneTaggingSwitch(landing)],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        color: olracBlue[50],
                        child: SharkInfoCard(
                          landing: landing,
                          listIndex: listIndex,
                        ),
                      ),
                      haul.tripId == _appStore.activeTrip?.id ? actionButtons() : Container(),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: LandingDetails(landing: landing),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10),
                      ),
                      Container(
                        child: landing.products.length > 0
                            ? ProductsList(landing: landing)
                            : noProducts(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            tagProductButton(haul, landing)
          ],
        ),
      );
    });
  }
}
