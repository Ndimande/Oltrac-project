import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/app_fab.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/main/drawer.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main/haul_section.dart';
import 'package:oltrace/widgets/screens/main/no_active_trip.dart';
import 'package:oltrace/widgets/screens/main/trip_section.dart';

class MainScreen extends StatefulWidget {
  final AppStore _appStore = StoreProvider().appStore;

  MainScreen();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _appBar() {
    return AppBar(
      title: Text(widget._appStore.hasActiveTrip ? '' : 'In Port'),
    );
  }

  Future<FishingMethod> _selectFishingMethod() async {
    return await Navigator.push<FishingMethod>(
        context, MaterialPageRoute(builder: (context) => FishingMethodScreen()));
  }

  _onPressStartHaul() async {
    final method = await _selectFishingMethod();
    if (method != null) {
      await widget._appStore.startHaul(method);
    }
  }

  _onPressEndHaul() async {
    bool confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ConfirmDialog(
        'End haul',
        'Are you sure you want to end the haul?',
      ),
    );

    if (confirmed) {
      try {
        await widget._appStore.endHaul();
      } on Exception catch (e) {
        print(e.toString());
        _scaffoldKey.currentState.showSnackBar(
          SnackBar(
            content: Text('Location not available.'),
          ),
        );
        return;
      }
    }
  }

  _onPressHaulFloatingActionButton() async {
    if (widget._appStore.hasActiveHaul) {
      await _onPressEndHaul();
    } else {
      await _onPressStartHaul();
    }
  }

  Widget _haulFloatingActionButton() {
    bool started = widget._appStore.hasActiveHaul;

    final Icon icon = Icon(started ? Icons.stop : Icons.play_arrow);
    final Color color = started ? Colors.red : Colors.green;
    return AppFAB(
      backgroundColor: color,
      label: Text(
        started ? 'End Haul' : 'Start Haul',
        style: TextStyle(fontSize: 20),
      ),
      icon: icon,
      onPressed: () async => await _onPressHaulFloatingActionButton(),
    );
  }

  Widget _tripFloatingActionButton() {
    return AppFAB(
      backgroundColor: Colors.green,
      icon: Icon(Icons.play_arrow),
      label: Text(
        'Start Trip',
        style: TextStyle(fontSize: 20),
      ),
      onPressed: () async {
        await widget._appStore.startTrip();
      },
    );
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final floatingActionButton = widget._appStore.hasActiveTrip
          ? _haulFloatingActionButton()
          : _tripFloatingActionButton();

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          appBar: _appBar(),
          drawer: MainDrawer(),
          body: Builder(
            builder: (_) {
              if (!widget._appStore.hasActiveTrip) {
                return NoActiveTrip();
              }

              return Column(
                children: <Widget>[
                  TripSection(),
                  Divider(),
                  Expanded(child: HaulSection()),
                ],
              );
            },
          ),
        ),
      );
    });
  }
}
