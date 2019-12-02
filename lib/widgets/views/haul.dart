import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/elapsed_counter.dart';
import 'package:oltrace/widgets/haul_list_item.dart';

class HaulView extends StatefulWidget {
  final AppStore _appStore;

  HaulView(this._appStore);

  HaulViewState createState() => HaulViewState();
}

class HaulViewState extends State<HaulView> {
  Widget _buildNoActiveHaul() {
    return Container(
      alignment: Alignment.center,
      child: Text(
        'No active haul.',
        style: TextStyle(fontSize: 26),
      ),
    );
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
                'Method:',
                style: TextStyle(fontSize: 14),
              ),
              Text(
                widget._appStore.activeHaul.fishingMethod.name,
                style: TextStyle(fontSize: 24),
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
                  Text('Started: ', style: TextStyle(fontSize: 14)),
                  Text(
                    friendlyTimestamp(widget._appStore.activeHaul.startedAt),
                    style: TextStyle(fontSize: 16),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Text('Elapsed: ', style: TextStyle(fontSize: 14)),
                    ElapsedCounter(
                      widget._appStore.activeHaul.startedAt,
                      textStyle: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
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
      itemBuilder: (context, index) => HaulListItem(hauls[index], () {}),
    );
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
