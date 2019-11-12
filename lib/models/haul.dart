import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishing_method.dart';

@immutable
class Haul extends Model {
  /// Timestamp of haul start
  final DateTime startedAt;

  /// Timestamp of haul end
  final DateTime endedAt;

  /// The fishing method used on the haul
  final FishingMethod fishingMethod;

  Haul({this.startedAt, this.endedAt, this.fishingMethod});

  Haul.fromMap(Map data)
      : startedAt = data['startedAt'],
        endedAt = data['endedAt'],
        fishingMethod = FishingMethod.fromMap(data['fishingMethod']),
        super.fromMap(data);

  Haul copyWith(
      {DateTime startedAt, DateTime endedAt, FishingMethod fishingMethod}) {
    return Haul(
        startedAt: startedAt, endedAt: endedAt, fishingMethod: fishingMethod);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'startedAt': startedAt,
      'endedAt': endedAt,
      'fishingMethod': fishingMethod.toMap()
    };
  }
}
