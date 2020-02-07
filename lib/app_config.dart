import 'package:oltrace/app_migrations.dart';

class AppConfig {
  /// Global flags.
  /// These values are checked by git before you commit to
  /// avoid bad production values.
  ///
  /// Enables / disables development features
  /// like buttons to fake data etc.
  static const DEV_MODE = false;

  /// Drop and recreate the database if true
  static const RESET_DATABASE = true;

  /// The title of the app
  static const APP_TITLE = 'OlTrace';

  static const defaultUserSettings = <String, dynamic>{
    'mobile_data': false,
    'uploadAutomatically': false,
    'darkMode': false,
    'bulkMode': false,
  };

  /// The sqlite database filename
  static const databaseFilename = 'oltrace.db';

  static final migrations = appMigrations;
}
