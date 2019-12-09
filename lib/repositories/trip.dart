import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/haul.dart';

class TripRepository extends DatabaseRepository<Trip> {
  /// The name of the database table
  static const _tableName = 'trips';
  final _database = DatabaseProvider().database;

  TripRepository();

  /// Get a Trip by [id]
  Future<Trip> find(int id, {bool withHauls = false}) async {
    List results = await _database.query(_tableName, where: 'id = $id');

    // Nothing found.
    if (results.length == 0) {
      return null;
    }

    final trip = fromDatabaseMap(results.first);

    if (withHauls) {
      final haulRepo = HaulRepository();

      final tripHauls = await haulRepo.all(
        where: 'trip_id = ${trip.id}',
      );

      return trip.copyWith(hauls: tripHauls);
    }

    return trip;
  }

  /// Get all trips in the database with hauls.
  Future<List<Trip>> all({String where}) async {
    final List<Map<String, dynamic>> tripResults = await _database.query(_tableName);

    final trips =
        tripResults.map((Map<String, dynamic> result) => fromDatabaseMap(result)).toList();

    final tripsWithHaulsFutures = trips.map((trip) async {
      final haulResults = await _database.query('hauls', where: 'trip_id = ${trip.id}');

      final hauls =
          haulResults.map((Map result) => HaulRepository().fromDatabaseMap(result)).toList();
      return trip.copyWith(hauls: hauls);
    }).toList();

    return Future.wait(tripsWithHaulsFutures);
  }

  /// Store a Trip
  /// returns id of new row
  Future<int> store(Trip trip) async {
    if (trip.id == null) {
      return await _database.insert(_tableName, toDatabaseMap(trip));
    }
    final withoutId = toDatabaseMap(trip)..remove('id');
    // remove null id
    return await _database.update(_tableName, withoutId);
  }

  /// Get the active Trip. The active trip is the trip
  /// that has ended_at = null.
  Future<Trip> getActiveTrip() async {
    List results = await _database.query(_tableName, where: "ended_at is null");
    if (results.length > 1) {
      throw Exception('More than one active Trip is not allowed');
    } else if (results.length == 0) {
      return null;
    }

    return fromDatabaseMap(results.first);
  }

  Trip fromDatabaseMap(Map<String, dynamic> result) {
    final startedAt = result['started_at'] != null ? DateTime.parse(result['started_at']) : null;

    final endedAt = result['ended_at'] != null ? DateTime.parse(result['ended_at']) : null;

    final Position endPosition = result['end_latitude'] == null || result['end_longitude'] == null
        ? null
        : Position(
            latitude: result['end_latitude'],
            longitude: result['end_longitude'],
          );

    return Trip(
      id: result['id'],
      startedAt: startedAt,
      endedAt: endedAt,
      startPosition: Position(
        latitude: result['start_latitude'],
        longitude: result['start_longitude'],
      ),
      endPosition: endPosition,
    );
  }

  Map<String, dynamic> toDatabaseMap(Trip trip) {
    return {
      'id': trip.id,
      'started_at': trip.startedAt == null ? null : trip.startedAt.toIso8601String(),
      'ended_at': trip.endedAt == null ? null : trip.endedAt.toIso8601String(),
      'start_latitude': trip.startPosition.latitude,
      'start_longitude': trip.startPosition.longitude,
      'end_latitude': trip.startPosition.latitude,
      'end_longitude': trip.startPosition.longitude,
    };
  }
}
