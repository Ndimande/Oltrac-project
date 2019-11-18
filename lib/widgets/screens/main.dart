import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/oltrace_bottom_navigation_bar.dart';
import 'package:oltrace/widgets/oltrace_drawer.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/time_ago.dart';
import 'package:oltrace/widgets/views/configure_vessel.dart';
import 'package:oltrace/widgets/views/tag_primary.dart';
import 'package:oltrace/widgets/views/tag_secondary.dart';
import 'package:oltrace/widgets/views/welcome.dart';
import 'package:oltrace/widgets/views/trip.dart';
import 'package:oltrace/widgets/views/tag.dart';
import 'package:oltrace/widgets/views/haul.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';

class MainScreen extends StatefulWidget {
  final AppStore _appStore;

  MainScreen(this._appStore);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  List<PopupMenuEntry<ContextMenuIndex>> _contextMenuItemBuilder(
      BuildContext context) {
    // Items shown on every screen
    var contextMenuActions = [
      PopupMenuItem(
        value: ContextMenuIndex.about,
        child: Text('About'),
      )
    ];

    // Additional items
    if (widget._appStore.tripHasStarted) {
      contextMenuActions.add(PopupMenuItem(
        value: ContextMenuIndex.endTrip,
        child: Text('End Trip'),
      ));
    }

    return contextMenuActions;
  }

  List<Widget> _appBarActions(context) {
    return [
      /// There's only one scaffold action
      PopupMenuButton(
          onSelected: (ContextMenuIndex index) async {
            switch (index) {
              case ContextMenuIndex.about:
                Navigator.pushNamed(context, '/about');

                break;

              case ContextMenuIndex.endTrip:
                final bool confirmed = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => ConfirmDialog('End trip',
                        'This will also end any active hauls. Are you sure?'));
                if (confirmed) {
                  widget._appStore.endTrip();
                  widget._appStore.changeMainView(NavIndex.trip);
                }

                break;
            }
          },
          itemBuilder: _contextMenuItemBuilder)
    ];
  }

  /// Handles the device back button navigation
  Future<bool> _onWillPop() async {
    switch (widget._appStore.mainNavIndex) {
      case NavIndex.tagSecondary:
      case NavIndex.tagPrimary:
        widget._appStore.changeMainView(NavIndex.tag);
        break;
      case NavIndex.welcome:
      case NavIndex.trip:
      case NavIndex.haul:
      case NavIndex.tag:
      case NavIndex.configureVessel:
    }
    return false;
  }

  _tripFloatingActionButton() {
    bool started = widget._appStore.tripHasStarted;
    final Function action = started
        ? () => widget._appStore.endTrip()
        : () => widget._appStore.startTrip();

    final Icon icon = Icon(started ? Icons.stop : Icons.add);
    final String dialogTitle = started ? 'End Trip' : 'Start Trip';
    final String dialogBody = started
        ? 'This will also end any active hauls. Are you sure?'
        : 'Are you sure?';

    return FloatingActionButton(
      child: icon,
      onPressed: () async {
        bool answer = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (_) => ConfirmDialog(dialogTitle, dialogBody));
        if (answer) {
          action();
        }
      },
    );
  }

  Future<FishingMethod> _selectFishingMethod() async {
    return await Navigator.push<FishingMethod>(context,
        MaterialPageRoute(builder: (context) => FishingMethodScreen()));
  }

  _haulFloatingActionButton() {
    bool started = widget._appStore.haulHasStarted;
    final Function action = started
        ? () => widget._appStore.endHaul()
        : () async {
            final method = await _selectFishingMethod();
            widget._appStore.startHaul(method);
          };

    final Icon icon = Icon(started ? Icons.stop : Icons.add);
    final String dialogTitle = started ? 'End Haul' : 'Start Haul';
    final String dialogBody = 'Are you sure?';

    return FloatingActionButton(
      child: icon,
      onPressed: () async {
        if (started) {
          bool answer = await showDialog<bool>(
              context: context,
              barrierDismissible: false,
              builder: (_) => ConfirmDialog('End haul',
                  'Are you sure you want to end the current haul?'));
          if (answer) {
            widget._appStore.endHaul();
          }
        } else {
          final method = await _selectFishingMethod();
          if (method != null) {
            widget._appStore.startHaul(method);
          }
        }
      },
    );
  }

  FloatingActionButton _floatingActionButton() {
    switch (widget._appStore.mainNavIndex) {
      case NavIndex.trip:
        return _tripFloatingActionButton();
      case NavIndex.haul:
        return _haulFloatingActionButton();
      case NavIndex.configureVessel:
      case NavIndex.tag:
      case NavIndex.tagPrimary:
      case NavIndex.tagSecondary:
      case NavIndex.welcome:
    }
    return null;
  }

  _buildAppBar() {
    Widget title = Text('In Port');
    if (widget._appStore.activeTrip != null) {
      if (widget._appStore.activeHaul != null) {
        title = Text(widget._appStore.activeHaul.fishingMethod.name);
      } else {
        title = TimeAgo(
            prefix: 'Trip started ',
            startedAt: widget._appStore.activeTrip.startedAt);
      }
    }
    return AppBar(
        title: title,
//          title: TripStartedAgo(trip: widget._appStore.activeTrip),
        actions: _appBarActions(context));
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      /// The bar displayed at the top of the app

      final Widget _bottomNavigationBar =
          widget._appStore.mainNavIndex == NavIndex.haul ||
                  widget._appStore.mainNavIndex == NavIndex.tag ||
                  widget._appStore.mainNavIndex == NavIndex.trip
              ? OlTraceBottomNavigationBar(widget._appStore)
              : null;

      return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            floatingActionButton: _floatingActionButton(),
            backgroundColor: Colors.white,
            bottomNavigationBar: _bottomNavigationBar,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            appBar: _buildAppBar(),
            drawer: OlTraceDrawer(widget._appStore),
            body: Builder(builder: (_) {
              switch (widget._appStore.mainNavIndex) {
                case NavIndex.welcome:
                  return WelcomeView(widget._appStore);
                case NavIndex.trip:
                  return TripView(widget._appStore);
                case NavIndex.haul:
                  return HaulView(widget._appStore);
                case NavIndex.tag:
                  return TagView(widget._appStore);
                case NavIndex.tagPrimary:
                  return TagPrimaryView(widget._appStore);
                case NavIndex.tagSecondary:
                  return TagSecondaryView(widget._appStore);
                case NavIndex.configureVessel:
                  return ConfigureVesselView(widget._appStore);
              }
              return Container();
            }),
          ));
    });
  }
}
