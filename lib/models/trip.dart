import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/profile.dart';

@immutable
class Trip extends Model {
  /// When the trip started
  final DateTime startedAt;

  /// When the trip ended
  final DateTime endedAt;

  /// Hauls in this trip
  final List<Haul> hauls;

  /// GPS Start Position
  final Position startPosition;

  /// GPS End Position
  final Position endPosition;

  Trip({
    id,
    @required this.startedAt,
    this.endedAt,
    this.hauls = const [],
    @required this.startPosition,
    this.endPosition,
  }) : super(id: id);

  Trip.fromMap(Map data)
      : startedAt = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
        endedAt = data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        hauls = (data['hauls'] as List).map((haul) => Haul.fromMap(haul)).toList(),
        startPosition = Position.fromMap(data['endPosition']),
        endPosition = Position.fromMap(data['startPosition']),
        super.fromMap(data);

  Trip copyWith({
    int id,
    Profile vessel,
    DateTime startedAt,
    DateTime endedAt,
    List<Haul> hauls,
    Position startPosition,
    Position endPosition,
  }) {
    return Trip(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      hauls: hauls ?? this.hauls,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
    );
  }

  Map<String, dynamic> toMap() {
    print(startPosition);
    return {
      'id': id,
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String(),
      'hauls': hauls.map((Haul haul) => haul.toMap()).toList(),
      'startPosition': startPosition.toJson(),
      'endPosition': endPosition?.toJson(),
    };
  }
}
