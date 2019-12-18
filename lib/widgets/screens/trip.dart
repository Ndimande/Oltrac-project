import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/haul_list_item.dart';

class TripScreen extends StatelessWidget {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final AppStore _appStore = StoreProvider().appStore;

  final Trip _trip;

  TripScreen(this._trip);

  Widget _buildInfoItem(String label, String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            text,
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfo(Trip trip) {
    final Position startPosition = trip.startPosition;
    final String endLocation =
        trip.endPosition != null ? Location.fromPosition(trip.endPosition).toString() : '-';
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildInfoItem('Started ', friendlyDateTimestamp(trip.startedAt)),
          _buildInfoItem(
              'Ended ', trip.endedAt != null ? friendlyDateTimestamp(trip.endedAt) : '-'),
          _buildInfoItem('Start Coords. ', Location.fromPosition(startPosition).toString()),
          _buildInfoItem('End Coords. ', endLocation),
          _buildInfoItem('Total hauls ', trip.hauls.length.toString()),
        ],
      ),
    );
  }

  Widget _buildHaulsList(List<Haul> hauls) {
    final List<HaulListItem> haulListItems = hauls
        .map((Haul haul) => HaulListItem(
              haul,
              () async => await Navigator.pushNamed(
                _scaffoldKey.currentContext,
                '/haul',
                arguments: haul,
              ),
            ))
        .toList();

    return Expanded(
      child: ListView(children: haulListItems),
    );
  }

  Widget _buildHaulsLabel(Trip trip) {
    final text = trip.hauls.length > 0 ? 'Hauls ' : 'No hauls on this trip';
    return Container(
      child: Text(
        text,
        style: TextStyle(fontSize: 30),
      ),
      padding: EdgeInsets.only(top: 10, left: 10),
    );
  }

  @override
  Widget build(BuildContext context) {
    var title = 'Trip ${_trip.id}';
    if (_appStore.hasActiveTrip && _appStore.activeTrip.id == _trip.id) {
      title += ' (Active)';
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              child: _buildTripInfo(_trip),
              padding: EdgeInsets.all(5),
            ),
            Divider(),
            _buildHaulsLabel(_trip),
            _buildHaulsList(_trip.hauls.reversed.toList())
          ],
        ),
      ),
    );
  }
}
