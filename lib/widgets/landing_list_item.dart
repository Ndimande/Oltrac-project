import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/landing_icon.dart';

class LandingListItem extends StatelessWidget {
  final Landing landing;
  final Function onPressed;
  final Function onLongPress;
  final bool isSelected;
  final int listIndex;

  LandingListItem({
    @required this.landing,
    @required this.onPressed,
    @required this.listIndex,
    this.onLongPress,
    this.isSelected = false,
  })  : assert(landing != null),
        assert(onPressed != null),
        assert(listIndex != null);

  Text get _speciesName => Text(
        landing.species.englishName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );

  Text get individuals => Text(' (${landing.individuals})');

  Widget get _title {
    final firstRow = <Widget>[
      Flexible(
        child: _speciesName,
      )
    ];

    if (landing.isBulk) {
      firstRow.add(individuals);
    }

    return Row(children: firstRow);
  }

  Widget get subtitle => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${landing.weightKilograms}, ${landing.lengthCentimeters}'),
          Text(friendlyDateTime(landing.createdAt)),
        ],
      );

  Widget get _icon => isSelected ? Icon(Icons.check_circle, color: olracBlue, size: 30) : ForwardArrow();

  BoxDecoration get _decoration => BoxDecoration(
        color: isSelected ? olracBlue[50] : Colors.transparent,
        border: listIndex == 1
            ? Border(bottom: BorderSide(color: Colors.grey[300]), top: BorderSide(color: Colors.grey[300]))
            : Border(top: BorderSide(color: Colors.grey[300])),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,
      child: ListTile(
        onLongPress: onLongPress,
        onTap: () => onPressed(listIndex),
        leading: LandingIcon(
          landing: landing,
          listIndex: listIndex,
        ),
        title: _title,
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[subtitle, _icon],
        ),
      ),
    );
  }
}
