import 'package:flutter/material.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/species.dart';

const GRAMS = 'GRAMS';
const OUNCES = 'OUNCES';

@immutable
class Tag extends Model {
  final String tagCode;

  final int haulId;

  final Species species;

  final DateTime createdAt;

  final int weight;

  final int length;

  final WeightUnit weightUnit;

  final LengthUnit lengthUnit;

  Tag({
    id,
    @required this.tagCode,
    @required this.haulId,
    @required this.species,
    @required this.createdAt,
    this.weight,
    this.length,
    weightUnit,
    lengthUnit,
  })  : this.weightUnit = weightUnit ?? WeightUnit.GRAMS,
        this.lengthUnit = lengthUnit ?? LengthUnit.CENTIMETERS,
        super(id: id);

  Tag.fromMap(Map data)
      : tagCode = data['tagCode'],
        haulId = data['haulId'],
        species = Species.fromMap(data['species']),
        createdAt = data['createdAt'],
        weight = data['weight'],
        length = data['length'],
        weightUnit = data['weightUnit'],
        lengthUnit = data['lengthUnit'],
        super.fromMap(data);

  Tag copyWith({
    int id,
    String tagId,
    int haulId,
    Species species,
    DateTime createdAt,
    int weight,
    int length,
    WeightUnit weightUnit,
    LengthUnit lengthUnit,
  }) {
    return Tag(
      id: id ?? this.id,
      tagCode: tagId ?? this.tagCode,
      haulId: haulId ?? this.haulId,
      species: species ?? this.species,
      createdAt: createdAt ?? this.createdAt,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      weightUnit: weightUnit ?? this.weightUnit,
      lengthUnit: lengthUnit ?? this.lengthUnit,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tagCode': tagCode,
      'haulId': haulId,
      'species': species.toMap(),
      'createdAt': createdAt,
      'weight': weight,
      'length': length,
      'weightUnit': weightUnit,
      'lengthUnit': lengthUnit,
    };
  }
}
