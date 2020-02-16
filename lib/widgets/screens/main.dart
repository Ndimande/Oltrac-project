import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/main/drawer.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main/haul_section.dart';
import 'package:oltrace/widgets/screens/main/no_active_trip.dart';
import 'package:oltrace/widgets/screens/main/trip_section.dart';
import 'package:oltrace/widgets/strip_button.dart';

class MainScreen extends StatefulWidget {
  MainScreen();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppStore _appStore = StoreProvider().appStore;

  Widget _appBar() {
    final title = _appStore.hasActiveTrip
        ? _appStore.hasActiveHaul ? 'Hauling...' : 'Active Trip'
        : 'Completed Trips';
    return AppBar(
      actions: <Widget>[appBarDate],
      title: Text(title),
    );
  }

  Widget get appBarDate {
    return Container(
      margin: EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      child: Text(friendlyDate(DateTime.now())),
    );
  }

  Future<FishingMethod> _selectFishingMethod() async {
    return await Navigator.push<FishingMethod>(
      context,
      MaterialPageRoute(builder: (context) => FishingMethodScreen()),
    );
  }

  _onPressStartHaul() async {
    final method = await _selectFishingMethod();
    if (method != null) {
      try {
        await _appStore.startHaul(method);
      } catch (e) {
        showTextSnackBar(_scaffoldKey, 'Could not start haul. ${Messages.LOCATION_NOT_AVAILABLE}');
        print(e);
      }
    }
  }

  _onPressEndHaul() async {
    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog('End haul', Messages.CONFIRM_END_HAUL),
    );

    if (confirmed) {
      try {
        await _appStore.endHaul();
      } catch (e) {
        print(e.toString());
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(content: Text('Could not end haul. ${Messages.LOCATION_NOT_AVAILABLE}')),
        );
        return;
      }
    }
  }

  _onPressHaulActionButton() async {
    if (_appStore.hasActiveHaul) {
      await _onPressEndHaul();
    } else {
      await _onPressStartHaul();
    }
  }

  _onPressStartTripButton() async {
    await _appStore.startTrip(_scaffoldKey);
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final String labelText = _appStore.hasActiveHaul ? 'End Haul' : 'Start Haul';
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          appBar: _appBar(),
          drawer: MainDrawer(),
          body: Builder(
            builder: (_) {
              if (!_appStore.hasActiveTrip) {
                return NoActiveTrip(onPressStartTrip: () async => await _onPressStartTripButton());
              }

              return Column(
                children: <Widget>[
                  TripSection(),
                  Expanded(child: HaulSection()),
                  StripButton(
                    centered: true,
                    labelText: labelText,
                    icon: Icon(
                      _appStore.hasActiveHaul ? Icons.stop : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    color: _appStore.hasActiveHaul ? Colors.red : Colors.green,
                    onPressed: () async => await _onPressHaulActionButton(),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
