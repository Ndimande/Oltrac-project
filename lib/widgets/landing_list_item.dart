import 'package:flutter/material.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/forward_arrow.dart';
import 'package:oltrace/widgets/landing_icon.dart';
import 'package:oltrace/widgets/time_ago.dart';

class LandingListItem extends StatelessWidget {
  final Landing _landing;
  final Function _onPressed;

  LandingListItem(this._landing, this._onPressed);

  Text get speciesName => Text(
        _landing.species.englishName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 22),
      );

  Text get individuals => Text(' (${_landing.individuals})');

  Widget get cardTitle {
    final firstRow = <Widget>[
      Flexible(
        child: speciesName,
      )
    ];

    if (_landing.isBulk) {
      firstRow.add(individuals);
    }

    return Row(children: firstRow);
  }

  Widget get subtitle => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('${_landing.weightKilograms}, ${_landing.lengthCentimeters}'),
          TimeAgo(prefix: 'Added ', dateTime: _landing.createdAt),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0),
      onPressed: _onPressed,
      child: ListTile(
        leading: LandingIcon(landing: _landing),
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
