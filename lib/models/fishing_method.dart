import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/fishing_method_type.dart';

@immutable
class FishingMethod extends Model {
  final String name;
  final String abbreviation;
  final FishingMethodType type;

  const FishingMethod({
    @required id,
    @required this.name,
    @required this.abbreviation,
    @required this.type,
  })  : assert(id != null),
        assert(name != null),
        assert(abbreviation != null),
        assert(type != null),
        super(id: id);

  FishingMethod.fromMap(Map data)
      : name = data['name'],
        abbreviation = data['abbreviation'],
        type = data['type'],
        super.fromMap(data);

  FishingMethod copyWith({String englishName, String abbreviation, FishingMethodType type}) {
    return FishingMethod(
      id: id ?? this.id,
      name: englishName ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'abbreviation': abbreviation,
      'type': type.toString(),
    };
  }
}
