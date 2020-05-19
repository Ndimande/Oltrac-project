import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class PackagingType extends Model {
  final String name;

  const PackagingType({id, this.name}) : super(id: id);

  PackagingType.fromMap(Map data)
      : name = data['name'],
        super.fromMap(data);

  @override
  PackagingType copyWith({String englishName, String id, String jurisdiction}) {
    return PackagingType(
      name: englishName ?? name,
      id: id ?? this.id,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
    };
  }
}
