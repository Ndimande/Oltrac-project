import 'package:flutter/material.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/landing_icon.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class SharkInfoCard extends StatelessWidget {
  final Landing landing;
  final int listIndex;
  final bool showIndex;

  const SharkInfoCard({this.landing, this.listIndex, this.showIndex = true});

  Widget _locationRow() {
    return Row(
      children: <Widget>[
        LocationButton(location: landing.location),
        Text(
          landing.location.toString(),
          style: const TextStyle(fontSize: 15),
        ),
      ],
    );
  }

  Widget _sharkIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: SvgIcon(height: 100, assetPath: SvgIcons.path(landing.species.scientificName)),
    );
  }

  Widget _sharkInfo() {
    String lengthWeight = landing.weightKilograms;
    if (landing.length != null) {
      lengthWeight += ', ' + landing.lengthCentimeters;
    }

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(lengthWeight, style: const TextStyle(fontSize: 15)),
          Text(friendlyDateTime(landing.createdAt), style: const TextStyle(fontSize: 15)),
          if (landing.isBulk && landing.individuals != null)
            Text('${landing.individuals} individuals', style: const TextStyle(fontSize: 15))
        ],
      ),
    );
  }

  Widget _indexIcon() {
    return showIndex == false
        ? Container(padding: const EdgeInsets.all(5))
        : Container(
            padding: const EdgeInsets.all(5),
            child: LandingIcon(landing: landing, listIndex: listIndex),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Row(
                children: <Widget>[
                  _indexIcon(),
                  _sharkInfo(),
                ],
              ),
            ),
            if (showIndex) _locationRow(),
          ],
        ),
        _sharkIcon(),
      ],
    );
  }
}
