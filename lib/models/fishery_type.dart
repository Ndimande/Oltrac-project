import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class FisheryType extends Model {
  final String name;
  final String safsCode; // e.g ONLF
  final String jurisdiction; // e.g Commonwealth

  const FisheryType({id, this.name, this.safsCode, this.jurisdiction}) : super(id: id);

  FisheryType.fromMap(Map data)
      : name = data['name'],
        safsCode = data['safsCode'],
        jurisdiction = data['jurisdiction'],
        super.fromMap(data);

  FisheryType copyWith({String englishName, String safsCode, String jurisdiction}) {
    return FisheryType(
        id: id,
        name: englishName ?? this.name,
        safsCode: safsCode ?? this.safsCode,
        jurisdiction: jurisdiction ?? this.jurisdiction);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'safsCode': safsCode,
      'jurisdiction': jurisdiction,
    };
  }

  Map<String, dynamic> toDatabaseMap() => toMap();
}
