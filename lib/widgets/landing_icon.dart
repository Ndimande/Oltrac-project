import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/data/svg_icons.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/svg_icon.dart';

class LandingIcon extends StatelessWidget {
  final Landing landing;
  final int listIndex;

  LandingIcon({this.landing, this.listIndex});

  Widget get sharkIcon => SvgIcon(assetPath: SvgIcons.path('Shark'));

  Widget get indexNumber => Container(
        margin: EdgeInsets.only(left: 5, top: 5),
        child: Text(
          listIndex.toString(),
          style: TextStyle(fontSize: 28, color: OlracColours.olspsBlue),
        ),
      );

  Color get _tagColor {
    if (landing.doneTagging == true) {
      return landing.isBulk ? Colors.green : Colors.lightGreen;
    }

    if (landing.products.isEmpty) {
      return landing.isBulk ? Colors.red : Colors.redAccent;
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
      Container(
        margin: EdgeInsets.only(left: 8, top: 11),
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
      margin: EdgeInsets.only(left: 25),
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
