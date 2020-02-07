import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/haul.dart';

class TripRepository extends DatabaseRepository<Trip> {
  /// The name of the database table
  var tableName = 'trips';
  final _database = DatabaseProvider().database;

  /// Get a Trip by [id]
  Future<Trip> find(int id, {bool withHauls = false}) async {
    List results = await _database.query(tableName, where: 'id = $id');

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
    final List<Map<String, dynamic>> tripResults = await _database.query(tableName);

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
      return await _database.insert(tableName, toDatabaseMap(trip));
    }
    // remove null id
    final withoutId = toDatabaseMap(trip)..remove('id');

    return await _database.update(tableName, withoutId);
  }

  /// Get the active Trip. The active trip is the trip
  /// that has ended_at = null.
  Future<Trip> getActiveTrip() async {
    List results = await _database.query(tableName, where: "ended_at is null");
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

    final Location endLocation = result['end_latitude'] == null || result['end_longitude'] == null
        ? null
        : Location(
            latitude: result['end_latitude'],
            longitude: result['end_longitude'],
          );

    return Trip(
      id: result['id'],
      startedAt: startedAt,
      endedAt: endedAt,
      startLocation: Location(
        latitude: result['start_latitude'],
        longitude: result['start_longitude'],
      ),
      endLocation: endLocation,
    );
  }

  Map<String, dynamic> toDatabaseMap(Trip trip) {
    return {
      'id': trip.id,
      'started_at': trip.startedAt == null ? null : trip.startedAt.toIso8601String(),
      'ended_at': trip.endedAt == null ? null : trip.endedAt.toIso8601String(),
      'start_latitude': trip.startLocation.latitude,
      'start_longitude': trip.startLocation.longitude,
      'end_latitude': trip.startLocation.latitude,
      'end_longitude': trip.startLocation.longitude,
    };
  }
}
