import 'dart:convert';

import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database_provider.dart';

import '../models/trip.dart';

class TripRepository {
  /// The name of the table
  static const _tableName = 'trips';
  static final _database = DatabaseProvider().database;

  /// Get all trips in the database
  static Future<List<Trip>> all() async {
    List<Map<String, dynamic>> results = await _database.query(_tableName);
    return results.map(
      (Map<String, dynamic> result) {
        final json = jsonDecode(result['json']);
        json['id'] = result['id'];
        return Trip.fromMap(json);
      },
    ).toList();
  }

  /// Get a Trip by id
  static Future<Trip> find(int id) async {
    List results = await _database.query(_tableName, where: 'id = $id');

    if (results.length == 0) {
      return null;
    }

    final Map result = results.first;
    return Trip.fromMap(result);
  }

  /// Get the active Trip.
  Future<Trip> getActiveTrip() async {
    List results = await _database.query(_tableName, where: 'ended_at = NULL');

    if (results.length > 1) {
      throw Exception('More than one active Trip is not allowed');
    } else if (results.length == 0) {
      return null;
    }

    return Trip.fromMap(results.first);
  }

  /// @return id of new row
  static Future<int> store(Trip trip) async {
    final withoutId = trip.toMap()..remove('id');
    if (trip.id == null) {
      return await _database.insert(_tableName, {'json': trip.toJson()});
    }
    // remove null id
    return await _database.update(_tableName, withoutId);
  }
}
