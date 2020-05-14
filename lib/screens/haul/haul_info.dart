import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
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
          color: OlracColours.olspsDarkBlue,
        ),
      );
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: Text(
            listIndex.toString(),
            style: TextStyle(fontSize: 32, color: OlracColours.olspsDarkBlue, fontWeight: FontWeight.bold),
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 5),
        svg,
      ],
    );
  }


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
          const SizedBox(height: 10),
          if (!isActiveHaul) TimeSpace(label: 'Ended ', dateTime: haul.endedAt, location: haul.endLocation),
          if (haul.fishingMethod.type == FishingMethodType.Static) _soakTime(),
          if (haul.fishingMethod.type == FishingMethodType.Static) _hooksOrTraps(),
        ],
      ),
    );
  }

  Widget _hooksOrTraps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Traps/Hooks',style: TextStyle(fontSize: 13),),
        Text(haul.hooksOrTraps.toString(),style: TextStyle(fontSize: 14),),
      ],
    );
  }

  Widget _soakTime() {
    final int hours = haul.soakTime.inHours;
    final int minutes = haul.soakTime.inMinutes % 60;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Soak Time', style: TextStyle(fontSize: 13)),
        Text('$hours hours $minutes minutes', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildHaulDetails() {
    return Container(
      color: OlracColours.olspsBlue[50],
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
            color: OlracColours.ninetiesRed,
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
            color: OlracColours.olspsBlue,
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
