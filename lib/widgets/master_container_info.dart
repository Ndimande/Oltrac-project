import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:olrac_widgets/olrac_widgets.dart';
import 'package:oltrace/framework/util.dart' as util;
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/widgets/location_button.dart';
import 'package:oltrace/widgets/master_container_icon.dart';

class MasterContainerInfo extends StatelessWidget {
  final MasterContainer masterContainer;
  final int indexNumber;
  final Function onPressDelete;
  final bool showDeleteButton;

  const MasterContainerInfo({
    this.masterContainer,
    @required this.indexNumber,
    this.onPressDelete,
    this.showDeleteButton = true,
  }) : assert(indexNumber != null);

  Widget _tagCode() {
    return Builder(builder: (BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Master Container ID',
            style: Theme.of(context).textTheme.caption,
          ),
          Text(
            masterContainer.tagCode ?? '-',
            style: Theme.of(context).textTheme.subtitle1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      );
    });
  }

  Widget _dateCreated() {
    return Builder(builder: (BuildContext context) {
      return Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Date Created', style: Theme.of(context).textTheme.caption),
              Text(util.friendlyDateTime(masterContainer.createdAt), style: Theme.of(context).textTheme.headline6),
            ],
          ),
          LocationButton(location: masterContainer.location),
        ],
      );
    });
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
              const SizedBox(height: 5),
              _dateCreated(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _deleteButton() {
    return StripButton(
      color: OlracColours.ninetiesRed,
      labelText: 'Delete',
      icon: const Icon(Icons.delete),
      onPressed: onPressDelete,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: OlracColours.fauxPasBlue[100],
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              MasterContainerIcon(indexNumber: indexNumber),
              _details(),
            ],
          ),
          if (showDeleteButton) _deleteButton(),
        ],
      ),
    );
  }
}
