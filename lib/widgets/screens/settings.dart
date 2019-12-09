import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/stores/app_store.dart';

final double _fontSize = 20;

class SettingsScreen extends StatefulWidget {
  final ThemeData theme;
  final Function setTheme;

  SettingsScreen(this.theme, this.setTheme);

  @override
  State<StatefulWidget> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  bool _allowMobileData = false;
  bool _uploadAutomatically = false;
  bool _darkTheme = true;

  SettingsScreenState();

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

  Widget _buildEnableDarkTheme() {
    final title = 'Dark Theme';
    final subtitle = 'Use a theme that is nicer for viewing in the dark';

    return SwitchListTile(
      subtitle: Text(subtitle),
      title: Text(
        title,
        style: TextStyle(fontSize: _fontSize),
      ),
      value: _darkTheme,
      onChanged: (state) {
        return; // todo Disabled for now
        if (state)
          widget.setTheme(AppConfig.darkTheme);
        else
          widget.setTheme(AppConfig.olspsTheme);

        setState(() {
          _darkTheme = !_darkTheme;
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
            children: <Widget>[
              _buildAllowMobile(),
              _buildAutoUpload(),
              _buildEnableDarkTheme(),
            ],
          ),
        ));
  }
}
