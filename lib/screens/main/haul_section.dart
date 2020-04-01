import 'package:flutter/material.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/widgets/grouped_hauls_list.dart';

class HaulSection extends StatelessWidget {
  final List<Haul> hauls;
  final Function(int, int) onPressHaulItem;

  HaulSection({this.hauls, this.onPressHaulItem}) : assert(hauls != null);

  Widget _buildNoHauls() {
    return Container(
      alignment: Alignment.center,
      child: Text('No hauls on this trip', style: TextStyle(fontSize: 20)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reversedHauls = hauls.reversed.toList();

    return Column(
      children: <Widget>[
        Expanded(
          child: Container(
            child: reversedHauls.length == 0
                ? _buildNoHauls()
                : GroupedHaulsList(hauls: reversedHauls, onPressHaulItem: onPressHaulItem),
          ),
        )
      ],
    );
  }
}
