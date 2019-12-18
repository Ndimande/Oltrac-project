import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/confirm_dialog.dart';
import 'package:oltrace/widgets/tag_list_item.dart';

class HaulScreen extends StatelessWidget {
  final AppStore _appStore = StoreProvider().appStore;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final Haul _haul;
  HaulScreen(this._haul);

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
          _buildDetailRow('Started', friendlyDateTimestamp(haul.startedAt)),
          _buildDetailRow('Ended', friendlyDateTimestamp(haul.endedAt) ?? '-'),
          _buildDetailRow('Start Location', startLocation.toString()),
          _buildDetailRow('End Location', endLocation),
        ],
      ),
    );
  }

  Widget _buildTagsSection(List<Tag> tags) {
    if (tags.length == 0) {
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          child: Text('No carcass tags'),
        ),
      );
    }

    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            _buildTagsLabel(tags),
            _buildTagsList(tags),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsList(List<Tag> tags) {
    final List<TagListItem> listTags = tags
        .map(
          (Tag tag) => TagListItem(
            tag,
            () async =>
                await Navigator.pushNamed(_scaffoldKey.currentContext, '/tag', arguments: tag),
          ),
        )
        .toList();

    return Expanded(
      child: ListView(
        children: listTags,
      ),
    );
  }

  _onPressTagButton(Haul haul, context) async {
    await Navigator.pushNamed(context, '/create_tag', arguments: haul);
  }

  _floatingActionButton({onPressed}) {
    return Container(
      height: 65,
      width: 200,
      child: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        label: Text(
          'Add Catch',
          style: TextStyle(fontSize: 22),
        ),
        icon: Icon(Icons.local_offer),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTagsLabel(List<Tag> tags) {
    final text = tags.length > 0 ? 'Tags ' : 'No tags for this haul';
    return Container(
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(fontSize: 30),
      ),
    );
  }

  bool _isHaulOfActiveTrip(Haul haul) => haul.tripId == _appStore.activeTrip?.id;

  bool _isActiveHaul(Haul haul) => _appStore.activeHaul?.id == haul.id;

  _cancelHaulAction() {
    return FlatButton.icon(
      textColor: Colors.white,
      label: Text('Cancel'),
      icon: Icon(
        Icons.cancel,
      ),
      onPressed: () async {
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('Cancel Haul',
              'Are you sure you want to cancel the haul? The haul will be removed. This action cannot be undone.'),
        );

        if (confirmed != null && confirmed) {
          Navigator.pop(_scaffoldKey.currentContext);
          await Future.delayed(Duration(seconds: 1));
          await _appStore.cancelHaul();
        }
      },
    );
  }

  _endHaulAction() {
    return FlatButton.icon(
      textColor: Colors.white,
      label: Text('End'),
      icon: Icon(
        Icons.check_circle,
      ),
      onPressed: () async {
        bool confirmed = await showDialog<bool>(
          context: _scaffoldKey.currentContext,
          builder: (_) => ConfirmDialog('End Haul',
              'Are you sure you want to end the haul? You will not be able to continue later.'),
        );

        if (confirmed) {
          await _appStore.endHaul();
        }
      },
    );
  }

  _deleteHaulAction() {
    return IconButton(
      icon: Icon(
        Icons.delete,
      ),
      onPressed: () async {
        // TODO implement
      },
    );
  }

  List<Widget> _actions(Haul haul) {
    final List actions = <Widget>[];
    if (_isActiveHaul(haul)) {
      actions.add(_endHaulAction());
      actions.add(_cancelHaulAction());
    } else {
      actions.add(_deleteHaulAction());
    }
    return actions;
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      // is the haul arg in the current trip
      final bool isActiveTrip =
          _appStore.hasActiveTrip ? _appStore.activeTrip.id == _haul.tripId : false;

      // either the active trip or a completed trip
      final Trip trip = isActiveTrip
          ? _appStore.activeTrip
          : _appStore.completedTrips.firstWhere((trip) => trip.id == _haul.tripId);

      // look through all hauls including hauls in the active trip
      final haul = trip.hauls.firstWhere((h) => _haul.id == h.id);
print(haul.toString());
      final floatingActionButton = _isHaulOfActiveTrip(haul)
          ? _floatingActionButton(
              onPressed: () async => await _onPressTagButton(haul, context),
            )
          : null;

      final titleText = _isActiveHaul(haul) ? 'Haul ${haul.id} (Active)' : 'Haul ${haul.id}';

      return Scaffold(
        key: _scaffoldKey,
        floatingActionButton: floatingActionButton,
        appBar: AppBar(
          title: Text(titleText),
          actions: _actions(haul),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(15),
                child: _buildHaulDetails(haul),
              ),
              Container(
                padding: EdgeInsets.only(bottom: 10),
                child: Divider(),
              ),
              _buildTagsSection(haul.tags)
            ],
          ),
        ),
      );
    });
  }
}
