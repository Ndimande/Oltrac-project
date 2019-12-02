import 'package:flutter/material.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/tag.dart';

class TagListItem extends StatelessWidget {
  final Tag _tag;
  final Function onPressed;

  TagListItem(this._tag, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blueGrey,
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: FlatButton(
          onPressed: onPressed,
          child: ListTile(
            title: Text(_tag.tagCode),
            subtitle: Text(_tag.species.englishName),
            trailing: Icon(
              Icons.keyboard_arrow_right,
            ),
          )),
    );
  }
}
