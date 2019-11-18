import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/vessel.dart';

@immutable
class Trip extends Model {
  final Vessel vessel;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<Haul> hauls;

  Trip(
      {@required this.vessel,
      this.startedAt,
      this.endedAt,
      this.hauls = const []});

  Trip.fromMap(Map data)
      : startedAt = DateTime.parse(data['startedAt']),
        endedAt = DateTime.parse(data['endedAt']),
        vessel = Vessel.fromMap(data['vessel']),
        hauls = data['hauls'];

  Trip copyWith(
      {Vessel vessel, DateTime startedAt, DateTime endedAt, List<Haul> hauls}) {
    return Trip(
        vessel: this.vessel,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        hauls: hauls ?? this.hauls);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'vessel': vessel.toMap(),
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String()
    };
  }
}
