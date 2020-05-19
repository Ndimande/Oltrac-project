import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class LandingIcon extends StatelessWidget {
  final Landing landing;
  final int listIndex;

  const LandingIcon({this.landing, this.listIndex});

  Widget get sharkIcon => SvgIcon(assetPath: SvgIcons.path('Shark'));

  Widget get indexNumber => Container(
        margin: const EdgeInsets.only(left: 5, top: 5),
        child: Text(
          listIndex.toString(),
          style: const TextStyle(fontSize: 28, color: OlracColours.olspsBlue),
        ),
      );

  Color get _tagColor {
    if (landing.doneTagging == true) {
      return landing.isBulk ? OlracColours.ninetiesGreen : Colors.lightGreen;
    }

    if (landing.products.isEmpty) {
      return landing.isBulk ? OlracColours.ninetiesRed : Colors.red;
    }

    return landing.isBulk ? OlracColours.olspsDarkBlue : OlracColours.olspsBlue;
  }

  Widget get tagTotalIcon {
    final stackChildren = <Widget>[
      Container(
        child: Icon(
          Icons.local_offer,
          size: 42,
          color: _tagColor,
        ),
      ),
      if (landing.isBulk)
        Container(
          margin: const EdgeInsets.only(top: 28),
          child: Text(
            'BB',
            style: TextStyle(color: OlracColours.olspsDarkBlue,fontSize: 12),
          ),
        ),
      Container(
        margin: const EdgeInsets.only(left: 8, top: 11),
        child: Container(
          width: 26,
          child: Text(
            landing.products.length.toString(),
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      )
    ];

    return Container(
      margin: const EdgeInsets.only(left: 25),
      child: Stack(
        children: stackChildren,
      ),
    );
  }

  Widget get doneTaggingIcon {
    return Container(
      width: 20,
      height: 20,
      child: Icon(
        Icons.delete,
        size: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        tagTotalIcon,
        indexNumber,
      ],
    );
  }
}
