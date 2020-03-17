import 'package:oltrace/app_migrations.dart';

class AppConfig {
  /// Global flags.
  /// These values are checked by git before you commit to
  /// avoid bad production values.
  ///
  /// Enables / disables development features
  /// like buttons to fake data etc.
  static final debugMode = (() {
    bool isDebug = false;
    assert((() => isDebug = true)());
    return isDebug;
  })();

  /// Drop and recreate the database if true
  static const RESET_DATABASE = false;

  /// The title of the app
  static const APP_TITLE = 'OlTrace';

  /// The URL to upload trips to
  static const TRIP_UPLOAD_URL = 'https://tracing.olracddm.com/incomings';

  /// The API key for this app for Sentry.io error reporting
  static const SENTRY_DSN = 'https://46c3ef2535a2460a8a00c013f0738e17@sentry.io/3728395';

  static const defaultUserSettings = <String, dynamic>{
    'mobile_data': false,
    'uploadAutomatically': false,
    'darkMode': false,
    'bulkMode': false,
  };

  static const MAX_HISTORY_SELECTABLE = const Duration(days: 100);

  /// The sqlite database filename
  static const databaseFilename = 'oltrace.db';

  static final migrations = appMigrations;
}
