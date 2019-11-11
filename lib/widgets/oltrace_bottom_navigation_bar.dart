import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';

final Map<NavIndex, int> _index = {
  NavIndex.haul: 0,
  NavIndex.tag: 1,
};

class TripBottomNavigationBar extends StatelessWidget {
  final AppStore _appStore;

  TripBottomNavigationBar(this._appStore);

  @override
  Widget build(BuildContext context) {
    int currentIndex = _index[_appStore.currentNavIndex];
    return BottomNavigationBar(
        onTap: (i) {
          if (i == 0) {
            _appStore.changeMainView(NavIndex.haul);
          } else if (i == 1) {
            if (_appStore.completedHauls.length > 0 ||
                _appStore.activeHaul != null) {
              _appStore.changeMainView(NavIndex.tag);
            } else {
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 1, milliseconds: 500),
                content:
                    Text('You must have an active or completed haul to tag.'),
              ));
            }
          }
          return null;
        },
        currentIndex: currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward),
              title: Text(
                'Haul',
                style: TextStyle(fontSize: 36),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.label),
              title: Text('Tag', style: TextStyle(fontSize: 36)))
        ]);
  }
}
