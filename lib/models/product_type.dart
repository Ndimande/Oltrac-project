import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class ProductType extends Model {
  final String name;

  ProductType({id, this.name}) : super(id: id);

  ProductType.fromMap(Map data)
      : name = data['name'],
        super.fromMap(data);

  ProductType copyWith({String name}) {
    return ProductType(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name};
  }
}
