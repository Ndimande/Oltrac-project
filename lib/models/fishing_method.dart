import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class FishingMethod extends Model {
  final String name;
  final String abbreviation;

  const FishingMethod({id, this.name, this.abbreviation}) : super(id: id);

  FishingMethod.fromMap(Map data)
      : name = data['name'],
        abbreviation = data['abbreviation'],
        super.fromMap(data);

  FishingMethod copyWith({String firstName, String abbreviation}) {
    return FishingMethod(
      id: id ?? this.id,
      name: firstName ?? this.name,
      abbreviation: abbreviation ?? this.abbreviation,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'abbreviation': abbreviation};
  }
}
