import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/data/olrac_icons.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/olrac_icon.dart';

enum TagState {
  untagged,
}

class LandingIcon extends StatelessWidget {
  final Landing landing;

  LandingIcon({this.landing});

  Widget get sharkIcon => OlracIcon(assetPath: OlracIcons.path('Shark'));

  Widget get sharkId => Container(
        margin: EdgeInsets.only(left: 5, top: 5),
        child: Text(
          landing.id.toString(),
          style: TextStyle(fontSize: 28, color: olracBlue),
        ),
      );

  Widget get tagTotalIcon {
    IconData icon = landing.doneTagging == true ? Icons.done : Icons.local_offer;
    Color tagColor = landing.products.length == 0 ? Colors.red : olracBlue;

    final stackChildren = <Widget>[
      Container(
        child: Icon(
          icon,
          size: 42,
          color: tagColor,
        ),
      ),
    ];

    if (landing.doneTagging == null || !landing.doneTagging == true) {
      stackChildren.add(Container(
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
      ));
    }
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
        sharkId,
      ],
    );
  }
}
