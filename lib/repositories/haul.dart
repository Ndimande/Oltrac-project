import 'package:geolocator/geolocator.dart';
import 'package:oltrace/data/fishing_methods.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/haul.dart';

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

  Future<Haul> getActiveHaul() async {
    List results = await database.query(tableName, where: "ended_at is null");
    if (results.length > 1) {
      throw Exception('More than one active Haul is not allowed');
    } else if (results.length == 0) {
      return null;
    }

    return fromDatabaseMap(results.first);
  }

  Haul fromDatabaseMap(Map<String, dynamic> result) {
    final DateTime startedAt = result['started_at'] != null
        ? DateTime.parse(
            result['started_at'],
          )
        : null;

    final DateTime endedAt = result['ended_at'] != null
        ? DateTime.parse(
            result['ended_at'],
          )
        : null;

    final FishingMethod fishingMethod = fishingMethods.firstWhere(
      (fm) => fm.id == result['fishing_method_id'],
      orElse: () => throw Exception('Fishing method does not exist.'),
    );

    final Position endPosition = result['end_latitude'] == null || result['end_longitude'] == null
        ? null
        : Position(
            latitude: result['end_latitude'],
            longitude: result['end_longitude'],
          );

    return Haul(
      id: result['id'],
      tripId: result['trip_id'],
      startedAt: startedAt,
      endedAt: endedAt,
      fishingMethod: fishingMethod,
      startPosition: Position(
        latitude: result['start_latitude'],
        longitude: result['start_longitude'],
      ),
      endPosition: endPosition,
    );
  }

  Map<String, dynamic> toDatabaseMap(Haul haul) {
    return {
      'id': haul.id,
      'trip_id': haul.tripId,
      'started_at': haul.startedAt == null ? null : haul.startedAt.toIso8601String(),
      'ended_at': haul.endedAt == null ? null : haul.endedAt.toIso8601String(),
      'fishing_method_id': haul.fishingMethod.id,
      'start_latitude': haul.startPosition.latitude,
      'start_longitude': haul.startPosition.longitude,
      'end_latitude': haul.endPosition?.latitude,
      'end_longitude': haul.endPosition?.longitude,
    };
  }
}
