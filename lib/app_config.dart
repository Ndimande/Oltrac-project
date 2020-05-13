import 'package:background_fetch/background_fetch.dart';
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
  static const bool RESET_DATABASE = false;

  /// The title of the app
  static const String APP_TITLE = 'SharkTrack';

  /// The URL to upload trips to
  static const String TRIP_UPLOAD_URL = 'https://tracing.olracddm.com/incomings';

  /// The API key for this app for Sentry.io error reporting
  static const String SENTRY_DSN = 'https://46c3ef2535a2460a8a00c013f0738e17@sentry.io/3728395';

  static const Map defaultUserSettings = <String, dynamic>{
    'mobileData': true,
    'uploadAutomatically': true,
    'bulkMode': false, //todo remove this everywhere
  };

  static const Duration MAX_HISTORY_SELECTABLE = Duration(days: 100);

  static const int MAX_SOAK_HOURS_SELECTABLE = 500;

  /// The sqlite database filename
  static const String DATABASE_FILENAME = 'sharktrack.db';

  static final migrations = appMigrations;

  static final backgroundFetchConfig = BackgroundFetchConfig(
    minimumFetchInterval: 15,
    enableHeadless: true,
    requiredNetworkType: NetworkType.ANY,
    stopOnTerminate: false,
    startOnBoot: true,
  );
}
