import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';

@immutable
class FisheryType extends Model {
  final String name;
  final String safsCode; // e.g ONLF
  final String jurisdiction; // e.g Commonwealth

  FisheryType({this.name, this.safsCode, this.jurisdiction});

  FisheryType.fromMap(Map data)
      : name = data['name'],
        safsCode = data['safsCode'],
        jurisdiction = data['jurisdiction'],
        super.fromMap(data);

  FisheryType copyWith(
      {String name, String safsCode, String jurisdiction, Country country}) {
    return FisheryType(
        name: name ?? this.name,
        safsCode: safsCode ?? this.safsCode,
        jurisdiction: jurisdiction ?? this.jurisdiction);
  }

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'safsCode': safsCode,
      'jurisdiction': jurisdiction
    };
  }
}
