import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/trip.dart';
import 'package:oltrace/providers/database.dart';
import 'package:oltrace/repositories/haul.dart';
import 'package:oltrace/repositories/master_container.dart';

class TripRepository extends DatabaseRepository<Trip> {
  /// The name of the database table
  @override
  final tableName = 'trips';

  final _database = DatabaseProvider().database;

  /// Get a [Trip] by id
  @override
  Future<Trip> find(int id) async {
    final List results = await _database.query(tableName, where: 'id = $id');

    // Nothing found.
    if (results.isEmpty) {
      return null;
    }

    final trip = fromDatabaseMap(results.first);

    final haulRepo = HaulRepository();

    final tripHauls = await haulRepo.all(
      where: 'trip_id = ${trip.id}',
    );

    return trip.copyWith(hauls: tripHauls);
  }

  /// Get all trips.
  @override
  Future<List<Trip>> all({String where}) async {
    final List<Map<String, dynamic>> tripResults = await _database.query(tableName, where: where);

    final List<Trip> trips = tripResults.map((Map<String, dynamic> result) => fromDatabaseMap(result)).toList();

    return Future.wait(trips.map((Trip trip) => _withNested(trip)).toList());
  }

  /// Get the active Trip. The active trip is the trip
  /// that has ended_at = null.
  Future<Trip> getActive() async {
    final List results = await _database.query(tableName, where: 'ended_at is null');

    assert(results.length <= 1);

    if (results.isEmpty) {
      return null;
    }

    final Trip trip = fromDatabaseMap(results.first);
    final List<Haul> hauls = await HaulRepository().forTrip(trip.id);

    return trip.copyWith(hauls: hauls);
  }

  /// Get all trips that have been ended.
  Future<List<Trip>> getCompleted() async {
    final List results = await _database.query(tableName, where: 'ended_at is not null');
    final List<Trip> trips = [];

    for (final Map result in results) {
      final Trip trip = fromDatabaseMap(result);
      final List<Haul> hauls = await HaulRepository().forTrip(trip.id);
      trips.add(trip.copyWith(hauls: hauls));
    }

    return trips;
  }

  @override
  Trip fromDatabaseMap(Map<String, dynamic> result) {
    final startedAt = result['started_at'] != null ? DateTime.parse(result['started_at']) : null;

    final endedAt = result['ended_at'] != null ? DateTime.parse(result['ended_at']) : null;

    final Location endLocation = result['end_latitude'] == null || result['end_longitude'] == null
        ? null
        : Location(latitude: result['end_latitude'], longitude: result['end_longitude']);

    return Trip(
      id: result['id'],
      uuid: result['uuid'],
      startedAt: startedAt,
      endedAt: endedAt,
      startLocation: Location(
        latitude: result['start_latitude'],
        longitude: result['start_longitude'],
      ),
      endLocation: endLocation,
      isUploaded: result['is_uploaded'] as int == 1,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(Trip trip) {
    return {
      'id': trip.id,
      'uuid': trip.uuid,
      'started_at': trip.startedAt == null ? null : trip.startedAt.toIso8601String(),
      'ended_at': trip.endedAt == null ? null : trip.endedAt.toIso8601String(),
      'start_latitude': trip.startLocation.latitude,
      'start_longitude': trip.startLocation.longitude,
      'end_latitude': trip.endLocation?.latitude,
      'end_longitude': trip.endLocation?.longitude,
      'is_uploaded': trip.isUploaded ? 1 : 0
    };
  }

  Future<Trip> _withNested(Trip trip) async {
    final List<Haul> hauls = await HaulRepository().forTrip(trip.id);
    final List<MasterContainer> masterContainers = await MasterContainerRepository().forTrip(trip.id);
    return trip.copyWith(
      hauls: hauls,
      masterContainers: masterContainers,
    );
  }
}
