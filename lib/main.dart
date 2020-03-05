import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/framework/user_settings.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/add_source_landing.dart';
import 'package:oltrace/widgets/screens/create_product.dart';
import 'package:oltrace/widgets/screens/edit_trip.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/haul.dart';
import 'package:oltrace/widgets/screens/landing.dart';
import 'package:oltrace/widgets/screens/landing_form.dart';
import 'package:oltrace/widgets/screens/main.dart';
import 'package:oltrace/widgets/screens/product.dart';
import 'package:oltrace/widgets/screens/settings.dart';
import 'package:oltrace/widgets/screens/splash.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/screens/trip_history.dart';
import 'package:oltrace/widgets/screens/welcome.dart';
import 'package:package_info/package_info.dart';
import 'package:sentry/sentry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// MobX [Store] holds the global ephemeral state.
final AppStore _appStore = StoreProvider().appStore;

/// A connection to SQLite through sqlflite.
Database _database;

/// A connection to SharedPreferences / NSUserDefaults
SharedPreferences _sharedPreferences;

final sentry = SentryClient(dsn: AppConfig.SENTRY_DSN);

final JsonRepository _jsonRepo = JsonRepository();

final LocationProvider _locationProvider = LocationProvider();

/// The app entry point. Execution starts here.
void main() async {

  FlutterError.onError = (details, {bool forceReport = false}) {
    try {
      sentry.captureException(exception: details.exception, stackTrace: details.stack);
      print('Flutter Exception! Sentry report sending..');
    } catch (e) {
      print('Sending report to sentry.io failed: $e');
    } finally {
      // Also use Flutter's pretty error logging to the device's console.
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    }
  };

  final stopwatch = Stopwatch()..start();
  print('=== OlTrace Started ===');
  // Being timing the boot process
  try {
    await boot();
    print('Booted in ${stopwatch.elapsed}');
  } catch(error, stackTrace) {
    print('General Exception! Sentry report sending...');
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
}

/// Boot the application.
///
/// Here we connect the backend to the application before it starts.
/// These are the minimum requirements to run the application.
/// We will restore persisted data to memory later.
Future<void> boot() async {
  // We must call this so we can do io before
  // Flutter runApp has been called.
  // (Was not required in 1.9 but is in 1.12)
  WidgetsFlutterBinding.ensureInitialized();

  // Connect our persistent storages.
  //
  // SharedPreferences is used for basic non-critical data such
  // as the user's preferences.
  _sharedPreferences = await SharedPreferencesProvider().connect();

  // Sqlflite database for trip data.
  _database = await DatabaseProvider().connect();

  // Get the user's app preferences from SharedPreferences.
  final UserSettings userSettings = _restoreUserSettings();

  // Run the Flutter app
  runZoned(
    () => runApp(OlTraceApp(userSettings)),
    onError: (Object error, StackTrace stackTrace) {
      try {
        print('Zoned Exception! Sentry report sending..');
        sentry.captureException(exception: error, stackTrace: stackTrace);
      } catch (e) {
        print('Sending report to sentry.io failed: $e');
        print('Original error: $error');
      }
    },
  );


}

/// Restore the user defined preferences for the app.
/// These can be modified by the user in the SettingsScreen.
UserSettings _restoreUserSettings() {
  final defaults = AppConfig.defaultUserSettings;

  final bool darkMode = _sharedPreferences.getBool('darkMode') ?? defaults['darkMode'];
  final bool allowMobileData =
      _sharedPreferences.getBool('allowMobileData') ?? defaults['uploadAutomatically'];
  final bool uploadAutomatically =
      _sharedPreferences.getBool('uploadAutomatically') ?? defaults['uploadAutomatically'];

  return UserSettings(
    darkMode: darkMode,
    allowMobileData: allowMobileData,
    uploadAutomatically: uploadAutomatically,
  );
}

/// Run things once the app has started and the splash screen is showing.
Future<AppStore> _initApp() async {
  // Run the migrator every time to ensure
  // tables are in the latest state.
  final migrator = Migrator(_database, AppConfig.migrations);
  await migrator.run(AppConfig.RESET_DATABASE);

  // Get the app version and some other info
  _appStore.packageInfo = await PackageInfo.fromPlatform();

  // Prompt for location access until the user accepts.
  while (
      await _locationProvider.permissionGranted == false || _locationProvider.listening == false) {
    // Begin listening to location stream.
    _locationProvider.startListening();
  }
  // Restore persisted data into app state
  return await _restoreState();
}

/// Restore the saved state from the database and elsewhere.
Future<AppStore> _restoreState() async {
  // Profile
  final Map profile = await _jsonRepo.get('profile');
  if (profile != null) {
    _appStore.profile = Profile.fromMap(profile);
  }
  return _appStore;
}

/// The main widget of the app
class OlTraceApp extends StatefulWidget {
  final Database database = DatabaseProvider().database;
  final UserSettings userSettings;

  OlTraceApp(this.userSettings);

  @override
  State<StatefulWidget> createState() {
    return OlTraceAppState(userSettings);
  }
}

class OlTraceAppState extends State<OlTraceApp> {
  // Used to reference the navigator outside the widget context.
  final _navigatorKey = GlobalKey<NavigatorState>();

  /// The current [UserSettings] as selected by
  /// the user on the [SettingsScreen].
  UserSettings _userSettings;

  OlTraceAppState(this._userSettings);

  @override
  void initState() {
    super.initState();
    final stopwatch = Stopwatch()..start();

    // Do startup logic
    _initApp().then((AppStore appStore) async {
      print('State restored in ${stopwatch.elapsed}');

      // Delay to show logos
      await Future.delayed(Duration(seconds: 2) - stopwatch.elapsed);

      // If profile is not already setup, show welcome screen
      if (appStore.profileConfigured) {
        await _navigatorKey.currentState.pushReplacementNamed('/');
      } else {
        await _navigatorKey.currentState.pushReplacementNamed('/welcome');
      }
    });
  }

  /// Change the user preferences and redraw the app
  void _updateUserSettings(UserSettings userSettings) {
    _sharedPreferences.setBool('darkMode', userSettings.darkMode);
    _sharedPreferences.setBool('allowMobileData', userSettings.allowMobileData);
    _sharedPreferences.setBool('uploadAutomatically', userSettings.uploadAutomatically);
    setState(() => _userSettings = userSettings);
  }

  @override
  Widget build(BuildContext context) {

    final theme = _userSettings.darkMode ? appThemes['dark'] : appThemes['light'];
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConfig.APP_TITLE,
      theme: theme,
      initialRoute: 'splash',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case 'splash':
            return MaterialPageRoute(builder: (_) => SplashScreen());

          case '/':
            return MaterialPageRoute(builder: (_) => MainScreen());

          case '/about':
            return MaterialPageRoute(builder: (_) => AboutScreen());

          case '/trip':
            final Trip trip = settings.arguments;

            return MaterialPageRoute(builder: (_) => TripScreen(tripId: trip.id));

          case '/edit_trip':
            final Trip trip = settings.arguments;

            return MaterialPageRoute(builder: (_) => EditTripScreen(trip));

          case '/haul':
            final Map args = settings.arguments as Map<String, dynamic>;
            final int haulId = args['haulId'] as int;
            final int listIndex = args['listIndex'] as int;

            assert(haulId != null);
            assert(listIndex != null);

            return MaterialPageRoute(
                builder: (_) => HaulScreen(haulId: haulId, listIndex: listIndex));

          case '/fishing_methods':
            return MaterialPageRoute(builder: (_) => FishingMethodScreen());

          case '/welcome':
            return MaterialPageRoute(builder: (_) => WelcomeScreen());

          case '/trip_history':
            return MaterialPageRoute(builder: (_) => TripHistoryScreen());

          case '/settings':
            return MaterialPageRoute(
              builder: (_) =>
                  SettingsScreen(_userSettings, (UserSettings us) => _updateUserSettings(us)),
            );

          case '/landing':
            final Map args = settings.arguments as Map<String, dynamic>;
            final landingId = args['landingId'] as int;
            final listIndex = args['listIndex'] as int;

            assert(landingId != null);
            assert(listIndex != null);

            return MaterialPageRoute(
              builder: (_) => LandingScreen(landingId: landingId, listIndex: listIndex),
            );

          case '/create_landing':
            final Haul haul = settings.arguments;
            return MaterialPageRoute(builder: (_) => LandingFormScreen(haulArg: haul));

          case '/edit_landing':
            final Landing landing = settings.arguments;
            return MaterialPageRoute(builder: (_) => LandingFormScreen(landingArg: landing));

          case '/create_product':
            final Map args = settings.arguments as Map;
            assert(args.containsKey('landings'));
            assert(args.containsKey('haul'));
            final List<Landing> sourceLandings = args['landings'] as List<Landing>;
            final Haul sourceHaul = args['haul'];
            return MaterialPageRoute(
                builder: (_) => CreateProductScreen(
                      initialSourceLandings: sourceLandings,
                      sourceHaul: sourceHaul,
                      listIndex: 0,
                    ));

          case '/product':
            final args = settings.arguments as Map<String, dynamic>;
            final int productId = args['productId'] as int;

            return MaterialPageRoute(builder: (_) => ProductScreen(productId: productId));

          case '/add_source_landing':
            final List<Landing> landings = settings.arguments as List<Landing>;
            return MaterialPageRoute(
                builder: (_) => AddSourceLandingsScreen(alreadySelectedLandings: landings));

          default:
            throw ('No such route: ${settings.name}');
        }
      },
    );
  }
}
