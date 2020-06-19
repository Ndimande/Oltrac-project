import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/westlake/forward_arrow.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/landing_list_item_icon.dart';
import 'package:olrac_widgets/westlake/westlake_list_item.dart';

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

  Widget _leading() => LandingListItemIcon(
        landing: landing,
        listIndex: listIndex,
      );

  Widget _title() => Builder(builder: (context) {
        return Text(
          landing.species.englishName,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.headline6,
        );
      });

  Widget _subtitle() => Builder(builder: (context) {
        String lengthWeight = landing.weightKilograms;
        if (landing.length != null) {
          lengthWeight += ', ' + landing.lengthCentimeters;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(lengthWeight, style: Theme.of(context).textTheme.subtitle1),
            Text(friendlyDateTime(landing.createdAt), style: Theme.of(context).textTheme.caption),
          ],
        );
      });

  Widget _trailing() {
    if (!isSelectable) {
      return const ForwardArrow();
    }

    final icon = onLongPress == null || landing.doneTagging
        ? const ForwardArrow()
        : Icon(isSelected ? Icons.check_box : Icons.check_box_outline_blank);

    return IconButton(
      icon: icon,
      onPressed: landing.doneTagging ? null : onLongPress,
      iconSize: 30,
      color: OlracColours.fauxPasBlue,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WestlakeListItem(
      onLongPress: landing.doneTagging || !isSelectable ? null : onLongPress,
      onPressed: () => onPressed(listIndex),
      leading: _leading(),
      title: _title(),
      subtitle: _subtitle(),
      trailing: _trailing(),
    );
  }
}
