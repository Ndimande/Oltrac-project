import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/skipper.dart';

@immutable
class Profile extends Model {
  final String name;
  final FisheryType fisheryType;
  final Skipper skipper;
  final Country country;
  final int fishingLicenseNumber;

  Profile(
      {id,
      @required this.name,
      @required this.fisheryType,
      @required this.skipper,
      @required this.country,
      this.fishingLicenseNumber})
      : super(id: id);

  Profile.fromMap(Map data)
      : name = data['name'],
        fisheryType = FisheryType.fromMap(data['fisheryType']),
        skipper = Skipper.fromMap(data['skipper']),
        country = Country.fromMap(data['country']),
        fishingLicenseNumber = data['fishingLicenseNumber'],
        super.fromMap(data);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'fisheryType': fisheryType.toMap(),
      'skipper': skipper.toMap(),
      'country': country.toMap(),
      'fishingLicenseNumber': fishingLicenseNumber,
    };
  }

  Profile copyWith(
      {String name,
      FisheryType fisheryType,
      Skipper skipper,
      Country country}) {
    return Profile(
        name: name ?? this.name,
        fisheryType: fisheryType ?? this.fisheryType,
        skipper: skipper ?? this.skipper,
        country: country ?? this.country);
  }

  Map<String, dynamic> toDatabaseMap() => toMap();
}
