import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';

/// The base select statement for hauls always
/// includes fishing_methods.
const String _sqlBasicSelect = '''
SELECT
*
FROM
  hauls
''';

/// Join the landings table
/// to get all associated landings
/// nested inside the hauls.
const String _sqlJoinLandings = '''
JOIN landings
ON landings.id = hauls.haul_id''';

class HaulRepository extends DatabaseRepository<Haul> {
  var tableName = 'hauls';

  /// Find a single [Haul] by [id]
  /// and optionally include related data
  /// by setting [withLandings] to true.
  ///
  /// Returns [null] if none found.
  Future<Haul> find(int id, {bool withLandings = false}) async {
    assert(id != null);

    var sql = _sqlBasicSelect;

    if (withLandings) {
      sql += _sqlJoinLandings;
    }

    sql += ' WHERE id = $id';

    final results = await database.rawQuery(sql);

    if (results.length == 0) {
      // Nothing found
      return null;
    }

    return fromDatabaseMap(results[0]);
  }

  @override
  Future<void> delete(int id) async {
    // delete all landings where haul id
    await database.delete(tableName, where: 'id = $id');
    await database.delete('landings', where: 'haul_id = $id');
  }

  Future<List<Haul>> forTripId(int tripId) async {
    List<Map<String, dynamic>> results = await database.query(tableName, where: 'trip_id = $tripId');
    if (results.length == 0) {
      return [];
    }
    final hauls = <Haul>[];
    for (Map<String, dynamic> result in results) {
      hauls.add(fromDatabaseMap(result));
    }

    return hauls;
  }

  Future<Haul> getActiveHaul() async {
    List results = await database.query(tableName, where: "ended_at is null");
    assert(results.length < 2);

    if (results.length == 0) {
      return null;
    }

    return fromDatabaseMap(results.first);
  }

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
