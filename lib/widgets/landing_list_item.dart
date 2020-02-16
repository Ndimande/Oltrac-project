import 'package:flutter/material.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/landing_icon.dart';
import 'package:oltrace/widgets/time_ago.dart';

class LandingListItem extends StatelessWidget {
  final Landing landing;
  final Function onPressed;
  final int listIndex;

  LandingListItem({this.landing, this.onPressed, this.listIndex});

  Text get speciesName => Text(
        landing.species.englishName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
      );

  Text get individuals => Text(' (${landing.individuals})');

  Widget get cardTitle {
    final firstRow = <Widget>[
      Flexible(
        child: speciesName,
      )
    ];

    if (landing.isBulk) {
      firstRow.add(individuals);
    }

    return Row(children: firstRow);
  }

  Widget get subtitle => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${landing.weightKilograms}, ${landing.lengthCentimeters}'),
//          TimeAgo(prefix: 'Added ', dateTime: landing.createdAt),
          Text(friendlyDateTime(landing.createdAt)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        border: listIndex == 1 ? Border(bottom: BorderSide(color: Colors.grey[300]),top: BorderSide(color: Colors.grey[300])) :Border(top: BorderSide(color: Colors.grey[300]))
      ),
      padding: EdgeInsets.all(0),
      child: ListTile(
        onTap: () => onPressed(listIndex),
        leading: LandingIcon(landing: landing,listIndex: listIndex,),
        title: cardTitle,
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            subtitle,
            ForwardArrow(),
          ],
        ),
      ),
    );
  }
}
