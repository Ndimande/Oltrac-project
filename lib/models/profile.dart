import 'package:meta/meta.dart';
import 'package:oltrace/framework/model.dart';
import 'package:oltrace/models/country.dart';
import 'package:oltrace/models/fishery_type.dart';
import 'package:oltrace/models/skipper.dart';

@immutable
class Profile extends Model {
  final String uuid;
  final String vesselName;
  final String vesselId;
  final FisheryType fisheryType;
  final Skipper skipper;
  final Country country;
  final int fishingLicenseNumber;

  const Profile({
    id,
    @required this.uuid,
    @required this.vesselName,
    this.vesselId,
    @required this.fisheryType,
    @required this.skipper,
    @required this.country,
    this.fishingLicenseNumber,
  }) : super(id: id);

  Profile.fromMap(Map data)
      : uuid = data['uuid'],
        vesselName = data['vesselName'],
        vesselId = data['vesselId'],
        fisheryType = FisheryType.fromMap(data['fisheryType']),
        skipper = Skipper.fromMap(data['skipper']),
        country = Country.fromMap(data['country']),
        fishingLicenseNumber = data['fishingLicenseNumber'],
        super.fromMap(data);

  Map<String, dynamic> toMap() {
    return {
      'uuid': uuid,
      'vesselName': vesselName,
      'vesselId': vesselId,
      'fisheryType': fisheryType.toMap(),
      'skipper': skipper.toMap(),
      'country': country.toMap(),
      'fishingLicenseNumber': fishingLicenseNumber,
    };
  }

  Profile copyWith({
    String uuid,
    String vesselName,
    String vesselId,
    FisheryType fisheryType,
    Skipper skipper,
    Country country,
  }) {
    return Profile(
      uuid: uuid ?? this.uuid,
      vesselName: vesselName ?? this.vesselName,
      vesselId: vesselId ?? this.vesselId,
      fisheryType: fisheryType ?? this.fisheryType,
      skipper: skipper ?? this.skipper,
      country: country ?? this.country,
    );
  }
}
