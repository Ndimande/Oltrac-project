import 'package:flutter/material.dart';

class RFID extends StatelessWidget {
  final tagCode;
  final Function onLongPress;

  RFID({this.tagCode, this.onLongPress});

  Widget _tagInfo() {
    final String tagCodeText = tagCode ?? '-';

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: Text(
              'Tag code',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Text(
            tagCodeText,
            style: TextStyle(fontSize: 40),
          ),
          Text(
            'Hold tag infront of reader to scan.',
            style: TextStyle(color: Colors.grey[500]),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      splashColor: null,
      onLongPress: onLongPress,
      onPressed: () {},
      child: _tagInfo(),
    );
  }
}
