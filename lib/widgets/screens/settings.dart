import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';

class SettingsScreen extends StatelessWidget {
  Widget _buildAllowMobile() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Use mobile data',
            style: TextStyle(fontSize: 16),
          ),
          Switch(
            value: true,
            onChanged: (state) {},
          )
        ],
      ),
    );
  }

  Widget _buildAutoUpload() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            'Upload automatically',
            style: TextStyle(fontSize: 16),
          ),
          Switch(
            value: true,
            onChanged: (state) {},
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppConfig.backgroundColor,
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Container(
          margin: EdgeInsets.only(left: 10),
          child: Column(
            children: <Widget>[_buildAllowMobile(), _buildAutoUpload()],
          ),
        ));
  }
}
