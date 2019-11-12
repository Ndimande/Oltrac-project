import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/oltrace_bottom_navigation_bar.dart';
import 'package:oltrace/widgets/oltrace_drawer.dart';
import 'package:oltrace/widgets/trip_started_ago.dart';
import 'package:oltrace/widgets/views/configure_vessel.dart';
import 'package:oltrace/widgets/views/tag_primary.dart';
import 'package:oltrace/widgets/views/tag_secondary.dart';
import 'package:oltrace/widgets/views/welcome.dart';
import 'package:oltrace/widgets/views/trip.dart';
import 'package:oltrace/widgets/views/tag.dart';
import 'package:oltrace/widgets/views/haul.dart';

class MainScreen extends StatefulWidget {
  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  final AppStore _appStore = AppStore();

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
    if (_appStore.tripHasStarted) {
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
                    builder: (_) => ConfirmDialog('End trip', 'Are you sure?'));
                if (confirmed) {
                  _appStore.endTrip();
                  _appStore.changeMainView(NavIndex.trip);
                }

                break;
            }
          },
          itemBuilder: _contextMenuItemBuilder)
    ];
  }

  /// Handles the back button navigation
  Future<bool> _onWillPop() async {
    switch (_appStore.currentNavIndex) {
      case NavIndex.tagSecondary:
      case NavIndex.tagPrimary:
        _appStore.changeMainView(NavIndex.tag);
        break;
      case NavIndex.trip:
        break;
      case NavIndex.haul:
      case NavIndex.tag:
      case NavIndex.configureVessel:
        _appStore.changeMainView(NavIndex.trip);
        break;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      /// The bar displayed at the top of the app
      final Widget _appBar = AppBar(
          title: TripStartedAgo(trip: _appStore.activeTrip),
          actions: _appBarActions(context));

      final Widget _bottomNavigationBar =
          _appStore.currentNavIndex == NavIndex.haul ||
                  _appStore.currentNavIndex == NavIndex.tag
              ? TripBottomNavigationBar(_appStore)
              : null;

      return WillPopScope(
          onWillPop: _onWillPop,
          child: Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: _bottomNavigationBar,
            appBar: _appStore.vesselIsConfigured ? _appBar : null,
            drawer:
                _appStore.vesselIsConfigured ? OlTraceDrawer(_appStore) : null,
            body: Builder(builder: (_) {
              if (!_appStore.vesselIsConfigured &&
                  _appStore.currentNavIndex != NavIndex.configureVessel) {
                return WelcomeView(_appStore);
              }
              switch (_appStore.currentNavIndex) {
                case NavIndex.trip:
                  return TripView(_appStore);
                case NavIndex.haul:
                  return HaulView(_appStore);
                case NavIndex.tag:
                  return TagView(_appStore);
                case NavIndex.tagPrimary:
                  return TagPrimaryView(_appStore);
                case NavIndex.tagSecondary:
                  return TagSecondaryView(_appStore);
                case NavIndex.configureVessel:
                  return ConfigureVesselView(_appStore);
              }
              return Container();
            }),
          ));
    });
  }
}
