import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/models/landing.dart';

class LandingListItemIcon extends StatelessWidget {
  final Landing landing;
  final int listIndex;

  const LandingListItemIcon({this.landing, this.listIndex});

  Widget get _indexNumber {
    return Builder(builder: (context) {
      return Container(
        margin: const EdgeInsets.only(left: 5, top: 5),
        child: Text(
          listIndex.toString(),
          style: Theme.of(context).primaryTextTheme.headline4,
        ),
      );
    });
  }

  Color get _tagColor {
    // Done Tagging
    const singleDoneTaggingColour = Colors.lightGreen;
    const bulkDoneTaggingColour = OlracColours.ninetiesGreen;

    // No Tags
    const singleNoTagsColour = Colors.red;
    const bulkNoTagsColour = OlracColours.ninetiesRed;

    // Has Tags but incomplete
    const singleHasTagsColour = OlracColours.fauxPasBlue;
    const bulkHasTagsColour = OlracColours.olspsDarkBlue;

    if (landing.doneTagging == true) {
      return landing.isBulk ? bulkDoneTaggingColour : singleDoneTaggingColour;
    }

    if (landing.products.isEmpty) {
      return landing.isBulk ? bulkNoTagsColour : singleNoTagsColour;
    }

    return landing.isBulk ? bulkHasTagsColour : singleHasTagsColour;
  }

  Widget get _tagTotalIcon {
    final Container tagIcon = Container(
      child: Icon(
        Icons.local_offer,
        size: 46,
        color: _tagColor,
      ),
    );

    final Container bulkBinBText = Container(
      margin: const EdgeInsets.only(top: 25),
      child: const Text(
        'B',
        style: TextStyle(color: OlracColours.olspsDarkBlue, fontSize: 20,fontWeight: FontWeight.bold),
      ),
    );

    final Container totalNumber = Container(
      margin: const EdgeInsets.only(left: 8, top: 10),
      child: Container(
        width: 26,
        child: Text(
          landing.products.length.toString(),
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );

    final stackChildren = <Widget>[
      tagIcon,
      if (landing.isBulk) bulkBinBText,
      totalNumber,
    ];

    return Container(
      margin: const EdgeInsets.only(left: 25),
      child: Stack(
        children: stackChildren,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        _tagTotalIcon,
        _indexNumber,
      ],
    );
  }
}
