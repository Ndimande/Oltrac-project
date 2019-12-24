import 'package:flutter/material.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/time_ago.dart';

class LandingListItem extends StatelessWidget {
  final Landing _landing;
  final Function _onPressed;

  LandingListItem(this._landing, this._onPressed);

  String _speciesName() {
    String speciesName = !_landing.isBulkLanding
        ? _landing.species.englishName
        : _landing.species.englishName + ' (${_landing.individuals} individuals)';

    if (_landing.hasProducts) {
      speciesName += '*';
    }
    return speciesName;
  }

  @override
  Widget build(BuildContext context) {
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
                _speciesName(),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('${_landing.weightKilograms} | ${_landing.lengthCentimeters}'),
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
