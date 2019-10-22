import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String _title;
  final String _question;
  ConfirmDialog(this._title, this._question);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(this._title),
        actions: <Widget>[
          FlatButton(
              child: Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true)),
          FlatButton(
              child: Text('No'),
              onPressed: () => Navigator.of(context).pop(false)),
        ],
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[Text(this._question)],
          ),
        ));
  }
}
