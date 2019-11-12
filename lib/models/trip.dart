import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/vessel.dart';

@immutable
class Trip extends Model {
  final Vessel vessel;
  final DateTime startedAt;
  final DateTime endedAt;

  Trip({this.vessel, this.startedAt, this.endedAt});

  Trip.fromMap(Map data)
      : startedAt = DateTime.parse(data['startedAt']),
        endedAt = DateTime.parse(data['endedAt']),
        vessel = Vessel.fromMap(data['vessel']);

  Trip copyWith({Vessel vessel, DateTime startedAt, DateTime endedAt}) {
    return Trip(
        vessel: this.vessel,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt);
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
