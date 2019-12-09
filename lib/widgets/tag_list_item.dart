import 'package:flutter/material.dart';
import 'package:oltrace/models/tag.dart';

class TagListItem extends StatelessWidget {
  final Tag _tag;
  final Function onPressed;

  TagListItem(this._tag, this.onPressed);

  @override
  Widget build(BuildContext context) {
    final String weight = (_tag.weight / 1000).toString() + ' kg';
    final String length = (_tag.length / 1000).toString() + ' cm';

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: FlatButton(
        onPressed: onPressed,
        child: ListTile(
          title: Text(_tag.species.englishName),
          subtitle: Text(weight + ' - ' + length),
          trailing: Icon(
            Icons.keyboard_arrow_right,
          ),
        ),
      ),
    );
  }
}
