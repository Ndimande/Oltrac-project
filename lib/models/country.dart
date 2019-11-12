import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class Country extends Model {
  final String name;
  final String iso3166Alpha3;

  Country({this.name, this.iso3166Alpha3});

  Country.fromMap(Map data)
      : name = data['name'],
        iso3166Alpha3 = data['iso3166Alpha2'],
        super.fromMap(data);

  Country copyWith({String name, String iso3166Alpha2}) {
    return Country(
        name: name ?? this.name,
        iso3166Alpha3: iso3166Alpha2 ?? this.iso3166Alpha3);
  }

  Map<String, dynamic> toMap() {
    return {'uuid': uuid, 'name': name, 'iso3166Alpha2': iso3166Alpha3};
  }
}
