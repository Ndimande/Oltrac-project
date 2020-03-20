import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/widgets/svg_icon.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/time_space.dart';

class HaulInfo extends StatelessWidget {
  final Haul haul;
  final Function onPressEndHaul;
  final Function onPressCancelHaul;
  final int listIndex;
  final bool isActiveHaul;

  HaulInfo({
    @required this.haul,
    @required this.onPressEndHaul,
    @required this.onPressCancelHaul,
    @required this.listIndex,
    @required this.isActiveHaul,
  })  : assert(haul != null),
        assert(onPressEndHaul != null),
        assert(onPressCancelHaul != null),
        assert(listIndex != null),
        assert(isActiveHaul != null);

  Widget numberedIcon() {
    final Widget svg = Builder(builder: (context) {
      return Container(
        width: 64,
        height: 64,
        child: SvgIcon(
          assetPath: SvgIcons.path(haul.fishingMethod.name),
          darker: true,
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: Text(
            listIndex.toString(),
            style: TextStyle(fontSize: 32, color: olracDarkBlue, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        SizedBox(width: 5),
        svg,
      ],
    );
  }

  Text get fishingMethodText => Text(
        haul.fishingMethod.name,
        style: TextStyle(fontSize: 24),
        softWrap: true,
      );

  Text dateTimeText({String label = 'Started '}) => Text(
        label + friendlyDateTime(haul.startedAt),
        style: TextStyle(fontSize: 16),
      );

  Widget get detailsSection {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TimeSpace(
            label: 'Started ',
            dateTime: haul.startedAt,
            location: haul.startLocation,
          ),
          !isActiveHaul
              ? TimeSpace(
                  label: 'Ended ',
                  dateTime: haul.endedAt,
                  location: haul.endLocation,
                )
              : Container(),
        ],
      ),
    );
  }

  Widget _buildHaulDetails(Haul haul) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          numberedIcon(),
          SizedBox(width: 10),
          Expanded(child: detailsSection),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            centered: true,
            onPressed: onPressEndHaul,
            labelText: 'End Haul',
            color: Colors.red,
            icon: Icon(
              Icons.stop,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StripButton(
            centered: true,
            onPressed: onPressCancelHaul,
            labelText: 'Cancel',
            color: olracBlue,
            icon: Icon(
              Icons.cancel,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List rows = <Widget>[
      Container(
        color: olracBlue[50],
        child: _buildHaulDetails(haul),
      )
    ];

    if (isActiveHaul) {
      rows.add(actionButtons());
    }

    return Column(
      children: rows,
    );
  }
}
