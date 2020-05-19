import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/framework/util.dart' as util;
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/master_container_icon.dart';
import 'package:oltrace/widgets/strip_button.dart';

class MasterContainerInfo extends StatelessWidget {
  final MasterContainer masterContainer;
  final int indexNumber;
  final Function onPressDelete;

  const MasterContainerInfo({this.masterContainer, @required this.indexNumber, this.onPressDelete}) : assert(indexNumber != null);

  Widget _tagCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Master Container ID',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(masterContainer.tagCode ?? '-', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _dateCreated() {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Date Created', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(util.friendlyDateTime(masterContainer.createdAt), style: const TextStyle(fontSize: 16)),
          ],
        ),
        LocationButton(location: masterContainer.location),
      ],
    );
  }

  Widget _details() {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _tagCode(),
              _dateCreated(),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlracColours.olspsBlue[100],
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              MasterContainerIcon(indexNumber: indexNumber),
              _details(),
            ],
          ),
          StripButton(
            color: OlracColours.ninetiesRed,
            labelText: 'Delete',
            icon: Icon(Icons.delete),
            onPressed: onPressDelete,
          ),
        ],
      ),
    );
  }
}
