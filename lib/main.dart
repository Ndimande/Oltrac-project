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
import 'package:oltrace/screens/about.dart';
import 'package:oltrace/screens/add_source_landing.dart';
import 'package:oltrace/screens/create_product.dart';
import 'package:oltrace/screens/diagnostics.dart';
import 'package:oltrace/screens/fishing_method.dart';
import 'package:oltrace/screens/haul.dart';
import 'package:oltrace/screens/landing.dart';
import 'package:oltrace/screens/landing_form.dart';
import 'package:oltrace/screens/main.dart';
import 'package:oltrace/screens/master_containers.dart';
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/screens/settings.dart';
import 'package:oltrace/screens/splash.dart';
import 'package:oltrace/screens/trip.dart';
import 'package:oltrace/screens/trip_history.dart';
import 'package:oltrace/screens/welcome.dart';
import 'package:oltrace/stores/app_store.dart';
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
  _setFlutterErrorHandler();

  final stopwatch = Stopwatch()..start();
  print('=== OlTrace Started ===');
  print(AppConfig.debugMode ? 'Dev Mode' : 'Release Mode');
  try {
    await boot();
    print('Booted in ${stopwatch.elapsed}');
  } catch (exception, stack) {
    await _handleError(exception, stack);
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
  final UserSettings userSettings = _getUserSettings();

  // Run the Flutter app
  runZoned(
    () => runApp(OlTraceApp(userSettings)),
    onError: (Object error, StackTrace stackTrace) {
      _handleError(error, stackTrace);
    },
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
  while (await _locationProvider.permissionGranted == false || _locationProvider.listening == false) {
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
      if (!AppConfig.debugMode) await Future.delayed(Duration(seconds: 5) - stopwatch.elapsed);

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
        return MaterialPageRoute(builder: (_) {
          switch (settings.name) {
            case 'splash':
              return SplashScreen();

            case '/':
              return MainScreen();

            case '/about':
              return AboutScreen();

            case '/trip':
              final Trip trip = settings.arguments;

              return TripScreen(tripId: trip.id);

            case '/haul':
              final Map args = settings.arguments as Map<String, dynamic>;
              final int haulId = args['haulId'] as int;
              final int listIndex = args['listIndex'] as int;

              assert(haulId != null);
              assert(listIndex != null);

              return HaulScreen(haulId: haulId, listIndex: listIndex);

            case '/fishing_methods':
              return FishingMethodScreen();

            case '/welcome':
              return WelcomeScreen();

            case '/trip_history':
              return TripHistoryScreen();

            case '/settings':
              return SettingsScreen(_userSettings, (UserSettings us) => _updateUserSettings(us));

            case '/landing':
              final Map args = settings.arguments as Map<String, dynamic>;
              final landingId = args['landingId'] as int;
              final listIndex = args['listIndex'] as int;

              assert(landingId != null);
              assert(listIndex != null);

              return LandingScreen(landingId: landingId, listIndex: listIndex);

            case '/create_landing':
              final Haul haul = settings.arguments;
              return LandingFormScreen(haulArg: haul);

            case '/edit_landing':
              final Landing landing = settings.arguments;
              return LandingFormScreen(landingArg: landing);

            case '/create_product':
              final Map args = settings.arguments as Map;
              assert(args.containsKey('landings'));
              assert(args.containsKey('haul'));
              final List<Landing> sourceLandings = args['landings'] as List<Landing>;
              final Haul sourceHaul = args['haul'];

              return CreateProductScreen(
                initialSourceLandings: sourceLandings,
                sourceHaul: sourceHaul,
                listIndex: 0,
              );

            case '/product':
              final args = settings.arguments as Map<String, dynamic>;
              final int productId = args['productId'] as int;

              return ProductScreen(productId: productId);

            case '/add_source_landing':
              final List<Landing> landings = settings.arguments as List<Landing>;
              return AddSourceLandingsScreen(alreadySelectedLandings: landings);

            case '/master_containers':
              return MasterContainersScreen();

            case '/developer':
              return DiagnosticsScreen();

            default:
              throw ('No such route: ${settings.name}');
          }
        });
      },
    );
  }
}

/// Restore the user defined preferences for the app.
/// These can be modified by the user in the SettingsScreen.
UserSettings _getUserSettings() {
  final defaults = AppConfig.defaultUserSettings;

  final bool darkMode = _sharedPreferences.getBool('darkMode') ?? defaults['darkMode'];
  final bool allowMobileData = _sharedPreferences.getBool('allowMobileData') ?? defaults['uploadAutomatically'];
  final bool uploadAutomatically = _sharedPreferences.getBool('uploadAutomatically') ?? defaults['uploadAutomatically'];

  return UserSettings(
    darkMode: darkMode,
    allowMobileData: allowMobileData,
    uploadAutomatically: uploadAutomatically,
  );
}

void _setFlutterErrorHandler() {
  FlutterError.onError = (details, {bool forceReport = false}) {
    _handleError(details.exception, details.stack);
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  };
}

Future<void> _sendSentryReport(Object exception, StackTrace stack) async {
  print('Sending report to Sentry.io...');
  try {
    await sentry.captureException(
      exception: exception,
      stackTrace: stack,
    );
    print('Sentry report sent');
  } catch (e) {
    print('Sending report to sentry.io failed: $e');
  }
}

Future<void> _handleError(Object exception, StackTrace stack) async {
  print(exception);
  print(stack);
  if (AppConfig.debugMode) {
    return;
  }

  _sendSentryReport(exception, stack);
}
