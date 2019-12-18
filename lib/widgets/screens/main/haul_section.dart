import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/haul_list_item.dart';

class HaulSection extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  _onPressHaulListItem(context, Haul haul) async {
    await Navigator.pushNamed(context, '/haul', arguments: haul);
  }

  Widget _buildNoHauls() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No hauls on this trip so far',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildHaulsList(List<Haul> hauls) {
    return ListView.builder(
      itemCount: hauls.length,
      itemBuilder: (context, index) {
        final Haul haul = hauls[index];

        return HaulListItem(
          haul,
          () async => await _onPressHaulListItem(context, haul),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final hauls = _appStore.activeTrip.hauls.reversed.toList();

      return Column(
        children: <Widget>[
          Container(
            height: 50,
            child: Container(
              alignment: Alignment.center,
              child: Text(
                'Hauls',
                style: TextStyle(fontSize: 30),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: hauls.length == 0 ? _buildNoHauls() : _buildHaulsList(hauls),
            ),
          )
        ],
      );
    });
  }
}
