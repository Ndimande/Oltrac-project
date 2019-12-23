import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/app_themes.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/framework/user_settings.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/profile.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/providers/shared_preferences.dart';
import 'package:oltrace/providers/store.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/json.dart';
import 'package:oltrace/repositories/landing.dart';
import 'package:oltrace/repositories/product.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/add_source_landing.dart';
import 'package:oltrace/widgets/screens/create_product.dart';
import 'package:oltrace/widgets/screens/create_landing.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/haul.dart';
import 'package:oltrace/widgets/screens/main.dart';
import 'package:oltrace/widgets/screens/product.dart';
import 'package:oltrace/widgets/screens/products.dart';
import 'package:oltrace/widgets/screens/settings.dart';
import 'package:oltrace/widgets/screens/splash.dart';
import 'package:oltrace/widgets/screens/landing.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/screens/trip_history.dart';
import 'package:oltrace/widgets/screens/welcome.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

/// MobX [Store] holds the global ephemeral state.
final AppStore _appStore = StoreProvider().appStore;

/// A connection to SQLite through sqlflite.
Database _database;

/// A connection to SharedPreferences / NSUserDefaults
SharedPreferences _sharedPreferences;

final TripRepository _tripRepo = TripRepository();
final HaulRepository _haulRepo = HaulRepository();
final JsonRepository _jsonRepo = JsonRepository();
final LandingRepository _landingRepo = LandingRepository();
final ProductRepository _productRepository = ProductRepository();

/// The app entry point. Execution starts here.
void main() {
  // Being timing the boot process process
  final stopwatch = Stopwatch()..start();
  boot().then((_) {
    print('Booted in ${stopwatch.elapsed}');
  });
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
  runApp(OlTraceApp(userSettings));
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

  // Active trip
  final Trip activeTrip = await _tripRepo.getActiveTrip();

  if (activeTrip != null) {
    final List<Haul> activeTripHauls = await _haulRepo.all(where: 'trip_id = ${activeTrip.id}');

    var newHauls = <Haul>[];
    for (Haul haul in activeTripHauls) {
      final List<Landing> haulLandings = await _landingRepo.all(where: 'haul_id = ${haul.id}');

      final newHaul = haul.copyWith(landings: haulLandings);
      newHauls.add(newHaul);
    }

    _appStore.activeTrip = activeTrip.copyWith(hauls: newHauls);
  }

  _restoreCompletedTrips(_appStore);
  return _appStore;
}

Future<void> _restoreCompletedTrips(appStore) async {
  final completedTrips = await _tripRepo.all(where: 'ended_at IS NOT NULL');

  final updatedTrips = <Trip>[];

  for (Trip trip in completedTrips) {
    // Get all hauls for this trip
    final tripHauls = await _haulRepo.all(where: 'trip_id = ${trip.id} AND ended_at IS NOT NULL');

    final updatedHauls = <Haul>[];

    for (Haul currentHaul in tripHauls) {
      // Get catches for this haul
      final haulLandings = await _landingRepo.all(where: 'haul_id = ${currentHaul.id}');
      updatedHauls.add(currentHaul.copyWith(landings: haulLandings));
    }
    updatedTrips.add(trip.copyWith(hauls: updatedHauls));
  }

  appStore.completedTrips = updatedTrips;

  await _restoreProducts();
}

Future<void> _restoreProducts() async {

  final sql = 'SELECT * FROM products JOIN product_landings '
      'ON product_landings.product_id = products.id';
   List<Map<String,dynamic>> results = await _database.rawQuery(sql);

  final List<Product> products = results.map((result) => _productRepository.fromDatabaseMap(result)).toList();
  _appStore.products = ObservableList.of(products);
}

/// The main widget of the app
class OlTraceApp extends StatefulWidget {
  // MobX store holds global ephemeral state.
  // final AppStore _appStore = StoreProvider().appStore;
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
      print('State initialised in ${stopwatch.elapsed}');

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

            return MaterialPageRoute(builder: (_) => TripScreen(trip));

          case '/haul':
            final Haul haul = settings.arguments;

            return MaterialPageRoute(builder: (_) => HaulScreen(haul));

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
            final Landing landing = settings.arguments;
            return MaterialPageRoute(builder: (_) => LandingScreen(landing));

          case '/create_tag':
            final Haul haul = settings.arguments;
            return MaterialPageRoute(builder: (_) => CreateLandingScreen(haul));

          case '/create_product':
            final Landing landing = settings.arguments;
            return MaterialPageRoute(builder: (_) => CreateProductScreen(landing));

          case '/add_source_landing':
            final List<Landing> landings = settings.arguments;
            return MaterialPageRoute(builder: (_) => AddSourceLandingsScreen(landings));

          case '/products':
            return MaterialPageRoute(builder: (_) => ProductsScreen());

          case '/product':
            final Product product = settings.arguments;
            return MaterialPageRoute(builder: (_) => ProductScreen(product));

          default:
            throw ('No such route: ${settings.name}');
        }
      },
    );
  }
}
