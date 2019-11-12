import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';

@immutable
class Fishery extends Model {
  final String name;
  final String safsCode; // e.g ONLF
  final String jurisdiction; // e.g Commonwealth

  Fishery({this.name, this.safsCode, this.jurisdiction});

  Fishery.fromMap(Map data)
      : name = data['name'],
        safsCode = data['safsCode'],
        jurisdiction = data['jurisdiction'],
        super.fromMap(data);

  Fishery copyWith(
      {String name, String safsCode, String jurisdiction, Country country}) {
    return Fishery(
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
