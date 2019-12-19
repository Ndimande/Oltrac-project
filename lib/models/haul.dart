import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/landing.dart';

@immutable
class Haul extends Model {
  /// Timestamp of haul start
  final DateTime startedAt;

  /// Timestamp of haul end
  final DateTime endedAt;

  /// The fishing method used on the haul
  final FishingMethod fishingMethod;

  final List<Landing> landings;

  final int tripId;

  final Position startPosition;
  final Position endPosition;

  Haul({
    id,
    @required this.tripId,
    @required this.startedAt,
    this.endedAt,
    @required this.fishingMethod,
    this.landings = const [],
    @required this.startPosition,
    this.endPosition,
  }) : super(id: id);

  Haul copyWith({
    int id,
    int tripId,
    DateTime startedAt,
    DateTime endedAt,
    FishingMethod fishingMethod,
    List<Landing> landings,
    Position startPosition,
    Position endPosition,
  }) {
    return Haul(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      landings: landings ?? this.landings,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
    );
  }

  Haul.fromMap(Map data)
      : tripId = data['trip_id'],
        startedAt = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
        endedAt = data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        fishingMethod = FishingMethod.fromMap(data['fishingMethod']),
        landings = data['landings'] as List<Landing>,
        startPosition = Position.fromMap(data['startPosition']),
        endPosition = Position.fromMap(data['endPosition']),
        super.fromMap(data);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String(),
      'fishingMethod': fishingMethod.toMap(),
      'landings': landings.map((l) => l.toMap()).toList(),
      'startPosition': startPosition?.toJson(),
      'endPosition': endPosition?.toJson(),
    };
  }
}
