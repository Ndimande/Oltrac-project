import 'package:flutter/material.dart';
import 'package:oltrace/data/olrac_icons.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/landing_icon.dart';
import 'package:oltrace/widgets/olrac_icon.dart';
import 'package:oltrace/widgets/time_ago.dart';

class SharkInfoCard extends StatelessWidget {
  final Landing landing;
  final int listIndex;

  SharkInfoCard({this.landing, this.listIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(5),
              child: LandingIcon(landing: landing, listIndex: listIndex),
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    landing.species.englishName,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${landing.weightKilograms}, ${landing.lengthCentimeters}'),
                      TimeAgo(prefix: 'Added ', dateTime: landing.createdAt),
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
