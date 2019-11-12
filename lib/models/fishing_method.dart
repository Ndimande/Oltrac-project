import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class FishingMethod extends Model {
  final String name;
  final String abbreviation;

  FishingMethod({this.name, this.abbreviation});

  FishingMethod.fromMap(Map data)
      : name = data['name'],
        abbreviation = data['abbreviation'],
        super.fromMap(data);

  FishingMethod copyWith({String name, String abbreviation}) {
    return FishingMethod(
        name: name ?? this.name,
        abbreviation: abbreviation ?? this.abbreviation);
  }

  Map<String, dynamic> toMap() {
    return {'uuid': uuid, 'name': name, 'abbreviation': abbreviation};
  }
}
