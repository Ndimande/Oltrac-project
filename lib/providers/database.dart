import 'package:oltrace/app_config.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  /// SQLite db filename
  static const _filename = AppConfig.databaseFilename;

  /// DatabaseProvider instance
  static final DatabaseProvider _databaseProvider = DatabaseProvider._();

  /// Database instance
  Database _database;

  /// Private constructor
  DatabaseProvider._();

  /// Singleton access
  factory DatabaseProvider() {
    return _databaseProvider;
  }

  /// Get the database object
  Database get database {
    if (_database == null) {
      throw Exception('Database not connected');
    }
    return _database;
  }

  /// Open a connection to the database
  /// the database must be connected first or
  /// getting a db instance will fail.
  Future<Database> connect() async {
    _database = await openDatabase(_filename);
    return _database;
  }
}
