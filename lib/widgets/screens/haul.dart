import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/create_tag.dart';
import 'package:oltrace/widgets/screens/tag.dart';
import 'package:oltrace/widgets/tag_list_item.dart';

class HaulScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  HaulScreen();

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
            child: Text(
              value,
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHaulDetails(Haul haul) {
    final startLocation = Location.fromPosition(haul.startPosition);
    final String endLocation =
        haul.endPosition != null ? Location.fromPosition(haul.endPosition).toString() : '-';
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildDetailRow('Fishing method', haul.fishingMethod.name),
          _buildDetailRow('Started', friendlyTimestamp(haul.startedAt)),
          _buildDetailRow('Ended', friendlyTimestamp(haul.endedAt) ?? '-'),
          _buildDetailRow('Start Coords.', startLocation.toString()),
          _buildDetailRow('End Coords.', endLocation),
        ],
      ),
    );
  }

  Widget _buildTagsList(List<Tag> tags) {
    return Expanded(
      child: ListView(
        children: tags
            .map((tag) => TagListItem(tag, () async {
                  final pageRoute = MaterialPageRoute(
                    builder: (context) => TagScreen(),
                    settings: RouteSettings(arguments: tag),
                  );

                  await Navigator.push(_scaffoldKey.currentContext, pageRoute);
                }))
            .toList(),
      ),
    );
  }

  _onPressTagButton(Haul haul, context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTagScreen(_appStore),
        settings: RouteSettings(
          arguments: haul,
        ),
      ),
    );
  }

  _floatingActionButton({onPressed}) {
    return Container(
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
        style: TextStyle(fontSize: 30),
      ),
    );
  }

  bool _isHaulOfActiveTrip(Haul haul) => haul.tripId == _appStore.activeTrip?.id;

  @override
  Widget build(BuildContext context) {
    final Haul haulArg = ModalRoute.of(context).settings.arguments;

    // is the haul arg in the current trip
    final bool isActiveTrip =
        _appStore.hasActiveTrip ? _appStore.activeTrip.id == haulArg.tripId : false;

    // either the active trip or a completed trip
    final Trip trip = isActiveTrip
        ? _appStore.activeTrip
        : _appStore.completedTrips.firstWhere((trip) => trip.id == haulArg.tripId);

    // look through all hauls including hauls in the active trip
    final haul = trip.hauls.firstWhere((h) => haulArg.id == h.id);

    final floatingActionButton = _isHaulOfActiveTrip(haul)
        ? _floatingActionButton(
            onPressed: () async => await _onPressTagButton(haul, context),
          )
        : null;

    final isActiveHaul = _appStore.activeHaul?.id == haul.id;

    final titleText = isActiveHaul ? 'Haul ${haul.id} (Active)' : 'Haul ${haul.id}';

    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: floatingActionButton,
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Container(
        child: Column(
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(15),
              child: _buildHaulDetails(haul),
            ),
            Container(
              padding: EdgeInsets.only(bottom: 10),
              child: Divider(),
            ),
            Container(
              child: _buildTagsLabel(haul.tags),
            ),
            _buildTagsList(haul.tags)
          ],
        ),
      ),
    );
  }
}
