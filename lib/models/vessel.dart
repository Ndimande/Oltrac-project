import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/skipper.dart';

@immutable
class Vessel extends Model {
  final String name;
  final FisheryType fisheryType;
  final Skipper skipper;
  final Country country;

  Vessel(
      {@required this.name,
      @required this.fisheryType,
      @required this.skipper,
      @required this.country});

  Vessel.fromMap(Map data)
      : name = data['name'],
        fisheryType = FisheryType.fromMap(data['fishery']),
        skipper = Skipper.fromMap(data['skipper']),
        country = Country.fromMap(data['country']),
        super.fromMap(data);

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'fishery': fisheryType.toMap(),
      'skipper': skipper.toMap(),
      'country': country.toMap()
    };
  }

  Vessel copyWith(
      {String name, FisheryType fishery, Skipper skipper, Country country}) {
    return Vessel(
        name: name ?? this.name,
        fisheryType: fishery ?? this.fisheryType,
        skipper: skipper ?? this.skipper,
        country: country ?? this.country);
  }
}
