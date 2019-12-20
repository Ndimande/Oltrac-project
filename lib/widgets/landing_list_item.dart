import 'package:flutter/material.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/time_ago.dart';

class LandingListItem extends StatelessWidget {
  final Landing _landing;
  final Function _onPressed;

  LandingListItem(this._landing, this._onPressed);

  @override
  Widget build(BuildContext context) {
    final bool bulkCatch = _landing.individuals > 1;

    final String weight = (_landing.weight / 1000).toString() + ' kg' + (bulkCatch ? ' total' : '');
    final String length = (_landing.length).toString() + ' cm' + (bulkCatch ? ' average' : '');
    final String species =
        !bulkCatch ? _landing.species.englishName : _landing.species.englishName + ' (${_landing.individuals} individuals)';

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: FlatButton(
        onPressed: _onPressed,
        child: ListTile(
          isThreeLine: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                species,
                style: TextStyle(fontSize: 18),
              ),
              Text('$weight | $length'),
            ],
          ),
          subtitle: TimeAgo(prefix: 'Added ', dateTime: _landing.createdAt),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
      ),
    );
  }
}
