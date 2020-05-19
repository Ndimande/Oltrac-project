import 'package:flutter/material.dart';

const double _actionFontSize = 22;

Text _actionText(String text) => Text(text, style: TextStyle(fontSize: _actionFontSize, color: Colors.white));

class ConfirmDialog extends StatelessWidget {
  final String _title;

  final String _question;

  const ConfirmDialog(this._title, this._question);

  Widget _buildTitle() {
    return Text(_title);
  }

  List _buildActions(context) {
    return <Widget>[
      Container(
        margin: const EdgeInsets.only(right: 20),
        child: FlatButton(
          child: _actionText('Yes'),
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ),
      FlatButton(
        child: _actionText('No'),
        onPressed: () => Navigator.of(context).pop(false),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: _buildTitle(),
      actions: _buildActions(context),
      content: SingleChildScrollView(
        child: Text(_question),
      ),
    );
  }
}
