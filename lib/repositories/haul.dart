import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/repositories/landing.dart';

class HaulRepository extends DatabaseRepository<Haul> {
  @override
  final String tableName = 'hauls';

  /// Find a single haul by id
  @override
  Future<Haul> find(int id) async {
    final List<Map> results = await database.query(tableName, where: 'id = $id');

    if (results.isEmpty) {
      return null;
    }

    final Haul haul = fromDatabaseMap(results.first);

    final List<Landing> landings = await LandingRepository().forHaul(haul.id);

    return haul.copyWith(landings: landings);
  }

  /// Get all hauls with optional condition.
  @override
  Future<List<Haul>> all({String where}) async {
    final List<Map<String, dynamic>> results = await database.query(tableName, where: where);

    final List<Haul> hauls = results.map((result) => fromDatabaseMap(result)).toList();

    final List<Haul> withNested = [];

    for (final Haul haul in hauls) {
      final List<Landing> landings = await LandingRepository().forHaul(haul.id);
      withNested.add(haul.copyWith(landings: landings));
    }

    return withNested;
  }

  /// Delete a haul by id.
  /// also deletes any landings of this haul.
  @override
  Future<void> delete(int id) async {
    await database.delete('landings', where: 'haul_id = $id');
    await database.delete(tableName, where: 'id = $id');
  }

  /// Get all the hauls for a Trip.
  Future<List<Haul>> forTrip(int tripId) async {
    final List<Map<String, dynamic>> results = await database.query(tableName, where: 'trip_id = $tripId');

    if (results.isEmpty) {
      return [];
    }

    final List<Haul> hauls = [];
    for (final Map<String, dynamic> result in results) {
      final Haul haul = fromDatabaseMap(result);
      final List<Landing> landings = await LandingRepository().forHaul(haul.id);
      hauls.add(haul.copyWith(landings: landings));
    }

    return hauls;
  }

  Future<Haul> getActiveHaul() async {
    final List results = await database.query(tableName, where: 'ended_at is null');
    assert(results.length < 2);

    if (results.isEmpty) {
      return null;
    }

    return fromDatabaseMap(results.first);
  }

  @override
  Haul fromDatabaseMap(Map<String, dynamic> result) {
    final DateTime startedAt = result['started_at'] != null ? DateTime.parse(result['started_at']) : null;

    final DateTime endedAt = result['ended_at'] != null ? DateTime.parse(result['ended_at']) : null;

    final FishingMethod fishingMethod = fishingMethods.firstWhere(
      (fm) => fm.id == result['fishing_method_id'],
      orElse: () => throw Exception('Fishing method does not exist.'),
    );

    final Location endLocation = result['end_latitude'] == null || result['end_longitude'] == null
        ? null
        : Location(latitude: result['end_latitude'], longitude: result['end_longitude']);

    return Haul(
      id: result['id'],
      tripId: result['trip_id'],
      startedAt: startedAt,
      endedAt: endedAt,
      fishingMethod: fishingMethod,
      startLocation: Location(
        latitude: result['start_latitude'],
        longitude: result['start_longitude'],
      ),
      endLocation: endLocation,
      soakTime: result['soak_time_minutes'] == null
          ? result['soak_time_minutes']
          : Duration(minutes: result['soak_time_minutes']),
      hooksOrTraps: result['hooks_or_traps'] as int,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(Haul haul) {
    return {
      'id': haul.id,
      'trip_id': haul.tripId,
      'started_at': haul.startedAt == null ? null : haul.startedAt.toIso8601String(),
      'ended_at': haul.endedAt == null ? null : haul.endedAt.toIso8601String(),
      'fishing_method_id': haul.fishingMethod.id,
      'start_latitude': haul.startLocation.latitude,
      'start_longitude': haul.startLocation.longitude,
      'end_latitude': haul.endLocation?.latitude,
      'end_longitude': haul.endLocation?.longitude,
      'soak_time_minutes': haul.soakTime?.inMinutes,
      'hooks_or_traps': haul.hooksOrTraps,
    };
  }
}
