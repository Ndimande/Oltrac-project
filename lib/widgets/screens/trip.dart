import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/haul_list_item.dart';
import 'package:oltrace/widgets/screens/haul.dart';

class TripScreen extends StatelessWidget {
  final AppStore _appStore;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TripScreen(this._appStore);

  Widget _buildInfoItem(String label, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(label),
        Text(
          text,
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildTripInfo(Trip trip) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInfoItem('Total hauls: ', trip.hauls.length.toString()),
          _buildInfoItem('Started: ', friendlyTimestamp(trip.startedAt)),
          _buildInfoItem('Ended: ', friendlyTimestamp(trip.endedAt)),
        ],
      ),
    );
  }

  Widget _buildHaulsList(List<Haul> hauls) {
    return Expanded(
      child: ListView(
        children: hauls
            .map((haul) => HaulListItem(haul, () async {
                  await Navigator.push(
                    _scaffoldKey.currentContext,
                    MaterialPageRoute(
                      builder: (context) => HaulScreen(_appStore),
                      settings: RouteSettings(
                        arguments: haul,
                      ),
                    ),
                  );
                }))
            .toList(),
      ),
    );
  }

  Widget _buildHaulsLabel(Trip trip) {
    final text = trip.hauls.length > 0 ? 'Hauls ' : 'No hauls on this trip';
    return Container(
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      padding: EdgeInsets.only(top: 10, left: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Trip trip = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppConfig.backgroundColor,
        appBar: AppBar(
          title: Text('Trip ${trip.id}'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildTripInfo(trip),
              Divider(),
              _buildHaulsLabel(trip),
              _buildHaulsList(trip.hauls)
            ],
          ),
        ));
  }
}
