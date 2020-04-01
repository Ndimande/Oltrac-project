import 'package:flutter/material.dart';
import 'package:oltrace/framework/user_settings.dart';

final double _fontSize = 20;

class SettingsScreen extends StatefulWidget {
  final UserSettings userSettings;
  final Function updateSettings;

  SettingsScreen(this.userSettings, this.updateSettings);

  @override
  State<StatefulWidget> createState() => SettingsScreenState(userSettings);
}

class SettingsScreenState extends State<SettingsScreen> {
  SettingsScreenState(UserSettings userSettings);

  Widget _buildAllowMobile() {
    final title = 'Use Mobile Data';
    final subtitle = 'Allow uploading data with a cellular connection';

    return SwitchListTile(
      subtitle: Text(subtitle),
      title: Text(
        title,
        style: TextStyle(fontSize: _fontSize),
      ),
      value: true, //widget.userSettings.allowMobileData,
      onChanged: (state) {
        widget.updateSettings(widget.userSettings.copyWith(allowMobileData: state));
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
      value: false, // widget.userSettings.uploadAutomatically,
      onChanged: (state) {
        widget.updateSettings(widget.userSettings.copyWith(uploadAutomatically: state));
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
            children: <Widget>[
              _buildAllowMobile(),
              _buildAutoUpload(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  'These settings can not be changed in this version. They will become available in a future version.',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
