import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/profile.dart';

@immutable
class Trip extends Model {
  /// When the trip started
  final DateTime startedAt;

  /// When the trip ended
  final DateTime endedAt;

  /// Hauls in this trip
  final List<Haul> hauls;

  /// GPS Start Location
  final Location startLocation;

  /// GPS End Location
  final Location endLocation;

  final bool isUploaded;

  const Trip({
    id,
    @required this.startedAt,
    this.endedAt,
    this.hauls = const [],
    @required this.startLocation,
    this.endLocation,
    this.isUploaded = false,
  }) : super(id: id);

  Trip.fromMap(Map data)
      : startedAt = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
        endedAt = data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        hauls = (data['hauls'] as List).map((haul) => Haul.fromMap(haul)).toList(),
        startLocation = Location.fromMap(data['endLocation']),
        endLocation = Location.fromMap(data['startLocation']),
        isUploaded = data['isUploaded'],
        super.fromMap(data);

  Trip copyWith({
    int id,
    Profile vessel,
    DateTime startedAt,
    DateTime endedAt,
    List<Haul> hauls,
    Location startLocation,
    Location endLocation,
    bool isUploaded
  }) {
    return Trip(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      hauls: hauls ?? this.hauls,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      isUploaded: isUploaded ?? this.isUploaded
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String(),
      'hauls': hauls.map((Haul haul) => haul.toMap()).toList(),
      'startLocation': startLocation.toMap(),
      'endLocation': endLocation?.toMap(),
      'isUploaded': isUploaded,
    };
  }
}
