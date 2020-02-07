import 'package:flutter/material.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/landing_icon.dart';
import 'package:oltrace/widgets/time_ago.dart';

class SharkInfoCard extends StatelessWidget {
  final Landing landing;

  SharkInfoCard({this.landing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          padding: EdgeInsets.all(5),
          child: LandingIcon(landing: landing),
        ),
        Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                landing.species.englishName,
                style: TextStyle(fontSize: 22),
              ),
              Text('${landing.weightKilograms}, ${landing.lengthCentimeters}'),
              TimeAgo(prefix: 'Added ', dateTime: landing.createdAt),
            ],
          ),
        )
      ],
    );
  }
}
