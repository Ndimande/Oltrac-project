import 'package:oltrace/framework/database_repository.dart';
import 'package:oltrace/models/location.dart';
import 'package:oltrace/models/master_container.dart';
import 'package:oltrace/models/product.dart';

class MasterContainerRepository extends DatabaseRepository<MasterContainer> {
  var tableName = 'master_containers';

  @override
  Future<int> store(MasterContainer masterContainer) async {
    // if no id create a new record
    if (masterContainer.id == null) {
      final int id = await database.insert(tableName, toDatabaseMap(masterContainer));
      await _storeProductRelations(masterContainer.copyWith(id: id));
      return id;
    } else {
      // We remove this item completely or sqlite will try
      // to set id = null
      final withoutId = toDatabaseMap(masterContainer)..remove('id');

      await database.update(tableName, withoutId, where: 'id = ${masterContainer.id}');
      await _storeProductRelations(masterContainer);
      return masterContainer.id;
    }
  }

  Future<int> _clearProductRelations(MasterContainer masterContainer) async {
    return await database.delete('master_container_has_products', where: 'master_container_id = ${masterContainer.id}');
  }

  Future<void> _storeProductRelations(MasterContainer masterContainer) async {
    await _clearProductRelations(masterContainer);
    for (Product product in masterContainer.products) {
      await database.insert('master_container_has_products', {
        'master_container_id': masterContainer.id,
        'product_id': product.id,
      });
    }
  }

  @override
  MasterContainer fromDatabaseMap(Map<String, dynamic> result) {
    final createdAt = result['created_at'] != null ? DateTime.parse(result['created_at']) : null;

    final List<Product> products = <Product>[];

    return MasterContainer(
      id: result['id'],
      createdAt: createdAt,
      tagCode: result['tag_code'],
      location: Location.fromMap({
        'latitude': result['latitude'],
        'longitude': result['longitude'],
      }),
      products: products,
      tripId: result['trip_id'],
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(MasterContainer mc) {
    return {
      'id': mc.id,
      'tag_code': mc.tagCode,
      'latitude': mc.location.latitude,
      'longitude': mc.location.longitude,
      'trip_id': mc.tripId
    };
  }
}
