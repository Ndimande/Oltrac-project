import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';
import 'package:uuid/uuid.dart';

@immutable
class Fishery implements Model {
  final String uuid;
  final String name;
  final String safsCode; // e.g ONLF
  final String jurisdiction; // e.g Commonwealth

  Fishery({this.name, this.safsCode, this.jurisdiction})
      : this.uuid = Uuid().v1();

  Fishery copyWith(
      {String name, String safsCode, String jurisdiction, Country country}) {
    return Fishery(
        name: name ?? this.name,
        safsCode: safsCode ?? this.safsCode,
        jurisdiction: jurisdiction ?? this.jurisdiction);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': uuid,
      'name': name,
      'safsCode': safsCode,
      'jurisdiction': jurisdiction
    };
  }

  Fishery.fromMap(Map data)
      : uuid = data['uuid'],
        name = data['name'],
        safsCode = data['safsCode'],
        jurisdiction = data['jurisdiction'];
}
