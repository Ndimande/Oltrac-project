import 'package:flutter/material.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/widgets/time_ago.dart';

class LandingListItem extends StatelessWidget {
  final Landing _landing;
  final Function _onPressed;

  LandingListItem(this._landing, this._onPressed);

  Widget _speciesName() {
    String speciesName = !_landing.isBulkLanding
        ? _landing.species.englishName
        : _landing.species.englishName + ' (${_landing.individuals} individuals)';
    return Container(
      margin: EdgeInsets.only(right: 2),
      child: Text(speciesName),
    );
  }

  Widget _titleWidget() {
    final firstRow = <Widget>[_speciesName()];
    if (_landing.hasProducts) {
      firstRow.add(Icon(
        Icons.local_offer,
        size: 16,
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(children: firstRow),
        Text('${_landing.weightKilograms} | ${_landing.lengthCentimeters}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: FlatButton(
        onPressed: _onPressed,
        child: ListTile(
          title: _titleWidget(),
          subtitle: TimeAgo(prefix: 'Added ', dateTime: _landing.createdAt),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
      ),
    );
  }
}
