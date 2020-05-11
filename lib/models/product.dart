import 'package:flutter/material.dart';
import 'package:oltrace/data/packaging_types.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/packaging_type.dart';
import 'package:oltrace/models/product_type.dart';

@immutable
class Product extends Model {
  // The unique code of the RFID tag
  final String tagCode;

  final DateTime createdAt;

  final int weight;

  final WeightUnit weightUnit;

  final Location location;

  final ProductType productType;

  final PackagingType packagingType;

  final List<Landing> landings;

  // The total number of products
  final int productUnits;

  const Product({
    id,
    @required this.tagCode,
    @required this.createdAt,
    @required this.location,
    @required this.productType,
    @required this.packagingType,
    @required this.landings,
    this.productUnits = 1,
    this.weight,
    this.weightUnit = WeightUnit.GRAMS,
  }) : super(id: id);

  Product.fromMap(Map data)
      : tagCode = data['tagCode'],
        createdAt = data['createdAt'],
        location = Location.fromMap({'latitude': data['latitude'], 'longitude': data['longitude']}),
        productType = productTypes.firstWhere((p) => p.id == data['id']),
        packagingType = packagingTypes.firstWhere((p) => p.id == data['id']),
        landings = data['landings'],
        weight = data['weight'],
        weightUnit = data['weightUnit'],
        productUnits = data['productUnits'],
        super.fromMap(data);

  Product copyWith(
      {int id,
      String tagId,
      DateTime createdAt,
      Location location,
      ProductType productType,
      PackagingType packagingType,
      List<Landing> products,
      int weight,
      WeightUnit weightUnit,
      int productUnits}) {
    return Product(
      id: id ?? this.id,
      tagCode: tagId ?? this.tagCode,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      productType: productType ?? this.productType,
      packagingType: packagingType ?? this.packagingType,
      landings: products ?? this.landings,
      weight: weight ?? this.weight,
      weightUnit: weightUnit ?? this.weightUnit,
      productUnits: productUnits ?? this.productUnits,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagCode': tagCode,
      'createdAt': createdAt.toUtc().toIso8601String(),
      'location': location.toMap(),
      'productType': productType.toMap(),
      'packagingType': packagingType.toMap(),
      'landings': landings,
      'weight': weight,
      'weightUnit': weightUnit.toString(),
      'productUnits': productUnits
    };
  }
}
