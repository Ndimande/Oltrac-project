import 'package:background_fetch/background_fetch.dart';
import 'package:oltrace/app_migrations.dart';

const bool DEV_RESET_DB = false;

class AppConfig {
  /// Is the app in debug mode?
  static final debugMode = (() {
    bool isDebug = false;
    assert((() => isDebug = true)());
    return isDebug;
  })();

  /// Drop and recreate the database if true
  // ignore: avoid_bool_literals_in_conditional_expressions, non_constant_identifier_names
  static final bool RESET_DATABASE = debugMode ? false : DEV_RESET_DB;

  /// The title of the app
  static const String APP_TITLE = 'SharkTrace';

  /// The subtitle of the app
  static const String APP_SUBTITLE = 'Onboard';

  /// The URL to upload trips to
  static const String TRIP_UPLOAD_URL = 'https://tracing.olracddm.com/incomings';

  /// The API key for this app for Sentry.io error reporting
  static const String SENTRY_DSN = 'https://46c3ef2535a2460a8a00c013f0738e17@sentry.io/3728395';

  /// The values that are set when none are found.
  static const Map defaultUserSettings = <String, dynamic>{
    'mobileData': true,
    'uploadAutomatically': false,
    'bulkMode': false, //todo remove this everywhere
  };

  /// How far back can be selected in datetime editors
  static const Duration MAX_HISTORY_SELECTABLE = Duration(days: 100);

  // todo this is not used except in diagnostics
  static const int MAX_SOAK_HOURS_SELECTABLE = 500;

  /// The sqlite database filename
  static const String DATABASE_FILENAME = 'sharktrace.db';

  static final migrations = appMigrations;

  static final backgroundFetchConfig = BackgroundFetchConfig(
    minimumFetchInterval: 15,
    enableHeadless: false,
    requiredNetworkType: NetworkType.ANY,
    stopOnTerminate: false,
    startOnBoot: true,
  );
}
