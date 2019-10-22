import 'package:flutter/material.dart';
import 'package:oltrace/stores/app_store.dart';

final Map<MainViewIndex, int> _index = {
  MainViewIndex.haul: 0,
  MainViewIndex.tag: 1,
};

class TripBottomNavigationBar extends StatelessWidget {
  final AppStore _appStore;

  TripBottomNavigationBar(this._appStore);

  @override
  Widget build(BuildContext context) {
    int currentIndex = _index[_appStore.currentMainViewIndex];
    return BottomNavigationBar(
        onTap: (i) {
          if (i == 0) {
            _appStore.changeMainView(MainViewIndex.haul);
          } else if (i == 1) {
            _appStore.changeMainView(MainViewIndex.tag);
          }
          return null;
        },
        currentIndex: currentIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.arrow_upward), title: Text('Haul')),
          BottomNavigationBarItem(icon: Icon(Icons.label), title: Text('Tag'))
        ]);
  }
}
