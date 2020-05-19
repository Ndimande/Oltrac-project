import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';

@immutable
class MasterContainer extends Model {
  // The unique code of the RFID tag
  final String tagCode;

  final DateTime createdAt;

  final Location location;

  final List<Product> products;

  final int tripId;

  const MasterContainer({
    int id,
    @required this.tagCode,
    @required this.createdAt,
    @required this.location,
    @required this.products,
    @required this.tripId,
  })  : assert(tagCode != null),
        assert(createdAt != null),
        assert(location != null),
        assert(products != null),
        assert(tripId != null),
        super(id: id);

  MasterContainer.fromMap(Map data)
      : tagCode = data['tagCode'],
        createdAt = data['createdAt'],
        location = Location.fromMap({'latitude': data['latitude'], 'longitude': data['longitude']}),
        products = data['products'],
        tripId = data['tripId'],
        super.fromMap(data);

  @override
  MasterContainer copyWith({
    int id,
    String tagId,
    DateTime createdAt,
    Location location,
    List<Product> products,
    int tripId,
  }) {
    return MasterContainer(
      id: id ?? this.id,
      tagCode: tagId ?? tagCode,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      products: products ?? this.products,
      tripId: tripId ?? this.tripId,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagCode': tagCode,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'location': location.toMap(),
      'products': products,
      'tripId': tripId,
    };
  }
}
