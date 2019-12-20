import 'package:flutter/material.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
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

  final List<Landing> landings;

  Product({
    id,
    @required this.tagCode,
    @required this.createdAt,
    @required this.location,
    @required this.productType,
    @required landings,
    this.weight,
    weightUnit,
    lengthUnit,
  })  : this.weightUnit = weightUnit ?? WeightUnit.GRAMS,
        this.landings = landings ?? [],
        super(id: id);

  Product.fromMap(Map data)
      : tagCode = data['tagCode'],
        createdAt = data['createdAt'],
        location = Location.fromMap({'latitude': data['latitude'], 'longitude': data['longitude']}),
        productType = productTypes.firstWhere((p) => p.id == data['id']),
        landings =
            [], // TODO oy vey // (data['landings'] as List).map((landing) => Landing.fromMap(landing)).toList(),
        weight = data['weight'],
        weightUnit = data['weightUnit'],
        super.fromMap(data);

  Product copyWith({
    int id,
    String tagId,
    DateTime createdAt,
    Location location,
    ProductType productType,
    List<Landing> landings,
    int weight,
    WeightUnit weightUnit,
  }) {
    return Product(
      id: id ?? this.id,
      tagCode: tagId ?? this.tagCode,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      productType: productType ?? this.productType,
      landings: landings ?? this.landings,
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
      'landings': landings.map((Landing landing) => landing.toMap()).toList(),
      'weight': weight,
      'weightUnit': weightUnit,
    };
  }
}
