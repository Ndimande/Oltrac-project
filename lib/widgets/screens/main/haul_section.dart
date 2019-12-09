import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/haul_list_item.dart';
import 'package:oltrace/widgets/screens/haul.dart';

class HaulSection extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  HaulSection();

  _onPressHaulListItem(context, Haul haul) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HaulScreen(),
        settings: RouteSettings(
          arguments: haul,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      final hauls = _appStore.activeTrip.hauls.reversed.toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 50,
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 20),
              child: Text(
                'Hauls',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: hauls.length == 0
                  ? Container(
                      alignment: Alignment.topCenter,
                      child: Text(
                        'No hauls on this trip so far',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: hauls.length,
                      itemBuilder: (context, index) {
                        final Haul haul = hauls[index];

                        return HaulListItem(
                          haul,
                          () async => await _onPressHaulListItem(context, haul),
                        );
                      },
                    ),
            ),
          )
        ],
      );
    });
  }
}
