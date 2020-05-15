import 'dart:async';

import 'package:flutter/material.dart';
import 'package:olrac_themes/olrac_themes.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_data.dart';
import 'package:oltrace/background_fetch.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/dio.dart';
import 'package:oltrace/providers/location.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/user_prefs.dart';
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
import 'package:oltrace/screens/product.dart';
import 'package:oltrace/screens/settings.dart';
import 'package:oltrace/screens/splash.dart';
import 'package:oltrace/screens/trip.dart';
import 'package:oltrace/screens/trip_history.dart';
import 'package:oltrace/screens/welcome.dart';
import 'package:package_info/package_info.dart';
import 'package:sqflite/sqflite.dart';
import 'package:background_fetch/background_fetch.dart';

/// A connection to SQLite through sqlflite.
Database _database;

final JsonRepository _jsonRepo = JsonRepository();

final LocationProvider _locationProvider = LocationProvider();

/// The app entry point. Execution starts here.
Future<void> main() async {
  setFlutterErrorHandler();

  final stopwatch = Stopwatch()..start();
  print('=== ${AppConfig.APP_TITLE} Started ===');
  print(AppConfig.debugMode ? 'Dev Mode' : 'Release Mode');
  try {
    await boot();
    print('Booted in ${stopwatch.elapsed}');
  } catch (exception, stack) {
    await handleError(exception, stack);
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

  // SharedPreferences is used for basic non-critical data such
  // as the user's preferences.
  await SharedPreferencesProvider().connect();

  // Sqlflite database for trip data.
  _database = await DatabaseProvider().connect();

  // Get the app version and some other info
  AppData.packageInfo = await PackageInfo.fromPlatform();

  // Dio HTTP client
  DioProvider().init();

  // Run the Flutter app
  runZoned(
    () {
      runApp(OlTraceApp());
      BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
    },
    onError: (Object error, StackTrace stackTrace) {
      handleError(error, stackTrace);
    },
  );
}

/// Run things once the app has started and the splash screen is showing.
Future<void> _onAppRunning() async {
  UserPrefsProvider().init();


  // Run the migrator every time to ensure
  // tables are in the latest state.
  final migrator = Migrator(_database, AppConfig.migrations);
  await migrator.run(AppConfig.RESET_DATABASE);

  // For IMEI access
  await requestPhonecallPermission();


  // Prompt for location access until the user accepts.
  while (await _locationProvider.permissionGranted == false || _locationProvider.listening == false) {
    // Begin listening to location stream.
    _locationProvider.startListening();
  }

  await _initBackgroundFetch();

  // Restore persisted data into app state
  final Map profile = await _jsonRepo.get('profile');
  if (profile != null) {
    AppData.profile = Profile.fromMap(profile);
  }
}

Future<void> _initBackgroundFetch() async {
  final int status = await BackgroundFetch.configure(AppConfig.backgroundFetchConfig, backgroundFetchCallback);
  print('BackgroundFetch configured status:$status');
}

/// The main widget of the app
class OlTraceApp extends StatefulWidget {
  final Database database = DatabaseProvider().database;

  OlTraceApp();

  @override
  State<StatefulWidget> createState() {
    return OlTraceAppState();
  }
}

class OlTraceAppState extends State<OlTraceApp> {
  // Used to reference the navigator outside the widget context.
  final _navigatorKey = GlobalKey<NavigatorState>();

  OlTraceAppState();

  @override
  void initState() {
    super.initState();
    final stopwatch = Stopwatch()..start();
    // Do startup logic
    _onAppRunning().then((_) async {
      print('App init in ${stopwatch.elapsed}');

      // Delay to show logos
      if (!AppConfig.debugMode) await Future.delayed(const Duration(seconds: 5) - stopwatch.elapsed);

      // If profile is not already setup, show welcome screen
      await _navigatorKey.currentState.pushReplacementNamed(AppData.profile != null ? '/' : '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: AppConfig.APP_TITLE,
      theme: OlracThemes.westlake,
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
              final Trip trip = settings.arguments as Trip;

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
              return SettingsScreen();

            case '/landing':
              final Map args = settings.arguments as Map<String, dynamic>;
              final landingId = args['landingId'] as int;
              final listIndex = args['listIndex'] as int;

              assert(landingId != null);
              assert(listIndex != null);

              return LandingScreen(landingId: landingId, listIndex: listIndex);

            case '/create_landing':
              final Haul haul = settings.arguments as Haul;
              return LandingFormScreen(haulArg: haul);

            case '/edit_landing':
              final Landing landing = settings.arguments as Landing;
              return LandingFormScreen(landingArg: landing);

            case '/create_product':
              final Map args = settings.arguments as Map;
              assert(args.containsKey('landings'));
              assert(args.containsKey('haul'));
              final List<Landing> sourceLandings = args['landings'] as List<Landing>;
              final Haul sourceHaul = args['haul'] as Haul;

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

            case '/developer':
              return DiagnosticsScreen();

            default:
              throw 'No such route: ${settings.name}';
          }
        });
      },
    );
  }
}
