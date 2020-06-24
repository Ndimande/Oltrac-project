import 'package:flutter/material.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/user_prefs.dart';

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
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.caption),
      title: Text(title, style: Theme.of(context).textTheme.headline6),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildAllowMobile() {
    const title = 'Use Mobile Data';
    const subtitle = 'Allow using a mobile connection.';
    return _booleanOption(
      title: title,
      subtitle: subtitle,
      value: mobileData,
      onChanged: _toggleMobileData,
    );
  }

  Widget _buildAutoUpload() {
    const title = 'Upload Automatically';
    const subtitle = 'Data will be periodically uploaded automatically.';

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
        title: const Text('Settings'),
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 10),
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
