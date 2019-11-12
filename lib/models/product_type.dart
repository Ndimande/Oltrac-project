import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class ProductType extends Model {
  final String name;

  ProductType({this.name});

  ProductType.fromMap(Map data)
      : name = data['name'],
        super.fromMap(data);

  ProductType copyWith({String name}) {
    return ProductType(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'uuid': uuid, 'name': name};
  }
}
