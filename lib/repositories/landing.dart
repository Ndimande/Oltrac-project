import 'package:oltrace/data/species.dart' as speciesData;
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/species.dart';

class LandingRepository extends DatabaseRepository<Landing> {
  var tableName = 'landings';

  Future<int> store(Landing landing) async {
    if (landing.id == null) {
      return await database.insert(tableName, toDatabaseMap(landing));
    }

    final withoutId = toDatabaseMap(landing)..remove('id');

    return await database.update(tableName, withoutId, where: 'id = ${landing.id}');
  }

  @override
  Future<Landing> find(int id) async {
    final List<Map> results = await database.query(tableName, where: 'id = $id');
    final Landing landing = fromDatabaseMap(results.first);

    return landing;
  }

  @override
  Future<void> delete(int id) async {
    await database.delete(tableName, where: 'id = $id');
    await database.delete('product_has_landings', where: 'landing_id = $id');
  }

  Future<List<Landing>> forHaul(Haul haul) async {
    final List<Map> results = await database.query(tableName, where: 'haul_id = ${haul.id}');
    List landings = <Landing>[];
    for (Map<String, dynamic> result in results) {
      landings.add(fromDatabaseMap(result));
    }

    return landings;
  }

  Future<List<Landing>> forProduct(Product product) async {
    final List<Map> results = await database.query('product_has_landings', where: 'product_id = ${product.id}');

    List landings = <Landing>[];
    for (Map<String, dynamic> result in results) {
      final int landingId = result['landing_id'];
      final List<Map> landingResults = await database.query('landings', where: 'id = $landingId');
      if (landingResults.length != 0) {
        final Landing landing = fromDatabaseMap(landingResults.first);
        landings.add(landing);
      }
    }

    return landings;
  }

  @override
  Landing fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    final lengthUnitResult = result['length_unit'];
    final weightUnitResult = result['weight_unit'];

    var lengthUnit;
    if (lengthUnitResult == LengthUnit.MICROMETERS.toString()) {
      lengthUnit = LengthUnit.MICROMETERS;
    } else if (lengthUnitResult == LengthUnit.INCHES.toString()) {
      lengthUnit = LengthUnit.INCHES;
    }

    var weightUnit;
    if (weightUnitResult == WeightUnit.GRAMS.toString()) {
      weightUnit = WeightUnit.GRAMS;
    } else if (weightUnitResult == WeightUnit.OUNCES.toString()) {
      weightUnit = WeightUnit.OUNCES;
    }

    return Landing(
      id: result['id'],
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
      individuals: result['individuals'],
      species: speciesData.species.firstWhere((Species s) => s.alpha3Code == result['species_code']),
      doneTagging: result['done_tagging'] == 1 ? true : false,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(Landing landing) {
    return {
      'haul_id': landing.haulId,
      'created_at': landing.createdAt == null ? null : landing.createdAt.toIso8601String(),
      'latitude': landing.location.latitude,
      'longitude': landing.location.longitude,
      'species_code': landing.species.alpha3Code,
      'weight_unit': landing.weightUnit.toString(),
      'length_unit': landing.lengthUnit.toString(),
      'weight': landing.weight,
      'length': landing.length,
      'individuals': landing.individuals,
      'done_tagging': landing.doneTagging == true ? 1 : 0
    };
  }
}
