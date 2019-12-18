import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/widgets/tag_list_item.dart';

class AddSourceTagScreen extends StatelessWidget {
  final _appStore = StoreProvider().appStore;
  final List<Tag> _alreadySelected;

  AddSourceTagScreen(List<Tag> tagsArg) : _alreadySelected = tagsArg;

  Widget _buildTagsList(List<Tag> tags) {
    final tagsNotAlreadySelected = tags
        .where((Tag t) => !_alreadySelected.map((sel) => sel.id).toList().contains(t.id))
        .toList();

    return Builder(
      builder: (context) {
        return tagsNotAlreadySelected.length == 0
            ? Container(
                child: Text('No unselected tags in this haul'),
              )
            : Column(
                children: tagsNotAlreadySelected.map((Tag t) {
                return TagListItem(t, () {
                  Navigator.pop(context, t);
                });
              }).toList());
      },
    );
  }

  Widget _buildHaul(Haul haul) {
    final startedDateTime = friendlyDateTimestamp(haul.startedAt);
    final endedDateTime = haul.endedAt != null ? friendlyDateTimestamp(haul.endedAt) : 'now';

    return Column(
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(15),
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Haul ${haul.id} (${haul.fishingMethod.name})',
                style: TextStyle(fontSize: 26),
              ),
              Text('$startedDateTime - $endedDateTime')
            ],
          ),
        ),
        _buildTagsList(haul.tags)
      ],
    );
  }

  Widget _buildHaulsList() {
    List<Haul> hauls = _appStore.activeTrip.hauls.reversed.toList();

    return ListView.builder(
      itemCount: hauls.length,
      itemBuilder: (context, index) => _buildHaul(hauls[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Source Tag'),
      ),
      body: _buildHaulsList(),
    );
  }
}
