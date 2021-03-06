import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/widgets/haul_list_item.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class GroupedHaulsList extends StatelessWidget {
  final List<Haul> hauls;
  final Function onPressHaul;
  final Function(int, int) onPressHaulItem;

  GroupedHaulsList({this.hauls, this.onPressHaul, this.onPressHaulItem})
      : assert(hauls != null),
        assert(onPressHaulItem != null);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> groupedByFishingMethod = groupBy(hauls, (Haul haul) => haul.fishingMethod)
        .entries
        .map((entry) => {'fishingMethod': entry.key, 'hauls': entry.value})
        .toList();

    return ListView.builder(
        addSemanticIndexes: true,
        itemCount: groupedByFishingMethod.length,
        itemBuilder: (BuildContext context, int index) {
          final Map fishingMethodGroup = groupedByFishingMethod[index];
          final int totalHauls = fishingMethodGroup['hauls'].length;

          // Relative index in list
          int haulIndex = totalHauls;

          final Widget svg = Container(
            width: 36,
            height: 36,
            child: SvgIcon(
              assetPath: SvgIcons.path(fishingMethodGroup['fishingMethod'].name),
              darker: true,
            ),
          );

          return ExpansionTile(
            backgroundColor: olracBlue[50],
            initiallyExpanded: true,
            title: Row(
              children: <Widget>[
                svg,
                SizedBox(
                  width: 10,
                ),
                Container(
                  width: 220,
                  child: Text(
                    fishingMethodGroup['fishingMethod'].name + ' hauls',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 22, color: olracDarkBlue),
                  ),
                )
              ],
            ),
            children: fishingMethodGroup['hauls']
                .map<Widget>((Haul haul) => HaulListItem(
                      haul: haul,
                      onPressed: (int pressedIndex) async => await onPressHaulItem(haul.id, pressedIndex),
                      listIndex: haulIndex--,
                    ))
                .toList(),
          );
        });
  }
}
