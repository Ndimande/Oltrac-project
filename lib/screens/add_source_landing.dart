import 'package:flutter/material.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/screens/haul.dart';
import 'package:oltrace/widgets/landing_list_item.dart';

class AddSourceLandingsScreen extends StatelessWidget {
  final List<Landing> alreadySelectedLandings;
  final SpeciesSelectMode selectionMode;
  final Haul sourceHaul;

  AddSourceLandingsScreen({this.alreadySelectedLandings, this.selectionMode, this.sourceHaul});

  Widget _buildLandingsList(List<Landing> landings) {
    final landingsNotAlreadySelected = landings
        .where((Landing t) => !alreadySelectedLandings.map((sel) => sel.id).toList().contains(t.id))
        .toList()
        .reversed;

    return Builder(
      builder: (context) {
        int listIndex = 1;
        return landingsNotAlreadySelected.length == 0
            ? _noUnselectedLandings()
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

  Widget _noUnselectedLandings() {
    return Center(
      child: Text('No unselected species in this haul', style: TextStyle(fontSize: 20)),
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
