import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
  static final SharedPreferencesProvider _provider = SharedPreferencesProvider._();

  SharedPreferences _sharedPreferences;

  SharedPreferencesProvider._();

  factory SharedPreferencesProvider() {
    return _provider;
  }

  SharedPreferences get sharedPreferences {
    if (_sharedPreferences == null) {
      throw Exception('Shared Preferences not connected');
    }
    return _sharedPreferences;
  }

  Future<SharedPreferences> connect() async {
    _sharedPreferences = await SharedPreferences.getInstance();
    return _sharedPreferences;
  }
}
