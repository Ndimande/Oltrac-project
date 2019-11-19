import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/vessel.dart';

@immutable
class Trip extends Model {
  final Vessel vessel;

  /// When the trip started
  final DateTime startedAt;

  /// When the trip ended
  final DateTime endedAt;

  // Hauls in this trip
  final List<Haul> hauls;

  Trip(
      {@required this.vessel,
      @required this.startedAt,
      this.endedAt,
      this.hauls = const []});

  Trip.fromMap(Map data)
      : startedAt = data['startedAt'] != null
            ? DateTime.parse(data['startedAt'])
            : null,
        endedAt =
            data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        vessel = Vessel.fromMap(data['vessel']),
        hauls =
            (data['hauls'] as List).map((haul) => Haul.fromMap(haul)).toList(),
        super.fromMap(data);

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
      'endedAt': endedAt == null ? null : endedAt.toIso8601String(),
      'hauls': hauls.map((Haul haul) => haul.toMap()).toList()
    };
  }
}
