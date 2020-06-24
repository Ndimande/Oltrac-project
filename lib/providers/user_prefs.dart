import 'package:oltrace/app_config.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPrefsProvider {
  static final UserPrefsProvider _userPrefsProvider = UserPrefsProvider._();
  final SharedPreferences _sharedPreferences = SharedPreferencesProvider().sharedPreferences;

  UserPrefs _userPrefs;

  UserPrefsProvider._();

  factory UserPrefsProvider() {
    return _userPrefsProvider;
  }

  UserPrefs get userPrefs {
    if (_userPrefs == null) {
      init();
    }
    return _userPrefs;
  }

  void init() {
    const Map defaults = AppConfig.defaultUserSettings;
    String key;
    key = 'uploadAutomatically';
    if (_sharedPreferences.getBool(key) == null) {
      _sharedPreferences.setBool(key, defaults[key]);
    }

    key = 'mobileData';
    if (_sharedPreferences.getBool(key) == null) {
      _sharedPreferences.setBool(key, defaults[key]);
    }

    key = 'bulkMode';
    if (_sharedPreferences.getBool(key) == null) {
      _sharedPreferences.setBool(key, defaults[key]);
    }
    _userPrefs ??= UserPrefs();
  }
}

class UserPrefs {
  static const String MOBILE_DATA = 'mobileData';
  static const String UPLOAD_AUTOMATICALLY = 'uploadAutomatically';

  final SharedPreferences _sharedPreferences = SharedPreferencesProvider().sharedPreferences;

  bool get mobileData => _sharedPreferences.getBool(MOBILE_DATA);

  bool get uploadAutomatically => _sharedPreferences.getBool(UPLOAD_AUTOMATICALLY);

  set mobileData(bool value) {
    _sharedPreferences.setBool(MOBILE_DATA, value);
  }

  set uploadAutomatically(bool value) {
    _sharedPreferences.setBool(UPLOAD_AUTOMATICALLY, value);
  }

  void toggleMobileData() {
    _sharedPreferences.setBool(MOBILE_DATA, !_sharedPreferences.getBool(MOBILE_DATA));
  }

  void toggleUploadAutomatically() {
    _sharedPreferences.setBool(UPLOAD_AUTOMATICALLY, !_sharedPreferences.getBool(UPLOAD_AUTOMATICALLY));
  }
}
