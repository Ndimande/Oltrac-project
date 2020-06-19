import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/messages.dart';
import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/screens/edit_haul.dart';
import 'package:oltrace/widgets/svg_icon.dart';
import 'package:oltrace/widgets/time_space.dart';

class HaulInfo extends StatelessWidget {
  final Haul haul;
  final Function onPressEndHaul;
  final Function onPressCancelHaul;
  final int listIndex;
  final bool isActiveHaul;
  final bool isTripUploaded;

  const HaulInfo({
    @required this.haul,
    @required this.onPressEndHaul,
    @required this.onPressCancelHaul,
    @required this.listIndex,
    @required this.isActiveHaul,
    @required this.isTripUploaded,
  })  : assert(haul != null),
        assert(onPressEndHaul != null),
        assert(onPressCancelHaul != null),
        assert(listIndex != null),
        assert(isTripUploaded != null),
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

    return Builder(builder: (BuildContext context) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            child: Text(
              listIndex.toString(),
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(color: OlracColours.olspsDarkBlue, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
          const SizedBox(width: 5),
          svg,
        ],
      );
    });
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
          const SizedBox(height: 5),
          if (!isActiveHaul) TimeSpace(label: 'Ended ', dateTime: haul.endedAt, location: haul.endLocation),
        ],
      ),
    );
  }

  Widget _hooksOrTraps() {
    return Builder(
      builder: (BuildContext context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text('Traps/Hooks', style: Theme.of(context).textTheme.caption),
            Text(
              haul.hooksOrTraps.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        );
      },
    );
  }

  Widget _soakTime() {
    return Builder(
      builder: (BuildContext context) {
        final int hours = haul.soakTime.inHours;
        final int minutes = haul.soakTime.inMinutes % 60;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Soak Time', style: Theme.of(context).textTheme.caption),
            Text('$hours hours $minutes minutes', style: Theme.of(context).textTheme.headline6),
          ],
        );
      },
    );
  }

  List<Widget> _staticGearDetails() {
    return [
      const Divider(),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          if (haul.fishingMethod.type == FishingMethodType.Static) _soakTime(),
          const SizedBox(width: 15),
          if (haul.fishingMethod.type == FishingMethodType.Static) _hooksOrTraps(),
        ],
      ),
    ];
  }

  Widget _editButton() {
    return Builder(builder: (BuildContext context) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        child: IconButton(
          iconSize: 32,
          icon: const Icon(Icons.edit, color: OlracColours.fauxPasBlue),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => EditHaul(haul: haul)));
          },
        ),
      );
    });
  }

  Widget _buildHaulDetails() {
    return Builder(builder: (BuildContext context) {
      return Container(
        color: OlracColours.fauxPasBlue[50],
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                numberedIcon(),
                const SizedBox(width: 10),
                Expanded(child: _detailsSection()),
                if (!isTripUploaded) _editButton(),
              ],
            ),
            if (haul.fishingMethod.type == FishingMethodType.Static) ..._staticGearDetails(),

          ],
        ),
      );
    });
  }

  Widget actionButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: StripButton(
            onPressed: onPressEndHaul,
            labelText: Messages.endHaulTitle(haul),
            color: OlracColours.ninetiesRed,
            icon: const Icon(Icons.stop, color: Colors.white),
          ),
        ),
        Expanded(
          child: StripButton(
            onPressed: onPressCancelHaul,
            labelText: 'Cancel',
            color: OlracColours.fauxPasBlue,
            icon: const Icon(Icons.cancel, color: Colors.white),
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
