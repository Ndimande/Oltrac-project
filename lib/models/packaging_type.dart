import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class PackagingType extends Model {
  final String name;

  const PackagingType({id, this.name}) : super(id: id);

  PackagingType.fromMap(Map data)
      : name = data['name'],
        super.fromMap(data);

  PackagingType copyWith({String firstName, String id, String jurisdiction}) {
    return PackagingType(
      name: firstName ?? this.name,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
    };
  }
}
