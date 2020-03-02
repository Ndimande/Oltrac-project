import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/widgets/landing_list_item.dart';
import 'package:oltrace/widgets/screens/haul.dart';

class AddSourceLandingsScreen extends StatelessWidget {
  final _appStore = StoreProvider().appStore;
  final List<Landing> alreadySelectedLandings;
  final SpeciesDialogSelection selectionMode;
  final Haul sourceHaul;

  AddSourceLandingsScreen({this.alreadySelectedLandings, this.selectionMode, this.sourceHaul});

  Widget _buildLandingsList(List<Landing> landings) {
    final landingsNotAlreadySelected = landings
        .where((Landing t) => !alreadySelectedLandings.map((sel) => sel.id).toList().contains(t.id))
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
                return LandingListItem(
                  listIndex: landingsNotAlreadySelected.length - listIndex++ + 1,
                  landing: l,
                  onPressed: (int index) {
                    Navigator.pop(context, [l]);
                  },
                );
              }).toList());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Source Species'),
      ),
      body: _buildLandingsList(sourceHaul.landings),
    );
  }
}
