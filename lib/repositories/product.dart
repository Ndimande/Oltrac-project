import 'package:oltrace/data/product_types.dart';
import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/product.dart';
import 'package:oltrace/models/product_type.dart';

class ProductRepository extends DatabaseRepository<Product> {
  var tableName = 'products';

  @override
  Future<Product> find(int id) {
    // TODO: implement find
    return null;
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

    // We need to store in the pivot table
    // for (var landing in product.landings) {
    //   final List<Map<String, dynamic>> res = await database.query('product_landings',
    //       where: 'product_id = $createdId AND landing_id = ${landing.id}');
    //   if (res.length == 0) {
    //     await database.insert(
    //       'product_landings',
    //       {'product_id': createdId, 'landing_id': landing.id},
    //     );
    //   }
    // }

    return createdId;
  }

  @override
  Product fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    return Product(
      id: result['id'],
      createdAt: createdAt,
      tagCode: result['tag_code'],
      location: Location.fromMap({
        'latitude': result['latitude'],
        'longitude': result['longitude'],
      }),
      weight: result['weight'],
      productType: productTypes.firstWhere((ProductType pt) => pt.id == result['product_type_id']),
      landingId: result['landing_id'],
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
      'product_type_id': product.productType.id,
      'landing_id': product.landingId
    };
  }
}
