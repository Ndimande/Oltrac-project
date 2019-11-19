import 'package:flutter/material.dart';
import 'package:oltrace/app_config.dart';
import 'package:oltrace/framework/migrator.dart';
import 'package:oltrace/providers/database_provider.dart';
import 'package:oltrace/repositories/trip.dart';
import 'package:oltrace/stores/app_store.dart';
import 'package:oltrace/widgets/screens/about.dart';
import 'package:oltrace/widgets/screens/fishing_method.dart';
import 'package:oltrace/widgets/screens/main.dart';
import 'package:oltrace/widgets/screens/settings.dart';
import 'package:oltrace/widgets/screens/trip.dart';
import 'package:oltrace/widgets/screens/welcome.dart';

/// The app entry point. Execution starts here.
void main() {
  _initDatabase().then((_) async {
    final AppStore _appStore = AppStore();
    _appStore.completedTrips = await TripRepository.all();
    runApp(OlTraceApp(_appStore));
  });
}

/// Connects to the sqlite database and
/// migrates database structure as required.
/// Database migrations are defined in app_config.dart
Future<void> _initDatabase() async {
  final dbProvider = DatabaseProvider();
  final db = await dbProvider.connect();
  final migrator = Migrator(db, AppConfig.migrations);
  await migrator.run(AppConfig.resetDatabaseOnRestart);
}

class OlTraceApp extends StatelessWidget {
  final AppStore _appStore;

  OlTraceApp(this._appStore);

  @override
  Widget build(BuildContext context) {
    /// If no vessel is set, show the welcome screen
    /// so the user can enter their details
    final initialRoute = _appStore.vessel == null ? '/welcome' : '/';

    return MaterialApp(
      title: AppConfig.appTitle,
      theme: AppConfig.materialAppTheme,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => MainScreen(_appStore),
        '/about': (context) => AboutScreen(),
        '/trip': (context) => TripScreen(_appStore),
        '/fishing_methods': (context) => FishingMethodScreen(),
        '/welcome': (context) => WelcomeScreen(_appStore),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
