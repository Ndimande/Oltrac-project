import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/species.dart';

@immutable
class Landing extends Model {
  final int haulId;

  final Species species;

  final DateTime createdAt;

  final int weight;

  final int length;

  final WeightUnit weightUnit;

  final LengthUnit lengthUnit;

  final Location location;

  final List<Product> products;

  // The number of fish
  final int individuals;

  final bool doneTagging;

  const Landing({
    id,
    @required this.haulId,
    @required this.species,
    @required this.createdAt,
    @required this.location,
    @required this.weight,
    @required this.length,
    this.products = const [],
    this.individuals = 1,
    this.weightUnit = WeightUnit.GRAMS,
    this.lengthUnit = LengthUnit.CENTIMETERS,
    this.doneTagging = false,
  }) : super(id: id);

  Landing.fromMap(Map data)
      : haulId = data['haulId'],
        species = Species.fromMap(data['species']),
        createdAt = data['createdAt'],
        location = Location.fromMap(data['location']),
        weight = data['weight'],
        length = data['length'],
        products = (data['products'] as List<Map>).map((item) => Product.fromMap(item)),
        weightUnit = data['weightUnit'],
        lengthUnit = data['lengthUnit'],
        individuals = data['inidividuals'],
        doneTagging = data['doneTagging'],
        super.fromMap(data);

  Landing copyWith({
    int id,
    String tagId,
    int haulId,
    Species species,
    DateTime createdAt,
    Location location,
    int weight,
    int length,
    List<Product> products,
    WeightUnit weightUnit,
    LengthUnit lengthUnit,
    int individuals,
    bool doneTagging,
  }) {
    return Landing(
        id: id ?? this.id,
        haulId: haulId ?? this.haulId,
        species: species ?? this.species,
        createdAt: createdAt ?? this.createdAt,
        location: location ?? this.location,
        weight: weight ?? this.weight,
        length: length ?? this.length,
        products: products ?? this.products,
        weightUnit: weightUnit ?? this.weightUnit,
        lengthUnit: lengthUnit ?? this.lengthUnit,
        individuals: individuals ?? this.individuals,
        doneTagging: doneTagging ?? this.doneTagging);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'haulId': haulId,
      'species': species.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'location': location.toMap(),
      'weight': weight,
      'length': length,
      'products': products,
      'products': products.map((Product product) => product.toMap()).toList(),
      'weightUnit': weightUnit.toString(),
      'lengthUnit': lengthUnit.toString(),
      'individuals': individuals,
      'doneTagging': doneTagging
    };
  }

  bool get hasProducts => this.products.length > 0;

  bool get isBulk => this.individuals > 1;

  String get weightKilograms =>
      (this.weight / 1000).toString() + ' kg' + (this.isBulk ? ' total' : '');

  String get lengthCentimeters => (this.length).toString() + ' cm' + (this.isBulk ? ' avg.' : '');
}
