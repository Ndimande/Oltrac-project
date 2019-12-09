import 'package:flutter/material.dart';

final double _fontSize = 20;

class SettingsScreen extends StatefulWidget {
  SettingsScreen();

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _allowMobileData = false;
  bool _uploadAutomatically = false;

  Widget _buildAllowMobile() {
    final title = 'Use Mobile Data';
    final subtitle = 'Allow uploading data with a cellular connection';

    return SwitchListTile(
      subtitle: Text(subtitle),
      title: Text(
        title,
        style: TextStyle(fontSize: _fontSize),
      ),
      value: _allowMobileData,
      onChanged: (state) {
        setState(() {
          _allowMobileData = state;
        });
      },
    );
  }

  Widget _buildAutoUpload() {
    final title = 'Upload Automatically';
    final subtitle = 'Upload data as soon as the internet becomes available';

    return SwitchListTile(
      subtitle: Text(subtitle),
      title: Text(
        title,
        style: TextStyle(fontSize: _fontSize),
      ),
      value: _uploadAutomatically,
      onChanged: (state) {
        setState(() {
          _uploadAutomatically = !_uploadAutomatically;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
