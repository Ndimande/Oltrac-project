import 'package:flutter/material.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/user_prefs.dart';

const double _fontSize = 20;
const String UPLOAD_AUTOMATICALLY_KEY = 'uploadAutomatically';
const String MOBILE_DATA_KEY = 'mobileData';

class SettingsScreen extends StatefulWidget {
  final sharedPrefs = SharedPreferencesProvider().sharedPreferences;
  final userPrefs = UserPrefsProvider().userPrefs;

  SettingsScreen();

  @override
  State<StatefulWidget> createState() {
    return SettingsScreenState(
      mobileData: userPrefs.mobileData,
      uploadAutomatically: userPrefs.uploadAutomatically,
    );
  }
}

class SettingsScreenState extends State<SettingsScreen> {
  SettingsScreenState({this.mobileData, this.uploadAutomatically});

  bool mobileData;
  bool uploadAutomatically;

  void _toggleUploadAutomatically() {
    setState(() {
      widget.userPrefs.toggleUploadAutomatically();
      uploadAutomatically = !uploadAutomatically;
    });
  }

  void _toggleMobileData() {
    setState(() {
      widget.userPrefs.toggleMobileData();
      mobileData = !mobileData;
    });
  }

  Widget _buildAllowMobile() {
    final title = 'Use Mobile Data';
    final subtitle = 'Allow uploading data with a cellular connection';

    return SwitchListTile(
      subtitle: Text(subtitle),
      title: Text(
        title,
        style: TextStyle(fontSize: _fontSize),
      ),
      value: mobileData,
      onChanged: (state) {
        _toggleMobileData();
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
      value: uploadAutomatically,
      onChanged: (state) {
        _toggleUploadAutomatically();
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
          ],
        ),
      ),
    );
  }
}
