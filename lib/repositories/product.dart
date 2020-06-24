import 'package:oltrace/data/packaging_types.dart';
import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/framework/util.dart';
import 'package:oltrace/models/haul.dart';
import 'package:oltrace/models/landing.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/packaging_type.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';
import 'package:oltrace/repositories/haul.dart';

class ProductRepository extends DatabaseRepository<Product> {
  @override
  final String tableName = 'products';

  @override
  Future<Product> find(int id) async {
    final List<Map> results = await database.query(tableName, where: 'id = $id');

    if (results.isEmpty) {
      return null;
    }

    return fromDatabaseMap(results.first);
  }

  @override
  Future<void> delete(int id) async {
    await _removeLandingRelations(id);
    await database.delete(tableName, where: 'id = $id');
  }

  Future<List<Product>> forLanding(int landingId) async {
    final List<Map> results = await database.query('product_has_landings', where: 'landing_id = $landingId');
    final List products = <Product>[];

    for (final Map result in results) {
      final Product product = await find(result['product_id']);
      products.add(product);
    }
    return products;
  }

  Future<List<Product>> forMasterContainer(int masterContainerId) async {
    final List<Map> results =
        await database.query('master_container_has_products', where: 'master_container_id = $masterContainerId');
    final List products = <Product>[];
    for (final Map result in results) {
      final Product product = await find(result['product_id']);
      products.add(product);
    }
    return products;
  }

  Future<List<Product>> forTrip(id) async {
    final List<Haul> hauls = await HaulRepository().forTrip(id);
    final List<Landing> allLandings = [];
    for (final Haul haul in hauls) {
      allLandings.addAll(haul.landings);
    }

    final List<Product> allProducts = [];
    for (final Landing landing in allLandings) {
      final List<Product> products = await ProductRepository().forLanding(landing.id);
      allProducts.addAll(products);
    }

    return allProducts;
  }

  @override
  Future<int> store(Product product) async {
    int createdId;

    // if no id create a new record
    if (product.id == null) {
      createdId = await database.insert(tableName, toDatabaseMap(product));
    } else {
      //Remove id or SQLite will try to set id = null
      final withoutId = toDatabaseMap(product)..remove('id');

      createdId = await database.update(tableName, withoutId, where: 'id = ${product.id}');
    }

    final Product storedProduct = product.copyWith(id: createdId);

    await _storeLandingRelations(storedProduct);

    return createdId;
  }

  Future<void> _storeLandingRelations(Product product) async {
    await _removeLandingRelations(product.id);
    for (final Landing landing in product.landings) {
      await database.insert('product_has_landings', {
        'landing_id': landing.id,
        'product_id': product.id,
      });
    }
  }

  Future<int> _removeLandingRelations(int productID) async {
    return await database.delete('product_has_landings', where: 'product_id = $productID');
  }

  @override
  Product fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    final List<Landing> landings = <Landing>[];

    final weightUnitResult = result['weight_unit'];
    WeightUnit weightUnit;
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
      packagingType: packagingTypes.firstWhere((PackagingType pt) => pt.id == result['packaging_type_id']),
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
      'created_at': product.createdAt.toIso8601String(),
    };
  }
}
