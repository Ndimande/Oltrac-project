import 'package:flutter/cupertino.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:uuid/uuid.dart';

@immutable
class Haul extends Model {
  final String uuid;
  final DateTime startedAt;
  final DateTime endedAt;
  final FishingMethod fishingMethod;

  Haul({this.startedAt, this.endedAt, this.fishingMethod})
      : this.uuid = Uuid().v1();

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
