import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';

class HaulListItem extends StatelessWidget {
  final Haul _haul;
  final Function onPressed;

  HaulListItem(this._haul, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final String startedAt = friendlyTimestamp(_haul.startedAt);
    final String endedAt = friendlyTimestamp(_haul.endedAt);
    final timePeriod = Text('$startedAt - $endedAt');

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Haul ${_haul.id}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text('${_haul.fishingMethod.name}')
      ],
    );
    return Card(
      color: Colors.blueGrey,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: FlatButton(
          onPressed: onPressed,
          child: ListTile(
            title: title,
            subtitle: timePeriod,
            trailing: Icon(
              Icons.keyboard_arrow_right,
            ),
          )),
    );
  }
}
