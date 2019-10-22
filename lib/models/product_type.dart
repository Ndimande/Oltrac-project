import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:uuid/uuid.dart';

@immutable
class ProductType implements Model {
  final String uuid;
  final String name;

  ProductType({this.name}) : this.uuid = Uuid().v1();

  ProductType copyWith({String name}) {
    return ProductType(name: name ?? this.name);
  }

  Map<String, dynamic> toMap() {
    return {'id': uuid, 'name': name};
  }
}
