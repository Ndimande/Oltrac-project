import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishing_method.dart';
import 'package:oltrace/models/fishing_method_type.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';

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

  final Location startLocation;

  final Location endLocation;

  /// The duration the gear was in the water
  final Duration soakTime;

  /// The number of traps or hooks on the line
  final int hooksOrTraps;

  List<Product> get products {
    final List<Product> uniqueProducts = <Product>[];
    landings.forEach(
      (Landing landing) => landing.products.forEach((Product product) {
        final Product existingProduct = uniqueProducts
            .singleWhere((Product p) => p.id == product.id && p.createdAt == product.createdAt, orElse: () => null);
        if (existingProduct == null) {
          uniqueProducts.add(product);
        }
      }),
    );
    return uniqueProducts;
  }

  int get totalLandingWeight => landings.fold(0, (total, Landing l) => total + l.weight);

  const Haul({
    id,
    @required this.tripId,
    @required this.startedAt,
    this.endedAt,
    @required this.fishingMethod,
    this.landings = const [],
    @required this.startLocation,
    this.endLocation,
    this.soakTime,
    this.hooksOrTraps,
  })  : assert(tripId != null),
        assert(startedAt != null),
        assert(fishingMethod != null),
        assert(startLocation != null),
        super(id: id);

  Haul copyWith({
    int id,
    int tripId,
    DateTime startedAt,
    DateTime endedAt,
    FishingMethod fishingMethod,
    List<Landing> products,
    Location startLocation,
    Location endLocation,
    Duration soakTime,
    int trapsOrHooks,
  }) {
    return Haul(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      fishingMethod: fishingMethod ?? this.fishingMethod,
      landings: products ?? this.landings,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      soakTime: soakTime ?? this.soakTime,
      hooksOrTraps: trapsOrHooks ?? this.hooksOrTraps,
    );
  }

  Haul.fromMap(Map data)
      : tripId = data['trip_id'],
        startedAt = data['startedAt'] != null ? DateTime.parse(data['startedAt']) : null,
        endedAt = data['endedAt'] != null ? DateTime.parse(data['endedAt']) : null,
        fishingMethod = FishingMethod.fromMap(data['fishingMethod']),
        landings = data['landings'] as List<Landing>,
        startLocation = Location.fromMap(data['startLocation']),
        endLocation = Location.fromMap(data['endLocation']),
        soakTime = Duration(minutes: data['soakTime']),
        hooksOrTraps = data['traps_or_hooks'] as int,
        super.fromMap(data);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tripId': tripId,
      'startedAt': startedAt == null ? null : startedAt.toIso8601String(),
      'endedAt': endedAt == null ? null : endedAt.toIso8601String(),
      'fishingMethod': fishingMethod.toMap(),
      'landings': landings.map((l) => l.toMap()).toList(),
      'startLocation': startLocation.toMap(),
      'endLocation': endLocation?.toMap(),
      'soakTime': soakTime?.inMinutes,
      'trapsOrHooks': hooksOrTraps
    };
  }
}
