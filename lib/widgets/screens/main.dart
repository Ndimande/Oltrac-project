import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/oltrace_bottom_navigation_bar.dart';
import 'package:oltrace/widgets/oltrace_drawer.dart';
import 'package:oltrace/widgets/trip_started_ago.dart';
import 'package:oltrace/widgets/views/configure_vessel.dart';
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
                  _appStore.changeMainView(MainViewIndex.home);
                }

                break;
            }
          },
          itemBuilder: _contextMenuItemBuilder)
    ];
  }

  Future<bool> _onWillPop() async {
    switch (_appStore.currentMainViewIndex) {
      case MainViewIndex.home:
        break;
      case MainViewIndex.haul:
      case MainViewIndex.tag:
      case MainViewIndex.configureVessel:
        _appStore.changeMainView(MainViewIndex.home);
        break;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      /// The bar displayed at the top of the app
      final Widget _appBar = AppBar(
          title: TripStartedAgo(trip: _appStore.currentTrip),
          actions: _appBarActions(context));

      // todo Does not update when TripView is changed due to being above the widget
      final Widget _bottomNavigationBar =
          _appStore.currentMainViewIndex == MainViewIndex.haul ||
                  _appStore.currentMainViewIndex == MainViewIndex.tag
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
                  _appStore.currentMainViewIndex !=
                      MainViewIndex.configureVessel) {
                return WelcomeView(_appStore);
              }
              switch (_appStore.currentMainViewIndex) {
                case MainViewIndex.home:
                  return TripView(_appStore);
                case MainViewIndex.haul:
                  return HaulView(_appStore);
                case MainViewIndex.tag:
                  return TagView(_appStore);
                case MainViewIndex.configureVessel:
                  return ConfigureVesselView(_appStore);
              }
              return Container();
            }),
          ));
    });
  }
}
