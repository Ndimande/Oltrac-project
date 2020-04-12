import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/widgets/strip_button.dart';
import 'package:oltrace/widgets/svg_icon.dart';
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
          assetPath: SvgIcons.path(haul.fishingMethod.abbreviation),
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

  Widget _detailsSection() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TimeSpace(
            label: 'Started ',
            dateTime: haul.startedAt,
            location: haul.startLocation,
          ),
          !isActiveHaul ? TimeSpace(label: 'Ended ', dateTime: haul.endedAt, location: haul.endLocation) : Container(),
          if (haul.fishingMethod.type == FishingMethodType.Static) _soakTime()
        ],
      ),
    );
  }

  Widget _soakTime() {
    final int hours = haul.soakTime.inHours;
    final int minutes = haul.soakTime.inMinutes % 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Soak Time', style: TextStyle(fontSize: 14)),
        Text('$hours hours $minutes minutes', style: TextStyle(fontSize: 17)),
      ],
    );
  }

  Widget _buildHaulDetails() {
    return Container(
      color: olracBlue[50],
      padding: EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          numberedIcon(),
          SizedBox(width: 10),
          Expanded(child: _detailsSection()),
        ],
      ),
    );
  }

  Widget actionButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            onPressed: onPressEndHaul,
            labelText: Messages.endHaulTitle(haul),
            color: Colors.red,
            icon: Icon(
              Icons.stop,
              color: Colors.white,
            ),
          ),
        ),
        Expanded(
          child: StripButton(
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
    return Column(
      children: <Widget>[
        _buildHaulDetails(),
        if (isActiveHaul) actionButtons(),
      ],
    );
  }
}
