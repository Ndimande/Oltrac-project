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

  void _toggleUploadAutomatically(bool state) {
    setState(() {
      widget.userPrefs.toggleUploadAutomatically();
      uploadAutomatically = !uploadAutomatically;
    });
  }

  void _toggleMobileData(bool state) {
    setState(() {
      widget.userPrefs.toggleMobileData();
      mobileData = !mobileData;
    });
  }

  Widget _booleanOption({String title, String subtitle, bool value, Function(bool) onChanged}) {
    return SwitchListTile(
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      title: Text(title, style: const TextStyle(fontSize: 20)),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAllowMobile() {
    const title = 'Use Mobile Data';
    final subtitle = mobileData ? 'On. Allow using a mobile connection.' : 'Off. Only WiFi connections will be used.';
    return _booleanOption(
      title: title,
      subtitle: subtitle,
      value: mobileData,
      onChanged: _toggleMobileData,
    );
  }

  Widget _buildAutoUpload() {
    const title = 'Upload Automatically';
    final subtitle = uploadAutomatically
        ? 'On. Data will be uploaded automatically.'
        : 'Off. Data will not be uploaded automatically.';

    return _booleanOption(
      title: title,
      subtitle: subtitle,
      value: uploadAutomatically,
      onChanged: _toggleUploadAutomatically,
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
