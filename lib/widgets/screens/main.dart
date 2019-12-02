import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/oltrace_drawer.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/time_ago.dart';
import 'package:oltrace/widgets/views/tag_primary.dart';
import 'package:oltrace/widgets/views/tag_secondary.dart';
import 'package:oltrace/widgets/views/trip.dart';
import 'package:oltrace/widgets/views/tag.dart';
import 'package:oltrace/widgets/views/haul.dart';

class MainScreen extends StatefulWidget {
  final AppStore _appStore;

  MainScreen(this._appStore);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final PageController _haulPageController = PageController(initialPage: 0);

  Future<FishingMethod> _selectFishingMethod() async {
    return await Navigator.push<FishingMethod>(context,
        MaterialPageRoute(builder: (context) => FishingMethodScreen()));
  }

  _onPressHaulFloatingActionButton() async {
    bool started = widget._appStore.haulHasStarted;

    if (started) {
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
        await _haulPageController.animateToPage(0,
            duration: Duration(milliseconds: 400), curve: Curves.easeInOutQuad);
      }
    } else {
      final method = await _selectFishingMethod();
      if (method != null) {
        await widget._appStore.startHaul(method);
        await _haulPageController.animateToPage(1,
            duration: Duration(milliseconds: 400), curve: Curves.easeInOutQuad);
      }
    }
  }

  Widget _floatingActionButton() {
    bool started = widget._appStore.haulHasStarted;

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

  Widget _buildAppBar() {
    Widget title = Text('In Port');
    if (widget._appStore.activeTrip != null) {
      if (widget._appStore.activeHaul != null) {
        title = Text(widget._appStore.activeHaul.fishingMethod.name);
      } else {
        title = TimeAgo(
          prefix: 'Trip started ',
          startedAt: widget._appStore.activeTrip.startedAt,
        );
      }
    }
    return AppBar(title: title);
  }

  Future<bool> _onWillPop() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: AppConfig.backgroundColor,
          floatingActionButton:
              widget._appStore.tripHasStarted ? _floatingActionButton() : null,
          floatingActionButtonLocation: widget._appStore.activeHaul == null
              ? FloatingActionButtonLocation.centerFloat
              : FloatingActionButtonLocation.endTop,
          appBar: _buildAppBar(),
          drawer: OlTraceDrawer(widget._appStore),
          body: Builder(builder: (_) {
            switch (widget._appStore.mainNavIndex) {
              case NavIndex.trip:
                return TripView(widget._appStore, _haulPageController);
              case NavIndex.haul:
                return HaulView(widget._appStore);
              case NavIndex.tag:
                return TagView(widget._appStore);
              case NavIndex.tagPrimary:
                return TagPrimaryView(widget._appStore);
              case NavIndex.tagSecondary:
                return TagSecondaryView(widget._appStore);
            }
            return null;
          }),
        ),
      );
    });
  }
}
