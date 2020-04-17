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

  const MasterContainer({
    id,
    @required this.tagCode,
    @required this.createdAt,
    @required this.location,
    @required this.products,
  })  : assert(tagCode != null),
        super(id: id);

  MasterContainer.fromMap(Map data)
      : tagCode = data['tagCode'],
        createdAt = data['createdAt'],
        location = Location.fromMap({'latitude': data['latitude'], 'longitude': data['longitude']}),
        products = data['products'],
        super.fromMap(data);

  MasterContainer copyWith({
    int id,
    String tagId,
    DateTime createdAt,
    Location location,
    List<Product> products,
  }) {
    return MasterContainer(
      id: id ?? this.id,
      tagCode: tagId ?? this.tagCode,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      products: products ?? this.products,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagCode': tagCode,
      'createdAt': createdAt.toIso8601String(),
      'location': location.toMap(),
      'products': products,
    };
  }
}
