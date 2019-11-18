import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';

TextStyle _itemTextStyle(bool active) => TextStyle(
    fontSize: 18, decoration: active ? TextDecoration.underline : null);

final Map<NavIndex, int> _index = {
  NavIndex.haul: 0,
  NavIndex.tag: 1,
  NavIndex.trip: 2
};

class OlTraceBottomNavigationBar extends StatelessWidget {
  final AppStore _appStore;

  OlTraceBottomNavigationBar(this._appStore);

  Function getOnPressTrip() {
    return () => _appStore.changeMainView(NavIndex.trip);
  }

  Function getOnPressHaul() {
    return _appStore.activeTrip == null
        ? null
        : () => _appStore.changeMainView(NavIndex.haul);
  }

  Function getOnPressTag() {
    if (!_appStore.hasActiveOrCompleteTrip) {
      return null;
    }
    if (_appStore.activeTrip != null &&
        !_appStore.activeTripHasActiveOrCompleteHaul) {
      return null;
    }
    return () => _appStore.changeMainView(NavIndex.tag);
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 4.0,
      child: new Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                  child: Text('Trip',
                      style: _itemTextStyle(
                          _appStore.mainNavIndex == NavIndex.trip)),
                  onPressed: getOnPressTrip()),
              FlatButton(
                child: Text(
                  'Haul',
                  style:
                      _itemTextStyle(_appStore.mainNavIndex == NavIndex.haul),
                ),
                onPressed: getOnPressHaul(),
              ),
            ],
          ),
          FlatButton(
            child: Text('Tag',
                style: _itemTextStyle(_appStore.mainNavIndex == NavIndex.tag)),
            onPressed: getOnPressTag(),
          ),
        ],
      ),
    );
  }
}
