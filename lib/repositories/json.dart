import 'dart:convert';

import 'package:oltrace/framework/model.dart';
import 'package:oltrace/providers/database.dart';

class JsonRepository<T extends Model> {
  static const _tableName = 'json';
  final _database = DatabaseProvider().database;

  Future<void> set(String key, Model model) async {
    final json = jsonEncode(model.toMap());
    final row = {'key': key, 'json': json};

    if (await get(key) == null) {
      await _database.insert(_tableName, row);
    } else {
      row.remove('key');
      await _database.update(_tableName, row, where: "key = '$key'");
    }
  }

  Future<Map<String, dynamic>> get(String key) async {
    final results = await _database.query(_tableName, where: "key = '$key'", limit: 1);
    return results.length != 0 ? jsonDecode(results[0]['json']) : null;
  }
}
