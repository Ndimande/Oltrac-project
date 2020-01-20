import 'package:flutter/material.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product_type.dart';

@immutable
class Product extends Model {
  final String tagCode;

  final DateTime createdAt;

  final int weight;

  final WeightUnit weightUnit;

  final Location location;

  final ProductType productType;

  final int landingId;

  Product({
    id,
    @required this.tagCode,
    @required this.createdAt,
    @required this.location,
    @required this.productType,
    @required this.landingId,
    this.weight,
    weightUnit,
    lengthUnit,
  })  : this.weightUnit = weightUnit ?? WeightUnit.GRAMS,
        super(id: id);

  Product.fromMap(Map data)
      : tagCode = data['tagCode'],
        createdAt = data['createdAt'],
        location = Location.fromMap({'latitude': data['latitude'], 'longitude': data['longitude']}),
        productType = productTypes.firstWhere((p) => p.id == data['id']),
        landingId = data['landingId'],
        weight = data['weight'],
        weightUnit = data['weightUnit'],
        super.fromMap(data);

  Product copyWith({
    int id,
    String tagId,
    DateTime createdAt,
    Location location,
    ProductType productType,
    int landingId,
    int weight,
    WeightUnit weightUnit,
  }) {
    return Product(
      id: id ?? this.id,
      tagCode: tagId ?? this.tagCode,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      productType: productType ?? this.productType,
      landingId: landingId ?? this.landingId,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagCode': tagCode,
      'createdAt': createdAt,
      'location': location.toMap(),
      'productType': productType.toMap(),
      'landingId': landingId,
      'weight': weight,
      'weightUnit': weightUnit,
    };
  }
}
