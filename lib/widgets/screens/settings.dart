import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  Widget _buildAllowMobile() {
    return Container(
      padding: EdgeInsets.all(5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text('Allow mobile data'),
          Switch(
            value: true,
            onChanged: (state) {
              return !state;
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Container(
          child: Column(
            children: <Widget>[_buildAllowMobile()],
          ),
        ));
  }
}
