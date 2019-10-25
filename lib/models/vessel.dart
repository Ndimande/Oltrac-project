import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery.dart';
import 'package:oltrace/models/skipper.dart';
import 'package:uuid/uuid.dart';

@immutable
class Vessel implements Model {
  final String uuid;
  final String name;
  final Fishery fishery;
  final Skipper skipper;
  final Country country;

  Vessel(
      {@required this.name, this.fishery, @required this.skipper, this.country})
      : uuid = Uuid().v1();

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'name': name,
      'fishery': fishery.toMap(),
      'skipper': skipper.toMap(),
      'country': country.toMap()
    };
  }

  Vessel copyWith(
      {String name, Fishery fishery, Skipper skipper, Country country}) {
    return Vessel(
        name: name ?? this.name,
        fishery: fishery ?? this.fishery,
        skipper: skipper ?? this.skipper,
        country: country ?? this.country);
  }
}
