import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/widgets/landing_list_item.dart';

class AddSourceLandingsScreen extends StatelessWidget {
  final _appStore = StoreProvider().appStore;
  final List<Landing> _alreadySelected;

  AddSourceLandingsScreen(List<Landing> landingsArgs) : _alreadySelected = landingsArgs;

  Widget _buildLandingsList(List<Landing> landings) {
    final landingsNotAlreadySelected = landings
      .where((Landing t) => !_alreadySelected.map((sel) => sel.id).toList().contains(t.id))
      .toList();

    return Builder(
      builder: (context) {
        int listIndex = 1;
        return landingsNotAlreadySelected.length == 0
          ? Container(
          child: Text('No unselected sharks in this haul'),
        )
          : Column(
          children: landingsNotAlreadySelected.map((Landing l) {
            return LandingListItem(listIndex: landingsNotAlreadySelected.length - listIndex++ +1, landing: l, onPressed: (int index) {
              Navigator.pop(context, l);
            });
          }).toList());
      },
    );
  }

  Widget _buildHaul(Haul haul, int listIndex) {
    final startedDateTime = friendlyDateTime(haul.startedAt);
    final endedDateTime = haul.endedAt != null ? friendlyDateTime(haul.endedAt) : 'now';

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Haul ${listIndex++} (${haul.fishingMethod.name})',
                style: TextStyle(fontSize: 20,color: olracBlue),
              ),
              Text('$startedDateTime - $endedDateTime')
            ],
          ),
        ),
        _buildLandingsList(haul.landings)
      ],
    );
  }

  Widget _buildHaulsList() {
    List<Haul> hauls = _appStore.activeTrip.hauls.reversed.toList();

    return ListView.builder(
      itemCount: hauls.length,
      itemBuilder: (context, index) => _buildHaul(hauls[index],hauls.length - index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Source Shark'),
      ),
      body: _buildHaulsList(),
    );
  }
}
