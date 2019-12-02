import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';

@immutable
class Species extends Model {
  final String englishName;
  final String scientificName;
  final String australianName;
  final String alpha3Code;
  final String taxonomicCode;
  final String family;
  final String order;
  final String majorGroup;
  final String yearbookGroup;
  final String isscaapGroup;
  final String cpcClass;
  final String cpcGroup;
  final String caabCode;

  Species(
      {this.englishName,
      this.alpha3Code,
      this.scientificName,
      this.taxonomicCode,
      this.australianName,
      this.family,
      this.order,
      this.majorGroup,
      this.yearbookGroup,
      this.isscaapGroup,
      this.cpcClass,
      this.cpcGroup,
      this.caabCode});

  Species.fromMap(Map data)
      : englishName = data['englishName'],
        alpha3Code = data['alpha3Code'],
        scientificName = data['scientificName'],
        taxonomicCode = data['taxonomicCode'],
        australianName = data['australianName'],
        family = data['family'],
        order = data['order'],
        majorGroup = data['majorGroup'],
        yearbookGroup = data['yearbookGroup'],
        isscaapGroup = data['isscaapGroup'],
        cpcClass = data['cpcClass'],
        cpcGroup = data['cpcGroup'],
        caabCode = data['caabCode'],
        super.fromMap(data);

  Species copyWith(
      {String name,
      String alpha3Code,
      String scientificName,
      String taxonomicCode,
      String australianName,
      String family,
      String order,
      String majorGroup,
      String yearbookGroup,
      String isscaapGroup,
      String cpcClass,
      String cpcGroup,
      String caabCode}) {
    return Species(
        englishName: name ?? this.englishName,
        alpha3Code: alpha3Code ?? this.alpha3Code,
        scientificName: scientificName ?? this.scientificName,
        taxonomicCode: taxonomicCode ?? this.taxonomicCode,
        australianName: australianName ?? this.australianName,
        family: family ?? this.family,
        order: order ?? this.order,
        majorGroup: majorGroup ?? this.majorGroup,
        yearbookGroup: yearbookGroup ?? this.yearbookGroup,
        isscaapGroup: isscaapGroup ?? this.isscaapGroup,
        cpcClass: cpcClass ?? this.cpcClass,
        cpcGroup: cpcGroup ?? this.cpcGroup,
        caabCode: caabCode ?? this.caabCode);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': englishName,
      'alpha3Code': alpha3Code,
      'scientificName': scientificName,
      'taxonomicCode': taxonomicCode,
      'australianName': australianName,
      'family': family,
      'order': order,
      'majorGroup': majorGroup,
      'yearbookGroup': yearbookGroup,
      'isscaapGroup': isscaapGroup,
      'cpcClass': cpcClass,
      'cpcGroup': cpcGroup,
      'caabCode': caabCode
    };
  }

  Map<String, dynamic> toDatabaseMap() => toMap();
}
