import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
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
  final bool isSelectable;

  const LandingListItem({
    @required this.landing,
    @required this.onPressed,
    @required this.listIndex,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectable = true,
  })  : assert(landing != null),
        assert(onPressed != null),
        assert(listIndex != null);

  Text get _speciesName => Text(
        landing.species.englishName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      );

  Text get individuals => Text(' (${landing.individuals})');


  Widget get _subtitle {
    String lengthWeight = landing.weightKilograms;
    if(landing.length != null) {
      lengthWeight += ', ' + landing.lengthCentimeters;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(lengthWeight),
        Text(friendlyDateTime(landing.createdAt)),
      ],
    );
  }

  Widget get _trailingIcon {
    if (!isSelectable) {
      return ForwardArrow();
    }

    final icon = onLongPress == null || landing.doneTagging
        ? ForwardArrow()
        : Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank);

    return IconButton(
      icon: icon,
      onPressed: landing.doneTagging ? null : onLongPress,
      iconSize: 30,
      color: OlracColours.olspsBlue,
    );
  }

  BoxDecoration get _decoration => BoxDecoration(
        color: isSelected ? OlracColours.olspsBlue[50] : Colors.transparent,
        border: listIndex == 1
            ? Border(bottom: BorderSide(color: Colors.grey[300]), top: BorderSide(color: Colors.grey[300]))
            : Border(top: BorderSide(color: Colors.grey[300])),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _decoration,
      child: ListTile(
        onLongPress: landing.doneTagging || !isSelectable ? null : onLongPress,
        onTap: () => onPressed(listIndex),
        leading: LandingIcon(
          landing: landing,
          listIndex: listIndex,
        ),
        title: _speciesName,
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[_subtitle, _trailingIcon],
        ),
      ),
    );
  }
}
