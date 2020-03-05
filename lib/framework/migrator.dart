import 'package:sqflite/sqflite.dart';

final _migrationTableName = 'migrations';

class Migrator {
  final List<Map<String, String>> _migrations;

  Database _database;

  Migrator(this._database, this._migrations);

  /// Get complete migrations and run any which are
  /// defined in app_migrations.dart but are not
  /// in the list.
  /// This way when we update the code, we can modify
  /// database structure safely by writing patches.
  ///
  /// Setting [reset] to true will reset the database.
  Future<void> run([bool reset = false]) async {
    if (reset) {
      print('Resetting database');
      await _reset();
    }

    if (reset || !await tableExists(_migrationTableName)) {
      print("Creating migrations table");
      await _createMigrationsTable();
    }

    final completeMigrations = await _queryCompleteMigrations();

    try {
      if (_migrationRequired(completeMigrations)) {
        final pendingMigrations = _getPendingMigrations(completeMigrations);
        await _migrate(pendingMigrations);
      } else {
        print('No migrations pending');
      }
    } catch (e) {
      print('Migrating failed');
      print(e);
      throw e;
    }
  }

  /// Check if a table exists.
  Future<bool> tableExists(String name) async {
    String sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='$name'";
    var result = await _database.rawQuery(sql);

    return result.length > 0 ? true : false;
  }

  /// Create the database table that stores
  /// the list of complete migrations
  Future<void> _createMigrationsTable() async {
    String sql = 'CREATE TABLE $_migrationTableName ( '
        'id INTEGER PRIMARY KEY, '
        'migration TEXT'
        ')';

    await _database.execute(sql);
  }

  /// Get a List of migrations that have not been run yet.
  Iterable _getPendingMigrations(List completeMigrations) {
    return _migrations.where((migration) => !completeMigrations
        .map((completeMigration) => completeMigration['migration'])
        .toList()
        .contains(migration['name']));
  }

  /// Run all pending migrations.
  Future<void> _migrate(Iterable pendingMigrations, {bool fresh = false}) async {
    for (var migration in pendingMigrations) {
      String name = migration['name'];
      print('Migrating $name');
      await _database.execute(migration['up']);
      await _database.insert('migrations', {'migration': name});
    }
  }

  /// Check if migration needs to happen.
  bool _migrationRequired(List completeMigrations) {
    return _migrations.length != completeMigrations.length;
  }

  /// Get a List of complete migrations.
  Future<List> _queryCompleteMigrations() async {
    return await _database.query('migrations', columns: ['id', 'migration']);
  }

  /// Get a list of all user created tables.
  Future<List<String>> getTableNames() async {
    List<Map> tables = await _database.rawQuery("SELECT name FROM sqlite_master"
        " WHERE type ='table' AND name NOT LIKE 'sqlite_%' AND  name != 'android_metadata'");
    return tables.map((table) => table['name'].toString()).toList();
  }

  /// Drop all tables to give a clean state.
  Future<void> _reset() async {
    List tableNames = await getTableNames();
    for (String tableName in tableNames) {
      _database.execute("DROP TABLE '$tableName'");
    }
  }
}
