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
  Product fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    return Product(
      createdAt: createdAt,
      tagCode: result['tag_code'],
      location: Location.fromMap({
        'latitude': result['latitude'],
        'longitude': result['longitude'],
      }),
      weight: result['weight'],
      productType: productTypes.firstWhere((ProductType pt) => pt.id == result['product_type_id']),
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(Product product) {
    return {
      'tag_code': product.tagCode,
      'latitude': product.location.latitude,
      'longitude': product.location.longitude,
      'weight': product.weight,
      'product_type_id': product.productType.id,
    };
  }
}
