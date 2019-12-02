import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class Country extends Model {
  final String name;
  final String iso3166Alpha3;

  const Country({id, this.name, this.iso3166Alpha3}) : super(id: id);

  Country.fromMap(Map data)
      : name = data['name'],
        iso3166Alpha3 = data['iso3166Alpha3'],
        super.fromMap(data);

  Country copyWith({String name, String iso3166Alpha3}) {
    return Country(
        id: id,
        name: name ?? this.name,
        iso3166Alpha3: iso3166Alpha3 ?? this.iso3166Alpha3);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'iso3166Alpha3': iso3166Alpha3};
  }
}
