import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:uuid/uuid.dart';

@immutable
class Country implements Model {
  final String uuid;
  final String name;
  final String iso3166Alpha3;

  Country({this.name, this.iso3166Alpha3}) : this.uuid = Uuid().v1();

  Country.fromMap(Map data)
      : uuid = data['uuid'],
        name = data['name'],
        iso3166Alpha3 = data['iso3166Alpha2'];

  Country copyWith({String name, String iso3166Alpha2}) {
    return Country(
        name: name ?? this.name,
        iso3166Alpha3: iso3166Alpha2 ?? this.iso3166Alpha3);
  }

  Map<String, dynamic> toMap() {
    return {'id': uuid, 'name': name, 'iso3166Alpha2': iso3166Alpha3};
  }
}
