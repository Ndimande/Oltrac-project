import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/tag.dart';
import 'package:oltrace/widgets/tag_list_item.dart';

class HaulScreen extends StatelessWidget {
  final AppStore _appStore;

  HaulScreen(this._appStore);

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaulDetails(Haul haul) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDetailRow('Fishing method', haul.fishingMethod.name),
          _buildDetailRow('Started', friendlyTimestamp(haul.startedAt)),
          _buildDetailRow('Ended', friendlyTimestamp(haul.endedAt)),
        ],
      ),
    );
  }

  Widget _buildTagsList(List<Tag> tags) {
    return Expanded(
      child: ListView(
        children: tags.map((tag) => TagListItem(tag, () {})).toList(),
      ),
    );
  }

  _onPressTagButton(Haul haul, context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagScreen(_appStore),
        settings: RouteSettings(
          arguments: haul,
        ),
      ),
    );
  }

  _floatingActionButton({onPressed}) {
    return Container(
      margin: EdgeInsets.only(top: 100),
      height: 65,
      width: 180,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Tag',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.add_circle_outline),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTagsLabel(List<Tag> tags) {
    final text = tags.length > 0 ? 'Tags ' : 'No tags for this haul';
    return Container(
      child: Text(
        text,
        style: TextStyle(fontSize: 20),
      ),
      padding: EdgeInsets.only(top: 10, left: 10),
    );
  }

  bool _isHaulOfActiveTrip(Haul haul) =>
      haul.tripId == _appStore.activeTrip?.id;

  @override
  Widget build(BuildContext context) {
    final Haul haulArg = ModalRoute.of(context).settings.arguments;

    final int haulArgTripId = haulArg.tripId;
    final bool isActiveTrip = _appStore.activeTrip != null
        ? _appStore.activeTrip.id == haulArg.tripId
        : false;

    Trip trip;
    if (isActiveTrip) {
      trip = _appStore.activeTrip;
    } else {
      trip = _appStore.completedTrips
          .firstWhere((trip) => trip.id == haulArgTripId);
    }
// get the haul from the trip from the store
    final haul = trip.hauls.firstWhere((h) => haulArg.id == h.id);

    print(_appStore.completedTrips);
    return Scaffold(
        backgroundColor: AppConfig.backgroundColor,
        floatingActionButton: _isHaulOfActiveTrip(haul)
            ? _floatingActionButton(
                onPressed: () async => await _onPressTagButton(haul, context),
              )
            : null,
        appBar: AppBar(
          title: Text('Haul ${haul.id}'),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildHaulDetails(haul),
              Divider(),
              _buildTagsLabel(haul.tags),
              _buildTagsList(haul.tags)
            ],
          ),
        ));
  }
}
