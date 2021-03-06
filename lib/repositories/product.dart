import 'package:oltrace/data/packaging_types.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/packaging_type.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';

class ProductRepository extends DatabaseRepository<Product> {
  var tableName = 'products';

  @override
  Future<Product> find(int id) async {
    List<Map> results = await database.query(tableName, where: 'id = $id');
    return fromDatabaseMap(results.first);
  }

  Future<List<Product>> forLanding(int landingId) async {
    final List<Map> results =
        await database.query('product_has_landings', where: 'landing_id = $landingId');
    final List products = <Product>[];

    for (Map result in results) {
      final Product product = await find(result['product_id']);
      products.add(product);
    }
    return products;
  }

  @override
  Future<int> store(Product product) async {
    int createdId;

    // if no id create a new record
    if (product.id == null) {
      createdId = await database.insert(tableName, toDatabaseMap(product));
    } else {
      // We remove this item completely or sqlite will try
      // to set id = null
      final withoutId = toDatabaseMap(product)..remove('id');

      createdId = await database.update(tableName, withoutId, where: 'id = ${product.id}');
    }
    final storedProduct = product.copyWith(id: createdId);
    // We need to store in the pivot table
    for (var landing in storedProduct.landings) {
      final String where = 'product_id = $createdId AND landing_id = ${landing.id}';
      final List<Map<String, dynamic>> res =
          await database.query('product_has_landings', where: where);
      if (res.length == 0) {
        await database.insert(
          'product_has_landings',
          {'product_id': createdId, 'landing_id': landing.id},
        );
      }
    }

    await _storeLandingRelations(product.copyWith(id: createdId));

    return createdId;
  }

  Future<void> _storeLandingRelations(Product product) async {
    await _removeOldRelations(product);
    for (Landing landing in product.landings) {
      await database.insert('product_has_landings', {
        'landing_id': landing.id,
        'product_id': product.id,
      });
    }
  }

  Future<int> _removeOldRelations(Product product) async {
    return await database.delete('product_has_landings', where: 'product_id = ${product.id}');
  }

  @override
  Product fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    final List<Landing> landings = <Landing>[];

    final weightUnitResult = result['weight_unit'];
    var weightUnit;
    if (weightUnitResult == WeightUnit.GRAMS.toString()) {
      weightUnit = WeightUnit.GRAMS;
    } else if (weightUnitResult == WeightUnit.OUNCES.toString()) {
      weightUnit = WeightUnit.OUNCES;
    }
    return Product(
      id: result['id'],
      createdAt: createdAt,
      tagCode: result['tag_code'],
      location: Location.fromMap({
        'latitude': result['latitude'],
        'longitude': result['longitude'],
      }),
      weight: result['weight'],
      weightUnit: weightUnit,
      productType: productTypes.firstWhere((ProductType pt) => pt.id == result['product_type_id']),
      packagingType:
          packagingTypes.firstWhere((PackagingType pt) => pt.id == result['packaging_type_id']),
      landings: landings,
      productUnits: result['product_units'],
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(Product product) {
    return {
      'id': product.id,
      'tag_code': product.tagCode,
      'latitude': product.location.latitude,
      'longitude': product.location.longitude,
      'weight': product.weight,
      'weight_unit': product.weightUnit.toString(),
      'product_type_id': product.productType.id,
      'packaging_type_id': product.packagingType.id,
      'product_units': product.productUnits,
    };
  }
}
