import 'package:flutter/material.dart';
import 'package:oltrace/data/olrac_icons.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/landing_icon.dart';
import 'package:oltrace/widgets/olrac_icon.dart';

class SharkInfoCard extends StatelessWidget {
  final Landing landing;
  final int listIndex;
  final bool showIndex;

  SharkInfoCard({this.landing, this.listIndex, this.showIndex = true});

  Widget get speciesText {
    String text = landing.species.englishName;
    if(landing.individuals > 1) {
      text += ' (${landing.individuals})';
    }
    return Text(
      text,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            showIndex == false
                ? Container(
                    padding: EdgeInsets.all(5),
                  )
                : Container(
                    padding: EdgeInsets.all(5),
                    child: LandingIcon(landing: landing, listIndex: listIndex),
                  ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  speciesText,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${landing.weightKilograms}, ${landing.lengthCentimeters}'),
//                      TimeAgo(prefix: 'Added ', dateTime: landing.createdAt),
                      Text(friendlyDateTime(landing.createdAt)),

                    ],
                  )
                ],
              ),
            ),
          ],
        ),
        Container(
          margin: EdgeInsets.only(right: 10),
          child: OlracIcon(height: 100, assetPath: OlracIcons.path(landing.species.scientificName)),
        ),
      ],
    );
  }
}
