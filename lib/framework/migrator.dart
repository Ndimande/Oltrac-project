import 'package:oltrace/framework/util.dart';
import 'package:oltrace/providers/database_provider.dart';
import 'package:sqflite/sqflite.dart';

class Migrator {
  final List<Map<String, String>> _migrations;

  Database _database;

  Migrator(this._database, this._migrations);

  Future<void> run([bool reset = false]) async {
    if (reset) {
      pd('Resetting database');
      await _reset();
    }

    if (reset || !await tableExists('migrations')) {
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
    }
  }

  Future<bool> tableExists(String name) async {
    String sql =
        "SELECT name FROM sqlite_master WHERE type='table' AND name='$name'";
    var result = await _database.rawQuery(sql);

    return result.length > 0 ? true : false;
  }

  Future<void> _createMigrationsTable() async {
    String sql = 'CREATE TABLE migrations ( '
        'id INTEGER PRIMARY KEY, '
        'migration TEXT'
        ')';

    await _database.execute(sql);
  }

  Iterable _getPendingMigrations(List completeMigrations) {
    return _migrations.where((migration) => !completeMigrations
        .map((completeMigration) => completeMigration['migration'])
        .toList()
        .contains(migration['name']));
  }

  Future<void> _migrate(Iterable pendingMigrations,
      {bool fresh = false}) async {
    for (var migration in pendingMigrations) {
      String name = migration['name'];
      print('Migrating $name');
      await _database.execute(migration['up']);
      await _database.insert('migrations', {'migration': name});
    }
  }

  bool _migrationRequired(List completeMigrations) {
    return _migrations.length != completeMigrations.length;
  }

  Future<List> _queryCompleteMigrations() async {
    return await _database.query('migrations', columns: ['id', 'migration']);
  }

  Future<List<String>> getTableNames() async {
    List<Map> tables = await _database.rawQuery("SELECT name FROM sqlite_master"
        " WHERE type ='table' AND name NOT LIKE 'sqlite_%' AND  name != 'android_metadata'");
    return tables.map((table) => table['name'].toString()).toList();
  }

  Future<void> _reset() async {
    List tableNames = await getTableNames();
    for (String tableName in tableNames) {
      _database.execute("DROP TABLE '$tableName'");
    }
  }
}
