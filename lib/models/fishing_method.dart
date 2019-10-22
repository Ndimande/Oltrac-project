import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:uuid/uuid.dart';

@immutable
class FishingMethod implements Model {
  final String uuid;
  final String name;
  final String abbreviation;

  FishingMethod({this.name, this.abbreviation}) : this.uuid = Uuid().v1();

  FishingMethod copyWith({String name, String abbreviation}) {
    return FishingMethod(
        name: name ?? this.name,
        abbreviation: abbreviation ?? this.abbreviation);
  }

  Map<String, dynamic> toMap() {
    return {'id': uuid, 'name': name, 'abbreviation': abbreviation};
  }
}
