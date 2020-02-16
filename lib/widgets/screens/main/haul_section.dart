import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/grouped_hauls_list.dart';

class HaulSection extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  Widget _buildNoHauls() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No hauls on this trip yet',
        style: TextStyle(fontSize: 20)
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final hauls = _appStore.activeTrip.hauls.reversed.toList();

      return Column(
        children: <Widget>[

          Expanded(
            child: Container(
              child: hauls.length == 0 ? _buildNoHauls() : GroupedHaulsList(hauls: hauls),
            ),
          )
        ],
      );
    });
  }
}
