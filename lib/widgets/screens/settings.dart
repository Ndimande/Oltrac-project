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
      value: widget.userSettings.allowMobileData,
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
      value: widget.userSettings.uploadAutomatically,
      onChanged: (state) {
        widget.updateSettings(widget.userSettings.copyWith(uploadAutomatically: state));
      },
    );
  }

  Widget _buildEnableDarkTheme() {
    final title = 'Dark Theme';
    final subtitle = 'Use a theme that is better for viewing in the dark';

    return SwitchListTile(
      subtitle: Text(subtitle),
      title: Text(
        title,
        style: TextStyle(fontSize: _fontSize),
      ),
      value: widget.userSettings.darkMode,
      onChanged: (state) {
        widget.updateSettings(widget.userSettings.copyWith(darkMode: state));
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
//              _buildEnableDarkTheme(),
            ],
          ),
        ));
  }
}
