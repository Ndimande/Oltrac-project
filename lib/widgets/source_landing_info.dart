import 'package:flutter/material.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class SourceLandingInfo extends StatelessWidget {
  final Landing landing;

  const SourceLandingInfo({this.landing});

  Text get _lengthWeightText {
    String lengthWeight = landing.weightKilograms;
    if (landing.length != null) {
      lengthWeight += ', ' + landing.lengthCentimeters;
    }
    return Text(lengthWeight, style: const TextStyle(fontSize: 15));
  }

  Text get _createdAt => Text(friendlyDateTime(landing.createdAt), style: const TextStyle(fontSize: 15));

  Text get _speciesNameText => Text(landing.species.englishName, style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),);

  Widget _sharkIcon() {
    return Container(
      margin: const EdgeInsets.only(right: 5),
      child: SvgIcon(height: 100, assetPath: SvgIcons.path(landing.species.scientificName)),
    );
  }

  Widget _info() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _speciesNameText,
          _lengthWeightText,
          _createdAt,
          if (landing.isBulk && landing.individuals != null)
            Text('${landing.individuals} individuals', style: const TextStyle(fontSize: 15))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _info(),
          _sharkIcon(),
        ],
      ),
    );
  }
}
