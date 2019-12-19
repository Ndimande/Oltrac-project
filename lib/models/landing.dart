import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
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

  // The number of fish
  final int individuals;

  Landing({
    id,
    @required this.haulId,
    @required this.species,
    @required this.createdAt,
    @required this.location,
    @required this.weight,
    @required this.length,
    individuals,
    weightUnit,
    lengthUnit,
  })  : this.weightUnit = weightUnit ?? WeightUnit.GRAMS,
        this.lengthUnit = lengthUnit ?? LengthUnit.CENTIMETERS,
        this.individuals = individuals ?? 1,
        super(id: id);

  Landing.fromMap(Map data)
      : haulId = data['haulId'],
        species = Species.fromMap(data['species']),
        createdAt = data['createdAt'],
        location = Location.fromMap(data['location']),
        weight = data['weight'],
        length = data['length'],
        weightUnit = data['weightUnit'],
        lengthUnit = data['lengthUnit'],
        individuals = data['inidividuals'],
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
    WeightUnit weightUnit,
    LengthUnit lengthUnit,
    int individuals,
  }) {
    return Landing(
      id: id ?? this.id,
      haulId: haulId ?? this.haulId,
      species: species ?? this.species,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      weightUnit: weightUnit ?? this.weightUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
      individuals: individuals ?? this.individuals,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'haulId': haulId,
      'species': species.toMap(),
      'createdAt': createdAt,
      'location': location.toMap(),
      'weight': weight,
      'length': length,
      'weightUnit': weightUnit,
      'lengthUnit': lengthUnit,
      'individuals': individuals,
    };
  }
}
