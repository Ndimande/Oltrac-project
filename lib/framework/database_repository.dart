import 'package:oltrace/framework/model.dart';
import 'package:oltrace/providers/database.dart';

/// Implement this interface to store and retrieve
/// database records.
abstract class DatabaseRepository<T extends Model> {
  final database = DatabaseProvider().database;
  // Override this to specify table name
  var tableName;

  /// Get all items from the database.
  Future<List<T>> all({String where}) async {
    List<Map<String, dynamic>> results = await database.query(tableName, where: where);
    return results
        .map(
          (Map<String, dynamic> result) => fromDatabaseMap(result),
        )
        .toList();
  }

  /// Get item by id.
  Future<T> find(int id);

  /// Insert or update records for a model.
  Future<int> store(T model) async {
    // if no id create a new record
    if (model.id == null) {
      return await database.insert(tableName, toDatabaseMap(model));
    }
    // We remove this item completely or sqlite will try
    // to set id = null
    final withoutId = toDatabaseMap(model)..remove('id');

    return await database.update(tableName, withoutId, where: 'id = ${model.id}');
  }

  Future<void> delete(int id) async {
    await database.delete(tableName, where: 'id = $id');
  }

  /// Parse the map returned by sqflite into
  /// the model.
  T fromDatabaseMap(Map<String, dynamic> result);

  /// Create a map that can be stored in the database
  Map<String, dynamic> toDatabaseMap(T model);
}
