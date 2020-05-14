import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/master_container.dart';
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

  /// Has the trip been uploaded?
  final bool isUploaded;

  final List<MasterContainer> masterContainers;

  bool get isActive => endedAt == null;

  const Trip({
    id,
    @required this.startedAt,
    this.endedAt,
    this.hauls = const [],
    @required this.startLocation,
    this.endLocation,
    this.isUploaded = false,
    this.masterContainers = const [],
  }) : super(id: id);

  Trip.fromMap(Map data)
      : startedAt = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
        endedAt = data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        hauls = (data['hauls'] as List).map((haul) => Haul.fromMap(haul)).toList(),
        startLocation = Location.fromMap(data['startLocation']),
        endLocation = Location.fromMap(data['endLocation']),
        isUploaded = data['isUploaded'],
        masterContainers = (data['masterContainers'] as List).map((mc) => MasterContainer.fromMap(mc)).toList(),
        super.fromMap(data);

  Trip copyWith({
    int id,
    Profile vessel,
    DateTime startedAt,
    DateTime endedAt,
    List<Haul> hauls,
    Location startLocation,
    Location endLocation,
    bool isUploaded,
    List<MasterContainer> masterContainers,
  }) {
    return Trip(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      hauls: hauls ?? this.hauls,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      isUploaded: isUploaded ?? this.isUploaded,
      masterContainers: masterContainers ?? this.masterContainers,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'startedAt': startedAt == null ? null : startedAt.toUtc().toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toUtc().toIso8601String(),
      'hauls': hauls.map((Haul haul) => haul.toMap()).toList(),
      'startLocation': startLocation.toMap(),
      'endLocation': endLocation?.toMap(),
      'isUploaded': isUploaded,
      'masterContainers': masterContainers.map((MasterContainer mc) => mc.toMap()).toList(),
    };
  }
}
