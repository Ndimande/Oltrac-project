import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/tag.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/repositories/tag.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/create_product.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main.dart';
import 'package:oltrace/widgets/screens/settings.dart';
import 'package:oltrace/widgets/screens/splash.dart';
import 'package:oltrace/widgets/screens/tag.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/screens/trip_history.dart';
import 'package:oltrace/widgets/screens/welcome.dart';
import 'package:package_info/package_info.dart';
import 'package:sqflite/sqflite.dart';

/// The app entry point. Execution starts here.
void main() {
  final stopwatch = Stopwatch()..start();
  _connectDatabase().then((Database database) {
    // MobX store holds global ephemeral state.
    final AppStore _appStore = StoreProvider().appStore;

    runApp(OlTraceApp(_appStore, database));
    print('booted in ${stopwatch.elapsed}');
  });
}

/// Connects to the sqlite database.
Future<Database> _connectDatabase() async {
  final dbProvider = DatabaseProvider();
  return await dbProvider.connect();
}

/// Run things required when the app starts
Future<AppStore> _initApp(AppStore appStore, Database database) async {
  // Run the migrator every time to ensure
  // tables are in the latest state.
  await _migrateDatabase(database, AppConfig.resetDatabaseOnRestart);

  // Get the app version and some other info
  appStore.packageInfo = await PackageInfo.fromPlatform();

  // Restore persisted data into app state
  return await _restoreState(database, appStore);
}

/// Run the database migrator which will create
/// and modify the database as required according
/// to the current migrations defined in app_config.dart.
Future<void> _migrateDatabase(Database database, bool resetDatabase) async {
  final migrator = Migrator(database, AppConfig.migrations);
  await migrator.run(resetDatabase);
}

/// Restore the saved state from the database and elsewhere.
Future<AppStore> _restoreState(Database database, AppStore appStore) async {
  final tripRepo = TripRepository();
  final haulRepo = HaulRepository();
  final jsonRepo = JsonRepository();
  final tagRepo = TagRepository();

  // Profile
  final Map profile = await jsonRepo.get('profile');
  if (profile != null) {
    appStore.profile = Profile.fromMap(profile);
  }

  // Active trip
  final Trip activeTrip = await tripRepo.getActiveTrip();

  if (activeTrip != null) {
    final List<Haul> activeTripHauls = await haulRepo.all(where: 'trip_id = ${activeTrip.id}');

    var newHauls = <Haul>[];
    for (Haul haul in activeTripHauls) {
      final List<Tag> haulTags = await tagRepo.all(where: 'haul_id = ${haul.id}');

      final newHaul = haul.copyWith(tags: haulTags);
      newHauls.add(newHaul);
    }

    appStore.activeTrip = activeTrip.copyWith(hauls: newHauls);
  }

  _restoreCompletedTrips(appStore);
  return appStore;
}

Future<void> _restoreCompletedTrips(appStore) async {
  final tripRepo = TripRepository();
  final haulRepo = HaulRepository();
  final tagRepo = TagRepository();

  final completedTrips = await tripRepo.all(where: 'ended_at IS NOT NULL');

  final updatedTrips = <Trip>[];

  for (Trip trip in completedTrips) {
    // Get all hauls for this trip
    final tripHauls = await haulRepo.all(where: 'trip_id = ${trip.id} AND ended_at IS NOT NULL');

    final updatedHauls = <Haul>[];

    for (Haul currentHaul in tripHauls) {
      // Get tags for this haul
      final haulTags = await tagRepo.all(where: 'haul_id = ${currentHaul.id}');
      updatedHauls.add(currentHaul.copyWith(tags: haulTags));
    }
    updatedTrips.add(trip.copyWith(hauls: updatedHauls));
  }

  appStore.completedTrips = updatedTrips;
}

/// The main widget of the app
class OlTraceApp extends StatefulWidget {
  final AppStore _appStore;
  final Database database;

  OlTraceApp(this._appStore, this.database);

  @override
  State<StatefulWidget> createState() => OlTraceAppState();
}

class OlTraceAppState extends State<OlTraceApp> {
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    final stopwatch = Stopwatch()..start();
    _initApp(
      widget._appStore,
      widget.database,
    ).then((AppStore appStore) async {
      print('State initialised in ${stopwatch.elapsed}');

      // If profile is not already setup, show welcome screen
      if (appStore.profileConfigured) {
        await navigatorKey.currentState.pushReplacementNamed('/');
      } else {
        await navigatorKey.currentState.pushReplacementNamed('/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: AppConfig.appTitle,
      theme: AppConfig.materialAppTheme,
      initialRoute: 'splash',
      routes: {
        'splash': (context) => SplashScreen(),
        '/': (context) => MainScreen(),
        '/about': (context) => AboutScreen(),
        '/trip': (context) => TripScreen(),
        '/fishing_methods': (context) => FishingMethodScreen(),
        '/welcome': (context) => WelcomeScreen(),
        '/trip_history': (context) => TripHistoryScreen(),
        '/settings': (context) => SettingsScreen(),
        '/tag': (context) => TagScreen(),
        '/create_product': (context) => CreateProductScreen(),
      },
    );
  }
}
