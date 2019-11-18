import 'package:flutter/material.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/big_button.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';

class HaulView extends StatefulWidget {
  final AppStore _appStore;

  HaulView(this._appStore);

  HaulViewState createState() => HaulViewState();
}

class HaulViewState extends State<HaulView> {
  Widget buildCurrentHaul() {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Text('Haul started at ' +
            widget._appStore.activeHaul.startedAt.toIso8601String()),
        BigButton(
            label: 'End Haul',
            onPressed: () {
              setState(() {
                widget._appStore.endHaul();
              });
            })
      ],
    ));
  }

  Widget _buildNoActiveHaul() {
    return Container(
        alignment: Alignment.center,
        child: Text(
          'No active haul.',
          style: TextStyle(fontSize: 26),
        ));
  }

  Widget _buildHaulInfo() {
    return Container(
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Method',
                  style: TextStyle(fontSize: 12),
                ),
                Text(
                  widget._appStore.activeHaul.fishingMethod.name,
                  style: TextStyle(fontSize: 22),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Started: ', style: TextStyle(fontSize: 12)),
                    Text(friendlyTimestamp(
                        widget._appStore.activeHaul.startedAt))
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text('Elapsed: ', style: TextStyle(fontSize: 12)),
                      ElapsedCounter(widget._appStore.activeHaul.startedAt)
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget _buildTopSection() {
    return widget._appStore.activeHaul == null
        ? _buildNoActiveHaul()
        : _buildHaulInfo();
  }

  Widget _buildBottomSection() {
    final List<Haul> completedHauls = widget._appStore.activeTrip.hauls;
    if (completedHauls.length == 0) {
      return Text('No completed hauls in this trip');
    }

    return _buildHaulListView(completedHauls);
  }

  Widget _buildHaulListView(List<Haul> hauls) {
    return ListView.builder(
        itemCount: hauls.length,
        itemBuilder: (context, index) {
          final Haul haul = hauls[index];
          final String startedAt = friendlyTimestamp(haul.startedAt);
          final String endedAt = friendlyTimestamp(haul.endedAt);
          final timePeriod = Text('$startedAt - $endedAt');

          return FlatButton(
              onPressed: () {},
              child: ListTile(
                title: timePeriod,
                subtitle: Text(haul.fishingMethod.name),
                trailing: Icon(Icons.keyboard_arrow_right),
              ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          child: _buildTopSection(),
          height: 110,
        ),
        Divider(
          thickness: 2,
        ),
        Expanded(child: _buildBottomSection()),
      ],
    );
  }
}
