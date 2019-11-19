import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/tag.dart';

@immutable
class Haul extends Model {
  /// Timestamp of haul start
  final DateTime startedAt;

  /// Timestamp of haul end
  final DateTime endedAt;

  /// The fishing method used on the haul
  final FishingMethod fishingMethod;

  final List<Tag> tags;

  Haul(
      {@required this.startedAt,
      this.endedAt,
      @required this.fishingMethod,
      this.tags = const []});

  Haul.fromMap(Map data)
      : startedAt = data['startedAt'] != null
            ? DateTime.parse(data['startedAt'])
            : null,
        endedAt =
            data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        fishingMethod = FishingMethod.fromMap(data['fishingMethod']),
        tags = data['tags'] as List<Tag>,
        super.fromMap(data);

  Haul copyWith(
      {DateTime startedAt, DateTime endedAt, FishingMethod fishingMethod}) {
    return Haul(
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        fishingMethod: fishingMethod ?? this.fishingMethod);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String(),
      'fishingMethod': fishingMethod.toMap()
    };
  }
}
