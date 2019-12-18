import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/screens/main/drawer.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main/haul_section.dart';
import 'package:oltrace/widgets/screens/main/no_active_trip.dart';
import 'package:oltrace/widgets/screens/main/trip_section.dart';
import 'package:oltrace/widgets/time_ago.dart';

class _AppBarActions {
  static const endTrip = 'End Trip';
  static const cancelTrip = 'Cancel Trip';
  static const endHaul = 'End Haul';
  static const cancelHaul = 'Cancel Haul';
}

class MainScreen extends StatefulWidget {
  final AppStore _appStore = StoreProvider().appStore;

  MainScreen();

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  _onPressAction(String action) async {
    print(action);
    switch (action) {
      case _AppBarActions.endTrip:
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('End Trip', 'Are you sure you want to end the trip?'),
        );
        if (confirmed) {
          await widget._appStore.endTrip();
        }
        break;
      case _AppBarActions.cancelTrip:
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('Cancel Trip', 'Are you sure you want to cancel the trip?'),
        );
        if (confirmed) {
          await widget._appStore.cancelTrip();
        }
        break;
      case _AppBarActions.endHaul:
        await _onPressEndHaul();
        break;
      case _AppBarActions.cancelHaul:
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('Cancel Haul', 'Are you sure you want to cancel the haul?'),
        );
        if (confirmed) {
          await widget._appStore.cancelHaul();
        }
        break;
    }
  }

  List<Widget> _appBarActions() {
    final actions = <String>[];
    if (widget._appStore.hasActiveHaul) {
      actions.add(_AppBarActions.endHaul);
      actions.add(_AppBarActions.cancelHaul);
    } else if (widget._appStore.hasActiveTrip) {
      actions.add(_AppBarActions.endTrip);
      actions.add(_AppBarActions.cancelTrip);
    }

    return [
      PopupMenuButton(
        icon: Icon(Icons.more_vert),
        onSelected: _onPressAction,
        itemBuilder: (context) {
          return actions.map((String item) {
            return PopupMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList();
        },
      ),
    ];
  }

  Widget _buildAppBar() {
    Widget title = Text('In Port');
    if (widget._appStore.hasActiveTrip) {
      if (widget._appStore.hasActiveHaul) {
        title = Text(widget._appStore.activeHaul.fishingMethod.name);
      } else {
        title = TimeAgo(
          prefix: 'Trip started ',
          startedAt: widget._appStore.activeTrip.startedAt,
        );
      }
    }

    return AppBar(
      title: title,
      // actions: widget._appStore.hasActiveTrip ? _appBarActions() : null,
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
      await widget._appStore.endHaul();
    }
  }

  _onPressHaulFloatingActionButton() async {
    if (widget._appStore.hasActiveHaul) {
      await _onPressEndHaul();
    } else {
      await _onPressStartHaul();
    }
  }

  Widget _floatingActionButton() {
    bool started = widget._appStore.hasActiveHaul;

    final Icon icon = Icon(started ? Icons.stop : Icons.play_arrow);
    final color = started ? Colors.red : Colors.green;
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 180,
      child: FloatingActionButton.extended(
        backgroundColor: color,
        label: Text(
          started ? 'End Haul' : 'Start Haul',
          style: TextStyle(fontSize: 22),
        ),
        icon: icon,
        onPressed: () async => await _onPressHaulFloatingActionButton(),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final floatingActionButton = widget._appStore.hasActiveTrip ? _floatingActionButton() : null;

      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          key: _scaffoldKey,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          appBar: _buildAppBar(),
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
