import 'package:oltrace/data/species.dart' as speciesData;
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/species.dart';
import 'package:oltrace/models/tag.dart';

class TagRepository extends DatabaseRepository<Tag> {
  var tableName = 'tags';

  Future<int> store(Tag tag) async {
    if (tag.id == null) {
      return await database.insert(tableName, toDatabaseMap(tag));
    }

    final withoutId = toDatabaseMap(tag)..remove('id');

    return await database.update(tableName, withoutId, where: 'id = ${tag.id}');
  }

  @override
  Future<Tag> find(int id) {
    // TODO: implement find
    return null;
  }

  @override
  Tag fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    final lengthUnitResult = result['length_unit'];
    final weightUnitResult = result['weight_unit'];

    var lengthUnit;
    if (lengthUnitResult == LengthUnit.CENTIMETERS.toString()) {
      lengthUnit = LengthUnit.CENTIMETERS;
    } else if (lengthUnitResult == LengthUnit.INCHES.toString()) {
      lengthUnit = LengthUnit.INCHES;
    }

    var weightUnit;
    if (weightUnitResult == WeightUnit.GRAMS.toString()) {
      weightUnit = WeightUnit.GRAMS;
    } else if (weightUnitResult == WeightUnit.OUNCES.toString()) {
      weightUnit = WeightUnit.OUNCES;
    }
    return Tag(
        id: result['id'],
        tagCode: result['tag_code'],
        createdAt: createdAt,
        location: Location.fromMap({
          'latitude': result['latitude'],
          'longitude': result['longitude'],
        }),
        haulId: result['haul_id'],
        length: result['length'],
        weight: result['weight'],
        lengthUnit: lengthUnit,
        weightUnit: weightUnit,
        species: speciesData.species.firstWhere((Species s) => s.id == result['species_id']));
  }

  @override
  Map<String, dynamic> toDatabaseMap(Tag tag) {
    return {
      'haul_id': tag.haulId,
      'tag_code': tag.tagCode,
      'created_at': tag.createdAt == null ? null : tag.createdAt.toIso8601String(),
      'latitude': tag.location.latitude,
      'longitude': tag.location.longitude,
      'species_code': tag.species.alpha3Code,
      'weight_unit': tag.weightUnit.toString(),
      'length_unit': tag.lengthUnit.toString(),
      'weight': tag.weight,
      'length': tag.length,
    };
  }
}
