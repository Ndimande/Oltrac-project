import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishery.dart';
import 'package:oltrace/models/vessel.dart';
import 'package:uuid/uuid.dart';

@immutable
class Trip implements Model {
  final String uuid;
  final Vessel vessel;
  final DateTime startedAt;
  final DateTime endedAt;

  Trip({this.vessel, this.startedAt, this.endedAt}) : this.uuid = Uuid().v1();

  /// Get a copy of the trip with changes.
  Trip copyWith({Vessel vessel, DateTime startedAt, DateTime endedAt}) {
    return Trip(
        vessel: this.vessel,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt);
  }

  /// Get the Trip as a map, usually to insert into the database.
  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'vessel': vessel.toMap(),
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String()
    };
  }

  /// Create a Trip from a map, usually a database result.
  /// todo change this to a constructor
  static Trip fromMap(Map data) {
    final String startedAtRaw = data['startedAt'];
    final String endedAtRaw = data['endedAt'];

    final DateTime startedAt =
        startedAtRaw != null ? DateTime.parse(startedAtRaw) : null;

    final DateTime endedAt =
        endedAtRaw != null ? DateTime.parse(endedAtRaw) : null;

    return Trip(
        vessel: Vessel(
            name: data['vessel']['name'],
            fishery: Fishery.fromMap(data['vessel']['fishery'])),
        startedAt: startedAt,
        endedAt: endedAt);
  }
}
