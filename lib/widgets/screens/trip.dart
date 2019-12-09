import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/haul_list_item.dart';
import 'package:oltrace/widgets/screens/haul.dart';

class TripScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final Position startPosition = _appStore.activeTrip.startPosition;

    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInfoItem('Total hauls: ', trip.hauls.length.toString()),
          _buildInfoItem('Started: ', friendlyTimestamp(trip.startedAt)),
          _buildInfoItem('Ended: ', trip.endedAt != null ? friendlyTimestamp(trip.endedAt) : '-'),
        ],
      ),
    );
  }

  Widget _buildHaulsList(List<Haul> hauls) {
    return Expanded(
      child: ListView(
        children: hauls
            .map((haul) => HaulListItem(haul, () async {
                  final pageRoute = MaterialPageRoute(
                    builder: (context) => HaulScreen(),
                    settings: RouteSettings(
                      arguments: haul,
                    ),
                  );
                  await Navigator.push(
                    _scaffoldKey.currentContext,
                    pageRoute,
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
              _buildHaulsList(trip.hauls.reversed.toList())
            ],
          ),
        ));
  }
}
