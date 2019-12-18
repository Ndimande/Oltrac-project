import 'package:flutter/material.dart';

class RFID extends StatelessWidget {
  final tagCode;

  RFID({this.tagCode});

  @override
  Widget build(BuildContext context) {
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
            style: TextStyle(fontSize: 28),
          ),
          Text(
            'Hold tag infront of reader to scan.',
            style: TextStyle(color: Colors.grey[500]),
          )
        ],
      ),
    );
  }
}
